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
		cp -r public/* ../dashboard-screenshotter/dashboard
	popd
}

function updateDocker {
	pushd dashboard-screenshotter
		docker build -t dash-builder .
	popd
}

function main {
	localIsBehind=0
	git remote update && git status -uno | grep -q 'Your branch is behind' && localIsBehind=1
	if [ $localIsBehind = 1 ]; then
		touch .rebuild-lock
		updateRepo
		updateAgenda
		updateDashboard
		updateDocker
		rm .rebuild-lock
	fi
}

main