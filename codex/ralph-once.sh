#!/usr/bin/env bash
set -euo pipefail

echo "== Ralph (single iteration) with Codex =="
echo

read -r -d '' PROMPT <<'EOF' || true
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

# Codex with auto-accept edits and print mode
result=$(codex --permission-mode acceptEdits -p "@prd.json @context.md @progress.md @init.sh @checks.sh $PROMPT")

echo "$result"

if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
	echo "✓ PRD complete."
	exit 0
fi
