#!/bin/bash
set -e

# Default modes
REBUILD=false
HOT_RELOAD=false

# Parse arguments
for arg in "$@"; do
  case $arg in
    --rebuild)
      REBUILD=true
      shift
      ;;
    --web)
      HOT_RELOAD=true
      shift
      ;;
  esac
done

echo "🚀 Starting GymKit local environment..."

if [ "$HOT_RELOAD" = true ]; then
  echo "📦 Starting PocketBase in background..."
  cd pb
  ./pocketbase serve &
  PB_PID=$!
  cd ..
  
  # Kill PB automatically when script exits (e.g. user quits flutter run)
  trap 'echo -e "\n🛑 Stopping PocketBase..."; kill $PB_PID 2>/dev/null || true; exit' SIGINT SIGTERM EXIT
  
  sleep 1
  echo "🌐 Starting Flutter in Hot Reload mode (Chrome)..."
  flutter run -d chrome
else
  # Static build mode (default or --rebuild)
  if [ "$REBUILD" = true ] || [ ! -d "build/web" ]; then
    echo "🏗️ Building Flutter web application..."
    flutter build web
  else
    echo "⚡ Using existing Flutter web build in build/web/ (Use --rebuild to generate a new one)"
  fi

  echo "📦 Starting PocketBase to serve backend AND frontend..."
  cd pb
  
  trap 'echo -e "\n🛑 Stopping PocketBase..."; kill $PB_PID 2>/dev/null || true; exit' SIGINT SIGTERM EXIT
  
  # PocketBase natively serves the static Flutter web build alongside its API
  ./pocketbase serve --publicDir=../build/web &
  PB_PID=$!
  cd ..
  
  echo "✅ GymKit is live!"
  echo "👉 Open your browser at: http://127.0.0.1:8090"
  echo "Press Ctrl+C to stop the server."
  
  # Hold the script alive to keep PB running
  wait $PB_PID
fi
