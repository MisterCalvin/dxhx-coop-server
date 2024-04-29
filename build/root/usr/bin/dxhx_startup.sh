#!/command/with-contenv bash
## File: Deus Ex Coop (DXHX) Docker Script - dxhx_startup.sh
## Author: Kevin Moore <admin@sbotnas.io>
## Created: 2023/11/07
## Modified: 2024/04/23
## License: MIT License

exec 2>&1
source /usr/bin/debug.sh

GAMEDIR=/container/deusex/System
SERVER_INI="$GAMEDIR/${SERVER_INI:=HX.ini}"
DX_RANDOMIZER_INI="$GAMEDIR/HXRandomizer.ini"

sed -i -e "s/^ServerName=.*$/ServerName=${SERVER_NAME:="Another Docker HX Coop Server"}/g;
	s/^AdminPassword=.*$/AdminPassword=$ADMIN_PASSWORD/g" "$SERVER_INI"

if [ "${DX_RANDOMIZER^^}" = "TRUE" ]; then

	case ${DX_GAMEMODE^^} in
	    "NORMAL RANDOMIZER"|0)
		    DX_GAMEMODE=0
	        ;;
	    "RANDOMIZER LITE"|1)
		    DX_GAMEMODE=3
	        ;;
        "RANDO MEDIUM"|9)
            DX_GAMEMODE=9
            ;;
	    "ZERO RANDO"|2)
		    DX_GAMEMODE=4
	        ;;
	    "SERIOUS SAM MODE"|3)
		    DX_GAMEMODE=5
	        ;;
	    "SPEEDRUN MODE"|4)
		    DX_GAMEMODE=6
	        ;;
	    "WALTONWARE"|5)
		    DX_GAMEMODE=7
	        ;;
	    *)
	        echo "Could not determine specified DX Gamemode, defaulting to Normal"
		    DX_GAMEMODE=0
	        ;;
	esac

	case "${DX_LOADOUT^^}" in
            "ALL ITEMS ALLOWED"|0)
                    DX_LOADOUT=0
                ;;
            "STICK WITH THE PROD PRUE"|1)
                    DX_LOADOUT=1
                ;;
            "STICK WITH THE PROD PLUS"|2)
                    DX_LOADOUT=2
                ;;
            "NINJA JC"|3)
                    DX_LOADOUT=3
                ;;
            "DON'T GIVE ME THE GEP GUN"|4)
                    DX_LOADOUT=4
                ;;
            "FREEMAN MODE"|5)
                    DX_LOADOUT=5
                ;;
            "GRENADES ONLY"|6)
                    DX_LOADOUT=6
                ;;
            "NO PISTOLS"|7)
                    DX_LOADOUT=7
                ;;
            "NO SWORDS"|8)
                    DX_LOADOUT=8
                ;;
            "NO OVERPOWERED WEAPONS"|9)
                    DX_LOADOUT=9
                ;;
            "BY THE BOOK"|10)
                    DX_LOADOUT=10
                ;;
	    "EXPLOSIVES ONLY"|11)
		    DX_LOADOUT=11
		;;
            *)
                echo "Could not determine specified Loadout, defaulting to All Items Allowed"
                    DX_LOADOUT=0
                ;;
        esac

	sed -i -e "s/^GameMode=.*$/GameMode=${DX_GAMEMODE:="0"}/g;
		s/^loadout=.*$/loadout=${DX_LOADOUT:="0"}/g;
        	s/^death_markers=.*$/death_markers=${DX_DEATHMARKERS:="True"}/g;
		s/^enable=.*$/enable=${DX_ENABLE_TELEMETRY:="False"}/g" "$DX_RANDOMIZER_INI"
	
	echo "DX Randomizer (${DX_VERSION:="Unknown Version"}) enabled..."
    DX_RANDOMIZER_ENABLED="?Game=HXRandomizer.HXRandoGameInfo"
fi


wine "$GAMEDIR/HCC.exe" server "$MAP${DX_RANDOMIZER_ENABLED-""}${MUTATORS:+"?Mutator=$MUTATORS"}${MAX_PLAYERS:+"?MaxPlayers=$MAX_PLAYERS"}${SERVER_PASSWORD:+"?GamePassword=$SERVER_PASSWORD"}?Difficulty=${DIFFICULTY:=1}" port="${SERVER_PORT:=7990}" ini="$SERVER_INI" "${ADDITIONAL_ARGS-""}" 2>&1
