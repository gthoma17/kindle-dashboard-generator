#!/bin/bash

pushd python-gcal-agenda-getter/
	pip install -r requirements.txt
	python3 agenda-getter.py
	cp agenda.json ../react-time-weather-agenda-dashboard/src
popd

pushd react-time-weather-agenda-dashboard/
	npm install
	npm run build
	cp -r build/* ../dashboard-screenshotter/dashboard
popd

pushd dashboard-screenshotter
	docker build -t dash-builder .