# Code Overview

## Goal

The code verifies whether transfer strategies can improve Q-learning path planning in related grid-maze environments.

Each script is a standalone MATLAB experiment. It defines a maze, trains one or more Q tables, extracts a learned path, and visualizes reward/step/path behavior.

## Directory Guide

| Directory | Purpose |
|---|---|
| `src/baseline_q_learning/` | Q-learning from scratch on 4x4, 8x8, and 12x12 mazes. |
| `src/direct_q_table_transfer/` | Source Q table is reused as the initial target Q table. |
| `src/transfer_term_q_learning/` | Q-learning update includes a decaying source-target transfer term. |
| `results/` | Selected existing output figures for quick inspection. |
| `tools/` | Verification helper for running all scripts. |

## Baseline Q-learning

Representative files:

- `q_learning_maze_4.m`
- `q_learning_maze_8.m`
- `q_learning_maze_12.m`

Core logic:

1. Encode each grid cell as a discrete state.
2. Use four actions: up, down, left, right.
3. Use epsilon-greedy exploration.
4. Update the Q table with the temporal-difference rule.
5. Penalize invalid movement and redundant steps.
6. Reward reaching the goal.
7. Back out the final path by greedily following the learned Q table.

## Direct Q-table Transfer

Representative files:

- `direct_q_transfer_single_target_4.m`
- `direct_q_transfer_multi_target_8.m`
- `direct_q_transfer_heatmap_12.m`

Core logic:

1. Train Q-learning on the source maze.
2. Train target tasks from scratch as the baseline.
3. Copy the source Q table into the target task as initialization.
4. Compare no-transfer and transfer learning with reward, step, heatmap, and path visualizations.

This method is simple and interpretable. It works best when source and target mazes are similar, but it can introduce negative transfer when the target task differs too much.

## Transfer-term Q-learning

Representative files:

- `transfer_term_q_learning_4.m`
- `transfer_term_q_learning_8.m`
- `transfer_term_q_learning_12.m`

Core update idea:

```text
td_error = reward + gamma * max(Q_target(next_state, :)) - Q_target(state, action)
migration_term = lambda_t * (Q_source(state, action) - Q_target(state, action))
Q_target(state, action) = Q_target(state, action) + alpha * (td_error + migration_term)
```

`lambda_t` decays over episodes. The target agent is guided more strongly by source-task experience early in training, then gradually relies more on its own target-task exploration.

## Verification

Run all scripts:

```matlab
addpath("tools");
results = run_all_matlab_scripts(pwd);
```

Expected result: all scripts return `PASS`.
