#!/usr/bin/env python3
import os
import sys
from pathlib import Path
from xml.sax.saxutils import escape

def main():
    if len(sys.argv) not in (2, 3):
        print(f"Usage: {Path(sys.argv[0]).name} <input_dir> [output_file]", file=sys.stderr)
        return 2

    in_dir = Path(sys.argv[1])
    out_file = Path(sys.argv[2]) if len(sys.argv) == 3 else Path("bundle.xml")

    if not in_dir.is_dir():
        print(f"Not a directory: {in_dir}", file=sys.stderr)
        return 2

    parts = []
    for p in sorted(in_dir.iterdir(), key=lambda x: x.name):
        if not p.is_file():
            continue
        data = p.read_text(encoding="utf-8", errors="replace")
        filename = escape(p.name)
        body = escape(data)
        parts.append(f'<file name="{filename}">\n{body}\n</file>\n')

    out_file.write_text("".join(parts), encoding="utf-8")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
