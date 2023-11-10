# Deus Ex Coop Dedicated Server
A Docker container for running a dedicated Deus Ex Coop server under Wine, built on Alpine. The container is built with the latest build of [DXHX](https://wiki.deusexcoop.com/index.php?title=Getting_Started) (Build `HX-0.9.89.4`) which can be installed with `HX_INSTALL="True"` in your docker compose file or docker run command. Your game directory (mounted in the container as `/container/deusex`) should be structured as follows:

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
    container_name: dxhx-coop-server
    environment:
      - "PUID=1000" # Optional: Set the UID for the user inside the container; Default: 1000
      - "PGID=1000" # Optional: Set the GID for the user inside the container; Default: 1000
      - "SERVER_NAME=" # Optional: Name of your server; Default: Another Docker HX Coop Server
      - "SERVER_PASSWORD=" # Optional: Server password. Clients will need the DXMTL mod installed to enter passwords, or type the following in console: open <youripaddress>:<port>?password=<password> in order to connect; Default: unset
      - "SERVER_PORT=" # Optional: Port the Server will listen on; Default: 7990
      - "SERVER_INI=" # Optional: Specify a custom server configuration file; Default: unset
      - "ADMIN_PASSWORD=" # Optional: Admin password (if empty admin login will be disabled); Default: unset
      - "MAP=00_Training" # Requird: Map to play; Default: 00_Training
      - "MUTATORS=" # Optional: A comma-separated list of Mutators to load; Default: unset
      - "MAX_PLAYERS=8" # Optional, Max Players for the server; Default: 8
      - "DIFFICULTY=1" # Optional: Specify game difficulty, 0 = Easy, 1 = Medium, 2 = Hard, or 3 = DeusEx (Realistic); Default: 1 (Medium)
      - "ADDITIONAL_ARGS=" # Optional: Pass additional arguments such as multihome or specify a custom log file; Default: unset
      - "INSTALL_HX=True" # Optional: Container will check for HX files in your game folder, if not found it will install the latest version; Default: unset
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
  -e ADDITIONAL_ARGS="" \
  -e INSTALL_HX="True" \
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

If you change the default port you must update the mapping on boths sides of the container (e.g., if you choose port 5941, you will need to ensure ports are mapped as 5941-5943:5941-5943)

## User / Group Identifiers
Taking a page from linuxserver.io's book, I have adapted the container to allow for configurable UID & GID mapping. If you would like to know more, please see [their page](https://docs.linuxserver.io/general/understanding-puid-and-pgid) on the topic. If you are unsure of what this is I recommend leaving `PUID` and `PGID` at their default values of `1000`.

Please note this will change file permissions on the mounted volume (`/container/deusex`) to the UID & GID set.

## Building
If you intend to build the Dockerfile yourself, I have not pinned the packages as Alpine does not keep old packages. At the time of writing (2023/11/08) I have built and tested the container with the following package versions:

| Package   			  | Version  	 |
|-------------------------|--------------|
| i386/alpine			  | 3.18.4     	 |
| wine     				  | 8.19-r0	     |
| shadow                  | 4.14.2-r0    |
| tzdata                  |	2023c-r1     |
| wget					  | 1.21.4-r0	 |
| s6-overlay              | 3.1.6.0      |

### Credits / Support
This is a fan made Docker image, please [open an issue](https://github.com/MisterCalvin/dxhx-coop-server/issues) if you need support. HX was created by Sebastian Kaufel (han), you can find more information about HX on their [Discord](https://steamcommunity.com/linkfilter/?u=https%3A%2F%2Fdiscord.gg%2FjCFJ3A6)
