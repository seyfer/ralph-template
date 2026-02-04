#!/usr/bin/env bash
set -euo pipefail

echo "== Ralph (single iteration) with Cursor Agent =="

if ! command -v agent >/dev/null 2>&1; then
	echo "ERROR: Cursor agent CLI not found. Install Cursor CLI first."
	exit 1
fi

# Check for API key
if [ -z "${CURSOR_API_KEY:-}" ]; then
	echo "ERROR: CURSOR_API_KEY environment variable not set"
	echo
	echo "Get your API key from:"
	echo "  https://cursor.com/dashboard?tab=background-agents"
	echo
	echo "Then export it:"
	echo "  export CURSOR_API_KEY=your_api_key_here"
	echo
	exit 1
fi

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
   - Only commit files YOU changed for this feature
   - Ignore any pre-existing uncommitted changes
7) If all features in prd.json have passes=true, output: <promise>COMPLETE</promise>
8) Do NOT ask questions - proceed autonomously with best judgment
EOF

# Cursor agent with --force flag to allow file modifications
# NOTE: DO NOT use -p/--print flag - it causes the CLI to hang indefinitely
# NOTE: Agent runs in interactive mode, so this script will only complete one iteration
agent --force \
	"@prd.json" \
	"@context.md" \
	"@progress.md" \
	"@init.sh" \
	"@checks.sh" \
	"$PROMPT"

# Check if PRD is complete by verifying prd.json
incomplete_count=$(jq '[.features[] | select(.passes == false)] | length' prd.json 2>/dev/null || echo "0")
echo
if [ "$incomplete_count" -eq 0 ]; then
	echo "✓✓✓ PRD complete! All features pass. ✓✓✓"
else
	echo "✓ Iteration complete. $incomplete_count features remaining."
	echo "Run 'bash ralph-once.sh' again to continue to the next feature."
fi
