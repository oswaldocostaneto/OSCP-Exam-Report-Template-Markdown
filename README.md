# OSCP Exam Report Template - o5Cn

This private fork is based on [noraj/OSCP-Exam-Report-Template-Markdown](https://github.com/noraj/OSCP-Exam-Report-Template-Markdown), with practical improvements for a real `ruby osert.rb generate` workflow.

The customization scope is focused on the **official OffSec OSCP report template v2.0** (`src/OSCP-exam-report-template_OS_v2.md`) and its PDF generation flow.

## Upstream Reference

- Upstream project: [noraj/OSCP-Exam-Report-Template-Markdown](https://github.com/noraj/OSCP-Exam-Report-Template-Markdown)
- Base PDF template: [Wandmalfarbe/eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template)
- Official OSCP v2.0 markdown base used by this fork: `src/OSCP-exam-report-template_OS_v2.md`

## Scope and Non-Goals

- This fork intentionally targets the official OSCP v2.0 template experience.
- Other exam templates provided by the upstream repository were not reworked in this fork.
- This fork supports two execution modes: native dependencies and Docker container.

## What This Fork Adds

- 📄 A versioned local Eisvogel template in `src/templates/eisvogel.latex`.
- 🖼️ A versioned local cover logo in `src/img/offsec-learning-partner.png`.
- 🧠 `osert.rb` now prioritizes local template/logo files (no global `~/.local/...` dependency).
- 📁 Better relative image path support (relative to the source `.md` directory).
- 🎯 OffSec-style custom cover page.
- 🔢 Page numbering starts at the main content (not on cover/TOC pages).
- 🧾 Custom footer with `OSID` on the left and `PAGE / TOTAL` on the right.
- 💻 Code blocks with border, light background, line numbers, and long-line wrapping.
- ✍️ Styled inline code.
- 🖼️ Image border + subtle shadow (including images with `{ width=... }`).
- 🔗 Improved long URL wrapping inside margins.
- 👀 Preview command support for macOS (`open`) and Linux (`xdg-open`).

## Generic Preview (No Real Report Data)

The screenshots below were generated only from the example template `src/OSCP-exam-report-template_OS_v2.md` and synthetic sample content.

### Cover Page

![Generic cover page](docs/screenshots/cover-page-generic.png)

### Contents Page

![Generic contents page](docs/screenshots/contents-page-generic.png)

### Example Page with Figure

![Generic page with figure](docs/screenshots/evidence-page-generic.png)

### Inline Code + Code Block Styling

![Generic inline code and code block styling](docs/screenshots/code-inline-block-generic.png)

## Included OffSec Example (DOCX -> Markdown)

This fork also includes an OffSec sample report converted from DOCX to Markdown, with a relative image directory ready to use:

- `src/examples/offsec-v2-docx/OSCP-Exam-Report-OffSec-v2-Example.md`
- `src/examples/offsec-v2-docx/OSCP-Exam-Report-From-DOCX_images/`

Generate it directly:

```bash
ruby osert.rb generate \
  -i /path/to/repo/src/examples/offsec-v2-docx/OSCP-Exam-Report-OffSec-v2-Example.md \
  -o /path/to/repo/output \
  -e OSCP \
  -s OS-12345678
```

## Usage Mode 1: Native Dependencies (Host Install)

```bash
ruby osert.rb init
ruby osert.rb generate
```

Direct mode:

```bash
ruby osert.rb generate \
  -i /path/to/Report.md \
  -o /path/to/output \
  -e OSCP \
  -s OS-12345678
```

## Usage Mode 2: Docker (Isolated Environment)

This mode avoids installing Pandoc/LaTeX/p7zip directly on your host system.
The bind mount `-v "$PWD":/workspace` is what makes generated files visible on the host.
Generated files will be written to your local `./output` directory.

Important:

- The `-i` input path must exist **inside the container**.
- If you only mount `-v "$PWD":/workspace`, then `-i` must point to `/workspace/...`.
- Host paths like `/home/user/...` or `/mnt/hgfs/...` will fail unless you mount them with an extra `-v`.

Build image:

```bash
docker build -t oscp-report-template:local .
```

After updating the repository (`git pull`), rebuild the image to pick up dependency changes:

```bash
docker build --no-cache -t oscp-report-template:local .
```

Interactive generation:

```bash
docker run --rm -it -v "$PWD":/workspace oscp-report-template:local generate
```

Non-interactive generation (recommended for containers):

```bash
printf 'n\nn\n' | docker run --rm -i -v "$PWD":/workspace oscp-report-template:local generate \
  -i /workspace/src/OSCP-exam-report-template_OS_v2.md \
  -o /workspace/output \
  -e OSCP \
  -s OS-12345678
```

Generate the included OffSec DOCX->Markdown example (with relative image folder):

```bash
printf 'n\nn\n' | docker run --rm -i -v "$PWD":/workspace oscp-report-template:local generate \
  -i /workspace/src/examples/offsec-v2-docx/OSCP-Exam-Report-OffSec-v2-Example.md \
  -o /workspace/output \
  -e OSCP \
  -s OS-12345678
```

The two `n` answers skip:

- PDF preview (`xdg-open`)
- optional external lab report prompt

Using a report file outside the repository (extra volume mount):

```bash
printf 'n\nn\n' | docker run --rm -i \
  -v "$PWD":/workspace \
  -v "/home/oscn/Desktop/New Folder":/reports \
  oscp-report-template:local generate \
  -i "/reports/Report.md" \
  -o /workspace/output \
  -e OSCP \
  -s OS-12345678
```

Direct mode:

```bash
docker run --rm -it -v "$PWD":/workspace oscp-report-template:local generate \
  -i /workspace/src/OSCP-exam-report-template_OS_v2.md \
  -o /workspace/output \
  -e OSCP \
  -s OS-12345678
```

With Docker Compose:

```bash
docker compose run --rm osert generate
```

Docker support in this fork is inspired by these community examples:

- [Tripex48 Docker example](https://github.com/Tripex48/OSCP-Exam-Report-Template-Markdown#docker)
- [ret2src Docker example](https://github.com/ret2src/OSCP-Exam-Report-Template-Markdown#docker)

## Relevant Files in This Fork

- `osert.rb`
- `filters/inline_code_box.lua`
- `src/templates/eisvogel.latex`
- `src/img/offsec-learning-partner.png`
- `src/examples/offsec-v2-docx/OSCP-Exam-Report-OffSec-v2-Example.md`
- `src/examples/offsec-v2-docx/OSCP-Exam-Report-From-DOCX_images/`
- `Dockerfile`
- `docker-entrypoint.sh`
- `docker-compose.yml`
- `docs/screenshots/`
