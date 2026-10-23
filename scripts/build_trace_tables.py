#!/usr/bin/env python3
"""Convert the trace catalog YAML files into Markdown tables for Quarto."""

from pathlib import Path

import yaml


ROOT_DIR = Path(__file__).resolve().parent.parent
DOCS_DIR = ROOT_DIR / "docs"
TABLES = {
    "tracce_esame": DOCS_DIR / "data" / "tracce_esame.yml",
    "materiali_editoriali": DOCS_DIR / "data" / "materiali_editoriali.yml",
}


def render_table(rows, source_path):
    if not isinstance(rows, list) or not rows:
        raise ValueError(f"La tabella YAML deve contenere una lista non vuota: {source_path}")

    if not isinstance(rows[0], dict) or not rows[0]:
        raise ValueError(f"La prima riga deve essere un dizionario non vuoto: {source_path}")

    columns = list(rows[0])
    if len(columns) != len(set(columns)):
        raise ValueError(f"Intestazioni duplicate nella tabella: {source_path}")

    lines = [
        "| " + " | ".join(columns) + " |",
        "| " + " | ".join("---" for _ in columns) + " |",
    ]

    for row_number, row in enumerate(rows, start=1):
        if not isinstance(row, dict) or list(row) != columns:
            raise ValueError(
                f"La riga {row_number} deve avere le stesse colonne e lo stesso ordine "
                f"della prima riga: {source_path}"
            )

        cells = []
        for column in columns:
            value = row[column]
            if not isinstance(value, str):
                raise ValueError(
                    f"Il valore della colonna '{column}' alla riga {row_number} "
                    f"deve essere testo: {source_path}"
                )
            cells.append(value.replace("|", r"\|").replace("\n", "<br>"))
        lines.append("| " + " | ".join(cells) + " |")

    return "\n".join(lines) + "\n"


def build_trace_tables():
    output_dir = DOCS_DIR / "_generated"
    output_dir.mkdir(parents=True, exist_ok=True)

    for table_name, source_path in TABLES.items():
        with source_path.open(encoding="utf-8") as source:
            rows = yaml.safe_load(source)
        markdown = render_table(rows, source_path)
        output_path = output_dir / f"{table_name}.md"
        output_path.write_text(markdown, encoding="utf-8")
        print(f"Tabella generata: {output_path}")


if __name__ == "__main__":
    build_trace_tables()
