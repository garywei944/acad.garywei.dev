---
layout: post
title: "From 405 ms to 0.68 ms: Tuning a CUDA Vector-Sum Reduction on an RTX 5090"
date: 2026-10-03
description: >-
  Five iterations of a 1 GiB FP32 reduction kernel, from one global atomic per element to ~88% of peak DRAM bandwidth.
tags:
  - CUDA
  - GPU
  - Performance
  - AI Generated
categories: cuda
giscus_comments: true
related_posts: true
toc:
  sidebar: left
---

<!-- prettier-ignore-start -->
> ##### AI-generated post, hand-written code
>
> This post was written by an AI assistant from my code, commit history, and benchmark results.
> The tuning itself was done for educational purposes: every line of code in it, from the kernels (v1 through v5)
> to the benchmark harness and L2 flusher, was written by hand.
{: .block-tip }
<!-- prettier-ignore-end -->

- Code: [sandbox/vecsum/vecsum.cu](https://github.com/garywei944/eva_cuda/blob/main/sandbox/vecsum/vecsum.cu)
- Hardware: NVIDIA GeForce RTX 5090 (170 SMs, 32 GB GDDR7, 1792 GB/s peak bandwidth)
- Problem: sum $$N = 2^{28}$$ random FP32 values (1 GiB) into a single float
- Reference: [Accelerating CUDA: Vector Sum Kernel Optimization](https://medium.com/@sagargupta4you/accelerating-cuda-vector-sum-kernel-optimization-3f0dabcd8e4e) by Sagar (Medium, 2025), which this exercise follows

## TL;DR

| Version                                | Time (ms) | Effective bandwidth | % of peak |
| -------------------------------------- | --------: | ------------------: | --------: |
| 1. One `atomicAdd` per element         |    405.51 |           2.65 GB/s |     0.15% |
| 2. Warp shuffle, one atomic per warp   |     12.38 |           86.7 GB/s |      4.8% |
| 3. Block reduction inside the loop     |      1.34 |            801 GB/s |       45% |
| 4. Register accumulation, reduce once  |     0.686 |           1565 GB/s |       87% |
| 5. Two-level warp reduction + `float4` |     0.682 |           1574 GB/s |       88% |

Effective bandwidth is $$2^{28} \times 4\ \text{B} / t$$. A sum reads every byte exactly once and does almost no
arithmetic, so it is purely memory-bound: the only goal is to stream 1 GiB out of DRAM as fast as the bus allows,
and to keep everything else (atomics, synchronization, reduction overhead) off the critical path.

The overall speedup is ~590×, but the interesting part is _where_ it came from: the first two steps removed
contention, the third removed synchronization, and the last step, the "classic" vectorized-load optimization,
gave less than 1%.

## Measuring it properly

Before tuning anything, the benchmark has to measure the right thing. A few details mattered:

- **CUDA events, not host timers.** `cudaEventRecord` around the launch, `cudaEventSynchronize` on the stop event,
  and `cudaGetLastError` after every launch.
- **Warmup + median.** 3 warmup rounds, then the median of 20 timed rounds.
- **Flush L2 between rounds.** The RTX 5090 has a large L2. Without flushing it, part of the input is still cached
  from the previous round and the kernel looks faster than DRAM allows. A small RAII helper `memset`s a buffer twice
  the size of L2 before each round:

```cpp
class L2Flusher {
 public:
  L2Flusher() {
    // get device
    int dev = 0;
    CUDA_CHECK(cudaGetDevice(&dev));

    int l2 = 0;
    CUDA_CHECK(cudaDeviceGetAttribute(&l2, cudaDevAttrL2CacheSize, dev));
    bytes_ = 2 * static_cast<size_t>(l2);
    CUDA_CHECK(cudaMalloc(&buf_, bytes_));
  }
  ~L2Flusher() { cudaFree(buf_); }

  L2Flusher(const L2Flusher&) = delete;
  L2Flusher& operator=(const L2Flusher&) = delete;

  void flush(cudaStream_t stream = 0) {
    CUDA_CHECK(cudaMemsetAsync(buf_, 0, bytes_, stream));
  }

 private:
  void* buf_ = nullptr;
  size_t bytes_ = 0;
};
```

- **Check the answer.** The GPU result is compared against a CPU loop that accumulates in `double`. Floating-point
  addition is not associative, so the GPU and CPU sums differ in the last few digits
  (`3947192.0` vs `3947189.25` here); the check uses a relative tolerance of $$10^{-4}$$.

## v1: one atomic per element — 405.51 ms

```cpp
__global__ void vector_sum_gpu(const float* x, float* y, const int n) {
  int tid = threadIdx.x + blockIdx.x * blockDim.x;

  for (int idx = tid; idx < n; idx += gridDim.x * blockDim.x) {
    atomicAdd(y, x[idx]);
  }
}
```

The most direct translation of `sum += x[i]`. Every one of the $$2^{28}$$ elements issues an `atomicAdd` to the
_same_ address, and atomics to one address are serialized in the L2. The memory system is idle; the kernel is
bottlenecked on ~0.66 billion serialized atomic operations per second. It is still ~4× slower than a single CPU core.

## v2: reduce within a warp first — 12.38 ms (33×)

```cpp
__inline__ __device__ float warpReduceSum(float val) {
#pragma unroll
  for (int offset = 16; offset > 0; offset /= 2) {
    val += __shfl_down_sync(0xffffffff, val, offset);
  }
  return val;
}

__global__ void vector_sum_gpu(const float* x, float* y, const int n) {
  int tid = threadIdx.x + blockIdx.x * blockDim.x;

  for (int idx = tid; idx < n; idx += gridDim.x * blockDim.x) {
    float val = warpReduceSum(x[idx]);
    if (threadIdx.x % 32 == 0) atomicAdd(y, val);
  }
}
```

`__shfl_down_sync` lets the 32 lanes of a warp exchange registers directly, without shared memory. Five shuffle
steps fold 32 values into lane 0, which then does the atomic. That cuts the atomic count by 32×, and the time drops
by almost exactly that factor. The kernel is still atomic-bound.

## v3: reduce within a block — 1.34 ms (9×)

```cpp
__global__ void vector_sum_gpu(const float* x, float* y, const int n) {
  __shared__ float sdata[BLOCK_SIZE / 32];
  int tid = threadIdx.x;
  int gid = blockIdx.x * blockDim.x + tid;

  for (int idx = gid; idx < n; idx += gridDim.x * blockDim.x) {
    float val = warpReduceSum(x[idx]);
    if (tid % 32 == 0) sdata[tid / 32] = val;

    __syncthreads();

    for (int i = BLOCK_SIZE / 64; i > 0; i /= 2) {
      if (tid < i) {
        sdata[tid] += sdata[tid + i];
      }
      __syncthreads();
    }
    if (tid == 0) atomicAdd(y, sdata[0]);
  }
}
```

Each warp writes its partial sum to shared memory, and a small tree combines the 8 warp sums of a 256-thread block.
Now there is one atomic per 256 elements, another 8× fewer. The kernel finally reaches ~45% of peak bandwidth.

But the whole reduction, including four `__syncthreads()` barriers, still runs _once per loop iteration_, i.e.
once per 256 loaded elements. Most of the time the SM is synchronizing instead of loading.

## v4: accumulate in registers, reduce once — 0.686 ms (2×)

```cpp
__global__ void vector_sum_gpu(const float* x, float* y, const int n) {
  __shared__ float sdata[BLOCK_SIZE / 32];
  int tid = threadIdx.x;
  int gid = blockIdx.x * blockDim.x + tid;
  int lane = tid % 32;
  int wid = tid / 32;

  float val = 0.f;
  for (int idx = gid; idx < n; idx += gridDim.x * blockDim.x) {
    val += x[idx];
  }

  val = warpReduceSum(val);
  if (lane == 0) sdata[wid] = val;

  __syncthreads();

  for (int i = BLOCK_SIZE / 64; i > 0; i /= 2) {
    if (tid < i) {
      sdata[tid] += sdata[tid + i];
    }
    __syncthreads();
  }
  if (tid == 0) atomicAdd(y, sdata[0]);
}
```

This is the step that matters most. The reduction is a two-phase algorithm:

1. **Streaming phase.** Each thread walks the array with a grid-stride loop and keeps a private running sum in a
   register. No communication, no barriers, no atomics; just coalesced loads.
2. **Combining phase.** Only after the loop does the block reduce its 256 partial sums and issue a single atomic.

For this to work, the grid must be _small_: just enough blocks to fill the GPU, so each thread processes many
elements. The launch size now comes from the occupancy API instead of $$\lceil N / 256 \rceil$$:

```cpp
int numSMs, blockPerSM;
CUDA_CHECK(cudaDeviceGetAttribute(&numSMs, cudaDevAttrMultiProcessorCount, 0));
CUDA_CHECK(cudaOccupancyMaxActiveBlocksPerMultiprocessor(
    &blockPerSM, vector_sum_gpu<BLOCK_SIZE>, BLOCK_SIZE, 0));
int blocks = numSMs * blockPerSM * 2;  // 170 * 6 * 2 = 2040 blocks
```

With 2040 blocks, the whole kernel issues 2040 atomics instead of $$2^{28}$$, and synchronization cost becomes
negligible. At 1565 GB/s, the kernel is at 87% of the 1792 GB/s spec. At this point it is genuinely DRAM-bound.

## v5: two-level warp reduction and `float4` loads — 0.682 ms

```cpp
template <int kBlockSize>
__global__ void vector_sum_gpu(const float* x, float* y, const int n) {
  static_assert(kBlockSize % 32 == 0, "Block size must be a multiple of 32");
  static_assert(kBlockSize <= 1024, "Block size must not exceed 1024");
  if (blockDim.x != kBlockSize) __trap();

  __shared__ float sdata[kBlockSize / 32];
  int tid = threadIdx.x;
  int gid = blockIdx.x * blockDim.x + tid;
  int lane = tid % 32;
  int wid = tid / 32;

  float val = 0.f;
  const float4* x_f4 = reinterpret_cast<const float4*>(x);
  for (size_t idx = gid; idx < n / 4; idx += gridDim.x * blockDim.x) {
    val += x_f4[idx].x + x_f4[idx].y + x_f4[idx].z + x_f4[idx].w;
  }

  // handle remainder
  if (n / 4 * 4 + gid < n) {
    val += x[n / 4 * 4 + gid];
  }

  val = warpReduceSum(val);
  if (lane == 0) sdata[wid] = val;

  __syncthreads();

  if (wid == 0) {
    val = lane < kBlockSize / 32 ? sdata[lane] : 0.f;
    val = warpReduceSum(val);
    if (lane == 0) atomicAdd(y, val);
  }
}
```

Three cleanups:

- **Template on block size.** `sdata` is sized at compile time, `static_assert`s catch invalid sizes, and a
  `__trap()` guards against launching with a mismatched `blockDim`.
- **Two-level warp reduction.** Warp 0 loads the per-warp sums from shared memory and does one more
  `warpReduceSum`, replacing the shared-memory tree and its barriers.
- **Vectorized loads.** Reading `float4` issues 128-bit loads, a quarter as many load instructions. `cudaMalloc`
  guarantees enough alignment for the cast; the scalar tail handles `n % 4 != 0`.

Each of these is the textbook next step, and together they gained **0.6%**. That is the real lesson from v5: once the
kernel is bandwidth-bound, fewer instructions don't help, because the instructions were never the bottleneck. A
rerun of the final version measured 0.692 ms; the run-to-run noise is about the same size as the improvement.

## Takeaways

- **Do the roofline arithmetic first.** For a memory-bound kernel, `bytes / peak bandwidth` is the floor
  (here ~0.6 ms). It tells you when to stop and which optimizations can possibly matter.
- **Contention and synchronization dominate naive reductions.** 99.8% of the total speedup came from issuing
  fewer atomics and fewer barriers, not from faster loads.
- **Separate the streaming and combining phases.** Accumulate privately in registers over a grid-stride loop, then
  reduce once per block. Size the grid by occupancy, not by problem size.
- **Benchmark hygiene is part of the result.** Without L2 flushing and median-of-N timing, the last few
  "improvements" would have been noise or cache effects.

The remaining ~12% gap to the spec sheet is roughly what a simple streaming read achieves in practice on GDDR
memory; closing it further would mean measuring a `cudaMemcpy`-style bandwidth ceiling on this card first, which is
the next experiment.
