#!/usr/bin/env bash
set -euo pipefail

echo "== Project init =="
echo "Node version: $(node -v 2>/dev/null || echo 'missing')"
echo "PNPM: $(pnpm -v 2>/dev/null || echo 'missing')"
echo

# Install deps if needed (adjust to your repo)
if [ -f "pnpm-lock.yaml" ]; then
	echo "Installing deps with pnpm..."
	pnpm install
elif [ -f "package-lock.json" ]; then
	echo "Installing deps with npm..."
	npm ci
else
	echo "No lockfile found. Adjust init.sh."
fi

echo
echo "Init complete."
echo "To run checks: bash plans/checks.sh"
