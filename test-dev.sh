cat << EOT
=================================================================================================
Hey! This script is trying to install logstash on your EC2 instance! 
Happy Cloud computing!!!
dev:sswraj@
==================================================================================================
EOT
echo -e "INSTALLATION BEGINS NOW \n"
sudo cp logstash.repo /etc/yum.repos.d/
home=~/logstash-installer/logs
rm -f GPG-KEY-elasticsearch* #removing the old key files
if [ ! -d "$home/applog" ]; then #Creating the log folder for the first time
        mkdir -p $home/applog
fi
if [ ! -d "$home/apperror" ]; then #creating the error folder for the first name
        mkdir -p $home/apperror
fi
date_log=`date  | cut -d " " -f 4 | sed -e "s/:/_/g"`
logfile=$home/applog/logfile_$date_log.log
errorfile=$home/apperror/errorfile_$date_log.log
#echo $logfile
#echo $errorfile
repository=/etc/yum.repos.d/logstash.repo
echo "Log file: $logfile"
echo -e "Error file: $errorfile \n "

installingjava(){
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
}
installingjava

installingsixversion(){
    checkversion
    ret=$?
    if [ $ret = "1" ] 
    then
        echo "Installing logstash 6.8 version"
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
        echo -e "[INFO]Installing Logstash \n "
        sudo yum install logstash -y >> $logfile 2>> $errorfile
        sudo usermod -a -G logstash ec2-user
        echo -e "[INFO]Installing amazon-es plugin \n"
        sudo /usr/share/logstash/bin/logstash-plugin install logstash-output-amazon_es >>$logfile 2>>$errorfile
        echo "[SUCCESS]Installation Complete.. Please create a pipeline on '/etc/logstash/logstash.conf' and run 'sudo /usr/share/logstash/bin/logstash -f /etc/logstash/logstash.conf'"
        exit 1
    else
        echo " Logstash already configured.. current version installed : $ret"
        exit 1
    fi
}

installingsevenversion(){
    echo "Trying to install 7.16.3"
    echo "Checking the previous versions on the EC2 instance"
    checkversion
    ret=$?
    if [ $ret = "7.16.3"] 
    then
        echo "You are already having the latest version: $ret"
        exit 1
    elif [ $ret = "6.8.23"]
    then
        echo "Current version: $ret"
        echo -e "Would you like to upgrade to 7.16.3? [yes/no] \n"
        read option
        if [ $option = "yes" ] 
        then
        echo "Deleting old version"
        sudo yum remove logstash -y >>$logfile 2>>$errorfile
        sudo rm -rf /etc/logstash
        sudo rm -rf /usr/share/logstash
        echo "Deletion of 6.8.3 completed, installing the new one"
        echo "Installing the 7.16.3 version..."
        sudo wget https://artifacts.elastic.co/downloads/logstash/logstash-oss-7.16.3-x86_64.rpm >>$logfile 2>>$errorfile
        sudo rpm -ivh logstash-oss-7.16.3-x86_64.rpm >>$logfile 2>>$errorfile
        echo "Installing the logstash-output-opensearch plugin"
        sudo /usr/share/logstash/bin/logstash-plugin  install --preserve logstash-output-opensearch >>$logfile 2>>$errorfile
        echo "Installation Successful"
        else
        echo "No action required from the script.. exiting.."
        exit 1
        fi
    else
        echo "No Previous Version found.. Installing the 7.16.3"
        sudo wget https://artifacts.elastic.co/downloads/logstash/logstash-oss-7.16.3-x86_64.rpm >>$logfile 2>>$errorfile
        sudo rpm -ivh logstash-oss-7.16.3-x86_64.rpm >>$logfile 2>>$errorfile
        echo "Installing the logstash-output-opensearch plugin"
        sudo /usr/share/logstash/bin/logstash-plugin  install --preserve logstash-output-opensearch >>$logfile 2>>$errorfile
        echo "Installation Successful"
    fi
}

checkversion(){
    if [ -d /usr/share/logstash/bin ] then
    echo "[WARN]Logstash is already configured!!!.. Checking the version \n"
    sleep 1
    if [ `/usr/share/logstash/bin/logstash --version | cut -d " " -f 2 | sed -n '2p'` = "7.16.3" ]
    then
        return 7.16.3
    fi
    if [ `/usr/share/logstash/bin/logstash --version | cut -d " " -f 2` = "6.8.23" ] 
    then
        return 6.8.23
    fi
    else
        return 1
    fi
}

uninstalllogstash(){
    checkversion
    ret=$?
    if [ $ret = "6.8.23" ] 
    then
    echo "Uninstalling 6.8.23"
    sudo yum remove logstash -y
    echo "cleaning up.."
    sudo rm -rf /etc/logstash
    sudo rm -rf /usr/share/logstash
    elif [ $ret = "7.16.3" ]  
    then
    echo "Uninstalling $ret"
    sudo rpm -e logstash-oss-7.16.3-1.x86_64
    echo "cleaning up.."
    sudo rm -rf /etc/logstash
    sudo rm -rf /usr/share/logstash   
    else
    echo "Nothing to Uninstall.."   
    fi
}


cat << EOT
=================================================================================================
Please enter which version yoou would like to install!
1. 6.8.3
2. 7.16.3 (As a Service)
3. Uninstall Logstash
==================================================================================================
EOT
read version

case $version in
        1) installingsixversion;;
        2) installingsevenversion;;
        3) uninstalllogstash;;
        *) echo default
        echo "Not Found will be updating the script soon..."
        ;;
esac