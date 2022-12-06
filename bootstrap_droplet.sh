#!/bin/bash

function install_nginx {
	apt update
	apt install nginx -y
	ufw allow 'Nginx Full'
}

function install_docker {
	apt install apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	apt-cache policy docker-ce
	apt install docker-ce -y
	systemctl enable docker.service
	systemctl enable containerd.service
}

function clone_repo {
	git clone https://github.com/gthoma17/kindle-dashboard-generator.git /app
}

function build_app {
	cd /app
	FORCE_REBUILD=1 ./makeScreenshot.sh 
}

function main {
	install_nginx
	install_docker
	clone_repo
	build_app

	# Once complete you'll still need to 
	# Setup cron to run the script every minute `crontab -e` `* * * * * bash /app/makeScreenshot.sh /var/www/html <YOUR_DAKBOARD_URL>`
}	

main