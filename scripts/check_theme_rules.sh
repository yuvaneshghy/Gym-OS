#!/usr/bin/env bash
# check_theme_rules.sh — CI check that enforces GymKit theme-system rules.
#
# Inside lib/features/ these are BANNED:
#   Color(0x…)
#   Colors.<name>
#   inline TextStyle(
#   BorderRadius.circular(
#
# Rationale: All styling must come from the global theme system
# (core/theme/, ThemeExtension<AppTokens>, and core/widgets/ App* wrappers).
#
# Usage:
#   bash scripts/check_theme_rules.sh
#   Returns exit code 0 if clean, 1 if violations found.

set -euo pipefail

SEARCH_DIR="lib/features"

if [ ! -d "$SEARCH_DIR" ]; then
  echo "✅ No $SEARCH_DIR directory found — nothing to check."
  exit 0
fi

VIOLATIONS=0

echo "🔍 Checking theme rules in $SEARCH_DIR ..."

# Pattern 1: Color(0x...)
if grep -rn --include='*.dart' 'Color(0x' "$SEARCH_DIR"; then
  echo "❌ Found Color(0x...) literals. Use Theme.of(context).colorScheme or context.tokens instead."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# Pattern 2: Colors.<anything>  (but not "// Colors" in comments — we grep for non-comment usage)
if grep -rn --include='*.dart' -E '^\s*[^/]*Colors\.' "$SEARCH_DIR"; then
  echo "❌ Found Colors.* usage. Use Theme.of(context).colorScheme or context.tokens instead."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# Pattern 3: inline TextStyle(
if grep -rn --include='*.dart' 'TextStyle(' "$SEARCH_DIR"; then
  echo "❌ Found inline TextStyle(). Use Theme.of(context).textTheme instead."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# Pattern 4: BorderRadius.circular(
if grep -rn --include='*.dart' 'BorderRadius\.circular(' "$SEARCH_DIR"; then
  echo "❌ Found BorderRadius.circular(). Use context.tokens radii or theme cardTheme instead."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

if [ "$VIOLATIONS" -gt 0 ]; then
  echo ""
  echo "💥 $VIOLATIONS theme rule violation(s) found in $SEARCH_DIR."
  echo "   Fix: move styling to core/theme/ or core/widgets/, then reference via Theme.of / context.tokens."
  exit 1
fi

echo "✅ All theme rules pass. No violations found."
exit 0
