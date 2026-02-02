#!/usr/bin/env bash
set -euo pipefail

echo "== Ralph (single iteration) with Claude Code =="
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

# Claude Code with live streaming output, filtered through jq for readable text
claude --permission-mode acceptEdits -p \
	--verbose \
	--output-format stream-json \
	--include-partial-messages \
	"@prd.json @context.md @progress.md @init.sh @checks.sh $PROMPT" \
	| jq -r 'if .type == "stream_event" and .event.delta.text then .event.delta.text elif .type == "result" then "\n\n[Done: \(.result // "completed")]" else empty end'
