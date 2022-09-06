#!/bin/bash
# Script para instalacion de DOCUMENTUM en sus versiones
echo "¿Que versión de CS desea instalar?"
echo "ej: 22.2.0"
read version
echo "El valor introducido es: $version"
echo "¿Cual es la IP de su maquina?"
echo "ej: 192.168.0.1"
read IP
echo "El valor introducido es: $IP"
echo "¿Desea instalar Documentum Administrator?"
echo "s/n"
read DA
echo "El valor introducido es: $DA"
echo "¿Desea instalar Documentum DFS?"
echo "s/n"
read DFS
echo "El valor introducido es: $DFS"
echo "¿Desea instalar Documentum xPlore?"
echo "s/n"
read XPLORE
echo "El valor introducido es: $XPLORE"

echo "Introduce la password del root"
read ROOT_PASSWORD


export APP_SERVER_PASSWORD=dmadmin
export INSTALL_OWNER_PASSWORD=dmadmin
export ROOT_PASSWORD=$ROOT_PASSWORD
export DOCBASE_PASSWORD=postgres
export DATABASE_PASSWORD=postgres
export GLOBAL_REGISTRY_PASSWORD=dmadmin
export AEK_PASSPHRASE=


echo "########################################"
echo "Eliminando cualquier contenedor de DCTM..."
#parada de todos los contenedores
docker stop $(docker ps -a|grep dctm_|cut -c 1-12)
#eliminamos contenedore
docker rm $(docker ps -a|grep dctm_|cut -c 1-12)
#eliminamos volumenes
echo "Eliminando cualquier volumen de DCTM..."
docker volume rm $(docker volume ls| grep dctm_|cut -c 21-)

#eliminamos redes
echo "Eliminando cualquier red de DCTM..."
docker network rm $(docker network ls|grep documentum|cut -c 1-12)



echo "Creamos la red Documentum..."
docker network create documentum
echo "Desplegando el contenedor de Postgres 11..."
docker-compose -f PostGres/PostGres-Docker-Compose.yml up -d


echo "Desplegando el contenedor de CS $version"
docker-compose -f CS/CS-Docker-Compose_Stateless.yml up -d

if $DA = "s"
    then
    echo "Desplegando el contenedor de DA $version"
    cd DA
    ./statelessda_config.sh
    fi

if $XPLORE = "s"
    then
    echo "Desplegando el contenedor de xPlore $version"
    fi



