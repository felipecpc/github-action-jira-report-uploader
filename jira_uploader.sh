#!/bin/bash
JIRA_INSTANCE=$1
JIRA_USER="$2"
JIRA_TOKEN="$3"
XRAY_CLIENT="$4"
XRAY_SECRET="$5"
PROJECT="$6"
SUMMARY="$7"
REPORT_FOLDER="$8"



JIRA_ISSUE_API="rest/api/2/issue"
XRAY_URL="https://xray.cloud.xpand-it.com"
XRAY_AUTH="api/v1/authenticate"
XRAY_IMPORT_RESULT="api/v1/import/execution"



ISSUE_TEMPLATE="{\"fields\": {\"project\":{\"key\": \"$PROJECT\"},\"summary\": \" $SUMMARY\",\"description\": \"Test report created automatically\",\"issuetype\": {\"name\": \"Test Execution\"}}}"

echo "--------------------------------------------------"
echo " Check if the report is already created"
echo "--------------------------------------------------"

QUERY_TEMPLATE='{"jql":"project = $PROJECT AND summary ~ \"\\\"SUMMARY\\\"\" AND issuetype = \"Test Execution\"","fields":["id","key","summary"]}'
QUERY_RESULT=$(curl -u $JIRA_USER:$JIRA_TOKEN -X POST --data "${QUERY_TEMPLATE//SUMMARY/$SUMMARY}" -H "Content-Type: application/json" $JIRA_INSTANCE/"rest/api/2/search")

TOTAL=$(echo $QUERY_RESULT | jq ".total")

if [ "$TOTAL" = 0 ]
then
    JIRA_ISSUE=$(curl -u $JIRA_USER:$JIRA_TOKEN -X POST --data "$ISSUE_TEMPLATE" -H "Content-Type: application/json" $JIRA_INSTANCE/$JIRA_ISSUE_API)
        JIRA_ISSUE=$(echo $JIRA_ISSUE | sed -n 's|.*"key":"\([^"]*\)".*|\1|p')
        echo "✅ Jira execution created with ID: $JIRA_ISSUE"
else
    JIRA_ISSUE=$(echo $QUERY_RESULT | jq ".issues[0].key")
    JIRA_ISSUE="${JIRA_ISSUE:1:${#JIRA_ISSUE}-2}"
    echo "✅ Jira execution already exists with ID: $JIRA_ISSUE"
fi

curl -u $JIRA_USER:$JIRA_TOKEN -X POST --data '{"transition":{"id":"31"}}' -H "Content-Type: application/json" $JIRA_INSTANCE/$JIRA_ISSUE_API/$JIRA_ISSUE/transitions

echo "--------------------------------------------------"
echo "Upload reports to XRAY"
echo "--------------------------------------------------"
for filename in "$REPORT_FOLDER"/*.xml; do 

    echo "ℹ️  Uploading results to the UI Test execution - $filename"
    
    token=$(curl -H "Content-Type: application/json" -X POST --data "{\"client_id\": \"$XRAY_CLIENT\",\"client_secret\": \"$XRAY_SECRET\" }" $XRAY_URL/$XRAY_AUTH)
                    echo "$token"
    curl -H "Content-Type: text/xml" -X POST -H "Authorization: Bearer ${token:1:${#token}-2}" --data @"$filename" $XRAY_URL/$XRAY_IMPORT_RESULT/junit?testExecKey=$JIRA_ISSUE
    echo "✅ Results uploaded to $XRAY_URL/$XRAY_IMPORT_RESULT/junit?testExecKey=$JIRA_ISSUE"

done