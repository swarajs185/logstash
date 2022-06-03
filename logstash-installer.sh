cat << EOT
=================================================================================================
EOT
sudo cp logstash.repo /etc/yum.repos.d/
home=~/logstash-installer/logs
rm -f GPG-KEY-elasticsearch* #removing the old key files

installingjava(){
    if [ -d "/usr/lib/java-1.8.0" ]; then
        echo -e "Java binaries are installing.. In case java is already installed. process will be ignored"
        sudo yum install java-1.8.0-openjdk.x86_64 -y 
        sleep 1
else
        echo -e "Installing java 1.8... \n"
        sudo yum install java-1.8.0-openjdk.x86_64 -y 
        if [ -s $errorfile ]; then
                echo -e "Installed successfully \n"
        else
                echo "Installation failed with errors:"
                echo "check the errorfile for more details on errors"
                exit 1
        fi
fi
}

checkversion(){
    if [ -d /usr/share/logstash/bin ] 
    then
    if [ "`/usr/share/logstash/bin/logstash --version | cut -d " " -f 2 | sed -n '2p'`" = "7.16.3" ]
    then
        return 3

    elif [ "`/usr/share/logstash/bin/logstash --version | cut -d " " -f 2`" = "6.8.23" ] 
    then
        return 2
    fi

    else
        return 1
    fi
}


installingsixversion(){
    checkversion
    ret=$?
    if [ $ret = 1 ] 
    then
        echo "Installing logstash 6.8 version"
        echo -e "Configuring and Installing Dependencies... \n"
        sudo wget https://artifacts.elastic.co/GPG-KEY-elasticsearch 
        sleep 1
        echo "Dependencies downloaded!! ...Searching for logstash repo"
        if [ -e $repository ]; then
        echo -e "Logstash repository found!!! \n"
        else
        echo -e "LOGSTASH Config file not found ........ Create a logstash.repo under /etc/yum.repos.d/ \n"
        sudo yum install logstash 
        echo "check errors for more details"
        exit 1
        fi
        echo -e "Installing Logstash \n "
        sudo yum install logstash -y 
        sudo usermod -a -G logstash ec2-user
        echo -e "Installing amazon-es plugin \n"
        sudo /usr/share/logstash/bin/logstash-plugin install logstash-output-amazon_es 
        echo "Installation Complete...'"
        exit 1
    else
       if [ $ret = 2 ] 
       then
           echo "You already have 6.8.23 version installed..."
        else
           echo "You already have latest version 7.16.3 version installed..."
       fi
    fi
}

installingsevenversion(){
    echo "Trying to install 7.16.3..."
    echo "Checking the previous versions on the EC2 instance..."
    checkversion
    ret=$?
    if [ $ret = 3 ] 
    then
        echo "You are already having the latest version: 7.16.3"
        exit 1
    elif [ $ret = 2 ]
    then
        echo "Current version: 6.8.23"
        echo "Would you like to upgrade to 7.16.3? [yes/no]:"
        read option
        if [ $option = "yes" ] 
        then
        upgradetoseven
        else
        echo "No action required"
        fi
    else
       echo "No Previous versions Found!!!"
       sevenversioninstall
    fi
}

upgradetoseven(){
    echo "Deleting old version"
    sudo yum remove logstash -y 
    sudo rm -rf /etc/logstash
    sudo rm -rf /usr/share/logstash
    echo "Deletion of 6.8.3 completed, installing the new one"
    sevenversioninstall
}

sevenversioninstall(){
    echo "Installing the 7.16.3 version..."
    if [ ! -e ./logstash-oss-7.16.3-x86_64.rpm ] 
    then
    echo "Installing Artifacts"
    sudo wget https://artifacts.elastic.co/downloads/logstash/logstash-oss-7.16.3-x86_64.rpm 
    fi
    echo "installing binaries"
    sudo rpm -ivh logstash-oss-7.16.3-x86_64.rpm 
    echo "Installing the logstash-output-opensearch plugin"
    sudo /usr/share/logstash/bin/logstash-plugin  install --preserve logstash-output-opensearch 
    echo "Installed the plugin" 
}


outversion(){
    checkversion
    ret=$?
    if [ $ret = 3 ] 
    then
        echo "Current Version: 7.16.3"
    elif [ $ret = 2 ]
    then
        echo "Current Version: 6.8.23"
    else
        echo "Logstash Not Installed"
    fi
}


uninstalllogstash(){
    checkversion
    ret=$?
    if [ $ret = 2 ] 
    then
    echo "Uninstalling 6.8.23"
    sudo yum remove logstash -y 
    echo "cleaning up.."
    sudo rm -rf /etc/logstash
    sudo rm -rf /usr/share/logstash
    checkversion
    ret=$?
    if [ $ret = 1 ]
    then
    echo "Uninstallation complete.."    
    fi
    elif [ $ret = 3 ]  
    then
    echo "Uninstalling 7.16.3"
    sudo rpm -e logstash-oss-7.16.3-1.x86_64 
    echo "cleaning up.."
    sudo rm -rf /etc/logstash
    sudo rm -rf /usr/share/logstash
    checkversion
    ret=$?
    if [ $ret = 1 ] 
    then
    echo "Uninstallation Complete..."
    fi
    else
    echo "Nothing to Uninstall.."   
    fi
}

copyconffile(){
    checkversion
    ret=$?
    if [ $ret = 1 ]
    then
    echo "no version detected.. exiting.."
    exit 1
    fi
    if [ $ret = 3 ] 
    then
    echo "Detected version 7.16.3.. Copying the file to /etc/logstash/conf.d/logstash.conf" 
    sudo cp ./logstash.conf /etc/logstash/conf.d/logstash.conf
    echo "Starting the Logstash service"
    sudo systemctl start logstash 
    echo "Started the logstash service, Please check the log at /var/log/logstash/logstash-plain.log"
    fi
    if [ $ret = 2 ] 
    then
    echo "Detected version 6.8.. Copying the file to /etc/logstash/conf.d/logstash.conf"
    sudo cp ./logstash.conf /etc/logstash/conf.d/logstash.conf
    echo "Starting the Logstash service..."
    sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/logstash.conf
    fi
}
if [[ $# -eq 0 ]]; then
    echo "Script is expecting the input.. Please run ./logstash-installer.sh --helpme for more details"
    exit 1
fi

#######################################Help me Window#######################################################
helpme(){
cat << EOT

This script is to install logstash for Amazon Linux EC2 server

Please run ./logstash-installer.sh --install for installing the logstash version

please run ./logstash-installer.sh --operations to perform the operations

Please run ./logstash-installer.sh --check-version to check the current version installed in EC2 instance

Versions available to install using the script
=================================================================================================
1. 6.8.23
2. 7.16.3 (As a Service)
==================================================================================================

Operations available after installing the logstash:
==================================================================================================
1. Uninstall Logstash
2. Check Logstash Version
3. Start Logstash service
4. Stop the logstash service (Applicable for 7.16.3 version)
5. Restart the logstash service  (Applicable for 7.16.3 version)
==================================================================================================
EOT
exit 1   
}
#################################Installation##########################################################
install(){
checkversion
ret=$?

if [ $ret = 1 ] 
then
cat << EOT
Please select the version you would like to install

1. 6.8.23
2. 7.16.3 (As a Service)
==================================================================================================
EOT
echo "Please enter your choice [1/2]: "
read version

case $version in
    1) installingjava
    installingsixversion
    ;;
    2) installingjava
    installingsevenversion
    ;;
    *) echo "Invalid Choice"
    ;;
esac

fi

if [ $ret = 2 ] 
then
echo "You already have 6.8.23 installed.. Would you like to upgrade to 7.16.3? (yes/no): "
read upop

if [ $upop = "yes" ] 
then
upgradetoseven
else
echo "No action Required"
fi

fi

if [ $ret = 3 ] 
then
echo "You already have the latest version 7.16.3"
fi
}
########################################Operations##################################################
operations(){
checkversion
ret=$?

if [ $ret = 3 ] 
then
cat << EOT
Operations available for 7.16.3:

1. Uninstall Logstash
2. Start Logstash service (Please configure logstash.conf file before starting logstash)
3. Stop the logstash service 
4. Restart the logstash service 
==================================================================================================
EOT

echo "Please Enter your choice [1/2/3/4]":
read out

case $out in
    1) uninstalllogstash
    exit 1
    ;;
    2) copyconffile
    ;;
    3) echo "Stopping the logstash service"
    sudo systemctl stop logstash 
    ;;
    4) echo "Restarting the logstash service"
    sudo systemctl restart logstash
    ;;
    *) echo "Invalid output"
       exit 1
    ;;
esac
fi

if [ $ret = 2 ]
then
cat << EOT
Operations available for 6.8.23:

1. Uninstall Logstash
2. Upgrade to 7.16.3
3. Start the logstash service (Please configure logstash.conf file before starting logstash)
==================================================================================================
EOT

echo "Please Enter your choice [1/2/3]":
read outsix

case $outsix in
    1) uninstalllogstash
    exit 1
    ;;
    2) upgradetoseven
    ;;
    3) copyconffile
    ;;
    *) echo "Invalid Input..."
    ;;
esac
fi

if [ $ret = 1 ] 
then
echo "Logstash Not Installed.. Please install the logstash to perform the Operations"    
fi
}


case $1 in
    "--check-version" | "-c") outversion
    exit 1
    ;;
    "--helpme" | "-h") helpme
    exit 1
    ;;
    "--install" | "-i") install
    exit 1
    ;;
    "--operations" | "-o") 
    operations
    exit 1
    ;;
    *) echo "$1 is a wrong operation.. Please check the format below"
    helpme
    exit 1
esac

cat << EOT
==============================================================================================
EOT
