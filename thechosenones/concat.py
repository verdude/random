#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path
from xml.sax.saxutils import escape
import sys


def iter_files_from_list(files):
    paths = []
    for f in files:
        if f == "-":
            paths.extend(
                line.strip() for line in sys.stdin if line.strip()
            )
        else:
            paths.append(f)

    for p in sorted((Path(p) for p in paths), key=lambda x: str(x)):
        if p.is_file():
            yield p

def iter_files_from_dir(d: Path):
    for p in sorted(d.iterdir(), key=lambda x: x.name):
        if p.is_file():
            yield p


def iter_files_from_glob(pattern: str, root: Path):
    # Path.rglob expects a pattern without leading "./"
    for p in sorted(root.rglob(pattern), key=lambda x: str(x)):
        if p.is_file():
            yield p


def iter_files_from_list(files):
    for p in sorted((Path(f) for f in files), key=lambda x: str(x)):
        if p.is_file():
            yield p


def bundle(files_iter):
    parts = []
    for p in files_iter:
        data = p.read_text(encoding="utf-8", errors="replace")
        filename = escape(p.name)
        body = escape(data)
        parts.append(f'<file name="{filename}">\n{body}\n</file>\n')
    return "".join(parts)


def parse_args(argv):
    ap = argparse.ArgumentParser(description="Bundle files into a simple XML format.")
    ap.add_argument("-o", "--output", default="bundle.xml", help="Output file (default: bundle.xml)")

    src = ap.add_mutually_exclusive_group(required=True)
    src.add_argument("input_dir", nargs="?", help="Input directory (non-recursive, existing behavior)")
    src.add_argument("-g", "--glob", dest="glob_pat", help="Recursive glob pattern (e.g. '**/*.txt')")
    src.add_argument("-f", "--files", nargs="+", help="Explicit list of files")

    ap.add_argument(
        "-C",
        "--root",
        default=".",
        help="Root directory for --glob (default: current directory)",
    )

    return ap.parse_args(argv)


def main(argv=None):
    args = parse_args(sys.argv[1:] if argv is None else argv)
    out_file = Path(args.output)

    if args.input_dir is not None:
        in_dir = Path(args.input_dir)
        if not in_dir.is_dir():
            print(f"Not a directory: {in_dir}", file=sys.stderr)
            return 2
        files_iter = iter_files_from_dir(in_dir)

    elif args.glob_pat is not None:
        root = Path(args.root)
        if not root.is_dir():
            print(f"Not a directory: {root}", file=sys.stderr)
            return 2
        files_iter = iter_files_from_glob(args.glob_pat, root)

    else:
      paths = []
      for f in args.files:
        if f == "-":
          paths.extend(line.strip() for line in sys.stdin if line.strip())
        else:
          paths.append(f)

      missing = [p for p in paths if not Path(p).is_file()]
      if missing:
        print("Not a file:\n" + "\n".join(missing), file=sys.stderr)
        return 2
      files_iter = iter_files_from_list(paths)

    out_file.write_text(bundle(files_iter), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
