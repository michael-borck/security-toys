#!/usr/bin/env bash
# Bundle every toy into one offline zip: lab machines, LMS uploads, students who want to keep them.
# Every toy is a single self-contained file, so this is an archive, not a build.
set -euo pipefail
cd "$(dirname "$0")"
OUT="security-toys-offline.zip"
rm -f "$OUT"
zip -r "$OUT" . \
  -x '*.git*' -x "$OUT" -x 'package.sh' -x '*.DS_Store' -x '._*' >/dev/null
echo "→ $OUT  ($(du -h "$OUT" | cut -f1))"
echo "  Open index.html from the unzipped folder. No server needed."
