#!/bin/bash

MAX_AGENDA_AGE='12 hours'
OUTPUT_FOLDER='/Users/greg/Downloads/kindle-dashboard-project/dashboard-maker'

function updateRepo {
	git pull
	echo "👷 got these new commits"
	git --no-pager log --decorate=short --pretty=oneline main@{1}..main
}

function updateAgenda {
	echo "👷‍♀️ getting a new agenda"
	pushd python-gcal-agenda-getter/
		pip install -r requirements.txt
		python3 agenda-getter.py
		cp agenda.json ../react-time-weather-agenda-dashboard/src
	popd
}

function updateDashboard {
	echo "👷‍♂️ rebuilding the dashboard with the new agenda"
	pushd react-time-weather-agenda-dashboard/
		npm install
		npm run build
		cp -r public/* ../dashboard-screenshotter/dashboard
	popd
}

function updateDocker {
	echo "🏗 rebuilding docker container with updated dashboard"
	pushd dashboard-screenshotter
		docker build -t dash-builder .
	popd
}

function rebuildApp {
	echo "👷‍♂️🚧👷 ~~~~~REBUILDING APP~~~~~ 👷‍♀️🚧👷"
	touch .rebuild-lock
	updateRepo
	updateAgenda
	updateDashboard
	updateDocker
	rm .rebuild-lock
}

function refreshAgenda {
	echo "👷‍♂️📅 ~~~~~REFRESHING AGENDA~~~~~ 🗓👷"
	touch .rebuild-lock
	updateAgenda
	updateDashboard
	updateDocker
	rm .rebuild-lock
}

function updateScreenshot {
	echo "📸 updating screenshot ~~~~~~~~~~~~~~"
	docker run -v $OUTPUT_FOLDER:/output -t dash-builder
}


function main {
	if [ -f ".rebuild-lock" ]; then
		echo "App is rebuilding, skipping this screenshot..."
	else
		localIsBehind=0
		agendaAge=$(date -r "react-time-weather-agenda-dashboard/src/agenda.json" +%s)
		git remote update && git status -uno | grep -q 'Your branch is behind' && localIsBehind=1
		
		if [ $localIsBehind = 1 ]; then
			rebuildApp

		elif (( agendaAge <= $(gdate -d "now + $MAX_AGENDA_AGE" +%s) )); then
			refreshAgenda

		fi

		updateScreenshot
	fi
}

main
