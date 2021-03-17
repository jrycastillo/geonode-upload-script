#! /usr/bin/bash

read -p "GeoServer Username: " username
echo "GeoServer Password: "
read -s password

import_id=$(curl -s -u $username:$password -XPOST -H "Content-type: application/json" -d @import.json "http://192.168.6.113/geoserver/rest/imports" | jq '.import.id')

# import_state=$(curl -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.import.state')

# echo $import_id
# echo $import_state

# if [[ $import_state = PENDING ]]; then

echo "Initiating an import to GeoServer and preparing tasks."
echo "STATUS:"
curl -s -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.import.href, .import .state'
curl -s -u $username:$password -XPOST "http://192.168.6.113/geoserver/rest/imports/{$import_id}"

echo "Importing data files to GeoServer."
curl -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/{$import_id}" | jq '.'

# fi

echo "Updating GeoNode Layers."
docker exec -it d379f67a81ef python manage.py updatelayers --skip-geonode-registered
