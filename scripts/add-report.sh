#!/usr/bin/env bash
# add-report.sh — Publish a report to the GitHub Pages reports site.
#
# Usage:
#   ./scripts/add-report.sh <report-file> <report-name>
#
# Arguments:
#   report-file   Path to the generated report file (HTML, XML, etc.)
#   report-name   Human-readable label shown on the landing page
#
# Optional environment variables:
#   REPORT_DATE     Override date (YYYY-MM-DD). Default: today UTC.
#   GIT_USER_NAME   Git commit author name. Default: "CI Bot"
#   GIT_USER_EMAIL  Git commit author email. Default: "ci@noreply"
#   SKIP_GIT_PUSH   Set to "1" to skip the git push (useful for dry-runs).
#
# Example (from your CI workflow):
#   REPORT_DATE=$(date -u +%Y-%m-%d) \
#   GIT_USER_NAME="github-actions[bot]" \
#   GIT_USER_EMAIL="github-actions[bot]@users.noreply.github.com" \
#   bash scripts/add-report.sh ./test-report.html "Build #${GITHUB_RUN_NUMBER}"

set -euo pipefail

REPORT_FILE="${1:?Usage: $0 <report-file> <report-name>}"
REPORT_NAME="${2:?Usage: $0 <report-file> <report-name>}"
REPORT_DATE="${REPORT_DATE:-$(date -u +%Y-%m-%d)}"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

DEST_DIR="reports/${REPORT_DATE}"
FILENAME="$(basename "$REPORT_FILE")"
DEST="${DEST_DIR}/${FILENAME}"

echo "→ Copying '${FILENAME}' → ${DEST}"
mkdir -p "$DEST_DIR"
cp "$REPORT_FILE" "$DEST"

echo "→ Updating reports.json"
REPORT_NAME="$REPORT_NAME" \
REPORT_DATE="$REPORT_DATE" \
REPORT_FILE_PATH="$DEST" \
REPORT_TIMESTAMP="$TIMESTAMP" \
python3 - <<'PYEOF'
import json, os, sys

manifest = "reports.json"

try:
    with open(manifest) as f:
        reports = json.load(f)
except Exception:
    reports = []

entry = {
    "name":      os.environ["REPORT_NAME"],
    "date":      os.environ["REPORT_DATE"],
    "file":      os.environ["REPORT_FILE_PATH"],
    "timestamp": os.environ["REPORT_TIMESTAMP"],
}

# Insert newest first so the file itself stays in order
reports.insert(0, entry)

with open(manifest, "w") as f:
    json.dump(reports, f, indent=2)
    f.write("\n")

print(f"  name : {entry['name']}")
print(f"  date : {entry['date']}")
print(f"  file : {entry['file']}")
print(f"  total: {len(reports)} report(s)")
PYEOF

echo "→ Committing"
git config user.name  "${GIT_USER_NAME:-CI Bot}"
git config user.email "${GIT_USER_EMAIL:-ci@noreply}"
git add reports.json "$DEST"
git commit -m "ci: add report '${REPORT_NAME}' [${REPORT_DATE}]"

if [[ "${SKIP_GIT_PUSH:-0}" != "1" ]]; then
  echo "→ Pushing"
  git push
fi

echo "✓ Done — ${REPORT_NAME} published for ${REPORT_DATE}"
