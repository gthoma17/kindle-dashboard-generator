#!/bin/bash

cd /app/dashboard
python3 -m http.server &

cd /app
node screenshot.js

cp dash.png /output