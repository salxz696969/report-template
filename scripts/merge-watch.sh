#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# merge-watch – Watch sources, recompile and merge on every change.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

IMAGE="report-typst"
HERE="$(cd "$(dirname "$0")/.." && pwd)"

if [ "${1:-}" != "--no-build" ]; then
  echo "==> Building Docker image …"
  docker build -t "$IMAGE" "$HERE"
fi

mkdir -p "$HERE/out"

# Temporary script: full build on each change
TMP="$(mktemp)"
cat > "$TMP" << 'PYEOF'
import subprocess, shutil, sys, time, os
from pathlib import Path

ROOT = Path("/app")
SRC_DIR = ROOT / "src"
BODY_TYP = SRC_DIR / "report.typ"
BODY_PDF = ROOT / "out" / "report-body.pdf"
HEADER_PDF = ROOT / "out" / "report-header.pdf"
OUTPUT_PDF = ROOT / "out" / "Internship_Report.pdf"

def compile_body():
    print("\033[94mCompiling Typst...\033[0m", flush=True)
    typst = shutil.which("typst")
    r = subprocess.run([typst, "compile", str(BODY_TYP), str(BODY_PDF)], capture_output=True, text=True)
    if r.returncode == 0:
        print(f"\033[92mBody compiled\033[0m", flush=True)
        return True
    for l in r.stderr.splitlines():
        if "error:" in l or "warning:" in l: print(f"  {l}", flush=True)
    return False

def combine():
    import pikepdf
    print("\033[94mMerging...\033[0m", flush=True)
    h = pikepdf.open(str(HEADER_PDF)) if HEADER_PDF.exists() else None
    b = pikepdf.open(str(BODY_PDF))
    o = pikepdf.Pdf.new()
    if h:
        for p in h.pages: o.pages.append(p)
    for p in b.pages: o.pages.append(p)
    OUTPUT_PDF.parent.mkdir(parents=True, exist_ok=True)
    o.save(str(OUTPUT_PDF))
    b.close()
    if h: h.close()
    print("\033[92mMerged\033[0m", flush=True)

def build():
    if compile_body():
        combine()

print(f"\033[96mWatching {SRC_DIR}...\033[0m", flush=True)
build()

def _ext(p):
    return p.endswith((".typ", ".bib", ".docx", ".png", ".jpg", ".webp", ".svg"))

mtimes = {}
for root, _, files in os.walk(str(SRC_DIR)):
    for f in files:
        if _ext(f):
            fp = os.path.join(root, f)
            try: mtimes[fp] = os.path.getmtime(fp)
            except OSError: pass

try:
    while True:
        time.sleep(1)
        changed = False
        for root, _, files in os.walk(str(SRC_DIR)):
            for f in files:
                if not _ext(f): continue
                fp = os.path.join(root, f)
                try: mt = os.path.getmtime(fp)
                except OSError: continue
                if fp not in mtimes or mt != mtimes[fp]:
                    mtimes[fp] = mt
                    changed = True
        if changed:
            print("\033[90m── Changed\033[0m", flush=True)
            build()
            print()
except KeyboardInterrupt:
    print("\nStopped.")
PYEOF

docker run --rm -it \
  -e PYTHONUNBUFFERED=1 \
  -v "$HERE/out:/app/out" \
  -v "$HERE/src:/app/src" \
  -v "$TMP:/app/build.py" \
  "$IMAGE" \
  python3 /app/build.py

rm -f "$TMP"
