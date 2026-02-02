# Long-running agent harness ("Ralph, disciplined")

## Setup
1) Fill `prd.json` with your project features/checklist.
2) Update `init.sh` and `checks.sh` so they match your repo commands.
3) Make sure your agent CLI is installed (`claude`, `codex`, etc).

## Run
Single iteration:
  bash plans/ralph-once.sh

N iterations:
  bash plans/ralph.sh 25

## Agent expectations
- Works on exactly ONE feature per iteration.
- Must run checks (`plans/checks.sh`) before marking anything done.
- Must update PRD + append progress log + commit.
- When everything is done, prints: <promise>COMPLETE</promise>

## Sources

This harness is based on the following approaches and research:

- [Ralph Wiggum as a "software engineer"](https://ghuntley.com/ralph/) - Geoffrey Huntley's original Ralph technique: a bash loop that forces incremental work with termination markers.
- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Anthropic's research on initializer agents, progress files, and feedback loops for multi-context-window workflows.
- [11 Tips For AI Coding With Ralph Wiggum](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum) - Matt Pocock's practical guide covering HITL vs AFK modes, PRD formats, feedback loops, and alternative loop types.
