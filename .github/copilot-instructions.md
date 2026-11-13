# Copilot instructions for Socratic-DB

## Repository scope

This repository is the source for an Italian Quarto book describing Socratic-DB, an AI-assisted Socratic tutor for relational database design. It also contains ready-to-configure tutor prompts for Gemini, Ollama, and agentic skills. The complete Python/FastAPI/validator stack described in the technical appendices is an architectural target, not an implementation currently present in this repository.

The central pedagogical invariant applies to all tutor artifacts: guide through questions and graduated help, rather than supplying a complete schema or solution SQL; do not score students; respond in Italian; do not use real personal data. Help levels must retain their meaning: L0 outcome only, L1 question, L2 domain counterexample, L3 theory without applying it to the student's solution, and L4 a partial isomorphic example in another domain.

## Documentation architecture

- `docs/_quarto.yml` is the authoritative book manifest: it defines chapter/appendix order, bibliography, Italian localization, output directory, and the pre-render script.
- The Markdown files in `docs/` are the editable book modules. Keep material appropriate to the main audience in the core chapters; retain infrastructure and implementation details in the technical appendices.
- `scripts/build_trace_tables.py` turns the two YAML catalogs in `docs/data/` into include files under `docs/_generated/`. Catalog rows must be non-empty lists of mappings with the same keys in the same order and string values only.
- `scripts/build_single_md.py` first generates those tables, then reads the configured `book.chapters` order and resolves Quarto `{{< include ... >}}` directives into `dist/socratic-db-full.md`. It intentionally excludes appendices because it reads `chapters`, not `appendices`.
- `gemini-gem/GEM_SYSTEM_INSTRUCTIONS.md`, `ollama/Modelfile`, and `skills/socratic-db/SKILL.md` express the same tutor role for different runtimes. Update their shared behavioral rules together; keep runtime-specific setup details local to each artifact.

Do not edit generated output: `dist/`, `docs/_book/`, and `docs/_generated/` are build products. Update the Markdown, YAML, or script sources instead.

## Prompt design across pilot phases

For Pilots 1–2, keep one Gem, one Skill, and one Modelfile. More runtime configurations do not reduce the context used by an individual interaction; they add configuration drift, make it easier to select the wrong tutor, and fragment a student's learning path.

Structure each runtime prompt as a concise shared core plus focused, selectable material:

- The **shared core** states the Socratic role, the non-solution and non-evaluation constraints, Italian language, privacy rules, and the L0–L4 definitions.
- A **phase/consegna module** specifies the learning objective, product-quality dimensions, expected format, common misconceptions, and a small number of examples for that phase (requirements, glossary, conceptual model, relational model, DDL, test data, or queries).
- The **maieutic level** is a cross-cutting response rule: it controls how a diagnosis is expressed, not which activity is being performed. Do not create a separate Gem, Skill, or Modelfile for every L0–L4 level.

Avoid embedding exhaustive instructions and examples for every phase × help-level combination in a single static prompt: even where the model's context window permits it, it competes with the student's trace, submission, and conversation history, making behavior less reliable. Phase × level examples may be maintained as modular reference material, but select only the relevant examples for an interaction. Specialize a separate runtime configuration only when a phase requires genuinely distinct inputs, formats, or deterministic controls.

## Build and validation

The Makefile targets require Quarto (with Typst for PDF) and Python with PyYAML. Run them from the repository root in a POSIX-compatible shell:

```sh
make html                 # render the HTML book
make pdf                  # render the Typst PDF
make docx                 # render the DOCX book
make md                   # build only dist/socratic-db-full.md
make all                  # render every supported format
python3 scripts/build_single_md.py  # focused validation of catalog generation and Markdown assembly
```

There is no configured automated test or lint suite, so no single-test command exists. For a change to an individual book module, render the affected output format; for catalog or include changes, use the focused Python command above.

## Content conventions

- Preserve Italian as the user-facing language and Quarto cross-reference syntax (for example, `{#sec-...}` and `@sec-...`).
- Treat technical claims in the appendices as specifications or future design unless implementation files demonstrate otherwise; do not claim a component is implemented merely because the documentation describes it.
- Keep original source materials, reviewed Markdown transcriptions, and student-facing exports distinct. Do not place restricted source material or personal data under `docs/`, because Quarto can copy assets from that directory into rendered output.
