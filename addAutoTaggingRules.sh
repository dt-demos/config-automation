#!/bin/bash

# reference: https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/configuration/auto-tag-api/

CREDS_FILE=creds.json
RULES_DIR=./autoTaggingRules
source ./common.lib
validate_creds_file $CREDS_FILE

echo "======================================================================"
echo "About to configure these items to $DT_TENANT_HOSTNAME"
ls -1 $RULES_DIR
echo "======================================================================"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

# Loop through the files rules subfolder and make a rule per file
for file in `ls -1 $RULES_DIR`; do

  DT_RULE_NAME="$file"
  FILE_PATH="$RULES_DIR/$file"

  echo ""
  echo ""
  echo "==================================================================================="
  echo "Processing $DT_RULE_NAME"
  echo "==================================================================================="
  echo "----------------------------------------------------"
  echo "Checking if $DT_RULE_NAME exists"
  echo "----------------------------------------------------"
  DT_ID=$(curl -s -X GET \
    "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache' \
    | jq -r '.values[] | select(.name == "'$DT_RULE_NAME'") | .id')

  # if exists, then delete it
  if [ "$DT_ID" != "" ]
  then
    echo "----------------------------------------------------"
    echo "Deleting $DT_RULE_NAME since exists (ID = $DT_ID)"
    echo "----------------------------------------------------"
    curl -X DELETE \
    "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags/$DT_ID?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -H 'cache-control: no-cache'
    sleep 10
  fi

  if [ "$1" != "--noadd" ]; then
    echo "----------------------------------------------------"
    echo "Adding $DT_RULE_NAME"
    echo "----------------------------------------------------"
    curl -X POST \
      "https://$DT_TENANT_HOSTNAME/api/config/v1/autoTags?Api-Token=$DT_API_TOKEN" \
      -H 'Content-Type: application/json' \
      -H 'cache-control: no-cache' \
      -d @$FILE_PATH
    fi
done

echo ""
echo "==================================================================================="
echo "Complete"
echo ""
