# Project Summary

## Background

Path planning is a core problem in intelligent navigation, robotics, logistics, and autonomous systems. In grid-maze path planning, an agent must learn how to move from a start state to a goal state while avoiding obstacles and reducing unnecessary steps.

Traditional Q-learning is interpretable and suitable for discrete grid environments, but it usually starts from scratch in every new environment. When the maze scale increases or obstacle layouts change, repeated training becomes inefficient.

## Research Gap

This project focuses on a practical gap in traditional reinforcement learning path planning:

- The agent repeatedly relearns similar navigation experience in related mazes.
- Training cost increases as the environment becomes larger or more complex.
- Directly reusing old policies may help, but it can also cause negative transfer when the target environment differs from the source environment.
- A lightweight and explainable transfer mechanism is needed before moving to heavier deep reinforcement learning methods.

## Method

The project uses tabular Q-learning as the base algorithm and compares three levels of path-planning strategy:

1. Baseline Q-learning from scratch.
2. Direct Q-table transfer from a source maze to target mazes.
3. Transfer-term Q-learning with a dynamically decaying migration term.

The experiments use 4x4, 8x8, and 12x12 grid mazes. For each scale, a source task and multiple target tasks are constructed to test whether source-task experience can improve target-task learning.

## Innovation Points

- Designed a source-target maze experiment framework for same-scale but different-layout path planning tasks.
- Used direct Q-table transfer as a clear baseline for knowledge reuse.
- Added a decaying transfer term into the Q-learning update, allowing early-stage experience inheritance and later-stage target adaptation.
- Compared methods through path visualization, step curves, reward curves, heatmaps, and AUC-style reward-area scores.

## My Contributions

- Built the MATLAB simulation environment for grid-maze path planning.
- Implemented baseline Q-learning, direct Q-table transfer, and transfer-term Q-learning.
- Designed 4x4, 8x8, and 12x12 maze experiments with source and target tasks.
- Ran comparative experiments and generated visual evidence for convergence behavior and path quality.
- Wrote the undergraduate thesis and defense materials around the algorithm design, experiment comparison, and result analysis.

## Capability Demonstrated

- Reinforcement learning fundamentals: state encoding, action selection, reward design, Q-table update.
- Transfer learning awareness: source task, target task, knowledge reuse, negative transfer risk.
- Experimental design: baseline comparison, controlled maze scale, multiple target tasks.
- MATLAB implementation and debugging.
- Research communication: thesis writing, figure generation, result explanation, and defense presentation.

## Honest Boundaries

This is a tabular Q-learning thesis project, not a deep reinforcement learning or robotics deployment project. Its value lies in clear algorithmic comparison, interpretable transfer design, and complete experimental validation. Natural extensions include DQN, prioritized replay, curriculum learning, graph-based state representation, or ROS/Gazebo simulation.
