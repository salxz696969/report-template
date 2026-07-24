# Internship Report — Base Template (for LLM agents)

## Purpose

This is a **base template** for an internship report written in Typst.
It contains the structural skeleton of a full report: chapter headings, theme
files, utility functions, build scripts, and a Docker-based compilation
environment. All project-specific content has been replaced with `TO FILL`
placeholders so that agents can fill in the blanks for a new internship.

A reference-final copy of the original project lives in `final/` (gitignored,
not pushed to GitHub).

---

## Directory Structure

```
base_form_typst/
├── Dockerfile
├── build.py
├── pyproject.toml
├── AGENTS.md
├── README.md
├── .gitignore
├── .dockerignore
├── scripts/
│   ├── body-run.sh          # Compile Typst body only
│   ├── body-watch.sh        # Watch + recompile body
│   ├── merge-run.sh         # Compile + merge header
│   └── merge-watch.sh       # Watch + full build
├── src/
│   ├── report.typ        # ** Entry point
│   ├── references.bib
│   ├── theme/
│   ├── func/
│   ├── media/
│   └── chapters/
└── final/                # Completed PDF (gitignored)
```

---

## What Is Pre-Filled

Only structural/utility content is preserved:

- **TOC, LOF, LOT, Abbreviations** — structural code only (DO NOT EDIT blocks)
- **Theme files** (`global-theme.typ`, `header-style.typ`) — fully functional
- **Utility functions** (`utils.typ`, `header-numbering.typ`) — fully functional
- **Bibliography** (`references.bib`) — generic tech references kept (can be added to)
- **Media** — technology logos and diagram examples preserved (replace with your own)
- **Build infrastructure** — Dockerfile, build.py, etc.

**No company-specific content is pre-filled.** All company description sections (`1_introduction.typ`) are `TO FILL`.

---

## What Is `TO FILL`

Every chapter has `[TO FILL]` placeholders where the original project-specific
content has been removed. **Sections and headings are preserved** — only paragraph
bodies, figure content, table rows, and subsection text are blanked.

Locations of `TO FILL` markers:

| File | What to fill |
|---|---|
| `0_intro.typ` | Acknowledgment, Khmer abstract body, English abstract body |
| `1_introduction.typ` | Entire chapter (internship details, company info, services, org chart, address) |
| `2_project_definition.typ` | Entire chapter body (project description, problematic, objectives, methodology, timeline) |
| `3_literature.typ` | Entire chapter body (existing systems, comparison, why our system) |
| `4_project_analysis.typ` | Entire chapter body (requirements, task breakdown, use cases, activity diagrams) |
| `5_detail_concept.typ` | Entire chapter body (architecture, data model, technologies) |
| `6_implementation.typ` + sub-files | Entire chapter body (project structure, installation, configuration, implementation details) |
| `7_conclusion.typ` | Entire chapter body (results, difficulties, perspectives, lessons learned) |
| `x_appendices.typ` | All appendix figures |

---

## Build Commands

All commands are in the `scripts/` folder. Run from repo root.

### Body only (fast — no merge)

```bash
# One-shot compile
./scripts/body-run.sh

# Watch sources, recompile on every change (run in its own terminal)
./scripts/body-watch.sh

# Skip image rebuild
./scripts/body-run.sh --no-build
./scripts/body-watch.sh --no-build
```

Output: `out/report-body.pdf`

### Full build (compile + merge header)

```bash
# One-shot compile + merge
./scripts/merge-run.sh

# Watch + full build on every change
./scripts/merge-watch.sh

# Skip image rebuild
./scripts/merge-run.sh --no-build
```

Output: `out/Internship_Report.pdf`

### Manual Typst-only compile

```bash
typst compile src/report.typ out/report-body.pdf
```

---

## Coding Style & Naming Conventions

- Use concise Typst markup.
- Keep chapter content in the matching file under `src/chapters/`.
- Use lowercase, descriptive asset names with hyphens (e.g., `admin-usecase.png`).
- Prefer PNG for diagrams in the PDF.
- Avoid committing generated PDFs (`.gitignore` blocks `*.pdf`).
- For figures, always use `#figure()` with a `caption:` and a `<label>` for cross-references.
- Each chapter file starts with `= CHAPTER TITLE <ch_label>`.

---

## How to Add or Reorder Chapters

1. Create a new file under `src/chapters/`.
2. Add an `#include "chapters/your-file.typ"` line in `src/report.typ` between the `// ========= Move these files to reorder` markers.
3. If a chapter has sub-files, create a subdirectory (e.g., `6_implementation/`) and include them from the parent chapter file.

---

## The `final/` Reference Report

The `final/` subfolder contains the completed report PDF from the original
project this template was derived from. **It is gitignored** — it exists
for layout reference only. Do not edit it.
