# Install Documentum Server 22.2 in Docker
0. docker login registry.opentext.com

1. docker pull postgres:11-bullseye
2. docker pull registry.opentext.com/dctm-server:22.2.0
2. docker pull registry.opentext.com/dctm-da:22.2.0




#parada de todos los contenedores
docker stop $(docker ps -a -q)
#eliminamos contenedore
docker rm $(docker ps -a -q)
#eliminamos volumenes
docker volume rm $(docker ps -a -q)
#eliminamos redes
docker network rm $(docker ps -a -q)

