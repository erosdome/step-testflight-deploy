#!/bin/bash

function echoStatusFailed {
  echo "export TESTFLIGHT_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
  echo
  echo "TESTFLIGHT_DEPLOY_STATUS: \"failed\""
  echo " --------------"
}

# default values

if [[ $TESTFLIGHT_NOTES ]]; then
	notes=$TESTFLIGHT_NOTES
else
	notes="Automatic build with Bitrise."
fi

notif_lower=`echo $TESTFLIGHT_NOTIFY | tr '[:upper:]' '[:lower:]'`
notify=""
if [[ $TESTFLIGHT_NOTIFY ]] && [[ "$notif_lower" = "true" ]]; then
	notify="true"
fi

replace_lower=`echo $TESTFLIGHT_REPLACE | tr '[:upper:]' '[:lower:]'`
replace=""
if [[ $TESTFLIGHT_REPLACE ]] && [[ "$replace_lower" = "true" ]]; then
	replace="true"
fi

echo "BITRISE_IPA_PATH: $BITRISE_IPA_PATH"
echo "BITRISE_DSYM_PATH: $BITRISE_DSYM_PATH"
echo "TESTFLIGHT_API_TOKEN: $TESTFLIGHT_API_TOKEN"
echo "TESTFLIGHT_TEAM_TOKEN: $TESTFLIGHT_TEAM_TOKEN"
echo "TESTFLIGHT_NOTIFY: $notify"
echo "TESTFLIGHT_NOTES: $notes"
echo "TESTFLIGHT_REPLACE: $replace"
echo "TESTFLIGHT_DISTRIBUTION_LIST: $TESTFLIGHT_DISTRIBUTION_LIST"

# test if files exist

# IPA
if [[ ! -f "$BITRISE_IPA_PATH" ]]; then
  echo
  echo "No IPA found to deploy. Terminating..."
  echo
  echoStatusFailed
  exit 1
fi

# dSYM if provided
if [[ $BITRISE_DSYM_PATH ]]; then
	if [[ ! -f "$BITRISE_DSYM_PATH" ]]; then
    echo
    echo "No DSYM found to deploy. Terminating..."
    echo
    echoStatusFailed
    exit 1
	fi
fi

# API token
if [[ ! $TESTFLIGHT_API_TOKEN ]]; then
  echo
  echo "No API token provided as environment variable. Terminating..."
  echo
  echoStatusFailed
  exit 1
fi

# Team token
if [[ ! $TESTFLIGHT_TEAM_TOKEN ]]; then
  echo
  echo "No Team token provided as environment variable. Terminating..."
  echo
  echoStatusFailed
  exit 1
fi

json=$(/usr/bin/curl http://testflightapp.com/api/builds.json \
	-F "file=@$BITRISE_IPA_PATH" \
	-F "dsym=@$BITRISE_DSYM_PATH" \
	-F "api_token=$TESTFLIGHT_API_TOKEN" \
	-F "team_token=$TESTFLIGHT_TEAM_TOKEN" \
	-F "distribution_lists=$TESTFLIGHT_DISTRIBUTION_LIST" \
	-F "notes=$notes" \
	-F "notify=$notify" \
	-F "replace=$replace" \
	)

echo " --- Result ---"
echo "$json"
echo " --------------\n"

# ERROR CHECK - if not json result, then something bad happened

if [[ ! $json =~ }.* ]]; then
  echo " --FAILED--"
  echo "$json"
  echoStatusFailed
  exit 1
fi

# everything is OK

echo "export BITRISE_DEPLOY_STATUS=\"success\"" >> ~/.bash_profile
echo "export TESTFLIGHT_DEPLOY_STATUS=\"success\"" >> ~/.bash_profile

# install url
install_url=$(ruby ./util-jsonval/parse_json.rb \
  --json-string="$json" \
  --prop=install_url)

echo "export BITRISE_DEPLOY_URL=\"$install_url\"" >> ~/.bash_profile
echo "export TESTFLIGHT_DEPLOY_INSTALL_URL=\"$install_url\"" >> ~/.bash_profile

# config url
config_url=`ruby ./util-jsonval/parse_json.rb \
  --json-string="$json" \
  --prop=config_url`
echo "export TESTFLIGHT_DEPLOY_CONFIG_URL=\"$config_url\"" >> ~/.bash_profile

# final results
echo
echo "--SUCCESS--"
echo "output env vars="
echo "TESTFLIGHT_DEPLOY_STATUS: \"success\""
echo "TESTFLIGHT_DEPLOY_INSTALL_URL: \"$install_url\""
echo "TESTFLIGHT_DEPLOY_CONFIG_URL: \"$config_url\""
echo " --------------"

exit 0