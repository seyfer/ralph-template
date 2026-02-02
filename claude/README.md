# Ralph Template for Claude Code

This is a pre-configured Ralph harness for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Quick Start

```bash
bash ralph-once.sh  # Single iteration
bash ralph.sh 10    # 10 iterations
```

## Setup

1. **Install Claude Code**

Native binary:
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Or via npm:
```bash
npm i -g @anthropic-ai/claude-code
```

2. **Authenticate**
```bash
claude  # Follow prompts to authenticate
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

## Live Streaming Output

The scripts use these flags for **real-time streaming** output, piped through `jq` for readable text:

```bash
claude --permission-mode acceptEdits -p \
  --verbose \
  --output-format stream-json \
  --include-partial-messages \
  "your prompt" \
  | jq -r 'if .type == "stream_event" and .event.delta.text then .event.delta.text elif .type == "result" then "\n\n[Done: \(.result // "completed")]" else empty end'
```

Key flags:
- `-p` / `--print` - Non-interactive mode (required for scripts)
- `--verbose` - Required for stream-json output
- `--output-format stream-json` - Real-time streaming (vs buffered text)
- `--include-partial-messages` - Show partial chunks as they arrive

The `jq` filter extracts:
- Text deltas from `stream_event` messages (live streaming text)
- Final result from `result` message

**Requires**: `jq` must be installed (`brew install jq` on macOS)

Without these flags, output is buffered until completion.

## Sandbox Mode (Optional)

Install [Docker Desktop 4.50+](https://docs.docker.com/desktop/install) for isolated execution:

```bash
# First-time setup: authenticate in sandbox
docker sandbox run claude

# Run with sandbox (requires ANTHROPIC_API_KEY)
export ANTHROPIC_API_KEY=your_key_here
docker sandbox run -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" claude ...
```

Benefits:
- ✅ Isolated execution environment
- ✅ Safe for autonomous runs
- ✅ Git config auto-injected
- ✅ State persists between runs

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
