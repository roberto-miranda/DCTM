#!/bin/bash

echo ".............. start script ......................."

cd ${HOME}

if [ $CP_WEB_APP ]; then
    APP_PATH=$CP_WEB_APP
else
    APP_PATH="${CATALINA_HOME}/webapps/da"
fi;

echo "Turning off compression filter in wdk/app.xml ..."
sed -i -e 's/<compression_filter_enabled>true<\/compression_filter_enabled>/<compression_filter_enabled>false<\/compression_filter_enabled>/' ${APP_PATH}/wdk/app.xml

##DA_EXT_CONF CHECK###
if [ "$DA_EXT_CONF" = "" ]; then
    ##defaulted to ${CATALINA_HOME}/webapps/da/external-configurations
    DA_EXT_CONF="${CATALINA_HOME}/webapps/da/external-configurations"
fi;


echo "External configuration folder at $DA_EXT_CONF ..."

echo "Initializing da with given defaults ..."
if [ ! -f  ${DA_EXT_CONF}/dfc.properties ]; then
    cp ${APP_PATH}/WEB-INF/classes/dfc.properties ${DA_EXT_CONF}/dfc.properties
fi;
if [ ! -f  ${DA_EXT_CONF}/app.properties ]; then
    cp ./app.properties ${DA_EXT_CONF}/app.properties
fi;
if [ ! -f ${DA_EXT_CONF}/otdsoauth.properties ]; then
    cp ./otdsoauth.properties ${DA_EXT_CONF}/otdsoauth.properties
fi;
if [ ! -f ${DA_EXT_CONF}/log4j2.properties ]; then
    cp ./log4j2.properties ${DA_EXT_CONF}/log4j2.properties
fi;
#create logs directory for gray logs
eval "mkdir -p ./documentum/logs"

#change log directory permission
eval "chmod -R u+rwx ./documentum/logs"

#update app.xml with presets and preferences password
eval "./encryptPasswordUpdate.pl" 

#update app.xml with properties file content or env values
eval "./updateAppXml.pl init" 

#update dfc.properties with properties file content or env values
eval "./updateDfcProperties.pl"

#update otds.properties with properties file content or env values
eval "./updateOtdsProperties.pl"

#update log4j2.properties
eval "./updateLog4j2Properties.pl"

echo "Starting volume monitoring for dfc.properties ..."
./volmon.sh -s ${DA_EXT_CONF}/dfc.properties -e ./updateDfcProperties.pl >> ./documentum/logs/volmon-dfc.log &

echo "Starting volume monitoring for app.xml ..."
./volmon.sh -s ${DA_EXT_CONF}/app.properties -e ./updateAppXml.pl >> ./documentum/logs/volmon-app-xml.log &

echo "Starting volume monitoring for otdsoauth.properties ..."
./volmon.sh -s ${DA_EXT_CONF}/otdsoauth.properties -e ./updateOtdsProperties.pl >> ./documentum/logs/volmon-otdsoauth.log &

echo "Starting volume monitoring for log4j2.properties ..."
./volmon.sh -s ${DA_EXT_CONF}/log4j2.properties -e ./updateLog4j2Properties.pl >> ./documentum/logs/volmon-log4j2.log &
if [ $NEW_RELIC_AGENT_ENABLED = "true" ]; then	
	echo "NewRelic agent has been enabled. Adding the agent switch to JAVA_OPTS"
	export JAVA_OPTS="$JAVA_OPTS -javaagent:${HOME}/newrelic/newrelic.jar"
	echo "JAVA_OPTS now $JAVA_OPTS"
fi;

set -x

pid=0

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

# run application
echo "Starting Tomcat ..."
${CATALINA_HOME}/bin/catalina.sh run &
pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
