#!/usr/bin/bash

generateKeystore() {
    local KEYSTORE=$1
    echo "Generating the keystore..."
    $KEYTOOL -genkey -noprompt -alias $ALIAS -dname "CN=$HOST, OU=$ORGUNIT, O=$ORGANISATION, L=$LOCATION, S=$STATE, C=$COUNTRY" -keystore $KEYSTORE -storepass $STOREPASS -keypass $KEYPASS -keyalg $KEYALG
}

generateCertificate() {
    local CERT=$1
    echo "Generating the certificate..."
    $KEYTOOL -export -noprompt -alias $ALIAS -file $CERT -storepass $STOREPASS -keypass $KEYPASS -keystore $KEYSTORE
}

updateTomcatConf() {
    local KEYSTORE=$1
    if ! grep -Fxq "#ssl# UPDATED" /opt/tomcat/conf/server.xml; then
        sed -i -e "s%<!-- #ssl#%<Connector protocol=\"HTTP/1.1\" port=\"8443\" maxThreads=\"200\" scheme=\"https\" secure=\"true\" SSLEnabled=\"true\" keystoreFile=\"$KEYSTORE\" keystorePass=\"$KEYPASS\" clientAuth=\"false\" sslProtocol=\"TLSv1.2\"/><!-- #ssl# UPDATED%" /opt/tomcat/conf/server.xml
    fi;
}

copyKeystoreCertificate() {
   local KEYSTORE=$1
   local CERTIFICATE=$2
   if [ ! $KEYSTORE = "" ]; then
       cp -ut $KEYSTORE /opt/tomcat/conf/. 2>/dev/null
   fi;
   if [ ! $CERTIFICATE = "" ]; then
       cp -ut $CERTIFICATE /opt/tomcat/conf/. 2>/dev/null
       cp -ut $CERTIFICATE ${DA_EXT_CONF}/. 2>/dev/null
   fi;
}

keytool=`which keytool`
HOST=`hostname`
ALIAS=datest
ORGUNIT="ECD"
ORGANISATION="OpenText"
LOCATION="BLR"
STATE="KA"
COUNTRY="IN"
STOREPASS="123456"
KEYPASS="123456"
KEYSTORE="/opt/tomcat/conf/$ALIAS.keystore"
CERT="/opt/tomcat/conf/$ALIAS.cer"
KEYALG="RSA"
KEYTOOL=`which keytool`

while getopts a:u:o:l:s:c:p:k:x:y:h: ARG; do
  case "$ARG" in
    a) ALIAS=$OPTARG;;
    u) ORGUNIT=OPTARG;;
    o) ORGANISATION=$OPTARG;;
    l) LOCATION=$OPTARG;;
    s) STATE=$OPTARG;;
    c) COUNTRY=$OPTARG;;
    p) STOREPASS=$OPTARG;;
    k) KEYPASS=$OPTARG;;
    x) USERKEYSTORE=$OPTARG;;
    y) USERCERT=$OPTART;;
    h) HOST=$OPTART;;
  esac
done

if [ ! -f $USERKEYSTORE ]; then
    updateTomcatConf $USERKEYSTORE
    copyKeystoreCertificate $USERKEYSTORE
elif [ ! -f $USERCERT ]; then
    generateKeystore $KEYSTORE
    generateCertificate $USERCERT
    updateTomcatConf $KEYSTORE
    copyKeystoreCertificate $KEYSTORE $USERCERT
else
    generateKeystore $KEYSTORE
    generateCertificate $CERT
    updateTomcatConf $KEYSTORE
    copyKeystoreCertificate $KEYSTORE $CERT
fi;
