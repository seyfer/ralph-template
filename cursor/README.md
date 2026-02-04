# Ralph Template for Cursor Agent

This is a pre-configured Ralph harness for [Cursor's CLI agent](https://cursor.com/docs/cli/overview).

## ⚠️ Important Limitations

**Cursor Agent runs in INTERACTIVE MODE ONLY**
- Only `ralph-once.sh` works (single iteration at a time)
- `ralph.sh` (multi-iteration loop) **does not work** - agent stops after each task waiting for follow-up
- For fully automated loops, use Claude Code or Codex with Docker Sandbox instead

## Quick Start

Run these commands from the `cursor/` directory.

```bash
# Set your API key (required!)
export CURSOR_API_KEY=your_api_key_here

# Run single iteration
bash ralph-once.sh
```

## Setup

1. **Install Cursor CLI**

```bash
curl https://cursor.com/install -fsS | bash
```

2. **Get API Key**

Get your API key from: https://cursor.com/dashboard?tab=background-agents

3. **Set Environment Variable**

```bash
export CURSOR_API_KEY=your_api_key_here
```

Add to your `~/.zshrc` or `~/.bashrc` for persistence:
```bash
echo 'export CURSOR_API_KEY=your_api_key_here' >> ~/.zshrc
source ~/.zshrc
```

4. **Customize your PRD**

Edit `prd.json` with your project features:
```bash
nano prd.json
```

5. **Configure checks**

Edit `checks.sh` to match your project's build/test commands:
```bash
nano checks.sh
```

6. **Run Ralph (single iteration only)**

```bash
bash ralph-once.sh
```

## Known Issues

❌ **Multi-iteration loop doesn't work** - Agent enters interactive mode and waits for follow-up after each task

❌ **No Docker Sandbox support** - Cursor agent only runs in local mode

❌ **Cannot use `-p/--print` flag** - Causes CLI to hang indefinitely

✅ **Use `--force` flag** - Allows file modifications without confirmation

## Files

- `ralph-once.sh` - Single iteration runner (the only script that works with Cursor)
- `prd.json` - Product requirements document
- `context.md` - Rolling context summary
- `progress.md` - Append-only progress log
- `init.sh` - Project initialization script
- `checks.sh` - Definition-of-done validation

**Note:** `ralph.sh` (multi-iteration loop) is not included because Cursor's interactive mode makes it unusable.

## How it Works

1. Agent reads PRD and finds highest-priority incomplete feature
2. Implements the feature
3. Runs `checks.sh` to validate
4. Updates PRD and progress log
5. Creates a git commit
6. **Stops and waits for next manual run**

Script verifies PRD completion by checking `prd.json` with `jq`

## Recommended Workflow

Since Cursor doesn't support automated loops:

1. Run `bash ralph-once.sh`
2. Review the changes
3. Run again when ready: `bash ralph-once.sh`
4. Repeat until PRD is complete (script will tell you when done)

**Requires**: `jq` for PRD completion verification (`brew install jq`)

**For true autonomous operation, use Claude Code or Codex with Docker Sandbox.**

## Learn More

- [Cursor CLI Documentation](https://cursor.com/docs/cli/overview)
- [Ralph technique](https://ghuntley.com/ralph/)
- [Getting Started with Ralph](https://www.aihero.dev/getting-started-with-ralph)
- [11 Tips for Ralph](https://www.aihero.dev/tips-for-ai-coding-with-ralph-wiggum)
