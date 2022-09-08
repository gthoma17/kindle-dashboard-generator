#!/bin/bash

set -e

OUTPUT_FOLDER="${1:-$(pwd)}"
MAX_AGENDA_AGE="${2:-12 hours}"

APP_FOLDER=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function updateRepo {
	git pull
	echo "$(date)| 👷 got these new commits"
	git --no-pager log --decorate=short --pretty=oneline main@{1}..main|true
}

function updateAgenda {
	echo "$(date)| 👷‍♀️ getting a new agenda"
	pushd python-gcal-agenda-getter/
		pip install -q -r requirements.txt
		python3 agenda-getter.py
		cp agenda.json ../react-time-weather-agenda-dashboard/src
	popd
}

function rebuildDashboard {
	echo "$(date)| 👷‍♂️ rebuilding the dashboard with the new agenda"
	pushd react-time-weather-agenda-dashboard/
		docker build -t react-time-weather-agenda-dashboard .
		docker run \
			-v $APP_FOLDER/dashboard-screenshotter/dashboard:/app/build \
			-v $APP_FOLDER/python-gcal-agenda-getter/:/app/src/agenda \
			-t react-time-weather-agenda-dashboard
	popd
}

function rebuildScreenshotter {
	echo "$(date)| 🏗 rebuilding docker container with updated dashboard"
	pushd dashboard-screenshotter
		docker build -t dash-builder .
	popd
}

function rebuildApp {
	echo "$(date)| 👷‍♂️🚧👷 ~~~~~REBUILDING APP~~~~~ 👷‍♀️🚧👷"
	touch .rebuild-lock
	updateRepo
	updateAgenda
	rebuildDashboard
	rebuildScreenshotter
	rm .rebuild-lock
}

function refreshAgenda {
	echo "$(date)| 👷‍♂️📅 ~~~~~REFRESHING AGENDA~~~~~ 🗓👷"
	touch .rebuild-lock
	updateAgenda
	rebuildDashboard
	rebuildScreenshotter
	rm .rebuild-lock
}

function updateScreenshot {
	echo "$(date)| 📸 ~~~~~~~~~~~~~~ updating screenshot ~~~~~~~~~~~~~~"
	docker run -v $OUTPUT_FOLDER:/output -t dash-builder
}

function main {

	if command -v gdate &> /dev/null # the date util on OSX isn't GNU date, which is what we needd
	then
		shopt -s expand_aliases
		alias date=gdate
	fi

	cd $APP_FOLDER
	if [ -f ".rebuild-lock" ]; then
		echo "$(date)| App is rebuilding, skipping this screenshot..."
	else
		localIsBehind=0
		agendaAge=$(date -r "python-gcal-agenda-getter/agenda.json" +%s)
		git remote update && git status -uno | grep -q 'Your branch is behind' && localIsBehind=1
		
		if [ $localIsBehind = 1 ]; then
			rebuildApp

		elif [ -n "$FORCE_REBUILD" ]; then
			echo "💢 REBUILDING BY FORCE!"
			rebuildApp

		elif (( agendaAge <= $(date -d "now - $MAX_AGENDA_AGE" +%s) )); then
			refreshAgenda

		fi

		updateScreenshot
	fi
}

main
