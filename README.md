# Transfer Reinforcement Learning for Grid Maze Path Planning

This repository is a public, code-focused version of my undergraduate thesis project on reinforcement learning path planning with transfer strategies.

The project studies how a Q-learning agent can reuse knowledge learned in a source maze to accelerate path planning in related target mazes. Experiments are conducted on 4x4, 8x8, and 12x12 grid mazes.

## Project Highlights

- Built baseline tabular Q-learning path planning experiments for grid mazes.
- Designed source-task and target-task maze settings with the same scale but different obstacle layouts.
- Implemented direct Q-table transfer by reusing the learned source-task Q table as the initial target-task Q table.
- Implemented a transfer-term Q-learning variant that adds a dynamically decaying migration term to the temporal-difference update.
- Compared baseline learning, direct transfer, and transfer-term learning using reward curves, step curves, path visualization, heatmaps, and an AUC-style reward-area metric.

## Repository Structure

```text
.
|-- src/
|   |-- baseline_q_learning/
|   |-- direct_q_table_transfer/
|   `-- transfer_term_q_learning/
|-- results/
|   |-- baseline_q_learning/
|   |-- direct_q_table_transfer/
|   `-- transfer_term_q_learning/
|-- docs/
|   |-- project_summary.md
|   |-- code_overview.md
|   |-- interview_notes.md
|   `-- publication_notes.md
|-- tools/
|   `-- run_all_matlab_scripts.m
|-- RUN_LOG.md
`-- README.md
```

## Core Methods

**Baseline Q-learning**

The agent learns a state-action value table in a grid maze using epsilon-greedy exploration, temporal-difference updates, terminal reward, movement cost, and invalid-move penalty.

**Direct Q-table transfer**

The source maze is trained first. The learned source Q table is then copied to target tasks as the initial target Q table. This tests whether previous path-planning experience can reduce repeated training cost in similar environments.

**Transfer-term Q-learning**

The target-task update adds a migration term:

```text
Q_target <- Q_target + alpha * (TD_error + lambda_t * (Q_source - Q_target))
```

where `lambda_t` decays over training. Early episodes inherit more source-task experience, while later episodes rely more on target-environment exploration.

## How To Run

Open MATLAB R2023a or later, set this repository as the working directory, and run:

```matlab
addpath("tools");
results = run_all_matlab_scripts(pwd);
```

Individual scripts can also be run directly from `src/`.

## Verification

All 15 MATLAB scripts in `src/` were executed successfully on MATLAB R2023a. See [RUN_LOG.md](RUN_LOG.md) for details.

## Notes

This public version intentionally excludes the original thesis document, defense slides, school identifiers, and raw private materials. The repository focuses on code, selected experiment outputs, and concise technical explanation.
