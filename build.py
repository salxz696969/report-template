#!/usr/bin/env python3
"""Build script: compile Typst body, merge header + body into final PDF."""

import subprocess
import shutil
import sys
import time
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC_DIR = ROOT / "src"
BODY_TYP = SRC_DIR / "report.typ"
BODY_PDF = ROOT / "out" / "report-body.pdf"
HEADER_PDF = ROOT / "out" / "report-header.pdf"
OUTPUT_PDF = ROOT / "out" / "Internship_Report.pdf"
REQUIRED_FONTS = ["Times New Roman", "IPAexGothic", "Khmer OS Siemreap", "Fira Code"]


def check_fonts() -> bool:
    typst = shutil.which("typst") or str(Path.home() / ".typst" / "bin" / "typst")
    r = subprocess.run([typst, "fonts"], capture_output=True, text=True)
    missing = [f for f in REQUIRED_FONTS if f not in r.stdout]
    if missing:
        print(f"\033[91m✘ Missing fonts:\033[0m {', '.join(missing)}")
        print("  Rebuild the Docker image:  docker build -t report-typst .")
        return False
    return True


def compile_body() -> bool:
    if not check_fonts():
        return False
    print("\033[94m⏳ Compiling Typst...\033[0m")
    typst = shutil.which("typst") or str(Path.home() / ".typst" / "bin" / "typst")
    cmd = [typst, "compile", str(BODY_TYP), str(BODY_PDF)]
    result = subprocess.run(cmd, capture_output=True, text=True)
    font_warnings = [l for l in result.stderr.splitlines() if "unknown font" in l.lower()]
    if font_warnings:
        print("\033[91m✘ Font fallback detected:\033[0m")
        for line in font_warnings:
            print(f"  {line.strip()}")
        print("  Rebuild the Docker image:  docker build -t report-typst .")
        return False
    if result.returncode == 0:
        print(f"\033[92m✔ Body compiled:\033[0m {BODY_PDF}")
        return True
    else:
        print("\033[91m✘ Compilation failed:\033[0m")
        for line in result.stderr.splitlines():
            if "error:" in line or "warning:" in line:
                print(f"  {line}")
        return False


def combine_pdfs() -> None:
    import pikepdf

    if not HEADER_PDF.exists():
        print(f"⚠️  No header PDF found, copying body to output")
        shutil.copy2(BODY_PDF, OUTPUT_PDF)
        return

    print("\033[94m⏳ Merging header + body (pikepdf)...\033[0m")

    header = pikepdf.open(str(HEADER_PDF))
    body = pikepdf.open(str(BODY_PDF))

    output = pikepdf.Pdf.new()

    for page in header.pages:
        output.pages.append(page)

    for page in body.pages:
        output.pages.append(page)

    OUTPUT_PDF.parent.mkdir(parents=True, exist_ok=True)
    output.save(str(OUTPUT_PDF))

    header.close()
    body.close()
    output.close()

    print(f"\033[92m✔ Merged:\033[0m {OUTPUT_PDF}")


def build_once() -> None:
    if compile_body():
        combine_pdfs()
    print(f"Done: {OUTPUT_PDF}")


def watch() -> None:
    if not check_fonts():
        sys.exit(1)
    print(f"\033[96m👁  Watching {SRC_DIR} for changes...\033[0m")
    print("   Press Ctrl+C to stop.\n")

    compile_body()

    def _ext(p: str) -> bool:
        return p.endswith((".typ", ".bib", ".docx", ".png", ".jpg", ".webp", ".svg"))

    mtimes = {}
    for root, _, files in os.walk(str(SRC_DIR)):
        for f in files:
            if _ext(f):
                fp = os.path.join(root, f)
                try:
                    mtimes[fp] = os.path.getmtime(fp)
                except OSError:
                    pass

    try:
        while True:
            time.sleep(1)
            changed = False
            for root, _, files in os.walk(str(SRC_DIR)):
                for f in files:
                    if not _ext(f):
                        continue
                    fp = os.path.join(root, f)
                    try:
                        mt = os.path.getmtime(fp)
                    except OSError:
                        continue
                    if fp not in mtimes or mt != mtimes[fp]:
                        mtimes[fp] = mt
                        changed = True
            if changed:
                print(f"\033[90m── File changed, recompiling...\033[0m")
                compile_body()
                print()
    except KeyboardInterrupt:
        print("\n\033[90mStopped.\033[0m")


if __name__ == "__main__":
    if "--watch" in sys.argv:
        watch()
    elif "--typst-only" in sys.argv:
        compile_body()
    elif "--merge-only" in sys.argv:
        combine_pdfs()
    else:
        build_once()
