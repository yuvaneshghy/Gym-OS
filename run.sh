#!/bin/bash
set -e

# Default modes
REBUILD=false
HOT_RELOAD=false
PURE_PB=false

# Parse arguments
for arg in "$@"; do
  case $arg in
    -h|--help)
      echo "GymKit Local Environment Runner"
      echo ""
      echo "Usage: ./run.sh [options]"
      echo ""
      echo "Options:"
      echo "  -h, --help    Show this help message"
      echo "  --web         Run Flutter with hot-reload and PocketBase in background"
      echo "  --pb          Run pure PocketBase only (Press 'r' or 'R' to restart it interactively)"
      echo "  --rebuild     Rebuild the Flutter static web bundle and serve with PocketBase"
      exit 0
      ;;
    --rebuild)
      REBUILD=true
      shift
      ;;
    --web)
      HOT_RELOAD=true
      shift
      ;;
    --pb)
      PURE_PB=true
      shift
      ;;
  esac
done

if [ "$PURE_PB" = true ]; then
  echo "🚀 Starting PocketBase (Pure Backend Mode)..."
  
  start_pb() {
    cd pb
    ./pocketbase serve &
    PB_PID=$!
    cd ..
  }
  
  start_pb
  trap 'echo -e "\n🛑 Stopping PocketBase..."; kill $PB_PID 2>/dev/null || true; exit' SIGINT SIGTERM EXIT
  
  echo ""
  echo "✅ PocketBase is live at: http://127.0.0.1:8090"
  echo "👉 Dashboard: http://127.0.0.1:8090/_/"
  echo "------------------------------------------------"
  echo "🔄 Press 'r' or 'R' to restart PocketBase."
  echo "🛑 Press Ctrl+C or 'q' to stop the server."
  echo "------------------------------------------------"
  
  while true; do
    read -r -s -n 1 key
    if [[ $key == "r" ]] || [[ $key == "R" ]]; then
      echo -e "\n🔄 Restarting PocketBase..."
      kill $PB_PID 2>/dev/null || true
      wait $PB_PID 2>/dev/null || true
      start_pb
      echo "✅ PocketBase restarted!"
    elif [[ $key == "q" ]] || [[ $key == "Q" ]]; then
      echo -e "\n🛑 Quitting..."
      kill $PB_PID 2>/dev/null || true
      exit 0
    fi
  done
fi

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
