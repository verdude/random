#!/usr/bin/env python3

import json
import re
import sys
from collections import defaultdict

error_output = sys.stdin.read()

error_pattern = re.compile(r"^\s*(\/.+?\.py):(\d+):(\d+) - error:(.*)$", re.MULTILINE)
matches = error_pattern.findall(error_output)

errors_by_file = defaultdict(list)
for match in matches:
    file_path, row, col, error = match
    errors_by_file[file_path].append(
        {"row": int(row), "col": int(col), "error": error.strip()}
    )

json_output = []
for file_path, errors in errors_by_file.items():
    json_output.append({"file": file_path, "errors": errors})

vim_commands = ["vim -c 'set hidden'"]

for entry in json_output:
    filename = entry["file"].replace("~", "$HOME")
    vim_commands.append("-c 'edit " + filename + "'")
    qf_entries = []
    for error in entry["errors"]:
        error_text = error["error"].replace("'", "''")
        qf_entry = "{{'filename': '{}', 'lnum': {}, 'col': {}}}".format(
            filename, error["row"], error["col"]
        )
        qf_entries.append(qf_entry)
    if qf_entries:
        vim_commands.append(f"-c \"call setqflist([{', '.join(qf_entries)}], 'r')\"")

vim_commands.append("-c 'copen'")

vim_command_line = " ".join(vim_commands)
print(vim_command_line)
