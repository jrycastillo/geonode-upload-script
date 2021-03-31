#! /usr/bin/bash
NOCOLOR='\033[0m'
RED='\033[1;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LIGHTBLUE='\033[1;34m'
CYAN='\033[0;36m'

url="http://192.168.6.113/api/layers"
metadata_file=metadataUpdate.json
data_list=lists.txt

echo -e "\n${CYAN}GEONODE METADATA UPDATE${NOCOLOR}"

read -p "GeoNode Username: " username;
read -sp "GeoNode Password: " password;

echo -e "\n${GREEN}Updating GeoNode Layers Metadata.${NOCOLOR}"

layer_id=$(curl -s -u $username:$password -XGET "{$url}/" | jq '.objects[] | .id')

for i in ${layer_id[@]};
do
        ext_end=$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.temporal_extent_end')
        ext_start=$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.temporal_extent_start')
        layer_title=$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq -r '.title')

        if [[ ${ext_end} = null && ${ext_start} = null ]];
        then
                FS=" ";while read line;
                do
                        line=($line);
                        
                        if [ "$line" = "$layer_title" ]
                        then
                                mv $metadata_file temp.json
                                extent_start="${line[1]}" extent_end="${line[2]}"  jq -r '.temporal_extent_start |= env.extent_start | .temporal_extent_end |= env.extent_end' temp.json > $metadata_file
                                rm temp.json
                                curl -s -u $username:$password -XPATCH -H "Content-type: application/json" -d @$metadata_file "{$url}/${i[@]}/"
                                echo -e "\n${CYAN}Temporal extent for this layer has been set.${NOCOLOR}"
                                echo -e "Title: ${GREEN}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.title')${NOCOLOR}"
                                echo -e "Workspace: ${GREEN}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.workspace')${NOCOLOR}"
                                echo -e "Temporal Extent Start: ${CYAN}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.temporal_extent_start')${NOCOLOR}"
                                echo -e "Temporal Extent End: ${CYAN}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.temporal_extent_end')${NOCOLOR}"
                                echo -e "";
                                
#                       elif [ "$layer_title" != "$line" ]
#                       then
#                               echo -e "${ORANGE}Layer not found in the list. (Please include in the $data_list file.)${NOCOLOR}"
#                               echo -e "Title: ${GREEN}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.title')${NOCOLOR}"
#                               echo -e "Workspace: ${GREEN}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.workspace')${NOCOLOR}"
#                               echo -e "Temporal Extent Start: ${CYAN}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.temporal_extent_start')${NOCOLOR}"
#                               echo -e "Temporal Extent End: ${CYAN}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.temporal_extent_end')${NOCOLOR}"
#                               echo -e "";
#                               break
                        fi
                done < $data_list
        else
                echo -e "${RED}Temporal extent for this layer is already set.${NOCOLOR}"
                echo -e "Title: ${GREEN}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.title')${NOCOLOR}"
                echo -e "Workspace: ${GREEN}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.workspace')${NOCOLOR}"
                echo -e "Temporal Extent Start: ${RED}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.temporal_extent_start')${NOCOLOR}"
                echo -e "Temporal Extent End: ${RED}$(curl -s -u $username:$password -XGET "{$url}/$i/" | jq '.temporal_extent_end')${NOCOLOR}"
                echo -e ""
        fi
done
