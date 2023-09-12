---
title: GPU Scheduler for De Novo Genome Assembly with Multiple MPI Processes
summary: |2-
  ELBA is the state-of-the-art distributed-memory parallel algorithm for overlap detection and layout simplification steps of *De Novo* genome assembly.
  We introduce 3 GPU schedulers for ELBA to accommodate multiple MPI processes and multiple GPUs.
tags:
- High Performance Computing
- Bioinformatics
date: "2023-05-15T00:00:00Z"

# Optional external URL for project (replaces project detail page).
external_link: ""

image:
  caption:
  focal_point: Smart

links:
url_code: "https://github.com/garywei944/ELBA/tree/GPU"
url_pdf: "https://s3.amazonaws.com/garywei.dev/GPU+Scheduler+for+De+Novo+Genome+Assembly+with+Multiple+MPI+Processes.pdf"
url_slides: ""
url_video: ""

# Slides (optional).
#   Associate this project with Markdown slides.
#   Simply enter your slide deck's filename without extension.
#   E.g. `slides = "example-slides"` references `content/slides/example-slides.md`.
#   Otherwise, set `slides = ""`.
slides: ""
---

# Abstract

*De Novo* Genome assembly is one of the most important tasks in computational biology.
ELBA is the state-of-the-art distributed-memory parallel algorithm for overlap detection and layout simplification steps of *De Novo* genome assembly but exists a performance bottleneck in pairwise alignment.

In this work, we introduce 3 GPU schedulers for ELBA to accommodate multiple MPI processes and multiple GPUs.
The GPU schedulers enable multiple MPI processes to perform computation on GPUs in a round-robin fashion.
Both strong and weak scaling experiments show that 3 schedulers are able to significantly improve the performance of baseline while there is a trade-off between parallelism and GPU scheduler overhead.
For the best performance implementation, the one-to-one scheduler achieves ~7-8x speed-up using 25 MPI processes compared with the baseline vanilla ELBA GPU scheduler.
