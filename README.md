# github-action-jira-report-uploader

## Dependencies 

This action was developed to be used together with JIRA and XRAY test plugin. 

## Flow

The action will 

- Query for test plans with the same summary name
- If there is no, a new test plan will be used
- Upload the test results to the test plan 

```

on: [push]

jobs:
  jira-report-uploader:
    runs-on: ubuntu-latest
    name: Upload test reports to JIRA
    steps:
    - uses: actions/checkout@v2
    - id: jira
      uses: felipecpc/github-action-jira-report-uploader@v1.0.2
      with:
        jira-instance: 'jira_instance'
        jira-user: 'jira@email.com'
        jira-token: 'jira_token'
        jira-in-progress-transition: '21'
        jira-done-transition: '41'
        xray-client: 'xray_client'
        xray-token: 'xray_token'
        project: 'PJ'
        issue-summary: '"[Automated Tests] This is the issue summary"'
        report-folder: 'reports'
        fix-version: 'v1.0.0'
```
