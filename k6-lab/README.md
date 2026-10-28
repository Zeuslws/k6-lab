# ITCS386 — Performance Testing with Grafana k6

Prepared from W10-K6_Lab_Exercise_v2 (revision 21 October 2026).

**Status:** Live tests completed on 28 October 2026 using k6 v2.2.0. RESULTS.md now contains real measurements and all nine reflection answers. A1–A5 passed all thresholds; the two deliberately strict tests failed as intended. Four HTML reports, summaries, logs and A2–A5 raw time-series exports are in reports/. Enter your name and student ID before submission.

## Run on Windows

1. Install k6: `winget install k6 --source winget`.
2. Reopen PowerShell and confirm `k6 version` works.
3. Extract this folder outside OneDrive and open it in VS Code.
4. In its PowerShell terminal, run `powershell -NoProfile -ExecutionPolicy Bypass -File .\run-lab.ps1`.
5. Allow approximately 23–25 minutes. Do not run another load test at the same time. Close the live dashboard browser tab if k6 waits for it to disconnect at the end of a run.
6. Review `reports/measured-results.md`, `reports/exit-codes.csv`, individual logs, and all four HTML reports. RESULTS.md is completed from the saved run; update it if you rerun the tests.
7. Create a **public** GitHub repository named `k6-lab`, upload this folder's contents, and submit the repository URL on MyCourses. Check the deadline there.

The runner preserves the original bug-hunt request using `ORIGINAL=1` before running the corrected default. It records real exit codes, including expected threshold failures. A stricter threshold can still pass; record what happened rather than copying an expected outcome from the handout. If necessary, make it stricter and rerun.

## Individual commands

```powershell
k6 run 01-first-test.js
k6 run --vus 5 --duration 20s 01-first-test.js
k6 run --vus 5 --iterations 20 01-first-test.js
k6 run 04-pizza-api.js
k6 run 05-no-token.js
k6 run 06-thresholds.js
k6 run -e P95=300 06-thresholds.js
$LASTEXITCODE
k6 run 07-requirement.js
k6 run -e P95=1 07-requirement.js
$LASTEXITCODE
k6 run -e ORIGINAL=1 --vus 5 --duration 20s 08-bug-hunt.js
k6 run explore.js
k6 run --vus 5 --duration 20s 08-bug-hunt.js
k6 run a1-smoke.js
k6 run --out web-dashboard=export=reports/a2-average.html a2-average.js
k6 run --out web-dashboard=export=reports/a3-stress.html a3-stress.js
k6 run --out web-dashboard=export=reports/a4-spike.html a4-spike.js
k6 run --out web-dashboard=export=reports/a5-soak.html a5-soak.js
```

Never exceed 5 VUs against this shared demo. Average and stress schedules each last 3 minutes; spike lasts 140 seconds; the permitted soak schedule lasts 11 minutes at no more than 2 VUs. Ramping scripts configure zero graceful stop/ramp-down, but the saved logs show short completion tails beyond the stage schedules. The measured rates include the actual run duration; see RESULTS.md.

If using Git locally, commit and push after each completed exercise as requested in the PDF. No repository has been created or published by this package.


