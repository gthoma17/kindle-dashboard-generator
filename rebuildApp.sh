#!/bin/bash

function updateRepo {
	git pull
}

function updateAgenda {
	pushd python-gcal-agenda-getter/
		pip install -r requirements.txt
		python3 agenda-getter.py
		cp agenda.json ../react-time-weather-agenda-dashboard/src
	popd
}

function updateDashboard {
	pushd react-time-weather-agenda-dashboard/
		npm install
		npm run build
		cp -r build/* ../dashboard-screenshotter/dashboard
	popd
}

function updateDocker {
	pushd dashboard-screenshotter
		docker build -t dash-builder .
	popd
}

function main {
	updateRepo
	updateAgenda
	updateDashboard
	updateDocker
}

main