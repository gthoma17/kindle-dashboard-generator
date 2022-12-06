#!/bin/bash



cd /app

SCREENSHOT_URL="${DASHBOARD_URL:-https://raw.githubusercontent.com/pascalw/kindle-dash/main/example/example.png}" node screenshot.js

cp screenshot.png /output.dash.png