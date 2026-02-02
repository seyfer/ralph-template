# Ralph Template for Codex

This is a pre-configured Ralph harness for [OpenAI Codex](https://openai.com/codex/).

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
codex auth  # Follow prompts to authenticate
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

## Sandbox Mode Benefits

Install [Docker Desktop 4.50+](https://docs.docker.com/desktop/install):

- ✅ Isolated execution environment
- ✅ Safe for autonomous runs
- ✅ Git config auto-injected
- ✅ State persists between runs

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

## Learn More

- [Ralph technique](https://ghuntley.com/ralph/)
- [Getting Started with Ralph](https://www.aihero.dev/getting-started-with-ralph)
- [11 Tips for Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)
