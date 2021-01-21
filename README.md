# github-action-jira-report-uploader

## Dependencies 

This action was developed to be used together with JIRA and XRAY test plugin. 

## Flow

The action will 

- Query for test executions with the same summary name
- If there is no, a new test execution will be used
- Upload the test results to the test execution 

```

on: [push]

jobs:
  jira-report-uploader:
    runs-on: ubuntu-latest
    name: Upload test reports to JIRA
    steps:
    - uses: actions/checkout@v2
    - id: jira
      uses: felipecpc/github-action-jira-report-uploader@v1.0.1
      with:
        jira-instance: 'jira_instance'
        jira-user: 'jira@email.com'
        jira-token: 'jira_token'
        xray-client: 'xray_client'
        xray-token: 'xray_token'
        issue-summary: '"[Automated Tests] This is the issue summary"'
        project: 'PJ'
        report-folder: 'reports'
```
