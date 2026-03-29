# uitest-report

GitHub Pages host for UI test reports.

## Viewing a report

Reports are served directly at:

```
https://azun-c.github.io/uitest-report/reports/report_<n>.html
```

## Publishing a report

Push a file named `report_<n>.html` into the `reports/` folder. GitHub Pages deploys automatically on every push to `main`.

```bash
cp my-test-report.html reports/report_<n>.html
git add reports/report_<n>.html
git commit -m "add report_<n>"
git push
```
