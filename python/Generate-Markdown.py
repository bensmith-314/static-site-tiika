#!/usr/bin/env python3

import sys
import markdown
from pathlib import Path

def convert_markdown_to_html(md_path):
    path = Path(md_path)
    if not path.exists():
        print(f"Error: File {md_path} not found.", file=sys.stderr)
        sys.exit(1)

    md_text = path.read_text(encoding="utf-8")

    # Enable meta extension to parse YAML-style front matter
    md = markdown.Markdown(extensions=["meta", "fenced_code", "codehilite"])
    html = md.convert(md_text)

    # Access metadata (optional)
    metadata = md.Meta
    # Example: print(metadata.get("date", [""])[0])

    print(html)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: md_to_html.py <path-to-markdown-file>", file=sys.stderr)
        sys.exit(1)

    convert_markdown_to_html(sys.argv[1])