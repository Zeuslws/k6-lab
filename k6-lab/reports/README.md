# Report evidence

Tests ran on 28 October 2026, approximately 22:44–23:08 Asia/Bangkok, using k6 v2.2.0.

- a2-average.html, a3-stress.html, a4-spike.html and a5-soak.html: generated k6 dashboard reports.
- Named .json files: k6 summary exports; matching .log files: console evidence.
- *-timeseries.json: newline-delimited metric samples from A2–A5.
- exit-codes.csv: all 17 execution outcomes.
- measured-results.md: Part A summary table.
- window-analysis.md: derived spike and soak window measurements and method.
- connectivity-check.*: earlier failed agent-session network probe, excluded from the successful lab measurements.

RESULTS.md in the parent folder contains the completed measurement discussion.
