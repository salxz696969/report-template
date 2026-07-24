# ──────────────────────────────────────────────────────────────────────────────
# Internship Report – Build Container
#
# Provides Typst, required fonts, and Python (for pikepdf merging).
# Fonts installed:
#   Times New Roman → msttcorefonts (real Microsoft font)
#   IPAex Gothic      → fonts-ipaexfont-gothic (Japanese, replaces Yu Gothic)
#   Khmer OS Siemreap → fonts-khmeros     (same)
#   Fira Code          → fonts-firacode   (same)
# ──────────────────────────────────────────────────────────────────────────────

FROM ubuntu:24.04 AS typst-base

ENV DEBIAN_FRONTEND=noninteractive

# ── 1. Enable multiverse for msttcorefonts ─────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository multiverse \
    && rm -rf /var/lib/apt/lists/*

# ── 2. System packages: fonts, Python, build tools ─────────────────────────
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula boolean true" \
    | debconf-set-selections \
    && apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    fontconfig \
    python3 \
    python3-pip \
    xz-utils \
    ttf-mscorefonts-installer \
    fonts-ipaexfont-gothic \
    fonts-khmeros \
    fonts-firacode \
    && rm -rf /var/lib/apt/lists/*

# ── 3. Install Typst compiler ─────────────────────────────────────────────
RUN curl -fsSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz \
    | tar xJ --strip=1 -C /usr/local/bin/ typst-x86_64-unknown-linux-musl/typst \
    && typst --version

# ── 4. Install Python deps for build.py ───────────────────────────────────
COPY pyproject.toml /tmp/
RUN pip install --break-system-packages pikepdf watchdog

# ── 5. Working directory & entrypoint ─────────────────────────────────────
WORKDIR /app
COPY . .

CMD ["python3", "build.py"]
