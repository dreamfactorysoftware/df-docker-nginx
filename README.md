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
