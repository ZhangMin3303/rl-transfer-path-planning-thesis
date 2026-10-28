# Transfer Reinforcement Learning for Grid Maze Path Planning

This repository is a public, code-focused version of my undergraduate thesis project on reinforcement learning path planning with transfer strategies.

The project investigates whether source-task knowledge can help learning in related grid mazes. The source covers 4x4, 8x8 and 12x12 simulations. No statistically reliable improvement across random seeds is claimed.

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

MATLAB R2023a is the recorded environment; later versions have not been checked here. Open MATLAB, set this repository as the working directory, and run:

```matlab
addpath("tools");
results = run_all_matlab_scripts(pwd);
```

Individual scripts can also be run directly from `src/`.

## Verification

The existing [RUN_LOG.md](RUN_LOG.md) contains historical execution notes for 15 scripts; it is not a record of a new full rerun.

On 2026-10-28, an unmodified copy of `transfer_term_q_learning_4.m` passed a selected execution check on MATLAB R2023a: 200 episodes, an 80-step cap, a finite 16x4 Q table and a final transfer weight of zero. This checks execution and basic invariants, not comparative performance. See [review scope](docs/REVIEW_2026-10-28.md) and [machine-readable result](docs/validation_2026-10-28.json).

The legacy reward-area plot uses a custom normalization and is not diagnostic ROC AUC. Its suitability for method comparisons, initialization fairness, action/terminal handling and results across seeds remain unvalidated. No gain or convergence advantage is inferred from this selected run.

## Notes

This public version intentionally excludes the original thesis document, defense slides, school identifiers, and raw private materials. The repository focuses on code, selected experiment outputs, and concise technical explanation.
