# Docker `/srv`

Running multiple isolated website environments with individual SSH access for the single-node Kubernetes person. Tailored towards PHP, secured by [Let's Encrypt](https://letsencrypt.org).
 
## Setup

- Install [Docker](https://docs.docker.com/engine/installation/).
- Install [Docker Compose](https://docs.docker.com/compose/install/).
- Install Let's Encrypt's [Certbot](https://certbot.eff.org).

### Initial

When starting up the main services in [`docker-compose.yml`](docker-compose.yml)
for the first time, execute the following command to secure the MySQL installation:

```bash
docker exec -it mysql mysql -u root -e "UPDATE mysql.user SET `Host` = '127.0.0.1' WHERE `User` = 'root'"
```

This ensures that the `root` MySQL user can only be accessed through Docker `exec`
commands, instead of over the network.

### Per Application

When setting up an SSH environment for an application, the container contains
preset private keys which are shared across all containers using this image.
Run the following command to regenerate new, individual keys specifically for
the container for security:

```bash
docker-compose exec {applicationName}-ssh ssh-keygen -A
docker-compose restart {applicationName}-ssh
```

Once container keys have been regenerated, create an `authorized_keys` file to
add the public keys you wish to allow to log in. This file is located in the
`./data/{applicationName}.ssh/` directory if you followed the
[`docker-compose.override-example.yml`](docker-compose.override-example.yml) file.

A `bin/create-standard-application.sh {domain}` script is coming soon.

## Databases

MySQL access isn't available outside the Docker network. Passwords do not have
to be safe unless you wish to prevent other applications guessing which
user/password combinations are available.

### Creating New Database/User for Application

```bash
docker-compose exec mysql mysql -u root -e "CREATE DATABASE `{applicationName}`"
docker-compose exec mysql mysql -u root -e "CREATE USER '{applicationName}'@'%' IDENTIFIED BY '{applicationName}'"
docker-compose exec mysql mysql -u root -e "GRANT ALL PRIVILEGES ON `{applicationName}`.* TO '{applicationName}'@'%'"
docker-compose exec mysql mysql -u root -e "FLUSH PRIVILEGES"
```
