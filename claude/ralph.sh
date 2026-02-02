#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
	echo "Usage: $0 <iterations>"
	echo
	echo "Example:"
	echo "  bash ralph.sh 10"
	exit 1
fi

notify() {
	# macOS notification
	if command -v osascript >/dev/null 2>&1; then
		osascript -e "display notification \"$1\" with title \"Ralph - Claude\""
	else
		echo "NOTIFY: $1"
	fi
}

PROMPT=$(
	cat <<'EOF'
You are operating inside a repository with a long-running agent harness.

Inputs:
- @prd.json (source of truth requirements + priority + pass/fail)
- @context.md (rolling summary; update only if needed)
- @progress.md (append-only log)
- @init.sh (how to set up)
- @checks.sh (definition-of-done gate)

Rules (must follow):
1) Pick the SINGLE highest-priority feature where passes=false. Work ONLY on that feature.
2) Do the implementation in the repo.
3) Run: bash checks.sh
   - If checks fail: fix until they pass OR if blocked, document exactly why in progress.md and stop.
4) Update prd.json for that feature:
   - passes=true only when checks pass
   - add notes if relevant
5) Append an entry to progress.md:
   - what changed, commands run, what's next
6) If you made meaningful progress, create a git commit for THIS feature only.
   Commit message format: "feat(F-XXX): <short summary>"
7) If ALL features in prd.json have passes=true, output exactly:
<promise>COMPLETE</promise>
EOF
)

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

for ((i = 1; i <= $1; i++)); do
	echo
	echo "=============================="
	echo "Iteration $i / $1"
	echo "=============================="
	echo "== Ralph (single iteration) with Claude Code =="

	# Stream output to console AND capture to file for checking
	set +e
	claude --permission-mode acceptEdits -p \
		"@prd.json @context.md @progress.md @init.sh @checks.sh $PROMPT" \
		2>&1 | tee "$TMPFILE"
	code=${PIPESTATUS[0]}
	set -e

	if grep -q "<promise>COMPLETE</promise>" "$TMPFILE"; then
		echo
		echo "✓✓✓ PRD complete after $i iterations ✓✓✓"
		notify "PRD complete after $i iterations"
		exit 0
	fi

	if [ $code -ne 0 ]; then
		echo
		echo "✗ Iteration $i failed (exit $code). Stopping."
		notify "Iteration $i failed. Check logs."
		exit $code
	fi
done

echo
echo "Reached max iterations ($1)."
notify "Reached max iterations ($1)."
