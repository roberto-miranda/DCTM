# Install Documentum Server 22.2 in Docker
1. docker pull registry.opentext.com/dctm-server:22.2.0
2. docker pull postgres:11-bullseye
docker run -d --name postgres11 --rm -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e PGDATA=/var/lib/postgresql/data/db_dockerdctm_22.2.0_dat.dat -v /tmp:/var/lib/postgresql/data -p 5432:5432 -it postgres:11-bullseye
