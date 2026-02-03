#!/usr/bin/env bash
set -euo pipefail

echo "== Running checks =="

# Adjust these for your project
if [ -f "package.json" ]; then
    if pnpm -v >/dev/null 2>&1; then
        pnpm typecheck
        pnpm test
    else
        npm run typecheck
        npm test
    fi
else
    echo "No package.json found. Edit checks.sh."
    exit 1
fi

echo "== Checks OK =="
