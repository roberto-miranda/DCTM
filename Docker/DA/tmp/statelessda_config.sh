echo "Creating docker image and installing DA"
echo USAGE : ./statelessda_config.sh

rm -rf ./tmp
mkdir ./tmp
cp ./* ./tmp

DOCBROKER_IP=`cat statelessda.conf | grep 'DOCBROKER_IP' | awk '{print($3);}'`
echo "DOCBROKER_IP : $DOCBROKER_IP"
sed -i -e "s/DOCBROKER_IP=.*/DOCBROKER_IP=${DOCBROKER_IP}/"  ./tmp/statelessda_compose.yml

DOCBROKER_PORT=`cat statelessda.conf | grep 'DOCBROKER_PORT' | awk '{print($3);}'`
echo "DOCBROKER_PORT : $DOCBROKER_PORT"
sed -i -e "s/DOCBROKER_PORT=.*/DOCBROKER_PORT=${DOCBROKER_PORT}/"  ./tmp/statelessda_compose.yml

GLOBAL_REGISTRY_DOCBASE_NAME=`cat statelessda.conf | grep 'GLOBAL_REGISTRY_DOCBASE_NAME' | awk '{print($3);}'`
echo "GLOBAL_REGISTRY_DOCBASE_NAME : $GLOBAL_REGISTRY_DOCBASE_NAME"
sed -i -e "s/GLOBAL_REGISTRY_DOCBASE_NAME=.*/GLOBAL_REGISTRY_DOCBASE_NAME=${GLOBAL_REGISTRY_DOCBASE_NAME}/"  ./tmp/statelessda_compose.yml

BOF_REGISTRY_USER_PASSWORD=`cat statelessda.conf | grep 'BOF_REGISTRY_USER_PASSWORD' | awk '{print($3);}'`
echo "BOF_REGISTRY_USER_PASSWORD : $BOF_REGISTRY_USER_PASSWORD"
sed -i -e "s/BOF_REGISTRY_USER_PASSWORD=.*/BOF_REGISTRY_USER_PASSWORD=${BOF_REGISTRY_USER_PASSWORD}/"  ./tmp/statelessda_compose.yml

CRYPTO_REGISTRY_DOCBASE_NAME=`cat statelessda.conf | grep 'CRYPTO_REGISTRY_DOCBASE_NAME' | awk '{print($3);}'`
echo "CRYPTO_REGISTRY_DOCBASE_NAME : $CRYPTO_REGISTRY_DOCBASE_NAME"
sed -i -e "s/CRYPTO_REGISTRY_DOCBASE_NAME=.*/CRYPTO_REGISTRY_DOCBASE_NAME=${CRYPTO_REGISTRY_DOCBASE_NAME}/"  ./tmp/statelessda_compose.yml

PRESETS_PREFERENCES_USER_PASSWORD=`cat statelessda.conf | grep 'PRESETS_PREFERENCES_USER_PASSWORD' | awk '{print($3);}'`
echo "PRESETS_PREFERENCES_USER_PASSWORD : $PRESETS_PREFERENCES_USER_PASSWORD"
sed -i -e "s/PRESETS_PREFERENCES_USER_PASSWORD=.*/PRESETS_PREFERENCES_USER_PASSWORD=${PRESETS_PREFERENCES_USER_PASSWORD}/"  ./tmp/statelessda_compose.yml

IMAGE_NAME=`cat statelessda.conf | grep 'IMAGE_NAME' | awk '{print($3);}'`
echo "IMAGE_NAME : $IMAGE_NAME"
sed -i -e "s/dastatelessimage/${IMAGE_NAME}/"  ./tmp/statelessda_compose.yml

CONTAINER_HOSTNAME=`cat statelessda.conf | grep 'CONTAINER_HOSTNAME' | awk '{print($3);}'`
echo "containername : $CONTAINER_HOSTNAME"
sed -i -e "s/dastatelesscontainer/${CONTAINER_HOSTNAME}/"  ./tmp/statelessda_compose.yml #

APPSERVER_PORT=`cat statelessda.conf | grep 'APPSERVER_PORT' | awk '{print($3);}'`
echo "APPSERVER_PORT : $APPSERVER_PORT"
sed -i -e "s/APPSERVER_PORT:/${APPSERVER_PORT}:/" ./tmp/statelessda_compose.yml
sed -i -e "s/APPSERVER_PORT=.*/APPSERVER_PORT=${APPSERVER_PORT}/"  ./tmp/statelessda_compose.yml

DFC_SESSION_SECURE_CONNECT_DEFAULT=`cat statelessda.conf | grep 'DFC_SESSION_SECURE_CONNECT_DEFAULT' | awk '{print($3);}'`
echo "DFC_SESSION_SECURE_CONNECT_DEFAULT : $DFC_SESSION_SECURE_CONNECT_DEFAULT"
sed -i -e "s/DFC_SESSION_SECURE_CONNECT_DEFAULT=.*/DFC_SESSION_SECURE_CONNECT_DEFAULT=${DFC_SESSION_SECURE_CONNECT_DEFAULT}/"  ./tmp/statelessda_compose.yml

docker-compose -f ./tmp/statelessda_compose.yml up -d #create image with compose
echo "DA Image creation completed"