# logstash Installer

This script used to install the logstash on EC2 instance


# Usage

Once you have cloned the repository, please move to the ```logstash``` directory

```cd logstash/```

Once you move to the directory, You need to provide the full access to the logstash-installer.sh script

```chmod 777 logstash-installer.sh```

Now you can execute the script by running the below command

```./logstash-installer.sh```

In this script, You can install 2 different version of Logstash with this script in Amazon Linux EC2 instance.

1. 6.8.23 which is compatible with older versions of Elasticsearch.
2. 7.16.3 which is compatible with newer builds of Opensearch.

Other than that you can also do the operations like, Uninstalling the logstash, checking the version and start the logstash service according to the version you have installed.

Please note that, before starting the logstash service, you need to configure the ```logstash.conf``` file present in the ```logstash``` folder.

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

