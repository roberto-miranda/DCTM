#!/bin/bash
clear
SALIR=0
OPCION=0
export APP_SERVER_PASSWORD=dmadmin
export INSTALL_OWNER_PASSWORD=dmadmin
export DOCBASE_PASSWORD=postgres
export DATABASE_PASSWORD=postgres
export GLOBAL_REGISTRY_PASSWORD=dmadmin
export AEK_PASSPHRASE=
export IP=$IP


echo "El nombre del repositorio sera: ${REP}"
while [ $SALIR -eq 0 ]; do
   echo "Menu:"
   echo "1) Instalar Documentum en Docker"
   echo "2) Redesplegar Documentum Administrator"
   echo "3) Desinstalar Contenedores DCTM"
   echo "4) Salir"
   echo "Opcion seleccionada: "
   read OPCION
   case $OPCION in
       1)
            echo "########################################"
            echo "Instalar Documentum en Docker seleccionado"
            echo "########################################"
            echo "Login en opentext..."
            docker login registry.opentext.com
            # Script para instalacion de DOCUMENTUM en sus versiones
            echo "¿Que versión de CS desea instalar?"
            echo "ej: 22.2.0"
            read version
            export VERSION=$version
            export VER=`echo $version|sed 's/\.//g'`
            export REP=rep${VER}
            echo "El valor introducido es: $version"
            echo "¿Cual es la IP de su maquina?"
            echo "ej: 192.168.0.1"
            read IP
            echo "El valor introducido es: $IP"

            echo "Introduce la password del root"
            read ROOT_PASSWORD

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
            echo "¿Desea instalar Documentum D2?"
            echo "s/n"
            read D2
            echo "El valor introducido es: $D2"

            echo "Cambiamos el valor del tablespace de postgres"
            cp ./PostGres/db/tmp/init.sh ./PostGres/db/init.sh
            sed -i -e "s/REP/${REP}/"  ./PostGres/db/init.sh
            echo "Creamos la red Documentum..."
            docker network create documentum
            echo "Desplegando el contenedor de Postgres 11..."
            docker-compose -f PostGres/PostGres-Docker-Compose.yml up -d
            sleep 15

            echo "Desplegando el contenedor de CS $version"
            docker-compose -f CS/CS-Docker-Compose_Stateless.yml up -d
            sleep 600
            if [ "$DA" = "s" ];
                then
                echo "Desplegando el contenedor de DA $version"
            docker-compose -f ./DA/statelessda_compose.yml up -d
            fi

            if [ "$DFS" = "s" ];
                then
                echo "Desplegando el contenedor de DFS $version"
            fi
            if [ "$XPLORE" = "s" ];
                then
                echo "Desplegando el contenedor de xPlore $version"
            fi
            if [ "$D2" = "s" ];
                then
                echo "Desplegando el contenedor de D2 $version"
            fi
           ;;
       2)
            echo "########################################"
            echo "Redesplegar Documentum Administrator"
            echo "########################################"
            echo "Login en opentext..."
            docker login registry.opentext.com
            # Script para instalacion de DOCUMENTUM en sus versiones
            echo "¿Que versión de CS desea instalar?"
            echo "ej: 22.2.0"
            read version
            export VERSION=$version
            export VER=`echo $version|sed 's/\.//g'`
            export REP=rep${VER}
            echo "El valor introducido es: $version"
            echo "¿Cual es la IP de su maquina?"
            echo "ej: 192.168.0.1"
            read IP
            echo "El valor introducido es: $IP"

            docker-compose -f ./DA/statelessda_compose.yml up -d
       ;;
       3)
            echo "########################################"
            echo "Desinstalar Contenedores DCTM seleccionado"
            echo "########################################"
            echo "¿Desea continuar con la limpieza? "
            echo "AVISO: Se eliminaran todos los contenedores con nombre DCTM y sus dependecias."
            echo "s/n"
            read continuar
            if [ "$continuar" = "s" ];
            then

                echo "########################################"
                echo "Eliminando cualquier contenedor de DCTM..."
                echo "########################################"
                #parada de todos los contenedores
                docker stop $(docker ps -a|grep dctm_|cut -c 1-12)
                #eliminamos contenedore
                docker rm $(docker ps -a|grep dctm_|cut -c 1-12)
                #eliminamos volumenes
                echo "########################################"
                echo "Eliminando cualquier volumen de DCTM..."
                echo "########################################"
                docker volume rm $(docker volume ls| grep dctm_|cut -c 21-)

                #eliminamos redes
                echo "########################################"
                echo "Eliminando cualquier red de DCTM..."
                echo "########################################"
                docker network rm $(docker network ls|grep documentum|cut -c 1-12)
                echo "########################################"
                echo "########################################"
                echo "########################################"
            else
            echo "Saliendo de la instalacion"
            exit;
            fi
        ;;
       4)
           SALIR=1 ;;
       *)
         echo "Opcion erronea";;
       esac
done
