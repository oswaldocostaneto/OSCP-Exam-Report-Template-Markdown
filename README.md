# OSCP Exam Report Template (Custom Private Fork)

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

1. A versioned local Eisvogel template in `src/templates/eisvogel.latex`.
2. A versioned local cover logo in `src/img/offsec-learning-partner.png`.
3. `osert.rb` now prioritizes local template/logo files (no global `~/.local/...` dependency).
4. Better relative image path support (relative to the source `.md` directory).
5. OffSec-style custom cover page.
6. Page numbering starts at the main content (not on cover/TOC pages).
7. Custom footer with `OSID` on the left and `PAGE / TOTAL` on the right.
8. Code blocks with border, light background, line numbers, and long-line wrapping.
9. Styled inline code.
10. Image border + subtle shadow (including images with `{ width=... }`).
11. Improved long URL wrapping inside margins.
12. Preview command support for macOS (`open`) and Linux (`xdg-open`).

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

Build image:

```bash
docker build -t oscp-report-template:local .
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

The two `n` answers skip:

- PDF preview (`xdg-open`)
- optional external lab report prompt

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
- `Dockerfile`
- `docker-entrypoint.sh`
- `docker-compose.yml`
- `docs/screenshots/`
