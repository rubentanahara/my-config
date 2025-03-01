#!/bin/bash

# Script to fix CocoaPods installation issues
echo "🔍 Checking CocoaPods installation..."

# Check if CocoaPods is installed
if which pod >/dev/null; then
  CURRENT_POD_VERSION=$(pod --version)
  echo "✓ CocoaPods is installed (version $CURRENT_POD_VERSION)"
else
  echo "✗ CocoaPods is not installed"
fi

# Check Ruby version
RUBY_VERSION=$(ruby -v | awk '{print $2}')
echo "ℹ️ Ruby version: $RUBY_VERSION"

# Check where pod is installed
if which pod >/dev/null; then
  POD_PATH=$(which pod)
  echo "ℹ️ CocoaPods path: $POD_PATH"
fi

echo "🔄 Reinstalling CocoaPods using Homebrew..."
brew uninstall cocoapods --force 2>/dev/null
brew install cocoapods

# Verify installation
if which pod >/dev/null; then
  NEW_POD_VERSION=$(pod --version)
  echo "✅ CocoaPods reinstalled successfully (version $NEW_POD_VERSION)"
  echo "🔍 New CocoaPods path: $(which pod)"
else
  echo "❌ CocoaPods installation failed"
  exit 1
fi

echo ""
echo "🚀 CocoaPods should now be working correctly!"
echo "If you still encounter issues, try the following:"
echo "1. Run 'pod repo update' to update your CocoaPods repository"
echo "2. In your iOS project directory, run 'pod deintegrate' followed by 'pod install'"
echo "3. Make sure your Podfile is correctly configured"
echo ""
