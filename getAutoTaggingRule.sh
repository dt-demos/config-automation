#!/bin/bash

# reference: https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/configuration/auto-tag-api/

CREDS_FILE=creds.json
DT_RULE_NAME=$1

source ./common.lib
validate_creds_file $CREDS_FILE

if [ -z "$DT_RULE_NAME" ]; then
  echo ""
  echo "Tag Name"
  echo "------------------------------------"
  curl -s -X GET \
    "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' | \
    jq -r '.values[] | .name' | sort
else
  # get the id based on the name
  DT_ID=$(curl -s -X GET \
    "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    | jq -r '.values[] | select(.name == "'$DT_RULE_NAME'") | .id')

  # if exists, then show it
  if [ "$DT_ID" != "" ]; then
    echo ""
    echo "------------------------------------------------------------"
    echo "$DT_RULE_NAME detail"
    echo "------------------------------------------------------------"
    curl -s -X GET \
        "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags/$DT_ID?Api-Token=$DT_API_TOKEN" \
        -H 'Content-Type: application/json' \
        -H 'cache-control: no-cache'  \
        | jq -r '.'
  else
    echo "------------------------------------------------------------"
    echo "Did not find rule: $DT_RULE_NAME"
    echo "------------------------------------------------------------"
  fi
fi

echo ""
echo ""