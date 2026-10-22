#!/usr/bin/env python3
"""
Script per assemblare i moduli della documentazione in un unico file Markdown.
Legge la sequenza dei capitoli configurata in docs/_quarto.yml e produce dist/socratic-db-full.md.
"""

from pathlib import Path
import yaml
import sys

def build_single_markdown():
    root_dir = Path(__file__).resolve().parent.parent
    docs_dir = root_dir / "docs"
    quarto_cfg = docs_dir / "_quarto.yml"
    dist_dir = root_dir / "dist"

    if not quarto_cfg.exists():
        print(f"Errore: file di configurazione Quarto non trovato: {quarto_cfg}", file=sys.stderr)
        sys.exit(1)

    with open(quarto_cfg, "r", encoding="utf-8") as f:
        config = yaml.safe_load(f)

    chapters = config.get("book", {}).get("chapters", [])
    if not chapters:
        print("Errore: nessun capitolo trovato in docs/_quarto.yml", file=sys.stderr)
        sys.exit(1)

    dist_dir.mkdir(parents=True, exist_ok=True)
    out_file = dist_dir / "socratic-db-full.md"

    title = config.get("book", {}).get("title", "Socratic-DB")
    subtitle = config.get("book", {}).get("subtitle", "")
    author = config.get("book", {}).get("author", "")

    header = [
        f"<!--",
        f"Questo documento è stato generato automaticamente dai sorgenti in docs/.",
        f"NON MODIFICARE DIRETTAMENTE QUESTO FILE. Modifica i file singoli in docs/.",
        f"-->",
        "",
        f"# {title}",
        f"**{subtitle}**" if subtitle else "",
        f"*Autore: {author}*" if author else "",
        "",
        "---",
        ""
    ]

    parts = ["\n".join(filter(None, header))]

    for ch in chapters:
        ch_path = docs_dir / ch
        if not ch_path.exists():
            print(f"Attenzione: capitolo mancante: {ch_path}", file=sys.stderr)
            continue

        with open(ch_path, "r", encoding="utf-8") as f:
            content = f.read().strip()

        parts.append(f"\n\n<!-- INIZIO CAPITOLO: {ch} -->\n\n{content}\n\n---\n")

    with open(out_file, "w", encoding="utf-8") as f:
        f.write("\n".join(parts))

    print(f"File Markdown unico generato con successo: {out_file} ({out_file.stat().st_size} bytes)")

if __name__ == "__main__":
    build_single_markdown()
