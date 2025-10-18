# Nightingale Server

![Nightingale](https://raw.githubusercontent.com/fireblade004/nightingale-server/main/.github/logo.png "Nightingale logo")

![Release](https://img.shields.io/github/v/release/fireblade004/nightingale-server)
![Docker Pulls](https://img.shields.io/docker/pulls/fireblade004/nightingale-server)
![Docker Stars](https://img.shields.io/docker/stars/fireblade004/nightingale-server)
![Image Size](https://img.shields.io/docker/image-size/fireblade004/nightingale-server)

This is a Docker container that automatically downloads and runs the
[Nightingale](https://store.steampowered.com/app/1928980/Nightingale/) dedicated server.

### WARNING: EXPERIMENTAL:
This container is currently in experimental state, you may experience issues including complete loss of saved-data. At present it is
expected that any users be familiar with [Docker](https://docs.docker.com/), [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD),
and the basics of shell scripting and server administration. If you experience any issues, you are welcome to report them although they are
currently unlikely to be actioned if they do not contain sufficient details to easily identify the root cause.

## Credit/license
This container is built on top of the Ubuntu-based [SteamCMD container](https://hub.docker.com/r/steamcmd/steamcmd) and was developed using
wolveix's [Satisfactory Server container](https://github.com/wolveix/satisfactory-server) as a template. The code to build this container
is licensed under the MIT license like the Satisfactory and SteamCMD containers it was modified/based from. License information for Ubuntu
is available [here](https://canonical.com/legal/open-source-licences). [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) itself
is property of Valve Corporation and subject to their terms. [Nightingale](https://playnightingale.com/) Server is property of
[Inflexion Games](https://www.inflexion.io/) and subject to their terms. Users are responsible for ensuring they abide by all terms of
software used.

## Setup

The [official documentation of the server](https://a.storyblok.com/f/239842/x/e8167d5c91/nightingale-dedicated-server-0-8-final.pdf) does
not appear to indicate the memory requirements of the server. An arbitrary warning threshold has been set to warn in the log on startup
if the memory available is below 8 GB. This will be updated if official recommendations are once a consensus is found regarding memory
requirements. You may experiment with adjusting the container's defined `--memory` restriction depending on available resources on your host
and the performance of the server.


You'll need to bind a local directory to the Docker container's `/config` directory. This directory will hold the
following directories:

- `/gamefiles` - this is for the game's files. They're stored outside the container to avoid needing to redownload
  11GB+ every time you want to rebuild the container
- `/logs` - this holds Steam's logs, and contains a pointer to Nightingale's logs (empties on startup unless
  `LOG=true`)

It is also recommended that you bind a local directory to the container's `/config/gamefiles/NWX/Saved` directory, as this is where
the Nightingale Server stores persistent information (saved data). Binding this separately allows for ease of backing up the savedata
separately from the entire install.

Before running the server image, you should find your user ID that will be running the container. This isn't necessary
in most cases, but it's good to find out regardless. If you're seeing `permission denied` errors, then this is probably
why. Find your ID in `Linux` by running the `id` command. Then grab the user ID (usually something like `1000`) and pass
it into the `-e PGID=1000` and `-e PUID=1000` environment variables.



Run the Nightingale server image like this (this is one command, make sure to copy all of it):<br>

```bash
docker run \
--detach \
--name=nightingale-server \
--hostname nightingale-server \
--restart unless-stopped \
--volume ./nightingale-server:/config \
--volume ./savedata:/config/gamefiles/NWX/Saved \
--env MAXPLAYERS=4 \
--env PGID=1000 \
--env PUID=1000 \
--env CONNECTIONPASSWORD=\<password\> \
--memory-reservation=4G \
--memory 8G \
--publish 7777:7777/tcp \
--publish 7777:7777/udp \
fireblade004/nightingale-server:latest
```

<details>
<summary>Explanation of the command</summary>

* `--detach` -> Starts the container detached from your terminal<br>
  If you want to see the logs replace it with `--sig-proxy=false`
* `--name` -> Gives the container a unique name
* `--hostname` -> Changes the hostname of the container
* `--restart unless-stopped` -> Automatically restarts the container unless the container was manually stopped
* `--volume` -> Binds the Nightingale config folder to the folder you specified
  Allows you to easily access your savegames
* For the environment (`--env`) variables please
  see [here](https://github.com/fireblade004/nightingale-server#environment-variables)
* NOTE: The CONNECTIONPASSWORD variable is optional, but strongly recommended, as omitting it makes the server open for anyone
* `--memory-reservation=4G` -> Reserves 4GB RAM from the host for the container's use
* `--memory 8G` -> Restricts the container to 8GB RAM
* `--publish` -> Specifies the ports that the container exposes. Ensure you publish both TCP and UDP for 7777 or your port of choice if you change it using the `SERVERGAMEPORT` environment variable<br>

</details>

### Docker Compose

If you're using [Docker Compose](https://docs.docker.com/compose/):

```yaml
services:
  nightingale-server:
    container_name: 'nightingale-server'
    hostname: 'nightingale-server'
    image: 'fireblade004/nightingale-server:latest'
    ports:
      - '7777:7777/tcp'
      - '7777:7777/udp'
    volumes:
      - './nightingale-server:/config'
      - './savedata:/config/gamefiles/NWX/Saved'
    environment:
      - MAXPLAYERS=4
      - PGID=1000
      - PUID=1000
      - CONNECTIONPASSWORD=<password>
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 8G
        reservations:
          memory: 4G
```

### Updating

The game automatically updates when the container is started or restarted (unless you set `SKIPUPDATE=true`).

To update the container image itself:

#### Docker Run

```shell
docker pull fireblade004/nightingale-server:latest
docker stop nightingale-server
docker rm nightingale-server
docker run ...
```

#### Docker Compose

```shell
docker compose pull
docker compose up -d
```

## Environment Variables

| Parameter               |  Default    | Function                                                  |
|-------------------------|:----------:|-----------------------------------------------------------|
| `DEBUG`                 |  `false`   | for debugging the server                                  |
| `CONNECTIONPASSWORD`    |            | set the password for connecting to the server             |
| `ADMINPASSWORD`         |            | set the password for admin access to the server           |
| `ENABLECHEATS`          |  `false`   | enable cheats on the server                               |
| `LOG`                   |  `false`   | set `true` to disable Nightingale log pruning             |
| `MAXPLAYERS`            |    `4`     | set the player limit for your server                      |
| `MULTIHOME`             |   `::`     | set the server's listening interface (usually not needed) |
| `PGID`                  |  `1000`    | set the group ID of the user the server will run as       |
| `PUID`                  |  `1000`    | set the user ID of the user the server will run as        |
| `SERVERGAMEPORT`        |  `7777`    | set the game's server port                                |
| `SKIPUPDATE`            |  `false`   | avoid updating the game on container start/restart        |
| `TIMEOUT`               |   `30`     | set client timeout (in seconds)                           |

## Running as Non-Root User

By default, the container runs with root privileges but executes Nightingale under `1000:1000`. If your host's user and
group IDs are `1000:1000`, you can run the entire container as non-root using Docker's `--user` directive. For different
user/group IDs, you'll need to clone and rebuild the image with your specific UID/GID:

### Building Non-Root Image

1. Clone the repository:

```shell
git clone https://github.com/fireblade004/nightingale-server.git
```

2. Create a docker-compose.yml file with your desired UID/GID as build args (note that the `PUID` and `PGID` environment
   variables will no longer be needed, remember to change `<password>`):

```yaml
services:
  nightingale-server:
    container_name: 'nightingale-server'
    hostname: 'nightingale-server'
    build:
      context: .
      args:
        UID: 1001  # Your desired UID
        GID: 1001  # Your desired GID
    user: "1001:1001"  # Must match UID:GID above
    ports:
      - '7777:7777/tcp'
      - '7777:7777/udp'
    volumes:
      - './nightingale-server:/config'
      - './savedata:/config/gamefiles/NWX/Saved'
    environment:
      - MAXPLAYERS=4
      - CONNECTIONPASSWORD=<password>
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 8G
        reservations:
          memory: 4G
```

3. Build and run the container:

```shell
docker compose up -d
```

## Known Issues

- The container is run as `root` by default. You can provide your own user and group using Docker's `--user` directive;
  however, if your proposed user and group aren't `1000:1000`, you'll need to rebuild the image (as outlined above).