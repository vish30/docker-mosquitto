docker-mosquitto
================

[![Docker Pulls](https://img.shields.io/docker/pulls/jllopis/mosquitto.svg)](https://cloud.docker.com/u/jllopis/repository/docker/jllopis/mosquitto)
[![Docker Stars](https://img.shields.io/docker/stars/jllopis/mosquitto.svg)](https://cloud.docker.com/u/jllopis/repository/docker/jllopis/mosquitto)
[![Docker Build Status](https://img.shields.io/docker/build/jllopis/mosquitto.svg)](https://cloud.docker.com/u/jllopis/repository/docker/jllopis/mosquitto)
[![](https://images.microbadger.com/badges/image/jllopis/mosquitto.svg)](https://microbadger.com/images/jllopis/mosquitto "Get your own image badge on microbadger.com")

Mosquitto MQTT Broker on Docker Image along with PostgreSQL db for auth.

A fork of [this](https://github.com/jllopis/docker-mosquitto) awesome repository.

# Quick installation

Navigate to `users.csv` in _postgres_ directory and add all the users whom you want pre-created in the broker. More information on add/edit users below.

Navigate to the root folder of repository.

    docker-compose up

Two containers will start. You can check the status using docker commands or I would suggest to use [Portainer](https://www.portainer.io/) to access/control docker containers.

# Version

**mosquitto** v1.5.5

This version implements MQTT over WebSocket. You can use an MQTT JavaScript library to connect, like Paho: https://github.com/eclipse/paho.mqtt.javascript

It has the auth plugin `https://github.com/jpmens/mosquitto-auth-plug` included. It uses (and is compiled with) support for `Redis`, `PostgreSQL`, `http` and `JWT` backends. The additional config for this plugin (sample `auth-plugin.conf` included) can be bind mounted in the extended configuration directory: `/etc/mosquitto.d`. Any file with a `.conf` extension will be loaded by `mosquitto` on startup.

For details on the auth plugin configuration, refer to the author repository. A little quick&dirty example its included at the end.

The docker images builds with _Official Alpine Linux edge_.

# Build

Use the provide _Makefile_ to build the image.

Alternatively you can start it by means of [docker-compose](https://docs.docker.com/compose): `docker-compose up`. This is useful when testing. It start up _postgres_ and link it to _mosquitto_ so you can test the _auth-plugin_ easily.

## Build the Mosquitto docker image

    $ sudo make

You can specify your repository and tag by

    $ sudo make REPOSITORY=my_own_repo/mqtt TAG=v1.5.5

Default for **REPOSITORY** is **jllopis/mosquitto** (should change this) and for **TAG** is **mosquitto version (1.5 now)**.

Actually the command executed by make is

    docker build --no-cache -t jllopis/mosquitto:v1.5.5 .

# Persistence and Configuration

If you want to use persistence for the container or just use a custom config file you must use **VOLUMES** from your host or better, data only containers.

The container has three directories that you can use:

- **/etc/mosquitto** to store _mosquitto_ configuration files

- **/etc/mosquitto.d** to store additional configuration files that will be loaded after _/etc/mosquitto/mosquitto.conf_

- **/var/lib/mosquitto** to persist the database

The logger outputs to **stderr** by default.
)
See the following examples for some guidance:

## Mapping host directories

    $ sudo docker run -ti \
      -v /tmp/mosquitto/etc/mosquitto:/etc/mosquitto \
      -v /tmp/mosquitto/etc/mosquitto.d:/etc/mosquitto.d \
      -v /tmp/mosquitto/var/lib/mosquitto:/var/lib/mosquitto \
      -v /tmp/mosquitto/auth-plug.conf:/etc/mosquitto.d/auth-plugin.conf \
      --name mqtt \
      -p 1883:1883 \
      -p 9883:9883 \
      jllopis/mosquitto:v1.5.5

## Data Only Containers

You must create a container to hold the directories first:

    $ sudo docker run -d -v /etc/mosquitto -v /etc/mosquitto.d -v /var/lib/mosquitto --name mqtt_data busybox /bin/true

and then just use **VOLUMES_FROM** in your container:

    $ sudo docker run -ti \
      --volumes-from mqtt_data \
      --name mqtt \
      -p 1883:1883 \
      -p 9883:9883 \
      jllopis/mosquitto:v1.5.5

The image will save its auth data (if configured) to _redis_. You can start and link a _redis_ container or use an existing _redis_ instance (remember to configure the plugin).

The included `docker-compose.yml` file is a good example of how to do it.

# Example of authenticated access

By default, all the users present in `./postgres/users.csv` will be created for auth.

Note: You can also use all the other auth backends supported by https://github.com/jpmens/mosquitto-auth-plug

## Add a user for authentication

(or whatever user u have configured...)

    $ docker run -ti --rm jllopis/mosquitto:v1.5.5 np -p secretpass
    PBKDF2$sha256$901$5nH8dWZV5NXTI63/$0n3XrdhMxe7PedKZUcPKMd0WHka4408V

Replace `secretpass` with your password. Copy the encoded string that is generated.

    sudo docker exec -it postgres-mosq psql broker_data mosq_user

After logging into PSQL console inside container.

    insert into account(username, password, super) 
        values('vish', 'PBKDF2$sha256$901$5nH8dWZV5NXTI63/$0n3XrdhMxe7PedKZUcPKMd0WHka4408V', 1);

This will add a new user with username `vish` and password `secretpass`.
You can use PostgreSQL commands to create/edit users then on.

And now everything *should* work! ;)

## Contributors

- See [contributors page](https://github.com/jllopis/docker-mosquitto/graphs/contributors) for a list of contributors.
