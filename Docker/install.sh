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
CS_recoger_variables(){
    echo "¿Cual es la IP de su máquina?"
    echo "ej: 192.168.0.1"
    read IP
    echo "El valor introducido es: $IP"
    export IP=$IP
    echo "Introduce la password del root"
    read ROOT_PASSWORD
    export ROOT_PASSWORD=$ROOT_PASSWORD
    echo "¿Que versión desea instalar?"
    echo "ej: 22.2.0"
    read version
    export VERSION=$version
    export VER=`echo $version|sed 's/\.//g'`
    export REP=rep${VER}
    echo "El valor introducido es: $version"
}
CLIENTS_recoger_variables(){
    echo "¿Que versión desea instalar?"
    echo "ej: 22.2.0"
    read version
    export VERSION=$version
    export VER=`echo $version|sed 's/\.//g'`
    export REP=$REP
    echo "El valor introducido es: $version"
    echo "¿Cual es la IP de su maquina?"
    echo "ej: 192.168.0.1"
    read IP
    echo "El valor introducido es: $IP"
    export IP=$IP
    echo "¿Cual es nombre de la Docbase?"
    read REP
    echo "El valor introducido es: $REP"

}
INFO_entorno(){
    echo "########################################################"
    echo "Informacion del entorno Documentum v$VERSION"
    echo "########################################################"
    echo "INSTALL_OWNER_PASSWORD: $INSTALL_OWNER_PASSWORD"
    echo "DOCBASE_PASSWORD: $DOCBASE_PASSWORD"
    echo "DATABASE_PASSWORD: $DATABASE_PASSWORD"
    echo "AEK_PASSPHRASE: $AEK_PASSPHRASE"
    echo "DOCBASE_NAME: $REP"
    echo "APP_SERVER_PASSWORD: $APP_SERVER_PASSWORD"
    echo "IP: $IP"
    echo "DOCBROKER_PORT: 1489"
    echo "DOCBASE_PORT: 50000"
    echo "DA_URL: http://$IP:8080/da"
    echo "DFS_URL: http://$IP:8084/dfs/services/core/QueryService"
    echo "########################################################"
}
INFO_entornoXPLORE(){
    echo "########################################################"
    echo "Informacion del entorno Documentum xPLORE v$VERSION"
    echo "########################################################"
    echo "DOCBASE_NAME: $REP"
    echo "IP: $IP"
    echo "DOCBROKER_PORT: 1489"
    echo "DOCBASE_PORT: 50000"
    echo "DA_URL: http://$IP:8080/da"
    echo "xPLORE_IndexAgent_URL: http://$IP:9300/indexAgent"
    echo "xPLORE_DSearch_URL: http://$IP:9200/dsearch"
    echo "xPLORE_DSearchADMIN_URL: http://$IP:9200/dsearchadmin"
    echo "########################################################"
}


echo "##################################################"
echo "######### ASISTENTE DE INSTALACION ##############"
echo "##################################################"

while [ $SALIR -eq 0 ]; do
   echo "##################################################"
   echo "MENU:"
   echo "1) Instalar Documentum en Docker"
   echo "2) Instalar/reinstalar Documentum Administrator"
   echo "3) Instalar/reinstalar Documentum Foundation Services"
   echo "4) Instalar/reinstalar Documentum xPlore"
   echo "9) Desinstalar Contenedores DCTM"
   echo "0) Salir"
   echo "##################################################"
   echo "Opcion seleccionada: "
   echo "##################################################"
   read OPCION
   case $OPCION in
       1)
            echo "########################################"
            echo "Instalar Documentum en Docker seleccionado"
            echo "########################################"
            echo "Login en opentext..."
            docker login registry.opentext.com
            # Script para instalacion de DOCUMENTUM en sus versiones
            CS_recoger_variables
            echo "¿Desea instalar Documentum Administrator?"
            echo "[s/n]"
            read DA
            echo "El valor introducido es: $DA"
            echo "¿Desea instalar Documentum DFS?"
            echo "[s/n]"
            read DFS
            echo "El valor introducido es: $DFS"

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
                docker-compose -f ./DFS/dfs_compose.yml up -d
            fi

            if [ "$D2" = "s" ];
                then
                echo "Desplegando el contenedor de D2 $version"
            fi
            INFO_entorno
           ;;

       2)
             echo "##################################################"
            echo "Instalar/reinstalar Documentum Administrator"
            echo "##################################################"
            echo "Login en opentext..."
            docker login registry.opentext.com
            CLIENTS_recoger_variables
            # Script para instalacion de DOCUMENTUM en sus versiones
            docker-compose -f ./DA/statelessda_compose.yml up -d
            INFO_entorno
       ;;
       3)
            echo "##################################################"
            echo "Instalar/reinstalar Documentum Foundation Services"
            echo "##################################################"
            echo "Desplegando el contenedor de DFS $version"
            echo "Login en opentext..."
            docker login registry.opentext.com
            # Script para instalacion de DOCUMENTUM en sus versiones
            CLIENTS_recoger_variables

            docker-compose -f ./DFS/dfs_compose.yml up -d
            INFO_entorno
       ;;
       4)
            echo "##################################################"
            echo "Instalar/reinstalar Documentum xPlore"
            echo "##################################################"
            echo "Desplegando el contenedor de xPlore $version"
            echo "Login en opentext..."
            docker login registry.opentext.com
            # Script para instalacion de DOCUMENTUM en sus versiones
            CLIENTS_recoger_variables

            docker-compose -f ./XPLORE/XPLORE-Docker-Compose_Stateless.yml up -d
            INFO_entornoXPLORE
       ;;
       9)
            echo "########################################"
            echo "Desinstalar Contenedores DCTM seleccionado"
            echo "########################################"
            echo "¿Desea continuar con la limpieza? "
            echo "AVISO: Se eliminaran todos los contenedores con nombre DCTM y sus dependecias."
            echo "[s/n]"
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
                docker volume rm $(docker volume ls -q| grep dctm_)

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
       0)
           SALIR=0
            exit
            ;;
       *)
         echo "Opcion erronea";;

       esac
done

