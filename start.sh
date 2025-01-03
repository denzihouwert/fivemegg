#!/bin/bash
## Make Colorful text for the console
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'

Text="${GREEN}[STARTUP]${NC}"

echo -e "${Text} ${BLUE}Starting checks for all updates...${NC}"
RELEASE_PAGE=$(curl -sSL https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/)
CHANGELOGS_PAGE=$(curl -sSL https://changelogs-live.fivem.net/api/changelog/versions/linux/server)

if [[ "${AUTO_UPDATE}" == "1" ]]; then
    DOWNLOAD_LINK=$(echo $CHANGELOGS_PAGE | jq -r '.latest_download')

    rm -rf /home/container/alpine > /dev/null 2>&1

    echo -e "${Text} ${BLUE}Updating CitizenFX Resource Files...${NC}"

    curl -sSL ${DOWNLOAD_LINK} -o ${DOWNLOAD_LINK##*/} > /dev/null 2>&1
    tar -xvf ${DOWNLOAD_LINK##*/} > /dev/null 2>&1
    rm -rf ${DOWNLOAD_LINK##*/} run.sh > /dev/null 2>&1

    echo -e "${Text} ${BLUE}CitizenFX Resources updated successfully!${NC}"
else 
    echo -e "${Text} ${BLUE}Auto Update is disabled!${NC}"
fi

echo -e "${Text} ${BLUE}Setting txAdmin credentials...${NC}"
if [[ "${TXADMIN_ENABLE}" == "1" ]]; then
if [ -z "$TXADMIN_USER" ]; then
    echo -e "${Text} ${RED}txAdmin username is not set! Please set TXADMIN_USER in Pterodactyl settings.${NC}"
    exit 1
fi

if [ -z "$TXADMIN_PASSWORD" ]; then
    echo -e "${Text} ${RED}txAdmin password is not set! Please set TXADMIN_PASSWORD in Pterodactyl settings.${NC}"
    exit 1
fi

echo -e "${Text} ${BLUE}Starting FiveM Server with custom txAdmin username and password...${NC}"

# Start the server with the specified txAdmin credentials
$(pwd)/alpine/opt/cfx-server/ld-musl-x86_64.so.1 --library-path "$(pwd)/alpine/usr/lib/v8/:$(pwd)/alpine/lib/:$(pwd)/alpine/usr/lib/" -- $(pwd)/alpine/opt/cfx-server/FXServer +set citizen_dir $(pwd)/alpine/opt/cfx-server/citizen/ +set sv_licenseKey ${FIVEM_LICENSE} +set steam_webApiKey ${STEAM_WEBAPIKEY} +set sv_maxplayers ${MAX_PLAYERS} +set serverProfile default +set txAdminPort ${TXADMIN_PORT} +set txAdminUser ${TXADMIN_USER} +set txAdminPassword ${TXADMIN_PASSWORD} $( [ "$TXADMIN_ENABLE" == "1" ] || printf %s '+exec server.cfg' )
