
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
