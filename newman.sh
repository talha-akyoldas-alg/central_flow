#!/bin/bash
# newman.sh

# Assign passed arguments to variables.....
BUILD_STATUS="$1"
WORKFLOW="$2"
BRANCH="$3"
REPOSITORY="$4"
ARTIFACT="$5"
BINBINAPIGW_COLLECTION_ID="$6"
BINBINAPIGW_TEST_ENVIRONMENT_ID="$7"
BINBINAPIGW_WORKSPACE_ID="$8"
BINBINAPIGW_API_TOKEN="$9"
TOMP_COLLECTION_ID="$10"
TOMP_TEST_ENVIRONMENT_ID="$11"
TOMP_WORKSPACE_ID="$12"
TOMP_API_TOKEN="$13"



if [[ "$BUILD_STATUS" == "cancelled" || "$BUILD_STATUS" == "skipped" ]]; then
  echo "Workflow skipped / cancelled"
  exit 1
fi


# Set the title
TITLE="${REPOSITORY##*/}"

# Convert workflow and repository name to lowercase
WORKFLOW_LOWERCASE=$(echo "$WORKFLOW" | tr '[:upper:]' '[:lower:]')
echo "Workflow: " $WORKFLOW_LOWERCASE
REPOSITORY_LOWERCASE=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]')
echo "Repository: " $REPOSITORY_LOWERCASE


# Dynamically determine which Collection Paremeters to be used
if [[ "$WORKFLOW_LOWERCASE" == *"test"* && "$REPOSITORY_LOWERCASE" == *"binbin-api-gateway"* ]]; then
    COLLECTION_ID="$BINBINAPIGW_COLLECTION_ID"
    ENVIRONMENT_ID="$BINBINAPIGW_TEST_ENVIRONMENT_ID"
    POSTMAN_WORKSPACE_ID="$BINBINAPIGW_WORKSPACE_ID"
    POSTMAN_API_TOKEN="$BINBINAPIGW_API_TOKEN"
elif [[ "$WORKFLOW_LOWERCASE" == *"test"* && "$REPOSITORY_LOWERCASE" == *"algoritma-tomp-api"* ]]; then
    COLLECTION_ID="$TOMP_COLLECTION_ID"
    ENVIRONMENT_ID="$TOMP_TEST_ENVIRONMENT_ID"
    POSTMAN_WORKSPACE_ID="$TOMP_WORKSPACE_ID"
    POSTMAN_API_TOKEN="$TOMP_API_TOKEN"
fi


#The Newman Command
newman run https://api.getpostman.com/collections/$COLLECTION_ID\?apikey\=$POSTMAN_API_TOKEN -e https://api.getpostman.com/environments/$ENVIRONMENT_ID\?apikey\=$POSTMAN_API_TOKEN -r cli,json,postman-cloud,htmlextra --reporter-json-export newman_json_report.json --reporter-postman-cloud-apiKey $POSTMAN_API_TOKEN --reporter-postman-cloud-workspaceId $POSTMAN_WORKSPACE_ID --reporter-htmlextra-export testResults/htmlreport.html | tee newman_terminal_output.txt


#Extracting Postman Cloud Result URL from Newman Terminal Output
url=$(grep -o 'https://go.postman.co/workspace/[^ ]*' newman_terminal_output.txt | head -1)
echo "$url" > newman_terminal_output.txt
echo "URL extracted and saved to newman_terminal_output.txt"
urlFromFile=$(cat newman_terminal_output.txt | tr -d '\n')
echo "POSTMAN_CLOUD_REPORT_BUTTON_LINK=$urlFromFile" >> $GITHUB_ENV

#Make Directory for Newman HTML reports
mkdir -p testResults