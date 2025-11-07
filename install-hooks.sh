#!/bin/bash
# Install Git hooks to prevent common mistakes

echo "📦 Installing Git hooks..."

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy pre-commit hook
cp .githooks/pre-commit .git/hooks/pre-commit

# Make executable
chmod +x .git/hooks/pre-commit

echo "✅ Git hooks installed successfully!"
echo ""
echo "The following checks will run before each commit:"
echo "  - New screen detection"
echo "  - SCREEN_INVENTORY.md update verification"
echo "  - Duplicate route detection"
echo ""
echo "To bypass hooks (NOT recommended):"
echo "  git commit --no-verify"
