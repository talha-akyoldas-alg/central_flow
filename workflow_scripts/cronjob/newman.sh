#!/bin/bash
#newman.sh file for the scheduled workflow

# Assign passed arguments to variables.....
COLLECTION_ID="$1"
ENVIRONMENT_ID="$2"
WORKSPACE_ID="$3"
POSTMAN_API_TOKEN="$4"

echo "Running Scheduled Newman Command"
newman run https://api.getpostman.com/collections/$COLLECTION_ID\?apikey\=$POSTMAN_API_TOKEN -e https://api.getpostman.com/environments/$ENVIRONMENT_ID\?apikey\=$POSTMAN_API_TOKEN -r cli,json,postman-cloud,htmlextra --reporter-json-export newman_json_report.json --reporter-postman-cloud-apiKey "$POSTMAN_API_TOKEN" --reporter-postman-cloud-workspaceId "$POSTMAN_WORKSPACE_ID" --reporter-htmlextra-export testResults/htmlreport.html | tee newman_terminal_output.txt

#Extracting Postman Cloud Result URL from Newman Terminal Output
url=$(grep -o 'https://go.postman.co/workspace/[^ ]*' newman_terminal_output.txt | head -1)
echo "$url" > newman_terminal_output.txt
pwd
echo "URL extracted and saved to newman_terminal_output.txt"
urlFromFile=$(cat newman_terminal_output.txt | tr -d '\n')
echo "POSTMAN_CLOUD_REPORT_BUTTON_LINK=$urlFromFile" >> $GITHUB_ENV

#Make Directory for Newman HTML reports
pwd
mkdir -p testResults