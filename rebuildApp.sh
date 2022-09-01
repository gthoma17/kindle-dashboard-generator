#!/bin/bash

pushd python-gcal-agenda-getter/
	python agenda-getter.py
	cp agenda.json ../react-time-weather-agenda-dashboard/src
popd

pushd react-time-weather-agenda-dashboard/
	npm run build
	cp -r build/* ../dashboard-screenshotter/dashboard

pushd dashboard-screenshotter
	docker build -t dash-builder .