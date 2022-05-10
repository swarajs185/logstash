cat << EOT
=================================================================================================
Hey! This script is trying to install logstash on your EC2 instance! 
Happy Cloud computing!!!
dev:sswraj@
==================================================================================================
EOT
echo -e "INSTALLATION BEGINS NOW \n"
sudo cp logstash.repo /etc/yum.repos.d/
home=.
rm -f GPG-KEY-elasticsearch* #removing the old key files
if [ ! -d "$home/log" ]; then #Creating the log folder for the first time
        mkdir -p log
fi
if [ ! -d "$home/error" ]; then #creating the error folder for the first name
        mkdir -p error
fi
date_log=`date  | cut -d " " -f 4 | sed -e "s/:/_/g"`
logfile=$home/log/logfile_$date_log.log
errorfile=$home/error/errorfile_$date_log.log
#echo $logfile
#echo $errorfile
repository=/etc/yum.repos.d/logstash.repo
echo "Log file: $logfile"
echo -e "Error file: $errorfile \n "
if [ -d "/usr/lib/java" ]; then
        echo -e "[INFO]Java 1.8 is already installed \n"
        sleep 1
else
        echo -e "Installing java 1.8... \n"
        sudo yum install java-1.8.0-openjdk.x86_64 -y > $logfile 2>> $errorfile
        if [ -s $errorfile ]; then
                echo -e "[SUCCESS]Installed successfully \n"
        else
                echo "[ERROR]Installation failed with errors:"
                echo "check the errorfile for more details on $errorfile"
                exit 1
        fi
fi
cat << EOT
=================================================================================================
Please enter which version yoou would like to install!
1. 6.8.3
2. 7.16.3 (As a Service)
==================================================================================================
EOT
read version
case $version in
        1) echo "Installing logstash 6.8 version"
        echo -e "Configuring and Installing Dependencies... \n"
        sudo wget https://artifacts.elastic.co/GPG-KEY-elasticsearch >> $logfile 2>> $errorfile
        sleep 1
        echo "[INFO]Dependencies downloaded!! ...Searching for logstash repo"
        if [ -e $repository ]; then
        echo -e "[INFO]Logstash repository found!!! \n"
        else
        echo -e "[WARN]:LOGSTASH Config file not found ........ Create a logstash.repo under /etc/yum.repos.d/ \n"
        sudo yum install logstash >> $errorfile 2>> $errorfile
        echo "[INFO]check $errorfile for more details"
        exit 1
        fi
        if [ -d "/etc/logstash" ]; then
        echo "[WARN]Logstash is already configured!!!.. Please create pipeline under /etc/logstash/logstash.conf"
        exit 1
        fi
        echo -e "[INFO]Installing Logstash \n "
        sudo yum install logstash -y >> $logfile 2>> $errorfile
        sudo usermod -a -G logstash ec2-user
        echo -e "[INFO]Installing amazon-es plugin \n"
        sudo /usr/share/logstash/bin/logstash-plugin install logstash-output-amazon_es >> $logfile 2>>$errorfile
        echo "[SUCCESS]Installation Complete.. Please create a pipeline on '/etc/logstash/logstash.conf' and run 'sudo /usr/share/logstash/bin/logstash -f /etc/logstash/logstash.conf'"
        ;;
        2) echo "Installing Logstash 7.16.3 vesion with Opensearch plugin"
        echo "Installing the 7.16.3 version for Opensearch"
        sudo rpm -ivh logstash-oss-7.16.3-x86_64.rpm >> $logfile 2>>$errorfile
        echo "Installing the logstash-output-opensearch plugin"
        sudo /usr/share/logstash/bin/logstash-plugin  install --preserve logstash-output-opensearch >>$logfile 2>$errorfile
        echo "Installation Successful"
        ;;
        *) echo default
        echo "Not Found will be updating the script soon"
        ;;
esac