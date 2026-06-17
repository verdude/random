#!/usr/bin/env bash
set -eEuo pipefail

ppid="$PPID"

echo "=== HUSKY: Parent process info ==="
echo "Time:        $(date -Is)"
echo "This PID:    $$"
echo "Parent PID:  $ppid"
echo

echo "--- ps ---"
ps -p "$ppid" -o pid,ppid,user,stat,lstart,etime,comm,args
echo

if [[ -d "/proc/$ppid" ]]; then
  echo "--- /proc/$ppid/cmdline ---"
  tr '\0' ' ' < "/proc/$ppid/cmdline"
  echo
  echo

  echo "--- /proc/$ppid/status ---"
  grep -E '^(Name|State|Pid|PPid|Uid|Gid|VmRSS|Threads):' "/proc/$ppid/status"
  echo

  echo "--- /proc/$ppid/exe ---"
  readlink -f "/proc/$ppid/exe" 2>/dev/null || true
  echo

  echo "--- /proc/$ppid/cwd ---"
  readlink -f "/proc/$ppid/cwd" 2>/dev/null || true
else
  echo "/proc/$ppid does not exist. Parent may have exited."
fi
