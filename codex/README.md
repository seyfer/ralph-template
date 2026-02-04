# Ralph Template for Codex

This is a pre-configured Ralph harness for [OpenAI Codex CLI](https://github.com/openai/codex).

## Quick Start

Run these commands from the `codex/` directory.

**Local Mode (Default):**
```bash
bash ralph-once.sh  # Single iteration
bash ralph.sh 10    # 10 iterations
```

**Sandbox Mode (Recommended):**
```bash
# Start a sandbox shell
docker sandbox run codex

# In the sandbox shell, from this directory:
bash ralph.sh 10
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

The scripts use `codex exec` with full access sandbox for non-interactive execution:

```bash
codex exec -m gpt-5.2-codex --sandbox danger-full-access "prompt"
```

### Why `danger-full-access`?

The default `--full-auto` (which uses `--sandbox workspace-write`) blocks writes to `.git`, preventing automated commits. Using `danger-full-access` allows:
- Git commits within the automation loop
- Full file system access for the agent
- Complete autonomous operation

### Interactive vs Non-Interactive Mode

**Interactive mode** (default `codex` command):
- Requires a terminal (TTY) connection
- Best for human-in-the-loop workflows
- Will fail with "stdout is not a terminal" if piped

**Non-interactive mode** (`codex exec`):
- Designed for scripts and automation
- Works with pipes and output capture
- Ideal for Ralph harness loops
- Does not require TTY

**Key flags for `codex exec`:**
- `-m, --model <MODEL>` - Select model to use
- `-s, --sandbox <MODE>` - Sandbox policy: `read-only`, `workspace-write`, `danger-full-access`
- `-C, --cd <DIR>` - Set working directory

**Key flags for interactive `codex` only:**
- `-a, --ask-for-approval <POLICY>` - Approval policy (not available in `exec`)
- `--full-auto` - Convenience alias for `--sandbox workspace-write -a on-request`

**Sandbox modes:**
- `read-only` - No file writes allowed
- `workspace-write` - Writes only in current directory (blocks `.git`)
- `danger-full-access` - Full file system access (allows git commits)
- `never` - Never ask for approval

## Sandbox Mode Benefits

Install [Docker Desktop 4.50+](https://docs.docker.com/desktop/install):

- Isolated execution environment
- Safe for autonomous runs
- Git config auto-injected
- State persists between runs

```bash
docker sandbox run codex
# In the sandbox shell, from this directory:
bash ralph.sh 25
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

## Working Directory

**Always run from the `codex/` directory:**
```bash
cd codex
bash ralph.sh 20
```

This ensures the local `prd.json`, `context.md`, and scripts are referenced correctly.

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
codex exec --help  # Non-interactive mode help

# Resume previous session
codex resume --last

# Run in a different directory
codex -C /path/to/project "prompt"

# Use specific model
codex exec -m gpt-5.2-codex --sandbox danger-full-access "prompt"

# Non-interactive with restricted sandbox (no git commits)
codex exec --full-auto "prompt"
```

## Learn More

- [Codex CLI GitHub](https://github.com/openai/codex)
- [Ralph technique](https://ghuntley.com/ralph/)
- [Getting Started with Ralph](https://www.aihero.dev/getting-started-with-ralph)
- [11 Tips for Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)
