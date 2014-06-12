#!/bin/bash

function echoStatusFailed {
  echo "export CONCRETE_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
  echo "export TESTFLIGHT_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
  echo
  echo "CONCRETE_DEPLOY_STATUS: \"failed\""
  echo "TESTFLIGHT_DEPLOY_STATUS: \"failed\""
  echo " --------------"
}

# default values

if [[ $TESTFLIGHT_NOTES ]]; then
  notes=$TESTFLIGHT_NOTES
else
  notes="Automatic build with Concrete."
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

echo "CONCRETE_IPA_PATH: $CONCRETE_IPA_PATH"
echo "CONCRETE_DSYM_PATH: $CONCRETE_DSYM_PATH"
echo "TESTFLIGHT_API_TOKEN: $TESTFLIGHT_API_TOKEN"
echo "TESTFLIGHT_TEAM_TOKEN: $TESTFLIGHT_TEAM_TOKEN"
echo "TESTFLIGHT_NOTIFY: $notify"
echo "TESTFLIGHT_NOTES: $notes"
echo "TESTFLIGHT_REPLACE: $replace"
echo "TESTFLIGHT_DISTRIBUTION_LIST: $TESTFLIGHT_DISTRIBUTION_LIST"

# test if files exist

# IPA
if [[ ! -f "$CONCRETE_IPA_PATH" ]]; then
  echo "No IPA found to deploy"
  echoStatusFailed
  exit 1
fi

# dSYM if provided
if [[ $CONCRETE_DSYM_PATH ]]; then
  if [[ ! -f "$CONCRETE_DSYM_PATH" ]]; then
    echo "No DSYM found to deploy"
    echoStatusFailed
    exit 1
  fi
fi

# API token
if [[ ! $TESTFLIGHT_API_TOKEN ]]; then
  echo "No API token found"
  echoStatusFailed
  exit 1
fi

# Team token
if [[ ! $TESTFLIGHT_TEAM_TOKEN ]]; then
  echo "No Team token found"
  echoStatusFailed
  exit 1
fi

json=$(/usr/bin/curl http://testflightapp.com/api/builds.json \
  -F "file=@$CONCRETE_IPA_PATH" \
  -F "dsym=@$CONCRETE_DSYM_PATH" \
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

echo "export CONCRETE_DEPLOY_STATUS=\"success\"" >> ~/.bash_profile
echo "export TESTFLIGHT_DEPLOY_STATUS=\"success\"" >> ~/.bash_profile

# install url
install_url=$(ruby ./util-jsonval/parse_json.rb \
  --json-string="$json" \
  --prop=install_url)

echo "export TESTFLIGHT_DEPLOY_INSTALL_URL=\"$install_url\"" >> ~/.bash_profile

# config url
config_url=`ruby ./util-jsonval/parse_json.rb \
  --json-string="$json" \
  --prop=config_url`
echo "export TESTFLIGHT_DEPLOY_CONFIG_URL=\"$config_url\"" >> ~/.bash_profile

# final results
echo "--SUCCESS--"
echo "output env vars="
echo " CONCRETE_DEPLOY_STATUS: \"success\""
echo " TESTFLIGHT_DEPLOY_STATUS: \"success\""
echo " TESTFLIGHT_DEPLOY_INSTALL_URL: \"$install_url\""
echo " TESTFLIGHT_DEPLOY_CONFIG_URL: \"$config_url\""
echo " --------------"

exit 0