# Overview

These are scripts to demo how to use the Dynatrace APIs for configuration.

# Setup

1. Create a Dynatrace API Token with read/write configuration permissions
1. Copy the file ```creds.template``` to ```creds.json```
1. Edit ```creds.json``` with your Dynatrace host and API Token
1. Install [jq](https://stedolan.github.io/jq/)

# Usage

All the scripts will read the Dynatrace host and API token from the ```creds.json``` file.

## 1. Get all configurations by name

Call the scripts with the GET prefix and no argument:  ```./getXXXXX.sh```

## 2. Get configuration details by name

Call the scripts with the GET prefix an an argument with the name ```./getXXXXX.sh [THE-NAME]```

## 3. Add configurations

The scripts with the ADD prefix loop through all the files in the subfolder such as ```managementZones``` and will for each file:
  * verify if already exists in Dynatrace. If it does, then delete it. 
  * add it as a new config in Dynatrace

To process the files, just call the script ```./addXXXXX.sh```

## 4. Delete configurations

The ADD scripts can also be used to just delete the configuration using the files in the subfolder by passing an ```--noadd``` argument.  For example: ```./addXXXXX.sh --noadd```

# configuration files

To create the files uses in add and delete confirations, follow this recipe:
1. manually make the config in the Dynatrace UI
1. use the ```./getXXXXX.sh [THE-NAME]``` script to get the JSON
1. remove these two sections from the file
    ```
      "metadata": {
        "configurationVersions": [
          0
        ],
        "clusterVersion": "1.183.127.20200108-111113"
      },
      "id": "-5049494235454945810",
    ```
1. Save the file with the **EXACT MATCHING** name as ```"name"``` attribute as found in the JSON file into the subfolder the corresponds to the script you are using.  For example use the ```autotaggingRules/``` folder for the ```addAutoTaggingRules.sh``` file.


