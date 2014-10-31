step-testflight-deploy
======================

Bitrise step to deploy an iOS application to Testflight. First, you have to register at https://www.testflightapp.com/ . You also have to create the required tokens.
- TestFlight API Token : on your account page, Upload API section. 
- Team Token: Click on your app's team name in the upper-right corner, edit info, and tehre is your Team Token.

This step depends on the Archive Step.

This Step is part of the [Open StepLib](http://www.steplib.com/), you can find its StepLib page [here](http://www.steplib.com/step/testflight-deploy)

# Input Environment Variables 
- BITRISE_IPA_PATH			(passed automatically)
- BITRISE_DSYM_PATH			(passed automatically)
- .
- TESTFLIGHT_API_TOKEN
- TESTFLIGHT_TEAM_TOKEN
- TESTFLIGHT_NOTES			(optional, default="Automatic build with Bitrise")
- TESTFLIGHT_NOTIFY			(optional, default=false) [true/false]
- TESTFLIGHT_REPLACE		(optional, default=false) [true/false]
- TESTFLIGHT_DISTRIBUTION_LIST (optional)

# Output Environment Variables
- TESTFLIGHT_DEPLOY_STATUS	[success/failed]
- TESTFLIGHT_DEPLOY_INSTALL_URL
- TESTFLIGHT_DEPLOY_CONFIG_URL
