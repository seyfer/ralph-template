# Ralph Template for Codex

This is a pre-configured Ralph harness for [OpenAI Codex CLI](https://github.com/openai/codex).

## Quick Start

**Local Mode (Default):**
```bash
bash ralph-once.sh  # Single iteration
bash ralph.sh 10    # 10 iterations
```

**Sandbox Mode (Recommended):**
```bash
# First-time setup
docker sandbox run codex

# Run with sandbox isolation
AGENT_CMD="docker sandbox run codex" bash ralph.sh 10
```

## Setup

1. **Install Codex CLI**

Using Homebrew:
```bash
brew install --cask codex
```

Or using npm:
```bash
npm install -g @openai/codex
```

2. **Authenticate**
```bash
codex login  # Follow prompts to authenticate
```

3. **Customize your PRD**

Edit `prd.json` with your project features:
```bash
nano prd.json
```

4. **Configure checks**

Edit `checks.sh` to match your project's build/test commands:
```bash
nano checks.sh
```

5. **Run Ralph**
```bash
bash ralph-once.sh  # Test single iteration
bash ralph.sh 25    # Run 25 iterations
```

## CLI Options

The scripts use `--full-auto` mode which is equivalent to:
```bash
codex --sandbox workspace-write -a on-request "prompt"
```

**Key flags:**
- `--full-auto` - Convenience alias for low-friction sandboxed automatic execution
- `-s, --sandbox <MODE>` - Sandbox policy: `read-only`, `workspace-write`, `danger-full-access`
- `-a, --ask-for-approval <POLICY>` - Approval policy: `untrusted`, `on-failure`, `on-request`, `never`
- `-C, --cd <DIR>` - Set working directory
- `-m, --model <MODEL>` - Select model to use

**Approval policies:**
- `untrusted` - Only run trusted commands without asking
- `on-failure` - Run all commands, ask only on failure
- `on-request` - Model decides when to ask (default with `--full-auto`)
- `never` - Never ask for approval

**For fully autonomous mode (use with caution):**
```bash
codex --dangerously-bypass-approvals-and-sandbox "prompt"
```

## Sandbox Mode Benefits

Install [Docker Desktop 4.50+](https://docs.docker.com/desktop/install):

- Isolated execution environment
- Safe for autonomous runs
- Git config auto-injected
- State persists between runs

```bash
AGENT_CMD="docker sandbox run codex" bash ralph.sh 25
```

See [Docker Sandboxes docs](https://docs.docker.com/ai/sandboxes/) for more.

## Files

- `ralph-once.sh` - Single iteration runner
- `ralph.sh` - Multi-iteration loop
- `prd.json` - Product requirements document
- `context.md` - Rolling context summary
- `progress.md` - Append-only progress log
- `init.sh` - Project initialization script
- `checks.sh` - Definition-of-done validation

## How it Works

1. Agent reads PRD and finds highest-priority incomplete feature
2. Implements the feature
3. Runs `checks.sh` to validate
4. Updates PRD and progress log
5. Creates a git commit
6. Repeats until all features pass

When done, outputs: `<promise>COMPLETE</promise>`

## Useful Commands

```bash
# Check version
codex --version

# Show help
codex --help

# Resume previous session
codex resume --last

# Run in a different directory
codex -C /path/to/project "prompt"

# Use specific model
codex -m gpt-4 "prompt"
```

## Learn More

- [Codex CLI GitHub](https://github.com/openai/codex)
- [Ralph technique](https://ghuntley.com/ralph/)
- [Getting Started with Ralph](https://www.aihero.dev/getting-started-with-ralph)
- [11 Tips for Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)
