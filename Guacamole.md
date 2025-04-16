*https://thuanbui.me/apache-guacamole/*
**Install Guacamole by docker**

```
git clone "https://github.com/boschkundendienst/guacamole-docker-compose.git"

cd guacamole-docker-compose
./prepare.sh

```
- Modify docker-compose.yaml
```
# guacamole
  guacamole:
    container_name: guacamole_compose
    depends_on:
    - guacd
    - postgres
    environment:
      GUACD_HOSTNAME: guacd
      POSTGRES_DATABASE: guacamole_db
      POSTGRES_HOSTNAME: postgres
      POSTGRES_PASSWORD: 'ChooseYourOwnPasswordHere1234'
      POSTGRES_USER: guacamole_user
    image: guacamole/guacamole
    links:
    - guacd
    networks:
      guacnetwork_compose:
    ports:
## enable next line if not using nginx
    - 8080:8080/tcp # Guacamole is on :8080/guacamole, not /.
## enable next line when using nginx
##    - 8080/tcp
    restart: always
```
- deploy
```
docker-compose up -d
- access URL
http://<IP-của-Server>:8080/guacamole
Username: guacadmin
Password: guacadmin

docker-compose down
```
