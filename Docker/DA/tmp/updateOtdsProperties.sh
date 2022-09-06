#!/bin/sh
if [ -z "$OTDS_PROTOCOL" ]
then 
    echo "OTDS_PROTOCOL is not defined, will be default to https";
	OTDS_PROTOCOL="https";
else
	echo "OTDS_PROTOCOL is $OTDS_PROTOCOL";
fi;
	
if [ -n $OTDS_API_SVC ] 
then
	CERT_DIR=/opt/otds.cer
	OTDSOAUTH_PROP_FILE=/opt/tomcat/webapps/da/WEB-INF/classes/com/documentum/web/formext/session/otdsoauth.properties
	APP_XML_FILE=/opt/tomcat/webapps/da/wdk/app.xml
	certURL="$OTDS_PROTOCOL://$OTDS_API_SVC/rest/systemconfig/certificate_content"
	curl --insecure $certURL > $CERT_DIR
	sed -i -e '/BEGIN CERTIFICATE/d' $CERT_DIR
	sed -i -e '/END CERTIFICATE/d' $CERT_DIR
	tr -d '\n' < $CERT_DIR
	certficate=`sed ':a;N;$!ba;s/\n//g' $CERT_DIR`
	echo "Certificate is : $certficate"
	> $OTDSOAUTH_PROP_FILE
	echo "otds_url=$OTDS_URL" >> $OTDSOAUTH_PROP_FILE
	echo "client_id=$CLIENT_ID" >> $OTDSOAUTH_PROP_FILE
	echo "client_secret=$CLIENT_SECRET" >> $OTDSOAUTH_PROP_FILE
	echo "certificate=$certficate" >> $OTDSOAUTH_PROP_FILE
	echo "Enabling otds_sso in wdk/app.xml file"		
	sed -i -e '/<otds_sso>/,/<\otds_sso>/s/<enabled>false<\/enabled>/<enabled>true<\/enabled>/' $APP_XML_FILE
fi;