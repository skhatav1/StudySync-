#!/usr/bin/env bash
set -euo pipefail

FLUTTER_HOME="/tmp/flutter"
API_BASE_URL="${API_BASE_URL:-https://studysync-api-26bn.onrender.com}"

if [ ! -d "$FLUTTER_HOME" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_HOME"
fi

"$FLUTTER_HOME/bin/flutter" config --enable-web

cd frontend
"$FLUTTER_HOME/bin/flutter" pub get
"$FLUTTER_HOME/bin/flutter" build web --release --dart-define="API_BASE_URL=$API_BASE_URL"
