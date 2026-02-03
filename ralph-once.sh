#!/usr/bin/env bash
set -euo pipefail

AGENT_CMD="${AGENT_CMD:-claude}"

echo "== Ralph (single iteration) =="

read -r -d '' PROMPT <<'EOF' || true
You are operating inside a repository with a long-running agent harness.

Inputs:
- @plans/prd.json (source of truth requirements + priority + pass/fail)
- @plans/context.md (rolling summary; update only if needed)
- @plans/progress.md (append-only log)
- @plans/init.sh (how to set up)
- @plans/checks.sh (definition-of-done gate)

Rules (must follow):
1) Pick the SINGLE highest-priority feature where passes=false. Work ONLY on that feature.
2) Do the implementation in the repo.
3) Run: bash plans/checks.sh
   - If checks fail: fix until they pass OR if blocked, document exactly why in progress.md and stop.
4) Update plans/prd.json for that feature:
   - passes=true only when checks pass
   - add notes if relevant
5) Append an entry to plans/progress.md:
   - what changed, commands run, what's next
6) If you made meaningful progress, create a git commit for THIS feature only.
   Commit message format: "feat(F-XXX): <short summary>"
   - Only commit files YOU changed for this feature
   - Ignore any pre-existing uncommitted changes
7) If all features in prd.json have passes=true, output: <promise>COMPLETE</promise>
8) Do NOT ask questions - proceed autonomously with best judgment
EOF

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

# Claude Code style
set +e
$AGENT_CMD --permission-mode acceptEdits -p \
	"@plans/prd.json @plans/context.md @plans/progress.md @plans/init.sh @plans/checks.sh $PROMPT" \
	2>&1 | tee "$TMPFILE"
code=${PIPESTATUS[0]}
set -e

if grep -q "<promise>COMPLETE</promise>" "$TMPFILE"; then
	# Verify by checking prd.json - model sometimes outputs COMPLETE prematurely
	incomplete_count=$(jq '[.features[] | select(.passes == false)] | length' plans/prd.json 2>/dev/null || echo "0")
	if [ "$incomplete_count" -eq 0 ]; then
		echo
		echo "✓ PRD complete."
		exit 0
	else
		echo
		echo "⚠ Model claimed COMPLETE but $incomplete_count features still have passes=false."
	fi
fi

if [ $code -ne 0 ]; then
	echo
	echo "✗ Failed (exit $code)."
	exit $code
fi
