# Kindle dash-builder

To setup:

* Put your built dashboard webapp in /dashboard
* Pull this repo on a droplet
* Build the docker image a first time with `docker build -t dash-builder .`
* Setup nginx????
* Run the container a first time with `docker run -v /nginx/site/I/guess:/output -t dash-builder`
* Setup CRON to run update this repo every day or so
* Setup CRON to run `pull-repo-and-rebuild.sh` every day or so
* Setup CRON `docker run -v /nginx/site/I/guess:/output -t dash-builder` as often as you need the dashboard updated