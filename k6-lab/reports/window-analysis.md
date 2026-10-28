# Spike and soak window analysis

Source: original k6 newline-delimited time-series exports. No network calls or reruns were used.

Method: filter Point records by metric and half-open elapsed-time window [start,end). Aggregate all endpoints for http_req_duration. Sort durations and linearly interpolate at index (n−1) × 0.95. Failure percentage is 100 × sum(http_req_failed values) / sample count. Elapsed-time origin is estimated as the first periodic vus timestamp minus one second; it is approximate, not an exact scenario-start timestamp. Windows are wide enough for practical comparison, but boundary classification is subject to this timing approximation.

Estimated origins (Asia/Bangkok): spike 2026-10-28T22:54:26.3515184+07:00; soak 2026-10-28T22:56:48.0241694+07:00.

| Test/window, elapsed seconds | Requests | p(95), ms | Max, ms | Failed requests |
| --- | --- | --- | --- | --- |
| Spike baseline 0–30 | 18 | 373.08 | 377.27 | 0 |
| Spike peak hold 35–65 | 78 | 356.33 | 373.46 | 0 |
| Spike post-drop 70–100 | 14 | 352.99 | 369.90 | 0 |
| Spike post-drop 100–130 | 15 | 356.39 | 365.23 | 0 |
| Soak early 60–180 | 122 | 361.85 | 374.02 | 0 |
| Soak late 480–600 | 125 | 365.54 | 625.94 | 0 |

| Spike 10-second window | Requests | p(95), ms |
| --- | --- | --- |
| 0–10 | 6 | 338.24 |
| 10–20 | 7 | 351.12 |
| 20–30 | 5 | 370.44 |
| 70–80 | 4 | 295.89 |
| 80–90 | 5 | 356.16 |
| 90–100 | 5 | 339.41 |
| 100–110 | 5 | 295.09 |
| 110–120 | 5 | 357.43 |
| 120–130 | 5 | 352.08 |

No sustained spike-related elevation was observed. Every post-drop bin remained below the pooled pre-spike p(95); no observable recovery interval was needed at 10-second resolution. This is not proof of instantaneous recovery, especially with only 4–5 samples per post-drop bin.

Soak p(95) changed by +3.690605 ms (+1.0199%). Average-versus-stress overall p(95) changed by −1.996615 ms (−0.5530%). These are descriptive single-run comparisons, not statistically established causal effects.
