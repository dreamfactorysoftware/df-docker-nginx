# df-docker-nginx
Docker container for DreamFactory 2.1.x using nginx.

# Prerequisites

## Get Docker
- See: [https://docs.docker.com/installation](https://docs.docker.com/installation)

### Get Docker Compose
- See [https://docs.docker.com/compose/install](https://docs.docker.com/compose/install)

### Using MS SQL?
The Docker image we provide does not include PHP drivers for MS SQL. If you need this functionality add the following to the 'apt-get install' line in the Dockerfile and build yourself a new image using the steps below.

php5-sybase php5-odbc freetds-common

# Configure using docker-compose
The easiest way to configure the DreamFactory application is to use docker-compose.

## 1) Clone the df-docker repo
`cd ~/repos` (or wherever you want the clone of the repo to be)  
`git clone https://github.com/dreamfactorysoftware/df-docker-nginx.git`  
`cd df-docker-nginx`

## 2) Edit `docker-compose.yml` (optional)

### Using load balance
The docker-compose.yml file is already configured to use load balance. 
The only thing that needs to be changes is teh APP_KEY. Change the APP_KEY 
from "UseAny32CharactersLongStringHere" to any 32 characters long string.

### Without using load balance
Rename the docker-compose.yml file to docker-compose.yml-lb-dist. Then 
rename docker-compose.yml-no-lb-dist to docker-compose.yml

## 3) Build images
`docker-compose build`

## 4) Start containers

_If your are using load balance then you can scale the web container using 
following command_

`docker-compose scale web=3`

Start the containers
`docker-compose up -d`

## 5) Add an entry to /etc/hosts
`127.0.0.1 dreamfactory.app`

## 6) Access the app
Go to 127.0.0.1 in your browser. It will take some time the first time. You will be asked to create your first admin user.

# Configure by building your own
If you don't want to use docker-compose you can build the images yourself.

## 1) Clone the df-docker repo
`cd ~/repos` (or wherever you want the clone of the repo to be)  
`git clone https://github.com/dreamfactorysoftware/df-docker-nginx.git`  
`cd df-docker-nginx`

## 2) Build dreamfactory/v2 image
`docker build -t dreamfactory/v2 .`  

## 3) Ensure that the database container is created and running
`docker run -d --name df-mysql -e "MYSQL_ROOT_PASSWORD=root" -e "MYSQL_DATABASE=dreamfactory" -e "MYSQL_USER=df_admin" -e "MYSQL_PASSWORD=df_admin" mysql`

## 4) Ensure that the redis container is created and running
`docker run -d --name df-redis redis`

## 5) Start the dreamfactorysoftware/df-docker container with linked MySQL and Redis server 
If your database and redis runs inside another container you can simply link it under the name `db` and `rd` respectively. 

### Using load balance

Creating three web containers to load balance among them.

_Replace "UseAny32CharactersLongStringHere" below with any 32 characters long string_

`docker run -d --name df-web1 -e "APP_KEY=UseAny32CharactersLongStringHere" -e "DB_HOST=db" -e "DB_USERNAME=df_admin" -e "DB_PASSWORD=df_admin" -e "DB_DATABASE=dreamfactory" -e "REDIS_HOST=rd" -e "REDIS_DATABASE=0" -e "REDIS_PORT=6379" --link df-mysql:db --link df-redis:rd dreamfactory/v2`

`docker run -d --name df-web2 -e "APP_KEY=UseAny32CharactersLongStringHere" -e "DB_HOST=db" -e "DB_USERNAME=df_admin" -e "DB_PASSWORD=df_admin" -e "DB_DATABASE=dreamfactory" -e "REDIS_HOST=rd" -e "REDIS_DATABASE=0" -e "REDIS_PORT=6379" --link df-mysql:db --link df-redis:rd dreamfactory/v2`

`docker run -d --name df-web3 -e "APP_KEY=UseAny32CharactersLongStringHere" -e "DB_HOST=db" -e "DB_USERNAME=df_admin" -e "DB_PASSWORD=df_admin" -e "DB_DATABASE=dreamfactory" -e "REDIS_HOST=rd" -e "REDIS_DATABASE=0" -e "REDIS_PORT=6379" --link df-mysql:db --link df-redis:rd dreamfactory/v2`

### Without using load balance
  
`docker run -d --name df-web -p 127.0.0.1:80:80 -e "DB_HOST=db" -e "DB_USERNAME=df_admin" -e "DB_PASSWORD=df_admin" -e "DB_DATABASE=dreamfactory" -e "REDIS_HOST=rd" -e "REDIS_DATABASE=0" -e "REDIS_PORT=6379" --link df-mysql:db --link df-redis:rd dreamfactory/v2`

## 6) Start the load balance (tutum/haproxy) container with linked df-web1, df-web2, df-web3  containers (optional, needed for load balance only)

`docker run -d -p 80:80 --name df-lb --link df-web1:df-web1 --link df-web2:df-web2 --link df-web3:df-web3 tutum/haproxy`

## 7) Add an entry to /etc/hosts
127.0.0.1 dreamfactory.app

## 8) Access the app
Go to 127.0.0.1 in your browser. It will take some time the first time. You will be asked to create your first admin user.

# Notes
- You may have to use `sudo` for Docker commands depending on your setup.
