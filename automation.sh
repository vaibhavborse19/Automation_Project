
myname='vaibhav'
s3_bucket='upgrad-vaibhav'

sudo apt update -y


REQUIRED_PKG="apache2"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt-get --yes install $REQUIRED_PKG 
fi



servstat=$(service apache2 status)

if [[ $servstat == *"active (running)"* ]]; then
	echo "process is running"
else 
	echo "process is not running hence restarting it now"
	sudo service apache2 restart
fi


timestamp=$(date '+%d%m%Y-%H%M%S')
tar -zcvf /tmp/${myname}-httpd-logs-$timestamp.tar /var/log/apache2/*.log 

sudo apt update
sudo apt install awscli
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar


cd  /var/www/html/
if [[ ! -f inventory.html ]]
then
   sudo touch inventory.html
fi

echo -en "Log Type\t\t\t Date Created\t\t\t Type\t\t\t Size<br>" >> /var/www/html/inventory.html
logsize=$(du -h /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1}')
echo -en "apache2-logs\t\t ${timestamp}\t\t tar\t\t ${logsize}\t\t<br>" >> /var/www/html/inventory.html



CRON_FILE="/etc/cron.d/automation"

if [ ! -f $CRON_FILE ]; then
	echo "cron file for automation does not exist, creating.."
	sudo touch $CRON_FILE
	/usr/bin/crontab $CRON_FILE
	/bin/echo "@daily /Automation_Project/automation.sh" >> sudo $CRON_FILE
fi
