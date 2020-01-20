# Overview

This project is to show how to use the [Dynatrace configuration API](https://www.dynatrace.com/support/help/extend-dynatrace/dynatrace-api/configuration-api/) with the configuration as code model.

A script named ```dtconfig.sh``` will parse the values in a provided YAML file that defines the various configurations to process.  A configuraton is in a single YAML file and Dynatrace configuration JSON files are in subfolders. See the ```sample/sample.yaml``` and subfolders as examples.

The main use case is to 'save' the Dynatrace configuration into JSON files and then use this files to re-load the configuration.  Getting and deleting configuration is also supported.  Once could have multiple configuration that can be saved and managed in one or more Dynatrace tenants too.

Currently, the following are supported:
* Auto tagging rules
* Management zones
* Request naming rules
* Alerting profiles

**Limitations**
* Config file names can not not have a space. Need to figure out the syntax of jq filter
* If add problem notifications, then need to figure out how to store alerting profile.  Since the  ID is stored in the notification and this id will change when the alering profile is re-added.

# Setup Dynatrace and Credentials file

1. Create a Dynatrace API Token with read/write configuration permissions
1. Copy the file ```creds.template``` to ```creds.json```
1. Edit ```creds.json``` with your Dynatrace host and API Token
1. Install [jq](https://stedolan.github.io/jq/).  This is used within the scripts to process theJSON information.

# Usage

1. Make a subfolder for the configuration
1. Copy ```sample/sample.yaml``` into this subfolder and edit it with the intended configuration types and names.
1. run the ```./dtconfig.sh``` script with the intended action.  

  ```
  Syntax  : ./dtconfig.sh <ACTION> <CONFIG_FILE> <CREDS_FILE>
  example : ./dtconfig.sh get ./sample/sample.yaml

    ACTION      : get, add, delete, save
    CONFIG_FILE : Yaml file with the configuration names to process
    CREDS_FILE  : JSON file with Dynatrace credentials. If not provided"
                  defaults to creds.json
  ```

## 'get' action

This action will parse all the names in the configuration YAML file and call the get configuration Dynatrace API and then just output the JSON information. One does not need subfolders with Dynatrace JSON configuration files, the action just used the name in the configuration YAML file.

  ```
  example : ./dtconfig.sh get ./sample/sample.yaml
  ```

## 'save' action

This action will first delete all the subfolders where the configuration YAML file is located, so be careful when running this.

Then this action will parse all the names in the configuration YAML file and do a few things:
* look for a matching file name in the subfolders where the configuration YAML file is located
* if not found, then skip that config and move to the next one
* if found, save the file contents as the POSTed payload to the add Dynatrace API call to a file with the name of the configuration

  ```
  example : ./dtconfig.sh save ./sample/sample.yaml
  ```

When the JSON is saved to the file, the script will also remove these two sections from the file since it will cause an error if added back into Dynatrace.

    ```
      "metadata": {
        "configurationVersions": [
          0
        ],
        "clusterVersion": "1.183.127.20200108-111113"
      },
      "id": "-5049494235454945810",
    ```

## 'add' action

This will parse all the names in the configuration YAML files and use the Dynatrace JSON configuration file with the same name found in the subfolders to make a new configuration in Dynatrace.  These Dynatrace JSON configuration files were created from the ```save``` action described the previous section.

As the action processes a configuration, it will:
  * verify if already exists in Dynatrace. If it does, then delete it. 
  * add it as a new config in Dynatrace

  ```
  example : ./dtconfig.sh add ./sample/sample.yaml
  ```

## 'delete' action

This will parse all the names in the configuration YAML file and first verify if it exists in Dynatrace. If it does, then delete it. if not found, then skip that config and move to the next one. One does not need subfolders with Dynatrace JSON configuration files, the action just used the name in the configuration YAML file.

  ```
  example : ./dtconfig.sh delete ./sample/sample.yaml
  ```
