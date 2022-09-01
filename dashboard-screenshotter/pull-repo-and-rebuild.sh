#!/bin/bash

cd /app
git pull
docker build -t dash-builder .