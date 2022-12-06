#!/bin/bash

set -e

OUTPUT_FOLDER="${1:-$(pwd)}"
DASHBOARD_URL="${1:-https://raw.githubusercontent.com/pascalw/kindle-dash/main/example/example.png}"

APP_FOLDER=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function updateRepo {
	git pull
	echo "$(date)| 👷 got these new commits"
	git --no-pager log --decorate=short --pretty=oneline main@{1}..main|true
}

function rebuildScreenshotter {
	echo "$(date)| 🏗 rebuilding docker container with updated dashboard"
	pushd dashboard-screenshotter
		docker build -t dash-builder .
	popd
}

function updateScreenshot {
	echo "$(date)| 📸 ~~~~~~~~~~~~~~ updating screenshot ~~~~~~~~~~~~~~"
	docker run \
		-v $OUTPUT_FOLDER:/output \
		-e DASHBOARD_URL=$DASHBOARD_URL \
		-t dash-builder
}

function rebuildApp {
	echo "$(date)| 👷‍♂️🚧👷 ~~~~~REBUILDING APP~~~~~ 👷‍♀️🚧👷"
	touch .rebuild-lock

	updateRepo

	rebuildScreenshotter

	updateScreenshot

	rm .rebuild-lock |true
}

function main {
	cd $APP_FOLDER
	if [ -f ".rebuild-lock" ]; then
		echo "$(date)| App is rebuilding, skipping this screenshot..."
	else
		if [ -n "$FORCE_REBUILD" ]; then
			echo "💢 REBUILDING BY FORCE!"
			rebuildApp
		fi
		updateScreenshot
	fi
}	

main
printf "Done @ $(date)--------------------------------------------------------------------------------\n"
