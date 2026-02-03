# Long-running agent harness ("Ralph, disciplined")

## Agent-Specific Templates

This repository provides pre-configured Ralph templates for different AI coding agents:

### 📁 [claude/](claude/)
**Claude Code** - Anthropic's coding agent
- ✅ Local mode support
- ✅ Docker Sandbox support
- ✅ Full autonomous multi-iteration loops
- ✅ Live streaming output with `--output-format stream-json`
- **Recommended for production use**

[Quick Start →](claude/README.md)

### 📁 [codex/](codex/)
**Codex** - OpenAI's coding agent
- ✅ Local mode support
- ✅ Docker Sandbox support
- ✅ Full autonomous multi-iteration loops
- ✅ Non-interactive execution with `codex exec`
- ✅ Full-access sandbox for git commits

[Quick Start →](codex/README.md)

### 📁 [cursor/](cursor/)
**Cursor Agent** - Cursor's CLI agent
- ✅ Local mode support
- ❌ No Docker Sandbox support
- ⚠️ Interactive mode only (manual iteration)
- Best for human-in-the-loop workflows

[Quick Start →](cursor/README.md)

---

## Quick Start

```bash
# Run single iteration
bash ralph-once.sh

# Run multiple iterations (e.g., 10)
bash ralph.sh 10
```

## Setup
1) Fill `prd.json` with your project features/checklist.
2) Update `init.sh` and `checks.sh` so they match your repo commands.
3) Install your agent CLI (see below).
4) (Optional) Set up a sandbox environment for safer execution.

### Install CLI Agents

**Claude Code** (Anthropic):
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Codex** (OpenAI):
```bash
# Install using Homebrew
brew install --cask codex

# Or install using npm
npm install -g @openai/codex
```

**Cursor Agent**:
```bash
curl https://cursor.com/install -fsS | bash
```

### Sandbox Setup (Optional)

Ralph can run in two modes:

**Local Mode** (default): The agent runs directly on your machine using your local environment.

**Sandbox Mode**: The agent runs in an isolated Docker container. Safer for autonomous runs, but requires Docker Desktop 4.50+.

#### Claude Code Live Streaming

For real-time output (instead of buffered), the scripts use streaming JSON piped through `jq`:

```bash
claude --permission-mode bypassPermissions -p \
  --verbose \
  --output-format stream-json \
  --include-partial-messages \
  "your prompt" \
  | jq --unbuffered -r 'if .type == "stream_event" and .event.delta.text then .event.delta.text elif .type == "result" then "\n\n[Done]" else empty end'
```

Key flags:
- `--permission-mode bypassPermissions` - Auto-approve all operations (edits + bash commands)
- `--verbose` - Required for stream-json
- `--output-format stream-json` - Real-time streaming output
- `--include-partial-messages` - Show chunks as they arrive
- `jq --unbuffered` - Disable output buffering for live streaming when piped

**Permission modes:**
- `acceptEdits` - Auto-approve file edits only (bash commands require approval)
- `bypassPermissions` - Auto-approve everything (fully autonomous, use with caution)

**Requires**: `jq` (`brew install jq` on macOS)

#### Claude Code Sandbox

Install [Docker Desktop 4.50+](https://docs.docker.com/desktop/install), then:

```bash
# First-time setup: authenticate Claude in sandbox
docker sandbox run claude

# Run Ralph in sandbox mode (requires API key for sandbox)
export ANTHROPIC_API_KEY=your_key_here
docker sandbox run -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" claude ...
```

Benefits:
- Isolated execution environment
- Your working directory mounts at the same path inside the container
- Git config auto-injected for proper commit attribution
- One sandbox per workspace - state persists between runs

See [Docker Sandboxes docs](https://docs.docker.com/ai/sandboxes/) for more.

#### Codex Non-Interactive Mode

Codex requires `codex exec` subcommand for non-interactive (script-based) execution:

```bash
# Interactive mode (requires TTY)
codex --full-auto "prompt"

# Non-interactive mode with full access (for scripts)
codex exec -m gpt-5.2-codex --sandbox danger-full-access "prompt"
```

**Why `danger-full-access`?** The default `--full-auto` uses `--sandbox workspace-write` which blocks writes to `.git`, preventing automated commits. Using `danger-full-access` allows full autonomous operation including git commits.

**Note**: The Ralph harness scripts use `codex exec` because regular `codex` commands fail with "stdout is not a terminal" when output is piped or captured.

#### Codex Sandbox

```bash
# First-time setup
docker sandbox run codex

# Run Ralph in sandbox mode
AGENT_CMD="docker sandbox run codex" bash ralph.sh 25
```

#### Cursor CLI (Local Mode Only)

> **Note**: Cursor's CLI (`agent`) does not currently have Docker Sandbox support. Runs in local mode only.

> **Important Limitation**: Cursor CLI runs in **interactive mode** and stops after each task completion, waiting for follow-up input. This means **only `ralph-once.sh` works** with Cursor. For automated multi-iteration loops (`ralph.sh`), use Claude Code or Codex with Docker Sandbox instead.

**Installation**

```bash
curl https://cursor.com/install -fsS | bash
```

**Authentication (Required)**

You must set the `CURSOR_API_KEY` environment variable:

1. Get your API key from: https://cursor.com/dashboard?tab=background-agents
2. Export it before running:

```bash
export CURSOR_API_KEY=your_api_key_here
bash ralph-once.sh  # Single iteration only!
```

**Modify scripts for Cursor**

The default `ralph-once.sh` uses Claude-specific flags. For Cursor, replace the `$AGENT_CMD` line:

```bash
# Use --force to allow file modifications
agent --force \
    "@prd.json @context.md @progress.md @init.sh @checks.sh $PROMPT"
```

**Key flags:**
- `--force`: Allow file modifications without confirmation
- `--approve-mcps`: Auto-approve MCP servers (if using MCP tools)

> **Warning**: Do NOT use the `-p/--print` flag - it causes the CLI to hang indefinitely.

**Known Issues**

- **Interactive mode only** - Agent stops after each iteration waiting for follow-up; `ralph.sh` loop doesn't work
- `-p/--print` flag causes indefinite hanging - do NOT use it
- Without `CURSOR_API_KEY`, you get keychain errors (`SecItemCopyMatching failed`)

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

## Agent expectations
- Works on exactly ONE feature per iteration.
- Must run checks (`checks.sh`) before marking anything done.
- Must update PRD + append progress log + commit.
- When everything is done, outputs: `<promise>COMPLETE</promise>`

**Note:** Scripts verify PRD completion by checking `prd.json` with `jq` - if model claims COMPLETE but features remain, the loop continues. Requires `jq` (`brew install jq`).

## Sources

This harness is based on the following approaches and research:

- [Ralph Wiggum as a "software engineer"](https://ghuntley.com/ralph/) - Geoffrey Huntley's original Ralph technique: a bash loop that forces incremental work with termination markers.
- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Anthropic's research on initializer agents, progress files, and feedback loops for multi-context-window workflows.
- [Getting Started with Ralph](https://www.aihero.dev/getting-started-with-ralph) - A beginner's guide to using Ralph for AI-powered coding.
- [11 Tips For AI Coding With Ralph Wiggum](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum) - Matt Pocock's practical guide covering HITL vs AFK modes, PRD formats, feedback loops, and alternative loop types.
