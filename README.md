step-testflight-deploy
======================

Concrete step to deploy an iOS application to Testflight. First, you have to register at https://www.testflightapp.com/ . You also have to create the required tokens.

This step depends on the Archive Step.

# Input Environment Variables 
- CONCRETE_IPA_PATH			(passed automatically)
- CONCRETE_DSYM_PATH		(passed automatically)
- .
- TESTFLIGHT_API_TOKEN
- TESTFLIGHT_TEAM_TOKEN
- TESTFLIGHT_NOTES			(optional, default="Automatic build with Concrete")
- TESTFLIGHT_NOTIFY			(optional, default=false) [true/false]
- TESTFLIGHT_REPLACE		(optional, default=false) [true/false]
- TESTFLIGHT_DISTRIBUTION_LIST (optional)

# Output Environment Variables
- CONCRETE_DEPLOY_STATUS		[success/failed]
- CONCRETE_DEPLOY_URL
- .
- TESTFLIGHT_DEPLOY_STATUS	[success/failed]
- TESTFLIGHT_DEPLOY_URL
