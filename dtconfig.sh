#!/bin/bash

# common library of shell script functions
source ./helper-scripts/common.lib

# parameters
ACTION=$1
CONFIG_FILE=$2
CREDS_FILE=$3

if [ $# -lt 2 ]; then
  echo "Aborting: Missing arguments"
  echo "Syntax  : ./dtconfig.sh <ACTION> <CONFIG_FILE> <CREDS_FILE>"
  echo "example : ./dtconfig.sh get ./sample/sample.yaml"
  echo ""
  echo "  ACTION      : get, add, delete, save"
  echo "  CONFIG_FILE : Yaml file with the configuration names to process"
  echo "  CREDS_FILE  : JSON file with Dynatrace credentials. If not provided,"
  echo "                defaults to creds.json"
  echo ""
  exit;
fi

# validate action argument
if ! [[ "$ACTION" =~ ^(get|add|delete|save)$ ]]; then
  echo "Aborting: Invalid ACTION argument. Values: get, add, delete, save"
  exit;
fi

# set default for creds file
if [ -z "$CREDS_FILE" ] ; then
  CREDS_FILE=./creds.json
fi

validate_creds_file $CREDS_FILE
validate_config_file $CONFIG_FILE

# process the configuration YAML file
CONFIG_FILE_DIR=`dirname $CONFIG_FILE`

clear
echo "======================================================================"
echo "About to $ACTION configuration for $DT_TENANT_HOSTNAME"
if [ "$ACTION" == "save" ]; then
  echo ""
  echo "WARNING: this will first delete all files in $CONFIG_FILE_DIR subfolder" 
fi
echo "======================================================================"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
echo ""

# create environment variables from yaml file
create_variables $CONFIG_FILE

#parse_yaml $CONFIG_FILE

# process autotaggingrules
x=0
for autotaggingrule in ${application_autotaggingrules[*]}; do
  CONFIG_NAME="${application_autotaggingrules[x]}"
  CONFIG_DIR="$CONFIG_FILE_DIR/auto-tagging-rules"
  CONFIG_FILE="$CONFIG_DIR/$CONFIG_NAME"
  CONFIG_API_NAME="autoTags"
  CONFIG_LABEL="Auto Tagging Rule"
  execute_action $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" "$CONFIG_DIR" "$CONFIG_API_NAME" "$CONFIG_LABEL"
  x="$((x+1))"
done

# process managementzones
x=0
for managementzone in ${application_managementzones[*]}; do
  CONFIG_NAME="${application_managementzones[x]}"
  CONFIG_DIR="$CONFIG_FILE_DIR/management-zones"
  CONFIG_FILE="$CONFIG_DIR/$CONFIG_NAME"
  CONFIG_API_NAME="managementZones"
  CONFIG_LABEL="Management Zone"
  execute_action $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_DIR $CONFIG_API_NAME "$CONFIG_LABEL"
  x="$((x+1))"
done

# process requestattributes
x=0
for requestattribute in ${application_requestattributes[*]}; do
  CONFIG_NAME="${application_requestattributes[x]}"
  CONFIG_DIR="$CONFIG_FILE_DIR/request-attributes"
  CONFIG_FILE="$CONFIG_DIR/$CONFIG_NAME"
  CONFIG_API_NAME="service/requestAttributes"
  CONFIG_LABEL="Request Attribute"
  execute_action $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_DIR $CONFIG_API_NAME "$CONFIG_LABEL"
  x="$((x+1))"
done

# process alertingprofile
x=0
for alertingprofile in ${application_alertingprofiles[*]}; do
  CONFIG_NAME="${application_alertingprofiles[x]}"
  CONFIG_DIR="$CONFIG_FILE_DIR/alerting-profile"
  CONFIG_FILE="$CONFIG_DIR/$CONFIG_NAME"
  CONFIG_API_NAME="alertingProfiles"
  CONFIG_LABEL="Alerting Profiles"
  execute_action $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_DIR $CONFIG_API_NAME "$CONFIG_LABEL"
  x="$((x+1))"
done

echo "======================================================================"
echo "Done"
echo "======================================================================"
