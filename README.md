step-testflight-deploy
======================

Concrete step to deploy an iOS application to Testflight. First, you have to register at https://www.testflightapp.com/ and create an app to utilize this step. You also have to create the required tokens.

This step depends on the Archive Step.

# Input Environment Variables 
- CONCRETE_IPA_PATH			(passed automatically)
- CONCRETE_DSYM_PATH		(passed automatically)
- .
- TESTFLIGHT_API_TOKEN
- TESTFLIGHT_TEAM_TOKEN
- TESTFLIGHT_NOTES			(optional, default="Automatic build with Concrete")
- TESTFLIGHT_NOTIFY
- TESTFLIGHT_REPLACE		(optional)
- TESTFLIGHT_DISTRIBUTION_LIST (optional)