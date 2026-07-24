#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# body-run – Compile the Typst body PDF only (fast, no merge).
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

IMAGE="report-typst"
HERE="$(cd "$(dirname "$0")/.." && pwd)"

if [ "${1:-}" != "--no-build" ]; then
  echo "==> Building Docker image …"
  docker build -t "$IMAGE" "$HERE"
fi

mkdir -p "$HERE/out"

docker run --rm \
  -e PYTHONUNBUFFERED=1 \
  -v "$HERE/out:/app/out" \
  -v "$HERE/src:/app/src" \
  -v "$HERE/build.py:/app/build.py" \
  "$IMAGE" \
  python3 build.py --typst-only

echo "==> Done: out/report-body.pdf"
