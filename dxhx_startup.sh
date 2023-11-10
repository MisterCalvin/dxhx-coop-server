#!/command/with-contenv sh
## File: Deus Ex Coop (DXHX) Docker Script - dxhx_startup.sh
## Author: Kevin Moore <admin@sbotnas.io>
## Date: 2023/11/07
## License: MIT License
GAMEDIR=/container/deusex/System
SERVER_INI="$GAMEDIR/${SERVER_INI:=HX.ini}"

sed -i -e "s/^ServerName=.*$/ServerName=${SERVER_NAME:="Another Docker HX Coop Server"}/g;
	s/^AdminPassword=.*$/AdminPassword=$ADMIN_PASSWORD/g" "$SERVER_INI"

wine "$GAMEDIR/HCC.exe" server $MAP${MUTATORS:+"?mutator=$MUTATORS"}${MAX_PLAYERS:+"?MaxPlayers=$MAX_PLAYERS"}${SERVER_PASSWORD:+"?GamePassword=$SERVER_PASSWORD"}?Difficulty=${DIFFICULTY:=1} port=${SERVER_PORT:=7990} ini=$SERVER_INI ${ADDITIONAL_ARGS:-}
