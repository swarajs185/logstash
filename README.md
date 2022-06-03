# logstash Installer

This script used to install the logstash on EC2 instance

Logstash information: https://wikitech.wikimedia.org/wiki/Logstash

This script is to install logstash for Amazon Linux EC2 server

Versions available to install using the script

```
1. 6.8.23
2. 7.16.3 (As a Service)
```

Operations available after installing the logstash:

```
1. Uninstall Logstash
2. Check Logstash Version
3. Start Logstash service
4. Stop the logstash service (Applicable for 7.16.3 version)
5. Restart the logstash service  (Applicable for 7.16.3 version)
```

# Usage

Once you have cloned the repository, please move to the ```logstash_installer``` directory

````cd logstash_installer/````

Once you move to the directory, You need to provide the full access to the logstash-installer.sh script

````chmod u+x logstash-installer.sh````

# Script Usage

To find the HelpMe Window

````./logstash-installer.sh -h```` or ````./logstash-installer.sh --helpme````

In order to install the Logstash service

````./logstash-installer.sh -i```` or ````./logstash-installer.sh --install````

In order to perform the operations like, Uninstalling the logstash, Upgrading the logstash and start,stop,restart the logstash service according to the version you have installed.

````./logstash-installer.sh -o```` or ````./logstash-installer.sh --operations````

In order to check the current logstash version installed

````./logstash-installer.sh -c```` or ````./logstash-installer.sh --check-version````


# NOTE:

Please note that, before starting the logstash service, you need to configure the ```logstash.conf``` file present in the ```logstash_installer``` folder.

For sample ```logstash.conf```, you can refer below 

VERSION: 6.8.23
-

For FGAC enabled domain

````
input {
    file {
        path => "/tmp/logs/*.log"
        start_position => beginning
    }
}

output {
  elasticsearch {
    hosts => "<domain-endpoint>:443"
    user  => "<username>"
    password => "<password>"
    index  => "log-%{+YYYY.MM.dd}"
    ssl => true
  }
}
````

For Non-FGAC domain

````
input {
    file {
        path => "/tmp/logs/*.log"
        start_position => beginning
    }
}

output {
  elasticsearch {
    hosts => "<domain-endpoint>:443"
    index  => "log-%{+YYYY.MM.dd}"
    ssl => true
  }
}
````

VERSION 7.16.3
-

For FGAC enabled domain

````
input {
    file {
        path => "/tmp/logs/*.log"
        start_position => beginning
    }
}

output {
  opensearch {
    hosts => "<domain-endpoint>:443"
    user  => "<username>"
    password => "<password>"
    index  => "log-%{+YYYY.MM.dd}"
    ssl => true
  }
}
````

For Non-FGAC domain

````
input {
    file {
        path => "/tmp/logs/*.log"
        start_position => beginning
    }
}

output {
  opensearch {
    hosts => "<domain-endpoint>:443"
    index  => "log-%{+YYYY.MM.dd}"
    ssl => true
  }
}
````

