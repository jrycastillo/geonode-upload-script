
#! /usr/bin/bash

read -p "GeoServer Username: " username
echo "GeoServer Password: "
read -s password

import_id=$(curl -s -u $username:$password -XPOST -H "Content-type: application/json" -d @import.json "http://192.168.6.113/geoserver/rest/imports" | jq '.import.id')

echo "Initiating an import to GeoServer and preparing tasks."
curl -s -u $username:$password -XPOST "http://192.168.6.113/geoserver/rest/imports/{$import_id}"

import_state=$(curl -s -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.import | .state')
task_state=$(curl -s -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.import.tasks[0] | .state')

if [[ ${import_state} = '"PENDING"' && ${task_state} = '"ERROR"' ]];
then
        echo "Error in uploading layers. (Duplicated Layers)"
else
        echo "Importing data files to GeoServer."
        curl -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.'
        echo "Updating GeoNode Layers."
        docker exec -it d379f67a81ef python manage.py updatelayers --skip-geonode-registered
fi
