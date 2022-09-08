# SETUP

* This assumes you have a droplet running Ubuntu 22


## install dependancies
* Install nginx	and pip
	* `sudo apt update`
	* `sudo apt install nginx python3-pip`
* Allow nginx through the firewall
	* `sudo ufw allow 'Nginx Full'`
* Install Docker (abridged from https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)
	* `sudo apt install apt-transport-https ca-certificates curl software-properties-common`
	* `curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`
	* `sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"`
	* `apt-cache policy docker-ce`
	* `sudo apt install docker-ce`
	* `sudo systemctl enable docker.service`
	* `sudo systemctl enable containerd.service`
* Clone this repo
	* `git clone https://github.com/gthoma17/kindle-dashboard-generator.git /app`
* Create Google credentials
	* Run `./makeScreenshot.sh` script once locally to create the files (Google will prompt for permission in a web browser)
	* Copy the files up to the droplet `scp python-gcal-agenda-getter/*.json root@143.198.149.83:/app/python-gcal-agenda-getter`
* Setup cron to run the script every minute `echo "* * * * * /app/makeScreenshot.sh /var/www/html" | tee -a /var/spool/cron/root`
