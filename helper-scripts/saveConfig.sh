#!/bin/bash

DT_TENANT_HOSTNAME=$1
DT_API_TOKEN=$2
CONFIG_NAME=$3
CONFIG_FILE_DIR=$4
CONFIG_API_NAME=$5
CONFIG_LABEL=$6

# get the id based on the name
DT_ID=$(curl -s -X GET \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  | jq -r '.values[] | select(.name == "'$CONFIG_NAME'") | .id')

# if exists, then show it
if [ "$DT_ID" != "" ]; then
  echo "------------------------------------------------------------"
  echo "Saving $CONFIG_LABEL: $CONFIG_NAME"
  echo "------------------------------------------------------------"
  curl -s -X GET \
      "https://$DT_TENANT_HOSTNAME/api/config/v1/$CONFIG_API_NAME/$DT_ID?Api-Token=$DT_API_TOKEN" \
      -H 'Content-Type: application/json' \
      -H 'cache-control: no-cache' \
      | jq -r 'del(.id,.metadata)' > "$CONFIG_FILE_DIR/$CONFIG_NAME"
else
  echo "------------------------------------------------------------"
  echo "Did not find $CONFIG_LABEL: $CONFIG_NAME"
  echo "------------------------------------------------------------"
fi
