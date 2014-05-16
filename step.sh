#!/bin/bash
source ./util-jsonval/step.sh

# default values

if [ ${TESTFLIGHT_NOTES+x} ]; then
	notes=$TESTFLIGHT_NOTES
else
	notes="Automatic build with Concrete."
fi

notif_lower=`echo $TESTFLIGHT_NOTIFY | tr '[:upper:]' '[:lower:]'`
notify=""
if [ ${TESTFLIGHT_NOTIFY+x} ] && [ "$notif_lower" = 'true' ]; then
	notify="true"
fi

replace_lower=`echo $TESTFLIGHT_REPLACE | tr '[:upper:]' '[:lower:]'`
replace=""
if [ ${TESTFLIGHT_REPLACE+x} ] && [ "$replace_lower" = 'true' ]; then
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
  echo "export CONCRETE_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
  echo "export TESTFLIGHT_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
  exit 1
fi

# dSYM if provided
if [ ${CONCRETE_DSYM_PATH+x} ]; then
	if [[ ! -f "$CONCRETE_DSYM_PATH" ]]; then
    echo "No DSYM found to deploy"
    echo "export CONCRETE_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
    echo "export TESTFLIGHT_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
    exit 1
	fi
fi

# API token
if [ ! ${TESTFLIGHT_API_TOKEN+x} ]; then
    echo "No API token found"
    echo "export CONCRETE_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
    echo "export TESTFLIGHT_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
    exit 1
fi

# Team token
if [ ! ${TESTFLIGHT_TEAM_TOKEN+x} ]; then
    echo "No Team token found"
    echo "export CONCRETE_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
    echo "export TESTFLIGHT_DEPLOY_STATUS=\"failed\"" >> ~/.bash_profile
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
echo " --------------"

prop='install_url'
install_url=`jsonval`

# TODO ERROR CHECK

echo "export CONCRETE_DEPLOY_STATUS=\"success\"" >> ~/.bash_profile
echo "export TESTFLIGHT_DEPLOY_STATUS=\"success\"" >> ~/.bash_profile

echo "export CONCRETE_DEPLOY_URL=\"$install_url\"" >> ~/.bash_profile
echo "export TESTFLIGHT_DEPLOY_URL=\"$install_url\"" >> ~/.bash_profile

echo "CONCRETE_DEPLOY_URL: \"$install_url\""
echo "TESTFLIGHT_DEPLOY_URL: \"$install_url\""

exit 0