#!/bin/bash

set -e

# Port validation
if ! [[ "$SERVERGAMEPORT" =~ $NUMCHECK ]]; then
    printf "Invalid server port given: %s\\n" "$SERVERGAMEPORT"
    SERVERGAMEPORT="7777"
fi
printf "Setting server port to %s\\n" "$SERVERGAMEPORT"

if ! [[ "$TIMEOUT" =~ $NUMCHECK ]] ; then
    printf "Invalid timeout number given: %s\\n" "$TIMEOUT"
    TIMEOUT="30"
fi
printf "Setting timeout to %s\\n" "$TIMEOUT"

# Game.ini settings.
if ! [[ "$MAXPLAYERS" =~ $NUMCHECK ]] ; then
    printf "Invalid max players given: %s\\n" "$MAXPLAYERS"
    MAXPLAYERS="4"
fi
printf "Setting max players to %s\\n" "$MAXPLAYERS"

# GameUserSettings.ini settings.
if [[ "${ENABLECHEATS,,}" == "true" ]]; then
    printf "ENABLECHEATS=true detected. Enabling cheats on the server\\n"
    ENABLECHEATS="-EnableCheats"
else
    ENABLECHEATS=""
fi

# Validate and set multihome address for network connections (useful for v6-only networks).
if [[ "$MULTIHOME" != "" ]]; then
    if [[ "$MULTIHOME" != "" ]] && [[ "$MULTIHOME" != "::" ]]; then
        # IPv4 regex matches addresses from 0.0.0.0 to 255.255.255.255.
        IPv4='^([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$'

        # IPv6 regex supports full and shortened formats like 2001:db8::1.
        IPv6='^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))$'

        if [[ "$MULTIHOME" =~ $IPv4 ]]; then
            printf "Multihome will accept IPv4 connections only\n"
        elif [[ "$MULTIHOME" =~ $IPv6 ]]; then
            printf "Multihome will accept IPv6 connections only\n"
        else
            printf "Invalid multihome address: %s (defaulting to ::)\n" "$MULTIHOME"
            MULTIHOME="::"
        fi
    fi

    if [[ "$MULTIHOME" == "::" ]]; then
        printf "Multihome will accept IPv4 and IPv6 connections\n"
    fi

    printf "Setting multihome to %s\n" "$MULTIHOME"
    MULTIHOME="-multihome=$MULTIHOME"
fi

# Check if a connection password is set and create the argument
if [[ "$CONNECTIONPASSWORD" != "" ]]; then
    CONNECTIONPASSWORD="-ini:ServerSettings:[/Script/NWX.NWXServerSettings]:Password=$CONNECTIONPASSWORD"
else
    CONNECTIONPASSWORD=""
fi

# Check if an admin password is set and create the argument
if [[ "$ADMINPASSWORD" != "" ]]; then
    ADMINPASSWORD="-ini:ServerSettings:[/Script/NWX.NWXServerSettings]:AdminPassword=$ADMINPASSWORD"
else
    ADMINPASSWORD=""
fi

# Check if difficulty is set and create the argument
if [[ "$STARTINGDIFFICULTY" != "" ]]; then
    STARTINGDIFFICULTY="-ini:ServerSettings:[/Script/NWX.NWXServerSettings]:StartingDifficulty=$STARTINGDIFFICULTY"
else
    STARTINGDIFFICULTY=""
fi

# Handle server status port
if [[ "$SERVERGAMEPORT" = "8888" ]]; then
    SERVERSTATUSPORT="8889"
else
    SERVERSTATUSPORT="8888"
fi

ini_args=(
    "$CONNECTIONPASSWORD"
    "$ADMINPASSWORD"
    "-ini:Game:[/Script/Engine.GameSession]:MaxPlayers=$MAXPLAYERS"
    "$ENABLECHEATS"
    "-statusPort=$SERVERSTATUSPORT"
)

if [[ "${SKIPUPDATE,,}" != "false" ]] && [ ! -f "/config/gamefiles/NWXServer.sh" ]; then
    printf "%s Skip update is set, but no game files exist. Updating anyway\\n" "${MSGWARNING}"
    SKIPUPDATE="false"
fi

if [[ "${SKIPUPDATE,,}" != "true" ]]; then
    STORAGEAVAILABLE=$(stat -f -c "%a*%S" .)
    STORAGEAVAILABLE=$((STORAGEAVAILABLE/1024/1024/1024))
    printf "Checking available storage: %sGB detected\\n" "$STORAGEAVAILABLE"

    if [[ "$STORAGEAVAILABLE" -lt 12 ]]; then
        printf "You have less than 12GB (%sGB detected) of available storage to download the game.\\nIf this is a fresh install, it will probably fail.\\n" "$STORAGEAVAILABLE"
    fi

    printf "\\nDownloading the latest version of the game...\\n"
    steamcmd +force_install_dir /config/gamefiles +login anonymous +app_update "$STEAMAPPID" validate +quit
    cp -r /home/steam/.steam/steam/logs/* "/config/logs/steam" || printf "Failed to store Steam logs\\n"
else
    printf "Skipping update as flag is set\\n"
fi

printf "Launching game server\\n\\n"

if [ ! -f "/config/gamefiles/NWXServer.sh" ]; then
    printf "NWXServer launch script is missing.\\n"
    exit 1
fi

cd /config/gamefiles || exit 1

chmod +x NWXServer.sh || true
./NWXServer.sh -port="$SERVERGAMEPORT" "${ini_args[@]}" "$@" &

sleep 2
SERVERPID="$(ps -eo pid,cmd | grep 'NWXServer-Linux-Shipping' | grep -v grep | awk '{print $1}')"
printf "Server PID detected as: %s\\n" "$SERVERPID"

shutdown() {
    printf "\\nReceived SIGINT or SIGTERM. Shutting down.\\n"
    kill -s 2 $SERVERPID 2>/dev/null
    wait
}
trap shutdown SIGINT SIGTERM

wait
