#!/bin/bash

DT_TENANT_HOSTNAME=$1
DT_API_TOKEN=$2
CONFIG_NAME=$3
CONFIG_API_NAME=$4
CONFIG_LABEL=$5

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
else
  echo "$CONFIG_LABEL $CONFIG_NAME does not exist"
fi
