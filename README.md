# README

The [hfactory-server-in-docker-machine](https://github.com/hfactory/hfactory-server-in-docker-machine) github project packages all the utilities necessary for a simple installation of HFactory Server via Docker. The image contains both an HBase standalone Docker and a HFactory Server inside a hfactoryserver Docker machine.

Restarting the containers allows you to start again with an empty HBase server.

## Prerequisites

To use the container, you need to have VirtualBox and Docker-machine installed.

### VirtualBox

In order to install VirtualBox, go to : https://www.virtualbox.org/wiki/Downloads

### Docker Machine

In order to install docker-machine, go to : http://docs.docker.com/machine/#installation

- Download the last version
- Put the command in the path

## Using the HFactory server in docker machine

For ease of use you can put the bin folder in your path.

### First initialization

Launch ```hfactory-env.sh init``` and edit the /etc/hosts file as required

### Using the containers

To start the containers simply use ```hfactory-env.sh start```

The hbase container is launched in host-only mode and you can connect to it directly using hfactoryserver for the hbase.zookeeper.quorum property

The hfactoryserver container is launched to listen on port 80 and you can connect to it directly using http://hfactoryserver

To stop the docker containers use ```hfactory-env.sh stop```

To read the logs ```hfactory-env.sh serverlog``` or ```hfactory-env.sh hbaselog```

To kill the containers if stopping it does not work ```hfactory-env.sh kill```

To restart the container ```hfactory-env.sh restart``` does stop/start

For getting the status ```hfactory-env.sh status``` gives you the docker processes running on the hfactoryserver instance

## docker-machine related commands

To launch the hfactoryserver docker machine ```hfactory-env.sh up```

To connect to it ```hfactory-env.sh ssh```

To stop it ```hbase-env.sh shutdown```

## Applications installation

```hfactory-env.sh putApp applicationFolder``` to add an application in the server

```hfactory-env.sh removeApp applicationName``` to remove an application from the server

## Advanced usage

To make the hbase container data persistent use ```export PERSISTS="true"```
