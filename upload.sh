#! /usr/bin/bash
NOCOLOR='\033[0m'
RED='\033[1;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LIGHTBLUE='\033[1;34m'
CYAN='\033[0;36m'

read -p "GeoServer Username: " username;
read -sp "GeoServer Password: " password;

# while read username password; do
# curl -iL --data-urlencode  username=$username --data-urlencode password=$password http://192.168.6.113/geoserver/web
# done
# docker exec -it d379f67a81ef python manage.py updatelayers --skip-geonode-registered -i --remove-deleted --traceback

import_id=$(curl -s -u $username:$password -XPOST -H "Content-type: application/json" -d @import.json "http://192.168.6.113/geoserver/rest/imports" | jq '.import.id')
task_id=$(curl -s -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.import.tasks[] | .id')

for i in ${task_id[@]};
do
        if [[ ${task_id} = 0 || ${task_id} > 0 ]];
        then
                curl -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}/tasks/$i/layer/" | jq '.'
        fi
done

echo -e "\n${GREEN}Initiating an import to GeoServer and preparing tasks.${NOCOLOR}"
curl -s -u $username:$password -XPOST "http://192.168.6.113/geoserver/rest/imports/{$import_id}"

import_state=$(curl -s -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.import | .state')
task_state=$(curl -s -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.import.tasks[] | .state')

for i in ${task_state[@]};
do
        if [[ ${import_state} = '"PENDING"' && ${task_state[@]} =~ '"COMPLETE"' ]];
        then
                echo -e "${RED}Some layers are already existing in GeoServer.${NOCOLOR}"
                echo -e "${ORANGE}Uploading not existing layers.${NOCOLOR}"
                echo -e "${GREEN}Importing data files to GeoServer.${NOCOLOR}\n"
                curl -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '. | .import.tasks[] | select(.state == "COMPLETE")'
                echo -e "\n${CYAN}Fetching data from GeoServer to GeoNode.\nUpdating GeoNode Layers.${NOCOLOR}"
                docker exec -it d379f67a81ef python manage.py updatelayers -v 3 --traceback --ignore-errors
                break
        elif [[ ${import_state} = '"PENDING"' && ${task_state[@]} != '"ERROR"' ]];
        then
                echo -e "${RED}Error in uploading layers.\nAll layers are existing in GeoServer.${NOCOLOR}"
                break
        else
                echo -e "${GREEN}Importing data files to GeoServer.${NOCOLOR}\n"
                curl -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.'
                echo -e "\n${CYAN}Fetching data from GeoServer to GeoNode.\nUpdating GeoNode Layers.${NOCOLOR}"
                docker exec -it d379f67a81ef python manage.py updatelayers -v 3 --traceback --ignore-errors
                break
        fi
done

#if [[ ${import_state} = '"PENDING"' && ${task_state[@]} == '"ERROR"' ]];
#then
#       echo -e "${RED}Error in uploading layers.\nAll layers are duplicated${NOCOLOR}"
#fi

#if [[ ${import_state} = '"PENDING"' && ${task_state[@]} =~ '"ERROR"' ]];
#then
#       echo -e "${RED}Error in uploading layers.\nAll layers are duplicated${NOCOLOR}"
#       echo -e "${RED}Some layers are duplicated.${NOCOLOR}"
#else
#       echo -e "${GREEN}Importing data files to GeoServer.${NOCOLOR}\n"
#        curl -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.'
#        echo -e "\n${LIGHTBLUE}Updating GeoNode Layers.${NOCOLOR}"
#        docker exec -it d379f67a81ef python manage.py updatelayers
#fi
