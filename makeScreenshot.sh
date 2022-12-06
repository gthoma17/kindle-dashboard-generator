#!/bin/bash

set -e

OUTPUT_FOLDER="${1:-$(pwd)}"
DASHBOARD_URL="${1:-https://raw.githubusercontent.com/pascalw/kindle-dash/main/example/example.png}"

APP_FOLDER=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


function updateScreenshot {
	echo "$(date)| 📸 ~~~~~~~~~~~~~~ updating screenshot ~~~~~~~~~~~~~~"
	docker run -i --init --cap-add=SYS_ADMIN \
		-e SCREENSHOT_URL=$DASHBOARD_URL \
		-v $OUTPUT_FOLDER:/output \
		-v dashboard-screenshotter:/script \
		--rm ghcr.io/puppeteer/puppeteer:latest \
		sh -c 'node -e /script/screenshot.js && cp dash.png /output'
}

function main {
	cd $APP_FOLDER
	updateScreenshot
}	

main
printf "Done @ $(date)--------------------------------------------------------------------------------\n"
