#!/usr/bin/env bash
set -euo pipefail

AGENT_CMD="${AGENT_CMD:-claude}"

echo "== Ralph (single iteration) =="

PROMPT=$(
	cat <<'EOF'
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
7) If ALL features in prd.json have passes=true, output exactly:
<promise>COMPLETE</promise>
EOF
)

# Claude Code style (works for your screenshot pattern)
result=$($AGENT_CMD --permission-mode acceptEdits -p "@plans/prd.json @plans/context.md @plans/progress.md @plans/init.sh @plans/checks.sh $PROMPT")

echo "$result"

if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
	echo "PRD complete."
	exit 0
fi
