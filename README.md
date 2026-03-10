# OSCP Exam Report Template (Custom Private Fork)

Fork privado baseado em [noraj/OSCP-Exam-Report-Template-Markdown](https://github.com/noraj/OSCP-Exam-Report-Template-Markdown), com melhorias para uso prático no fluxo `ruby osert.rb generate`.

## Referência ao projeto original

- Upstream: [noraj/OSCP-Exam-Report-Template-Markdown](https://github.com/noraj/OSCP-Exam-Report-Template-Markdown)
- Template base LaTeX: [Wandmalfarbe/eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template)

## O que este fork adiciona

1. Template Eisvogel versionado no próprio projeto: `src/templates/eisvogel.latex`
2. Logo local versionada: `src/img/offsec-learning-partner.png`
3. `osert.rb` prioriza template/logo locais (sem depender de arquivo global em `~/.local/...`)
4. Suporte robusto a caminhos relativos de imagem (relativos ao `.md`)
5. Capa customizada estilo OffSec
6. Paginação iniciando no conteúdo principal (não na capa/sumário)
7. Rodapé customizado (`OSID` à esquerda e `PAGE / TOTAL` à direita)
8. Code blocks com borda/fundo/número de linhas e quebra de linha longa
9. Inline code estilizado
10. Borda + sombra sutil para imagens (incluindo imagens com `{ width=... }`)
11. Melhor quebra de URLs longas
12. Preview compatível com macOS (`open`) e Linux (`xdg-open`)

## Screenshots (template genérico)

As imagens abaixo foram geradas **somente** a partir do template de exemplo `src/OSCP-exam-report-template_OS_v2.md` com dados fictícios.

### Capa

![Capa genérica](docs/screenshots/cover-page-generic.png)

### Sumário

![Sumário genérico](docs/screenshots/contents-page-generic.png)

### Página com imagem (placeholder)

![Página genérica com imagem](docs/screenshots/evidence-page-generic.png)

## Uso

```bash
ruby osert.rb init
ruby osert.rb generate
```

Modo direto:

```bash
ruby osert.rb generate \
  -i /caminho/Report.md \
  -o /caminho/output \
  -e OSCP \
  -s OS-12345678
```

## Estrutura relevante

- `osert.rb`
- `filters/inline_code_box.lua`
- `src/templates/eisvogel.latex`
- `src/img/offsec-learning-partner.png`
- `docs/screenshots/`
