# uitest-report

GitHub Pages host for UI test reports.

## Report links

Each report is accessible directly at:

```
https://<owner>.github.io/uitest-report/reports/report_<n>.html
```

For example: `https://<owner>.github.io/uitest-report/reports/report_42.html`

## Publishing a report from CI

1. Generate your report as `report_<run_number>.html`
2. Push it to `reports/` in this repo

See `.github/workflows/example-ci.yml` for a ready-to-adapt workflow.

### Prerequisites

Create a PAT with `repo` scope (or a fine-grained token with **Contents: Read & Write**) and add it as `REPORTS_PUSH_TOKEN` in your project repo's secrets.
