#!/bin/bash

# Cyberzilla Weather System Update Installer
set -e

echo "🔧 Installing Cyberzilla Weather System Updates..."

# Check dependencies
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed. Please install Go first."
    exit 1
fi

# Run the hotfix script
if [[ -f "hot_fix.sh" ]]; then
    ./hot_fix.sh
else
    echo "❌ hot_fix.sh not found. Please ensure you're in the project root."
    exit 1
fi

echo ""
echo "✅ Update installation complete!"
echo "🌐 Start the server: ./weather-app"
echo "📚 Documentation: cat HOTFIX_README.md"
