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

# process autotaggingrules
for autotaggingrule in ${application_autotaggingrules[*]}; do
  CONFIG_NAME="$autotaggingrule"
  CONFIG_DIR="$CONFIG_FILE_DIR/auto-tagging-rules"
  CONFIG_FILE="$CONFIG_DIR/$CONFIG_NAME"
  CONFIG_API_NAME="autoTags"
  CONFIG_LABEL="Auto Tagging Rule"
  case $ACTION in
    get)
      ./helper-scripts/getConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
    add)
      ./helper-scripts/addConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_FILE $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
    delete)
      ./helper-scripts/deleteConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
    save)
      rm -rf "$CONFIG_DIR"
      mkdir "$CONFIG_DIR"
      ./helper-scripts/saveConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_DIR $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
  esac
  x="$((x+1))"
done

# process managementzones
for managementzone in ${application_managementzones[*]}; do
  CONFIG_NAME="$managementzone"
  CONFIG_DIR="$CONFIG_FILE_DIR/management-zones"
  CONFIG_FILE="$CONFIG_DIR/$CONFIG_NAME"
  CONFIG_API_NAME="managementZones"
  CONFIG_LABEL="Management Zone"
  case $ACTION in
    get)
      ./helper-scripts/getConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
    add)
      ./helper-scripts/addConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_FILE $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
    delete)
      ./helper-scripts/deleteConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
    save)
      rm -rf "$CONFIG_DIR"
      mkdir "$CONFIG_DIR"
      ./helper-scripts/saveConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_DIR $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
  esac
  x="$((x+1))"
done

# process requestattributes
for requestattribute in ${application_requestattributes[*]}; do
  CONFIG_NAME="$requestattribute"
  CONFIG_DIR="$CONFIG_FILE_DIR/request-attributes"
  CONFIG_FILE="$CONFIG_DIR/$CONFIG_NAME"
  CONFIG_API_NAME="service/requestAttributes"
  CONFIG_LABEL="Request Attribute"
  case $ACTION in
    get)
      ./helper-scripts/getConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
    add)
      ./helper-scripts/addConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_FILE $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
    delete)
      ./helper-scripts/deleteConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
    save)
      rm -rf "$CONFIG_DIR"
      mkdir "$CONFIG_DIR"
      ./helper-scripts/saveConfig.sh $DT_TENANT_HOSTNAME $DT_API_TOKEN "$CONFIG_NAME" $CONFIG_DIR $CONFIG_API_NAME "$CONFIG_LABEL"
      ;;
  esac
  x="$((x+1))"
done

echo "======================================================================"
echo "Done"
echo "======================================================================"
