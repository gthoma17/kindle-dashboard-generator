#!/bin/bash

if [ -f ".rebuild-lock" ]; then
    echo "App is rebuilding, skipping this screenshot..."
else
    docker run -v /varr/www/html:/output -t dash-builder
fi
