#!/bin/bash

DT_TENANT_HOSTNAME=$1
DT_API_TOKEN=$2
CONFIG_NAME=$3
CONFIG_FILE=$4
CONFIG_API_NAME=$5
CONFIG_LABEL=$6

if ! [ -f "$CONFIG_FILE" ]; then
  echo "==================================================================================="
  echo "SKIPPING $CONFIG_LABEL $CONFIG_NAME"
  echo "Missing $CONFIG_FILE file"
  exit
fi

echo "==================================================================================="
echo "Checking if $CONFIG_LABEL $CONFIG_NAME exists"

DT_ID=$(curl -s -X GET \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  | jq -r '.values[] | select(.name == "'$CONFIG_NAME'") | .id')

# if exists, then delete it
if [ "$DT_ID" != "" ]
then
  echo "Deleting $CONFIG_LABEL $CONFIG_NAME (ID = $DT_ID)"
  curl -X DELETE \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/$CONFIG_API_NAME/$DT_ID?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache'
  
  echo "Waiting 10 seconds to ensure $CONFIG_NAME is deleted"
  sleep 10
else
  echo "$CONFIG_LABEL $CONFIG_NAME does not exist"
fi

echo "Adding $CONFIG_LABEL $CONFIG_NAME"
curl -X POST \
  "https://$DT_TENANT_HOSTNAME/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'cache-control: no-cache' \
  -d @$CONFIG_FILE
echo ""
