# Run Log

Environment:

- MATLAB: R2023a available at `D:\MATLAB\bin\matlab.exe`
- Verification target: local public整理版 `rl-transfer-path-planning-thesis`
- Run mode: `DefaultFigureVisible = off`
- Command:

```matlab
addpath("tools");
results = run_all_matlab_scripts(pwd);
```

## Static Check

`checkcode` successfully parsed all 15 MATLAB scripts. Reported items were code-quality/performance warnings, mainly:

- growing path arrays inside loops;
- preallocated variables overwritten before use;
- intermediate TD-error variables assigned but not later reused.

No syntax-level blocker was found.

## Full Execution Result

All 15 scripts executed successfully.

| Script | Status | Time |
|---|---:|---:|
| `q_learning_maze_12.m` | PASS | 7.26s |
| `q_learning_maze_4.m` | PASS | 1.11s |
| `q_learning_maze_4_legacy_duplicate.m` | PASS | 12.91s |
| `q_learning_maze_8.m` | PASS | 0.88s |
| `direct_q_transfer_heatmap_12.m` | PASS | 18.81s |
| `direct_q_transfer_heatmap_4.m` | PASS | 2.74s |
| `direct_q_transfer_heatmap_8.m` | PASS | 5.83s |
| `direct_q_transfer_multi_target_12.m` | PASS | 25.54s |
| `direct_q_transfer_multi_target_4.m` | PASS | 3.10s |
| `direct_q_transfer_multi_target_8.m` | PASS | 5.43s |
| `direct_q_transfer_single_target_4.m` | PASS | 12.51s |
| `direct_q_transfer_single_target_8.m` | PASS | 12.62s |
| `transfer_term_q_learning_12.m` | PASS | 8.97s |
| `transfer_term_q_learning_4.m` | PASS | 2.59s |
| `transfer_term_q_learning_8.m` | PASS | 3.72s |

Smoke-test output from the 4x4 baseline included the learned optimal path:

```text
1 -> 5 -> 9 -> 10 -> 11 -> 15 -> 16
```
