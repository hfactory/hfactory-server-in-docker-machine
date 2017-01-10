#!/bin/bash
set -e

DIR="$( cd "$( dirname "$0" )" && pwd )"
IDS="hbase server"
MACHINE_NAME=hfactoryserver
#USE_CONFDIR="-v ${homedir}/conf:/conf"

dm(){
	docker-machine "$@"
}

dmip(){
  dm ip $MACHINE_NAME 2> /dev/null
}

dmup(){
  ign=$(dm start $MACHINE_NAME 2> /dev/null)
}

dmenv(){
  dm env ${MACHINE_NAME} | grep '^export'
}

up() {
  dmup
  # Use eval "$(up)" to initialize docker env
  echo $(dmenv)
}

killz(){
	eval "$(dmenv)"
	echo "Killing hfactory docker containers:"
	echo $IDS | xargs -n 1 docker kill
	echo $IDS | xargs -n 1 docker rm
}

stop(){
	eval "$(dmenv)"
	echo "Stopping hfactory docker containers:"
	echo $IDS | xargs -n 1 docker stop
	echo $IDS | xargs -n 1 docker rm
}

serverlog(){
	eval "$(dmenv)"
	echo "Show Server logs"
	docker logs -f server
}

hbaselog(){
	eval "$(dmenv)"
	echo "Show HBase logs"
	docker logs -f hbase
}

start(){
	eval "$(up)"
	homedir=$(dm ssh $MACHINE_NAME pwd)
	if [ ${PERSISTS:-false} = "true" ]
		then
			PERSIST_DATA=${homedir}/data:/data
	fi
	echo "Starting HFactory containers"
	STANDALONEHBASE=$(docker run \
		-d \
		-v ${homedir}/share:/share \
		$PERSIST_DATA \
		--name hbase \
		--net host \
		hfactory/hbase)
	echo "Started hbase in container $STANDALONEHBASE"
	HFACTORY_SERVER=$(docker run \
		-d \
		-v ${homedir}/apps:/apps \
		$USE_CONFDIR \
		--name server \
		--net host \
		hfactory/server)
	echo "Started hfactory server in container $HFACTORY_SERVER"
}

update(){
	eval "$(dmenv)"
	echo $IDS | awk -v RS=' ' -v FS='\n' '{ print "hfactory/" $1 ":latest"}' | xargs -n 1 docker pull
}

upgrade(){
	dm upgrade $MACHINE_NAME
	update
}

copyPath(){
  scp -i "$HOME/.docker/machine/machines/$MACHINE_NAME/id_rsa" -r $1 docker@$(dmip):$2
}

case "$1" in
	init)
		dm create --driver virtualbox $MACHINE_NAME || echo "Already exists"
		eval "$(up)"
		update
		dm ssh $MACHINE_NAME "mkdir share data apps conf"
		ip=$(dmip)
		echo "Update /etc/hosts with the following line:"
		echo "$ip	hfactoryserver"
		echo "Then use $0 start to start the hfactory environment and connect to it with the http://hfactoryserver"
		echo "Use $0 putApp appFolder to add an application and $0 removeApp appName to remove it"
		;;
	putApp)
		if [ -d "$2" ]
			then
				appName=$(basename $2)
				dm ssh $MACHINE_NAME "rm -rf apps/$appName"
				copyPath $2 apps
		fi
		;;
	removeApp)
		if [ -d "$2" ]
			then
				appName=$(basename $2)
				dm ssh $MACHINE_NAME "rm -rf apps/$appName"
		fi
		;;
#	updateConf)
#		copyPath ${2:-conf}'/*' conf
#		;;
	up)
		dmup
		;;
	shutdown)
		dm stop $MACHINE_NAME
		;;
	restart)
		stop
		start
		;;
	start)
		start
		;;
	stop)
		stop
		;;
	hbaselog)
		hbaselog
		;;
	serverlog)
		serverlog
		;;
	kill)
		killz
		;;
	upgrade)
		upgrade
		;;
	update)
		update
		;;
	ssh)
		dm ssh
		;;
	status)
		eval "$(dmenv)"
		docker ps
		;;
	*)
		echo "Usage: $0 {init|start|stop|hbaselog|serverlog|kill|update|upgrade|restart|status|up|shutdown|ssh}"
		echo "Also:  $0 putApp appFolder"
		echo "       $0 removeApp appName"
		RETVAL=1
esac

