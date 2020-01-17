#!/bin/bash

# reference: https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/configuration-api/management-zones-api/

CREDS_FILE=creds.json
DT_RULE_NAME=$1

source ./common.lib
validate_creds_file $CREDS_FILE

# get all zones if not passed in
if [ -z "$DT_RULE_NAME" ]; then
  echo ""
  echo "Management Zone List"
  echo "--------------------"
  curl -s -X GET \
    "https://$DT_TENANT_HOSTNAME/api/config/v1/managementZones?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    | jq -r '.values[] | .name' | sort

else
  # get the ID based on the name
  DT_ID=$(curl -s -X GET \
    "https://$DT_TENANT_HOSTNAME/api/config/v1/managementZones?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    | jq -r '.values[] | select(.name == "'$DT_RULE_NAME'") | .id')

  # if exists, then show the details
  if [ "$DT_ID" != "" ]; then
    echo ""
    echo "------------------------------------------------------------"
    echo "Details for Management Zone: $DT_RULE_NAME"
    echo "------------------------------------------------------------"
    curl -s -X GET \
        "https://$DT_TENANT_HOSTNAME/api/config/v1/managementZones/$DT_ID?Api-Token=$DT_API_TOKEN" \
        -H 'Content-Type: application/json' \
        -H 'cache-control: no-cache' \
        | jq -r '.'
  else
    echo "------------------------------------------------------------"
    echo "Did not find rule: $DT_RULE_NAME"
    echo "------------------------------------------------------------"
  fi
fi
echo ""
echo ""