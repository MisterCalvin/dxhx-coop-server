# Deus Ex Coop Dedicated Server
A Docker container for running a dedicated Deus Ex Coop server under Wine, built on Alpine. The container is built with the latest build of <a href="https://wiki.deusexcoop.com/index.php?title=Getting_Started" target="_blank">HX Coop</a> (Build `HX-0.9.89.4`).Your game directory (mounted in the container as `/container/deusex`) should be structured as follows:

    .
    ├── ...
    ├── CoopSave
    ├── Maps
    ├── Sounds
    └── System

### docker compose

```
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
      - "MAP=00_Training" # Optional: Map to play; Default: 00_Training
      - "MUTATORS=" # Optional: A comma-separated list of Mutators to load; Default: unset
      - "MAX_PLAYERS=8" # Optional, Max Players for the server; Default: 8
      - "DIFFICULTY=1" # Optional: Specify game difficulty, 0 = Easy, 1 = Medium, 2 = Hard, or 3 = DeusEx (Realistic); Default: 1 (Medium)
      - "ADDITIONAL_ARGS=" # Optional: Pass additional arguments such as multihome or specify a custom log file; Default: unset
      - "DX_RANDOMIZER=False" # Optional: Enable DX Randomizer mod (will also download mod if not available in game folder); Default: False
      - "DX_DEATHMARKERS=True" # Optional: Death Markers show you where other players have died, using a skull icon. It also tells you how they died and when (only for DX Randomizer); Default: True
      - "DX_ENABLE_TELEMETRY=False" # Optional: Enable Online Features for DX Randomizer, including posting in-game events to their Mastodon bot, updating their death marker database, and leaderboards; Default: False
      - "DX_GAMEMODE=0" # Optional: Gamemode for DX Randomizer (0 = Normal, 1 = Randomizer Lite, 2 = Zero Rando, 3 = Serious Sam Mode, 4 = Speedrun Mode, 5 = WaltonWare); Default: 0 (Normal)
      - "DX_LOADOUT=0" # Optional: Choose the load for DX Randomizer (0 = All Items Allowed, 1 = Prod Plus, 2 = Prod Pure, 3 = Ninja JC, 4 = By the Book, 5 = No Overpowered, 6 = Don't Give me the GEP Gun, 7 = No Pistaols, 8 = No Swords, 9 = Grenades Only, 10 = Freeman Mode; Default = 0 (All Items Allowed))
      - "DX_AUTOUPDATE=True" # Optional: Grab latest version of DX Randomizer on each container boot. See disclaimers in README.md; Default: True
    volumes:
      - /path/to/your/gamefiles/:container/deusex
      - dxhx-coop-wine:/container/.wine
    ports:
      - 7990-7992:7990-7992/udp
    restart: unless-stopped

volumes:
  dxhx-coop-wine:
    name: dxhx-coop-wine
```

### docker cli
Create a named volume before executing the command below: docker volume create dxhx-coop-wine (this will persist your .wine directory, allowing for quicker server startup times)

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
  -e DX_RANDOMIZER="False" \
  -e DX_DEATHMARKERS="True" \
  -e DX_ENABLE_TELEMETRY="False" \
  -e DX_GAMEMODE="0" \
  -e DX_LOADOUT="0" \
  -e DX_AUTOUPDATE="True" \
  -p 7990-7992:7990-7992/udp \
  -v /path/to/gamefiles/:/container/deusex \
  -v dxhx-coop-wine:/container/.wine \
  --restart unless-stopped \
  ghcr.io/mistercalvin/dxhx-coop-server:latest
```
  
## Server Ports
HX Coop requires Base Port + 2 (Default port is 7990, so 7990-7992/udp)

| Port         | Default  |
| ------------ | -------- |
| Join 		     | 7990/udp |
| ServerQuery  | 7991/udp |
| ServerUplink | 7992/udp |

If you change the default port you must update the mapping on boths sides of the container (e.g., if you choose port `5941`, you will need to ensure ports are mapped as `5941-5943:5941-5943`)

## User / Group Identifiers
Taking a page from linuxserver.io's book, I have adapted the container to allow for configurable UID & GID mapping. If you would like to know more, please see <a href="https://docs.linuxserver.io/general/understanding-puid-and-pgid" target="_blank">their page</a> on the topic. If you are unsure of what this is I recommend leaving `PUID` and `PGID` at their default values of `1000`.

Please note this will change file permissions on the mounted volume (`/container/deusex`) to the UID & GID set.
## Disclaimers / Bugs
- If you enable DX_AUTOUPDATE, the container will check the DX Randomizer GitHub repo for a new version at each boot (this is limited to once per hour to avoid public API rate limits). Any user who connects to your server who does not have DX Randomizer installed will automatically fetch it from your server, and will continue to fetch updates from the server whenever an update is available. However, if a user manually installs DX Randomizer, they will need to update their version manually each time an update is available, otherwise they will receive a file mistmatch error.

## Building
If you intend to build the Dockerfile yourself, I have not pinned the packages as Alpine does not keep old packages. At the time of writing (2024/04/29) I have built and tested the container with the following package versions:

| Package   			               | Version   |
| ------------------------------ | --------- |
| alpine		                     | 3.19.1    |
| wine (**i386 only**)     	     | 9.0-r0	   |
| hangover-wine (**arm64 only**) | 9.5-r0	   |
| bash                           | 5.2.21-r0 |
| tzdata      		               | 2024a-r0	 |
| shadow                         | 4.14.2-r0 |
| wget					                 | 1.24.5-r0 |
| figlet                         | 2.2.5-r3  |
| jq                             | 1.7.1-r0  |
| s6-overlay                     | 3.1.6.2   |

## ARM64 Support
This container has been adapted for use on ARM64 processors by utilizing the project <a href="https://github.com/AndreRH/hangover" target="_blank">AndreRH/hangover</a>. ARM64 support is experimental and was only tested on a Raspberry Pi 4, you may experience additional bugs.

### Credits / Support
This is repo is not affiliated with the HX project, if you are having issues with the Docker container specifically, please [open an issue](https://github.com/MisterCalvin/dxhx-coop-server/issues). HX was created by Sebastian Kaufel (han), you can find more information about HX on their <a href="https://steamcommunity.com/linkfilter/?u=https%3A%2F%2Fdiscord.gg%2FjCFJ3A6" target="_blank">Discord</a>. Deus Ex Randomizer is created by Die4Ever and TheAstropath, you can find their page <a href="https://github.com/Die4Ever/deus-ex-randomizer" target="_blank">here</a>
