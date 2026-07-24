# Internship Report — Base Template

A **base template** for internship reports, written in
[Typst](https://typst.app/).

This template contains:
- A complete report skeleton with chapter headings preserved
- `TO FILL` placeholders in every content section (no pre-filled company data)
- Docker build environment with all required fonts (no local setup needed)
- A gitignored `final/` reference PDF of the completed report

---

## Quick Start (Docker — Recommended)

**Prerequisites:** [Docker](https://docs.docker.com/engine/install/)

```bash
# Fast: compile the Typst body only (no header merge)
./scripts/body-run.sh

# Watch for changes, recompile body on save
./scripts/body-watch.sh

# When ready: merge header + body into the final PDF
./scripts/merge-run.sh
```

Output goes to `out/`:
- `report-body.pdf` — Typst body (from `body-run` / `body-watch`)
- `Internship_Report.pdf` — Final merged PDF (from `merge-run`)

> **First run** builds the Docker image (installs Typst, fonts, Python).
> Skip rebuild with `--no-build`:
> ```bash
> ./scripts/body-run.sh --no-build
> ./scripts/body-watch.sh --no-build
> ```

### Typical workflow

```bash
# Terminal 1 — watch and recompile body on save
./scripts/body-watch.sh

# Terminal 2 — when you want the final PDF with header
./scripts/merge-run.sh --no-build
```

---

## Available Scripts

| Script | What it does |
|---|---|
| `scripts/body-run.sh` | Compile Typst body only (fast) |
| `scripts/body-watch.sh` | Watch sources, recompile body on every change |
| `scripts/merge-run.sh` | Compile body + merge header into final PDF |
| `scripts/merge-watch.sh` | Watch sources, full build (compile + merge) on every change |

---

## Filling In the Template

Each chapter file under `src/chapters/` has `TO FILL` markers where you need
to write your own content. See the per-file table in `AGENTS.md`.

Steps:

1. **Header pages** — Create a `.docx` file with your cover page, project
   title, advisor, and dates. Convert it to PDF, extract the first 3 pages,
   and save as `out/report-header.pdf`.

2. **Abstracts** — Edit `0_intro.typ` (Khmer + English abstract sections).

3. **Chapters 1–7** — Replace each `TO FILL` block with your own content.
   Headings are already set — just fill bodies, figures, and tables.

4. **Appendices** — Add your own screenshots and diagrams (replace `placeholder.png`).

---

## Project Structure

```
src/
├── report.typ              # Entry point — imports all chapters
├── references.bib          # Bibliography (BibTeX, IEEE style)
├── theme/                  # Styling (fonts, headers, tables, etc.)
├── func/                   # Helper utilities (code-figure, numbering)
├── media/                  # Images & diagrams (replace placeholder.png)
└── chapters/               # Report content (one file per chapter)
```

---

## Docker Fonts

The Docker container includes these fonts for zero-host-dependency builds:

| Used in source | Installed font |
|---|---|
| Times New Roman | Times New Roman (msttcorefonts) |
| Yu Gothic | IPAexGothic (IPAex font) |
| Khmer OS Siemreap | Khmer OS Siemreap |
| Fira Code | Fira Code |

---

## License / Attribution

This template is provided for internship report use. The original report
content (in `final/`) belongs to its respective authors. Media assets
(logos, screenshots) are property of their respective owners.
