# Deus Ex Coop Dedicated Server
A Docker container for running a dedicated Deus Ex Coop server under Wine, built on Alpine. The container is built with the latest build of [DXHX](https://wiki.deusexcoop.com/index.php?title=Getting_Started) (Build `HX-0.9.89.4`) already installed to `System/`. Your game directory (mounted in the container as `/container/deusex`) should be structured as follows:

    .
    ├── ...
    ├── CoopSave
    ├── Maps
    ├── Sounds
    └── System

### docker compose

```
version: "3.8"
services:
  dxhx-coop-server:
    image: ghcr.io/mistercalvin/dxhx-coop-server:latest
    build:
      context: .
    container_name: dxhx-coop-server
    environment:
      - "PUID=1000" # Optional: Set the UID for the user inside the container; Default: 1000
      - "PGID=1000" # Optional: Set the GID for the user inside the container; Default: 1000
      - "SERVER_NAME=" # Optional: Name of your server; Default: Another Docker HX Coop Server
      - "SERVER_PASSWORD=" # Optional: Server password. Clients will need the DXMTL mod installed to enter passwords, or type the following in console: open <youripaddress>:<port>?password=<password> in order to connect; Default: unset
      - "SERVER_PORT=" # Optional: Port the Server will listen on; Default: 7990
      - "SERVER_INI=" # Optional: Specify a custom server configuration file; Default: unset
      - "ADMIN_PASSWORD=" # Optional: Admin password (if empty admin login will be disabled); Default: unset
      - "MAP=01_NYC_UNATCOHQ" # Requird: Map to play; Default: 00_Training
      - "MUTATORS=" # Optional: A comma-separated list of Mutators to load; Default: unset
      - "MAX_PLAYERS=8" # Optional, Max Players for the server; Default: 8
      - "DIFFICULTY=1" # Optional: Specify game difficulty, 0 = Easy, 1 = Medium, 2 = Hard, or 3 = DeusEx (Realistic); Default: 1 (Medium)
      - "RESTORE_PROGRESS=False" # Optional: Server will change to last known map if server crashes or shuts down. This is experimental and is not guaranteed to work; Default: False
      - "ADDITIONAL_ARGS=" # Optional: Pass additional arguments such as multihome or specify a custom log file; Default: unset
    volumes:
      - /path/to/your/gamefiles/:container/deusex
    ports:
      - 7990-7992:7990-7992/udp
    restart: unless-stopped
```

### docker cli

```
docker run -d \
  --name=dxhx-coop-server \
  -e PUID="1000" \
  -e PGID="1000" \
  -e SERVER_NAME="" \
  -e SERVER_PASSWORD="" \
  -e SERVER_INI="" \
  -e SERVER_PORT="" \
  -e ADMIN_PASSWORD="" \
  -e MAP="00_Training" \
  -e MUTATORS="" \
  -e MAX_PLAYERS="8" \
  -e DIFFICULTY="1" \
  -e RESTORE_PROGRESS="False" \
  -e ADDITIONAL_ARGS="" \
  -p 7990-7992:7990-7992/udp \
  -v /path/to/gamefiles/:/container/deusex \
  --restart unless-stopped \
  ghcr.io/mistercalvin/dxhx-coop-server:latest
```
  
## Server Ports
DXHX requires Base Port + 2 (Default port is 7990, so 7990-7992/udp)

| Port      | Default  |
|-----------|----------|
| Join 		| 7990/udp|
| ServerQuery     | 7991/udp|
| ServerUplink       	| 7992/udp|

## User / Group Identifiers
Taking a page from linuxserver.io's book, I have adapted the container to allow for configurable UID & GID mapping. If you would like to know more, please see [their page](https://docs.linuxserver.io/general/understanding-puid-and-pgid) on the topic. If you are unsure of what this is I recommend leaving `PUID` and `PGID` at their default values of `1000`.

Please note this does not change file permissions on the mounted volume (`/container/deusex`), it only changes the default container users (`wine`) UID/GID to the specified value. Make sure proper permissions are applied to the game files directory on the host.

## Building
If you intend to build the Dockerfile yourself, I have not pinned the packages as Alpine does not keep old packages. At the time of writing (2023/11/08) I have built and tested the container with the following package versions:

| Package   			  | Version  	 |
|-------------------------|--------------|
| i386/alpine			  | 3.18.4     	 |
| wine     				  | 8.19-r0	     |
| shadow                  | 4.14.2-r0      |
| wget					  | 1.21.4-r0	 |
| s6-overlay              | 3.1.6.0      |

## Features / TODO
Restore Progress (Experimental) - If enabled, server will attempt to restore previous game progress (level, inventories) after it has been shutdown or crashed. This is currently experimental and may not work. TODO: Level needs to be reloaded after initially launched (each time the server executable is restarted it will delete all files in `CoopSave/ServerCurrent/`), can we skip doing this by making the save files immutable so HX cannot delete them?
- [ ] Reduce image size? Image is currently 432MB, check to see if we can remove any unused Wine directories to save on space
- [ ] Some variables do not have command line options (notably, servername), will need to edit server ini files if we intend to update these via docker-compose .env vars. Look in to custom ini file structure and possibly custom logs
- [ ] Is there any form of RCON available for Deus Ex? It does not seem to support it out of the box, and the only Mutator I could find was extremely convoluted
- [ ] Write documentation
