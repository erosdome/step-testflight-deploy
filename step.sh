#!/bin/bash

if [ -f "$CONCRETE_IPA_PATH" ]; then
  export TF_IPA="$CONCRETE_IPA_PATH"
else
  echo 'No IPA found to deploy'
  exit 1
fi

if [ ! -z "$TESTFLIGHT_TEAM_TOKEN" ]; then
  export TF_TEAM_TOKEN="$TESTFLIGHT_TEAM_TOKEN"
else
  echo 'No team token found'
  exit 1
fi

if [ ! -z "$TESTFLIGHT_API_TOKEN" ]; then
  export TF_API_TOKEN="$TESTFLIGHT_API_TOKEN"
else
  echo 'No api token found'
  exit 1
fi

if [ ! -z "$TESTFLIGHT_NOTES" ]; then
  export TF_NOTES="$TESTFLIGHT_NOTES"
else
  export TF_NOTES="Automatic build with Concrete"
fi

if [ -f "$CONCRETE_DSYM_PATH" ]; then
  export TF_DSYM="$CONCRETE_DSYM_PATH"
fi

if [ $TESTFLIGHT_NOTIFY ]; then
  export TF_NOTIFY=True
else
  export TF_NOTIFY=False
fi

if [ $TESTFLIGHT_REPLACE ]; then
  export TF_REPLACE=True
else
  export TF_REPLACE=False
fi

if [ -f "$TF_DSYM" ]; then
  curl http://testflightapp.com/api/builds.json \
    -F file=@"${TF_IPA}" \
    -F dsym=@"${TF_DSYM}" \
    -F team_token="${TF_TEAM_TOKEN}" \
    -F api_token="${TF_API_TOKEN}" \
    -F notes="${TF_NOTES}" \
    -F distribution_lists="${TESTFLIGHT_DISTRIBUTION_LIST}" \
    -F notify="${TF_NOTIFY}" \
    -F replace="${TF_REPLACE}"
else 
  curl http://testflightapp.com/api/builds.json \
    -F file=@"${TF_IPA}" \
    -F team_token="${TF_TEAM_TOKEN}" \
    -F api_token="${TF_API_TOKEN}" \
    -F notes="${TF_NOTES}" \
    -F distribution_lists="${TESTFLIGHT_DISTRIBUTION_LIST}" \
    -F notify="${TF_NOTIFY}" \
    -F replace="${TF_REPLACE}"
fi