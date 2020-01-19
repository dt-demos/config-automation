#!/bin/bash

DT_TENANT_HOSTNAME=$1
DT_API_TOKEN=$2
CONFIG_NAME=$3 
CONFIG_API_NAME=$4
CONFIG_LABEL=$5

# if did not pass in a CONFIG_NAME, then just return a list of existing ones
if [ -z "$CONFIG_NAME" ]; then
  echo ""
  echo "$CONFIG_LABEL"
  echo "------------------------------------"
  curl -s -X GET \
    "https://$DT_TENANT_HOSTNAME/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' | \
    jq -r '.values[] | .name' | sort
else
  # get the id based on the name
  DT_ID=$(curl -s -X GET \
    "https://$DT_TENANT_HOSTNAME/api/config/v1/$CONFIG_API_NAME?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    | jq -r '.values[] | select(.name == "'$CONFIG_NAME'") | .id')

  # if exists, then show it
  if [ "$DT_ID" != "" ]; then
    echo ""
    echo "------------------------------------------------------------"
    echo "$CONFIG_LABEL: $CONFIG_NAME detail"
    echo "------------------------------------------------------------"
    curl -s -X GET \
        "https://$DT_TENANT_HOSTNAME/api/config/v1/$CONFIG_API_NAME/$DT_ID?Api-Token=$DT_API_TOKEN" \
        -H 'Content-Type: application/json' \
        -H 'cache-control: no-cache'  \
        | jq -r '.'
  else
    echo "------------------------------------------------------------"
    echo "Did not find $CONFIG_LABEL: $CONFIG_NAME"
    echo "------------------------------------------------------------"
  fi
fi