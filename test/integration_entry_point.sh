#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log_file="$(mktemp)"
entry_pid=""
jekyll_pid=""

cleanup() {
  if [ -n "${entry_pid}" ] && kill -0 "${entry_pid}" 2>/dev/null; then
    kill -TERM "${entry_pid}" 2>/dev/null || true
    wait "${entry_pid}" 2>/dev/null || true
  fi
  if [ -n "${jekyll_pid}" ] && kill -0 "${jekyll_pid}" 2>/dev/null; then
    kill -TERM "${jekyll_pid}" 2>/dev/null || true
  fi
  rm -f "${log_file}"
}
trap cleanup EXIT

cd "${repo_root}"

if ! command -v inotifywait >/dev/null 2>&1; then
  echo "inotifywait is required for the entry-point integration test" >&2
  exit 1
fi

if curl -fsS --max-time 1 http://127.0.0.1:8080/ >/dev/null 2>&1; then
  echo "port 8080 is already serving HTTP; stop the existing server before running this test" >&2
  exit 1
fi

bash bin/entry_point.sh >"${log_file}" 2>&1 &
entry_pid=$!

server_ready=false
for _ in $(seq 1 200); do
  jekyll_pid="$(pgrep -P "${entry_pid}" -f "jekyll serve" | head -n 1 || true)"
  if curl -fsS --max-time 1 http://127.0.0.1:8080/ >/dev/null 2>&1; then
    server_ready=true
    break
  fi
  if ! kill -0 "${entry_pid}" 2>/dev/null; then
    break
  fi
  sleep 0.1
done

if [ "${server_ready}" != true ]; then
  echo "entry point did not start a reachable Jekyll server" >&2
  cat "${log_file}" >&2
  exit 1
fi

sleep 1
if grep -q "directory is already being watched" "${log_file}"; then
  echo "entry point configured duplicate watch paths" >&2
  grep -A 5 -B 1 "directory is already being watched" "${log_file}" >&2
  exit 1
fi

original_jekyll_pid="${jekyll_pid}"
python3 -c 'from pathlib import Path; path = Path("_config.yml"); path.write_bytes(path.read_bytes())'

server_restarted=false
for _ in $(seq 1 200); do
  restarted_pid="$(pgrep -P "${entry_pid}" -f "jekyll serve" | tail -n 1 || true)"
  if [ -n "${restarted_pid}" ] && [ "${restarted_pid}" != "${original_jekyll_pid}" ]; then
    jekyll_pid="${restarted_pid}"
    if curl -fsS --max-time 1 http://127.0.0.1:8080/ >/dev/null 2>&1; then
      server_restarted=true
      break
    fi
  fi
  sleep 0.1
done

if [ "${server_restarted}" != true ]; then
  echo "entry point did not restart Jekyll after _config.yml changed" >&2
  cat "${log_file}" >&2
  exit 1
fi

kill -TERM "${entry_pid}"
wait "${entry_pid}" 2>/dev/null || true
entry_pid=""

for _ in $(seq 1 30); do
  if ! kill -0 "${jekyll_pid}" 2>/dev/null; then
    break
  fi
  sleep 0.1
done

if kill -0 "${jekyll_pid}" 2>/dev/null; then
  echo "Jekyll remained running after the entry point terminated" >&2
  exit 1
fi
jekyll_pid=""

echo "entry-point integration checks passed"
