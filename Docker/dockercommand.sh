docker --help
docker version
**exec into a container**
```
docker exec -it 4420c4452c5c sh
telnet 192.168.56.6 25
```
docker login
ex: docker login localhost:8080

docker ps -A
docker images ls

#check disk usage of image, container volume, cache
docker system df 
# check realtime events from server
docker system events 
#check information of all system as such container number, image number 
docker system info
# remove all container, image not use  
docker system prune 
# remove all container, image, network, build cache and volume not use.
docker system prune -a --volume 
docker image prune, docker container prune

## build image from Dockerfile
docker image build
docker image history IMAGE_NAME

## check detail of one container
docker image inspect IMAGE 
## excep into container
docker inspect ID_CONTAINER 

#BUILD 
docker image build -t my_image:my_tag 

#CONTAINER 
docker container create IMAGE 
docker container inspect CONTAINER
docker 	container logs CONTAINER
docker container ls 
docker container prune
docker container rm 
docker container run IMAGE 
docker container start 
docker container stop 
docker container kill CONTAINER	
# start container
docker container create --name CONTAINER_NAME IMAGE
docker container run --name CONTAINER_NAME -d IMAGE --rm 
--rm delete container when it stop 
-d run container under background

## DOCKER COMPOSE 
#cd into Dockerfile.yaml file
docker-compose build 

docker-compose up -d  
docker-compose down 

docker login DOCKER_REGISTRY
dokcer tag ...
docker push 


docker rm -f ID_container
docker image rm -f ID_Image
