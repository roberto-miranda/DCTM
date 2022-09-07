echo "Creating docker image and installing DFS"
rm -rf ./tmp;
mkdir ./tmp;
cp  ./dfs_compose.yml ./tmp/;

CONTAINER_HOSTNAME=`cat dfs_config.conf | grep 'CONTAINER_HOSTNAME' | awk -F = '{print $2}' | sed -e 's/ //g'`;
echo "CONTAINER_HOSTNAME : $CONTAINER_HOSTNAME";
sed -i -e "s/dfshost/${CONTAINER_HOSTNAME}/"  ./tmp/dfs_compose.yml; #

IMAGE_NAME=`cat dfs_config.conf | grep 'IMAGE_NAME' | awk -F = '{print $2}'| sed -e 's/ //g'`;
echo "IMAGE_NAME : $IMAGE_NAME";
sed -i -e "s/dfsimage/${IMAGE_NAME}/"  ./tmp/dfs_compose.yml; #

DOCBASE_NAME=`cat dfs_config.conf | grep 'DOCBASE_NAME' | awk -F = '{print $2}' | sed -e 's/ //g'`;
echo "DOCBASE : $DOCBASE_NAME";
sed -i -e "s/DocbaseName/${DOCBASE_NAME}/"  ./tmp/dfs_compose.yml;
sed -i -e "s/DOCBASE_NAME=.*/DOCBASE_NAME=${DOCBASE_NAME}/"  ./tmp/dfs_compose.yml;

BOF_REGISTRY_USER_PASSWORD=`cat dfs_config.conf | grep 'BOF_REGISTRY_USER_PASSWORD' | awk -F = '{print $2}' | sed -e 's/ //g'`;
sed -i -e "s/BOF_REGISTRY_USER_PASSWORD=.*/BOF_REGISTRY_USER_PASSWORD=${BOF_REGISTRY_USER_PASSWORD}/"  ./tmp/dfs_compose.yml; #

DFC_DATA_DIR=`cat dfs_config.conf | grep 'DFC_DATA_DIR' | awk -F = '{print $2}' | sed -e 's/ //g'`;
sed -i -e "s/DFC_DATA_DIR=.*/DFC_DATA_DIR=${DFC_DATA_DIR}/"  ./tmp/dfs_compose.yml; #

DOCBROKER_HOST=`cat dfs_config.conf | grep 'DOCBROKER_HOST' | awk -F = '{print $2}'| sed -e 's/ //g'`;
echo "DOCBROKER_HOST : $DOCBROKER_HOST";
sed -i -e "s/DOCBROKER_HOST=.*/DOCBROKER_HOST=${DOCBROKER_HOST}/"  ./tmp/dfs_compose.yml; #

DOCBROKER_PORT=`cat dfs_config.conf | grep 'DOCBROKER_PORT' | awk -F = '{print $2}'| sed -e 's/ //g'`;
echo "DOCBROKER_PORT : $DOCBROKER_PORT";
sed -i -e "s/DOCBROKER_PORT=.*/DOCBROKER_PORT=${DOCBROKER_PORT}/"  ./tmp/dfs_compose.yml; #

SECURE_CONNECT_MODE=`cat dfs_config.conf | grep 'SECURE_CONNECT_MODE' | awk -F = '{print $2}'| sed -e 's/ //g'`;
echo "SECURE_CONNECT_MODE : $SECURE_CONNECT_MODE";
sed -i -e "s/SECURE_CONNECT_MODE=.*/SECURE_CONNECT_MODE=${SECURE_CONNECT_MODE}/"  ./tmp/dfs_compose.yml; #

TOMCAT_PORT=`cat dfs_config.conf | grep 'TOMCAT_PORT' | awk -F = '{print $2}'| sed -e 's/ //g'`;
echo "TOMCAT_PORT : $TOMCAT_PORT";
sed -i -e "s/TOMCAT_PORT/${TOMCAT_PORT}/"  ./tmp/dfs_compose.yml; #

TOMCAT_SECURE_PORT=`cat dfs_config.conf | grep 'TOMCAT_SECURE_PORT' | awk -F = '{print $2}'| sed -e 's/ //g'`;
echo "TOMCAT_SECURE_PORT : $TOMCAT_SECURE_PORT";
sed -i -e "s/TOMCAT_SECURE_PORT/${TOMCAT_SECURE_PORT}/"  ./tmp/dfs_compose.yml; #

tr -d '\015' <./tmp/dfs_compose.yml >./tmp/dfs_compose1.yml;
mv -f ./tmp/dfs_compose1.yml ./tmp/dfs_compose.yml
docker-compose -f ./tmp/dfs_compose.yml up -d;#create image with compose
echo "DFS installation completed.";

