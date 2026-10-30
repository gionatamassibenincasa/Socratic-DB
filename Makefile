# Makefile per la compilazione della documentazione di Socratic-DB tramite Quarto

QUARTO ?= quarto
PYTHON ?= python3

.PHONY: help all pdf docx html md single-md zip clean dist-init

help:
	@echo "Comandi disponibili per Socratic-DB:"
	@echo "  make all       - Compila tutti i formati (PDF, DOCX, HTML, Markdown unico)"
	@echo "  make pdf       - Compila il documento PDF tipografico (motore Typst)"
	@echo "  make docx      - Compila il documento Word DOCX"
	@echo "  make html      - Compila il sito/libro web HTML"
	@echo "  make md        - Genera il file Markdown unico (dist/socratic-db-full.md)"
	@echo "  make zip       - Esporta i file tracciati da Git in socratic-db.zip"
	@echo "  make clean     - Rimuove la cartella dist/ e le cache di Quarto"

dist-init:
	@mkdir -p dist

all: pdf docx html md

pdf: dist-init
	@echo "==> Rendering PDF (Typst) tramite Quarto..."
	@cd docs && $(QUARTO) render --to typst
	@cp docs/_book/Socratic-DB.pdf dist/
	@echo "Output PDF pronto in: dist/Socratic-DB.pdf"

docx: dist-init
	@echo "==> Rendering DOCX tramite Quarto..."
	@cd docs && $(QUARTO) render --to docx
	@cp docs/_book/Socratic-DB.docx dist/
	@echo "Output DOCX pronto in: dist/Socratic-DB.docx"

html: dist-init
	@echo "==> Rendering HTML Book tramite Quarto..."
	@cd docs && $(QUARTO) render --to html
	@cp -r docs/_book/* dist/
	@echo "Output HTML pronto in: dist/index.html"

md: single-md

single-md: dist-init
	@echo "==> Generazione Markdown unico..."
	@$(PYTHON) scripts/build_single_md.py

zip:
	@echo "==> Creazione socratic-db.zip dai file tracciati da Git..."
	@rm -f socratic-db.zip
	@git ls-files -z | xargs -0 zip -q -X socratic-db.zip

clean:
	@echo "==> Pulizia dist/ e cache..."
	@rm -rf dist docs/_book docs/.quarto .quarto
