#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
	echo "Usage: $0 <iterations>"
	exit 1
fi

notify() {
	# macOS notification (works without extra deps)
	if command -v osascript >/dev/null 2>&1; then
		osascript -e "display notification \"$1\" with title \"Ralph Harness\""
	else
		echo "NOTIFY: $1"
	fi
}

for ((i = 1; i <= $1; i++)); do
	echo
	echo "=============================="
	echo "Iteration $i"
	echo "=============================="

	set +e
	out=$(bash plans/ralph-once.sh 2>&1)
	code=$?
	set -e

	echo "$out"

	if echo "$out" | grep -q "<promise>COMPLETE</promise>"; then
		echo "PRD complete after $i iterations."
		notify "PRD complete after $i iterations"
		exit 0
	fi

	if [ $code -ne 0 ]; then
		echo "Iteration $i failed (exit $code). Stopping."
		notify "Iteration $i failed. Check logs."
		exit $code
	fi
done

echo "Reached max iterations ($1)."
notify "Reached max iterations ($1)."
