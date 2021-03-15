#! /usr/bin/bash

read -p "GeoServer Username: " username
echo "GeoServer Password: " 
read -s password

curl -u $username:$password -XPOST -H "Content-type: application/json" -d @import.json "http://192.168.6.113/geoserver/rest/imports"
echo ""
curl -u $username:$password -XPOST "http://192.168.6.113/geoserver/rest/imports/$id"
echo ""
curl -u $username:$password -XGET "http://192.168.6.113/geoserver/rest/imports/"
echo ""

docker exec -it d379f67a81ef bash
$HOME/.override_env; \
    echo DATABASE_URL=$DATABASE_URL; \
    echo GEODATABASE_URL=$GEODATABASE_URL; \
    echo SITEURL=$SITEURL; \
    echo ALLOWED_HOSTS=$ALLOWED_HOSTS; \
    echo GEOSERVER_PUBLIC_LOCATION=$GEOSERVER_PUBLIC_LOCATION; \
    django-admin updatelayers --skip-geonode-registered
# geonode-upload-script
