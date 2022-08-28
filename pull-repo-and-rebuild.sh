#!/bin/bash

cd /app/kindle-dashboard-generator
git pull
docker build -t dash-builder .