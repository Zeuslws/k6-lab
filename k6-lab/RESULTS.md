# K6 lab results

Name: Ratchapon 
Student ID: 6688068 
Run date: 28 October 2026, approximately 22:44–23:08 (Asia/Bangkok).  
k6: v2.2.0, commit 00a9a1b7f5, Go 1.26.5, windows/amd64.  
Target: https://quickpizza.grafana.com, accessed from the user's Windows PC over the public internet. Connection type and ISP were not recorded.

**Evidence status: COMPLETE for the test measurements.** All 17 runner entries completed. A1–A5 passed every configured threshold. Only the deliberately strict 0.6 and 0.7 runs exited with code 99. Results below come from the saved JSON summaries, logs, exit-codes.csv and raw time-series exports. Four HTML reports are present. The earlier agent-session connectivity failure is retained separately as connectivity-check.* and is excluded from these results. Name and student ID still need to be entered.

## Part 0

- **Step 0.1:** One request; http_req_duration = **271.89 ms**. With one sample, avg, min, median, max, p(90) and p(95) all equal 271.8883 ms. The HTTP status check passed.
- **Step 0.2:** **80 requests**, **3.834 req/s**, p(95) = **270.58 ms**; all 80 checks passed. Five VUs each wait for the response and sleep for one second. Mean HTTP time was 263.42 ms, giving roughly 5 / (1 + 0.26342) = 3.96 req/s before connection/setup and other overhead. The measured rate is therefore below 5 req/s.
- **Step 0.3:** **20 completed iterations**, shared across 5 VUs; 20 requests and 20/20 checks passed. An iteration limit fixes the amount of work; a duration fixes the load period.
- **Step 0.4:** **3/3 checks passed (100%)**: HTTP 200, pizza name present and every ingredient vegetarian. Checking the ingredients verifies the business rule rather than only HTTP success.
- **Step 0.5:** **HTTP 401**, confirmed by the passing unauthorized-response check (**1/1**). http_req_failed = **0% (0/1)** because `http.expectedStatuses(401)` explicitly treats this required refusal as expected.
- **Step 0.6:** Normal run: p(95) = **369.71 ms**, exit **0**, all thresholds passed. P95=300 run: p(95) = **368.71 ms**, exit **99**; only `p(95)<300` failed. All HTTP requests and checks succeeded in both runs. This demonstrates that threshold failure can occur without HTTP failure.
- **Step 0.7:** With 3 VUs for 30 seconds, measured p(95) = **368.29 ms**, p(99) = **373.66 ms**, and http_req_failed = **0%**. All three requirements passed: `p(95)<1000`, `p(99)<1500`, and `rate<0.01`; exit **0**. With P95=1, p(95) = **366.09 ms** and p(99) = **373.81 ms**; only `p(95)<1` failed, producing exit **99**. Both runs completed 69 requests and passed 138/138 checks.
- **Step 0.8:** The catalog in `reports/explore.log` confirms **Pepperoni** and **Knife**. The original lowercase exclusions produced **33 failed checks out of 225 (14.67%)** over 75 requests: 9 failures for “no pepperoni” and 24 for “no knife needed”; all 75 HTTP status checks passed. The corrected capitalized exclusions passed **225/225 checks (100%)** over 75 requests. This supports case-sensitive exclusion matching as the bug. The 33 failures count checks, not necessarily 33 distinct requests, because a request can fail both exclusions. Both runs exited 0 because the script has no thresholds; failed checks alone did not change the exit code. Random recommendations can pass by chance, and a finite all-pass corrected run is evidence rather than proof for every possible recommendation.

## Part A results

Values are taken from the corresponding JSON summaries. Users are observed maximum VUs; duration values are milliseconds. Failed is the failed HTTP request percentage; Checks is the successful check percentage. Request rates use k6's reported full-run rate.

| Step | Test type | Users | Req/s | p(95), ms | Max, ms | Failed | Checks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A1 | Smoke | 1 | 0.492 | 407.87 | 538.08 | 0.00% | 100.00% |
| A2 | Average load | 3 | 1.294 | 361.07 | 375.43 | 0.00% | 100.00% |
| A3 | Stress | 5 | 2.141 | 359.08 | 376.03 | 0.00% | 100.00% |
| A4 | Spike | 5 | 1.061 | 358.75 | 377.27 | 0.00% | 100.00% |
| A5 | Soak | 2 | 0.987 | 362.73 | 625.94 | 0.00% | 100.00% |

| Step | Requests | Successful checks | Exit code | Threshold outcome | HTML report |
| --- | --- | --- | --- | --- | --- |
| A1 | 15 | 20/20 | 0 | All passed | Not required |
| A2 | 240 | 320/320 | 0 | All passed | [Average](reports/a2-average.html) |
| A3 | 393 | 524/524 | 0 | All passed | [Stress](reports/a3-stress.html) |
| A4 | 150 | 200/200 | 0 | All passed | [Spike](reports/a4-spike.html) |
| A5 | 654 | 872/872 | 0 | All passed | [Soak](reports/a5-soak.html) |

## Part B

1. **Results:** See the Part A tables. Every configured threshold passed for A1–A5, with no HTTP failures or failed checks. The configured stage schedules were 3 minutes each for average and stress, 140 seconds for spike, and 11 minutes for soak. Logs show short completion tails beyond these schedules (for example, average ended at 3m05.4s and soak at 11m02.8s), so these results do not claim exact wall-clock termination at the final stage boundary.

2. **Why below 5 requests/s?** Five VUs represent five concurrent users, not a fixed rate of five requests per second. Each user in Step 0.2 waits for an HTTP response and then sleeps for one second; the observed throughput was 3.834 req/s. Part A uses a different journey: three HTTP requests plus randomized think times, so its rates should not be compared directly with the single-request iteration as if the workloads were identical.

3. **Average versus stress and the operational envelope:** Average-load p(95) was **361.07 ms** and stress p(95) was **359.08 ms**, a change of **−2.00 ms (−0.55%)**, calculated before rounding. Request rate increased from 1.294 to 2.141 req/s, with zero failures in both tests. There was no observed tail-latency deterioration at the higher load. These small loads appear to remain inside the operational envelope for this run, but shared-site and internet variation prevent attributing the small improvement to load. Five VUs is the permitted maximum here, not a demonstrated capacity limit or breaking point.

4. **Spike recovery:** Raw time-series samples give baseline p(95) **373.08 ms** during 0–30 s (18 requests), versus **356.33 ms** during the 5-VU hold at 35–65 s (78 requests). Following the drop ending at 70 s, p(95) was **352.99 ms** at 70–100 s and **356.39 ms** at 100–130 s. No requests failed in these windows. The first post-drop 10-second bin, 70–80 s, had p(95) **295.89 ms**; all later 10-second bins through 130 s remained below the pooled baseline p(95). There was **no observable sustained slowdown requiring recovery**: recovery is approximately **0 s at 10-second resolution**, not a precisely measured instantaneous recovery. Low request counts per bin and mixed endpoints limit the comparison. See [the spike report](reports/a4-spike.html) and [the calculation evidence](reports/window-analysis.md).

5. **Soak stability:** Equal steady-load windows excluding the ramps show early (1–3 min) p(95) **361.85 ms**, **0/122 failures (0%)**, versus late (8–10 min) p(95) **365.54 ms**, **0/125 failures (0%)**. The change was **+3.69 ms (+1.02%)**. Tail latency was broadly stable across these windows, with no failures; the late window included the run's **625.94 ms** maximum, so isolated latency variation did occur. This short test does not demonstrate progressive degradation or rule out a memory leak. A several-hour soak could expose accumulating allocations, increased garbage collection, latency growth or memory exhaustion. See [the soak report](reports/a5-soak.html) and [the calculation evidence](reports/window-analysis.md).
6. **Why p(95), not the average?** An average can look good while a minority of users experience very slow responses. The 95th percentile describes tail latency, linking the threshold to the experience of most requests. It still does not describe the worst 5%, which is why a separate p(99) rule can be useful.

7. **Why a lab could differ:** (a) Internet latency, routing, packet loss and local Wi-Fi conditions vary; a controlled lab network is usually more predictable. (b) Other users share the public service and compete for resources; a controlled lab can isolate background load and fix server resources. Consequently, changes between these runs cannot automatically be attributed to the VU count alone.

8. **Why not hundreds of users on an unowned site?** Heavy testing can exhaust shared resources, disrupt legitimate users, and create costs. Such testing requires the owner's explicit authorization and agreed limits. This exercise authorizes only small-scale loads: no more than 5 VUs, with the stated duration limits and the 2-VU soak exception.

9. **Vague and testable requirement:**

   Vague: “My food-delivery app should show restaurant search results quickly.”

   Testable: “In an authorized staging environment, with 3 concurrent users performing restaurant searches for 30 seconds and a 1-second think time after each search, at least 95% of search requests must complete in under 1000 ms, at least 99% in under 1500 ms, and fewer than 1% may fail.” Send only search requests in this test so the following metrics apply to that operation:

   ```javascript
   export const options = {
     vus: 3,
     duration: '30s',
     thresholds: {
       http_req_duration: ['p(95)<1000', 'p(99)<1500'],
       http_req_failed: ['rate<0.01'],
     },
   };
   ```

   This is a proposed requirement, not a claim about an actual food-delivery app's performance. It does not authorize testing that app's production service.


