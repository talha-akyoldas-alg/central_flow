#!/bin/bash

# Assign passed arguments to variables.....
WORKFLOW="$1"
REPOSITORY="$2"
ARTIFACT="$3"
GOOGLE_CHAT_BINBIN_TEST_URL="$4"
GOOGLE_CHAT_BINBIN_PROD_URL="$5"
GOOGLE_CHAT_ALGORITMA_TEST_URL="$6"
GOOGLE_CHAT_ALGORITMA_PROD_URL="$7"

TIME=$(TZ="Europe/Istanbul" date '+%Y-%m-%d %H:%M:%S')


# Set the title for Google Chat Card
TITLE="${REPOSITORY##*/} Test Results" 


# Convert to lowercase
WORKFLOW_LOWERCASE=$(echo "$WORKFLOW" | tr '[:upper:]' '[:lower:]')
echo "WORKFLOW: " $WORKFLOW_LOWERCASE
REPOSITORY_LOWERCASE=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]')
echo "REPOSITORY: " $REPOSITORY


# Dynamically determine which Google Chat URL to use
if [[ "$WORKFLOW_LOWERCASE" == *"test"* && "$REPOSITORY_LOWERCASE" != *"algoritma"* ]]; then
    GOOGLE_CHAT_URL="$GOOGLE_CHAT_BINBIN_TEST_URL"
elif [[ "$WORKFLOW_LOWERCASE" == *"rollback"* && "$REPOSITORY_LOWERCASE" != *"algoritma"* ]]; then
    GOOGLE_CHAT_URL="$GOOGLE_CHAT_BINBIN_PROD_URL"
elif [[ "$WORKFLOW_LOWERCASE" == *"prod"* && "$REPOSITORY_LOWERCASE" != *"algoritma"* ]]; then
    GOOGLE_CHAT_URL="$GOOGLE_CHAT_BINBIN_PROD_URL"
elif [[ "$WORKFLOW_LOWERCASE" == *"test"* && "$REPOSITORY_LOWERCASE" == *"algoritma"* ]]; then
    GOOGLE_CHAT_URL="$GOOGLE_CHAT_ALGORITMA_TEST_URL"
elif [[ "$WORKFLOW_LOWERCASE" == *"prod"* && "$REPOSITORY_LOWERCASE" == *"algoritma"* ]]; then
    GOOGLE_CHAT_URL="$GOOGLE_CHAT_ALGORITMA_PROD_URL"
fi


if [ -z "$GOOGLE_CHAT_URL" ]; then
  echo "Error: GOOGLE_CHAT_URL is empty"
  exit 1
fi


# URL for the success and failure icons
SUCCESS_ICON="https://www.iconsdb.com/icons/preview/green/ok-xxl.png"
FAILURE_ICON="https://www.iconsdb.com/icons/preview/red/x-mark-3-xxl.png"

# Set Subtitle and Image URL based on assertions failed count
if [ "$ASSERTIONS_FAILED" -gt 0 ]; then
  IMAGE_URL="$FAILURE_ICON"
  SUBTITLE="We have a failed test!"
else
  IMAGE_URL="$SUCCESS_ICON"
  SUBTITLE="All tests succeeded!"
fi


#Set Button Texts
POSTMAN_CLOUD_REPORT_BUTTON_TEXT="POSTMAN CLOUD REPORT"
NEWMAN_HTML_REPORT_BUTTON_TEXT="NEWMAN HTML REPORT"


#Set Google Chat Notification Requester Payload
JSON_PAYLOAD=$(cat << EOM
{
    "cards": [
        {
            "header": {
                "title": "$TITLE",
                "subtitle": "$SUBTITLE",
                "imageUrl": "$IMAGE_URL"
            },
            "sections": [
                {
                    "widgets": [
                        {
                            "keyValue": {
                                "topLabel": "Time (Istanbul)",
                                "content": "$TIME"
                            }
                        },
                        {
                            "keyValue": {
                                "topLabel": "Result",
                                "content": "$SUCCESS_RATIO% SUCCESS"
                            }
                        },
                        {
                            "keyValue": {
                                "topLabel": "Iterations",
                                "content": "$ITERATIONS_TOTAL executed, $ITERATIONS_FAILED failed"
                            }
                        },
                        {
                            "keyValue": {
                                "topLabel": "Requests",
                                "content": "$REQUESTS_TOTAL executed, $REQUESTS_FAILED failed"
                            }
                        },
                        {
                            "keyValue": {
                                "topLabel": "Test-Scripts",
                                "content": "$TEST_SCRIPTS_TOTAL executed, $TEST_SCRIPTS_FAILED failed"
                            }
                        },
                        {
                            "keyValue": {
                                "topLabel": "Prerequest-Scripts",
                                "content": "$PRE_REQUEST_SCRIPTS_TOTAL executed, $PRE_REQUEST_SCRIPTS_FAILED failed"
                            }
                        },
                        {
                            "keyValue": {
                                "topLabel": "Assertions",
                                "content": "$ASSERTIONS_TOTAL executed, $ASSERTIONS_FAILED failed"
                            }
                        },
                        {
                            "keyValue": {
                                "topLabel": "Total Run Duration",
                                "content": "$RUN_DURATION_TOTAL s"
                            }
                        },
                        {
                            "keyValue": {
                                "topLabel": "Average Response Time",
                                "content": "$RESPONSE_TIME_TOTAL ms [min: $RESPONSE_TIME_MIN ms, max: $RESPONSE_TIME_MAX s]" 
                            }
                        },
                        {
                            "buttons": [
                                {
                                    "textButton": {
                                        "text": "$POSTMAN_CLOUD_REPORT_BUTTON_TEXT",
                                        "onClick": {
                                            "openLink": {
                                                "url": "$POSTMAN_CLOUD_REPORT_BUTTON_LINK"
                                            }
                                        }
                                    }
                                }
                            ]
                        },
                        {
                            "buttons": [
                                {
                                    "textButton": {
                                        "text": "$NEWMAN_HTML_REPORT_BUTTON_TEXT",
                                        "onClick": {
                                            "openLink": {
                                                "url": "$NEWMAN_HTML_REPORT_BUTTON_LINK"
                                            }
                                        }
                                    }
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]
}
EOM
)


# Send HTTP Request to Google Chat
curl -H 'Content-Type: application/json' -X POST \
  "${GOOGLE_CHAT_URL}" \
  --data "$JSON_PAYLOAD"