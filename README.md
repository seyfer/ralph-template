# Long-running agent harness ("Ralph, disciplined")

## Quick Start

```bash
# Run single iteration
bash plans/ralph-once.sh

# Run multiple iterations (e.g., 10)
bash plans/ralph.sh 10
```

## Setup
1) Fill `prd.json` with your project features/checklist.
2) Update `init.sh` and `checks.sh` so they match your repo commands.
3) Make sure your agent CLI is installed (`claude`, `codex`, etc).
4) (Optional) Set up a sandbox environment for safer execution.

### Sandbox Setup (Optional)

Ralph can run in two modes:

**Local Mode** (default): The agent runs directly on your machine using your local environment.

**Sandbox Mode**: The agent runs in an isolated Docker container. Safer for autonomous runs, but requires Docker Desktop 4.50+.

#### Claude Code Sandbox

Install [Docker Desktop 4.50+](https://docs.docker.com/desktop/install), then:

```bash
# First-time setup: authenticate Claude in sandbox
docker sandbox run claude

# Run Ralph in sandbox mode
AGENT_CMD="docker sandbox run claude" bash ralph.sh 25
```

Benefits:
- Isolated execution environment
- Your working directory mounts at the same path inside the container
- Git config auto-injected for proper commit attribution
- One sandbox per workspace - state persists between runs

See [Docker Sandboxes docs](https://docs.docker.com/ai/sandboxes/) for more.

#### Codex Sandbox

```bash
# First-time setup
docker sandbox run codex

# Run Ralph in sandbox mode
AGENT_CMD="docker sandbox run codex" bash ralph.sh 25
```

#### Cursor CLI (Local Mode Only)

> **Note**: Cursor's CLI (`agent`) does not currently have Docker Sandbox support. You can run it in local mode only.

**Installation**

```bash
curl https://cursor.com/install -fsS | bash
```

**Authentication (Required for headless mode)**

For headless/script mode, you must set the `CURSOR_API_KEY` environment variable:

1. Get your API key from: https://cursor.com/dashboard?tab=background-agents
2. Export it before running:

```bash
export CURSOR_API_KEY=your_api_key_here
bash plans/ralph.sh 25
```

Or inline:
```bash
CURSOR_API_KEY=your_api_key_here bash plans/ralph.sh 25
```

**Run Cursor Agent with Ralph locally**

Cursor's CLI tool is called `agent`. Key flags for headless/script usage:
- `-p, --print`: Non-interactive print mode (required for Ralph)
- `--force`: Allow file modifications without confirmation
- `--output-format text`: Clean text output (or `stream-json` for real-time)
- `--approve-mcps`: Auto-approve MCP servers (if using MCP tools)

**Important**: The default `ralph-once.sh` uses Claude-specific flags. For Cursor, modify `ralph-once.sh`:

```bash
# Replace the $AGENT_CMD line with:
agent -p --force --output-format text \
    "@plans/prd.json @plans/context.md @plans/progress.md @plans/init.sh @plans/checks.sh $PROMPT"
```

For loop execution, modify `ralph.sh` to call agent directly (output buffering issues with subshell capture):

```bash
# In the loop, replace the subshell capture with direct execution:
agent -p --force --output-format text \
    "@plans/prd.json @plans/context.md @plans/progress.md @plans/init.sh @plans/checks.sh $PROMPT"

# Check completion via prd.json instead of grepping output:
if ! grep -q '"passes": false' plans/prd.json; then
    echo "PRD complete."
    exit 0
fi
```

**Known Issues**

- The CLI may hang indefinitely after responding, even in `--print` mode
- Keychain access errors (`SecItemCopyMatching failed`) occur if `CURSOR_API_KEY` is not set
- Some users report better results with alternative agents like [opencode](https://github.com/opencode-ai/opencode) for headless use

For isolated execution, consider:
- Running Ralph on a separate development machine or VM
- Using Docker to containerize your entire project workspace
- Using other sandbox-supported agents (Claude Code, Codex, Gemini, cagent, Kiro)

See [Cursor CLI documentation](https://cursor.com/docs/cli/overview) for more details.

#### Other Supported Sandboxes

Docker Sandboxes also supports: **Gemini**, **cagent**, and **Kiro**

```bash
# Gemini
docker sandbox run gemini
AGENT_CMD="docker sandbox run gemini" bash ralph.sh 25

# cagent (Docker's agent)
docker sandbox run cagent
AGENT_CMD="docker sandbox run cagent" bash ralph.sh 25

# Kiro (AWS)
docker sandbox run kiro
AGENT_CMD="docker sandbox run kiro" bash ralph.sh 25
```

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
- [Getting Started with Ralph](https://www.aihero.dev/getting-started-with-ralph) - A beginner's guide to using Ralph for AI-powered coding.
- [11 Tips For AI Coding With Ralph Wiggum](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum) - Matt Pocock's practical guide covering HITL vs AFK modes, PRD formats, feedback loops, and alternative loop types.
