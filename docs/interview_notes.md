# Interview Notes

## One-minute Version

My undergraduate thesis studied reinforcement learning path planning with transfer strategies. I used grid mazes as the environment and Q-learning as the base algorithm. The problem I focused on was that traditional Q-learning often retrains from scratch when the environment changes, which is inefficient for related path-planning tasks.

I implemented three experiment groups: baseline Q-learning, direct Q-table transfer, and an improved Q-learning update with a dynamically decaying transfer term. The transfer term lets the target task inherit useful source-task experience in the early stage, while gradually reducing the transfer influence so the agent can adapt to the new maze layout.

The project demonstrates my understanding of reinforcement learning, reward design, transfer learning, controlled experiments, MATLAB implementation, and research-style result analysis.

## What The Project Solves

It tries to reduce repeated training cost in similar path-planning environments. Instead of treating every new maze as a completely new task, the agent reuses what it learned from a source maze.

## Why Transfer Is Needed

In related mazes, many navigation patterns are reusable. For example, the agent has already learned that invalid moves should be avoided and that shorter paths are preferred. Transfer learning allows these learned preferences to guide target-task training.

## What Is New In My Work

The project does not stop at simply copying the source Q table. It compares direct Q-table transfer with a transfer-term update:

```text
TD learning + dynamic source-target correction
```

This makes the transfer process softer. The source task guides early exploration, but the target task still has room to adapt.

## How To Explain The Research Gap

Traditional Q-learning is interpretable but sample-inefficient. Deep reinforcement learning is more powerful but heavier and less transparent. My project sits in the middle: it keeps the explainability of tabular Q-learning while adding a lightweight transfer mechanism to improve learning efficiency in related tasks.

## Possible Interview Questions

**Q: Why not use DQN directly?**

A: The thesis focused on interpretable transfer mechanisms. Tabular Q-learning makes the state-action value update visible, so it is easier to analyze how source-task knowledge affects target-task learning. DQN would be a natural extension for larger or continuous environments.

**Q: What is the main risk of transfer learning here?**

A: Negative transfer. If source and target mazes differ too much, the source Q table may bias the agent toward poor actions. That is why the transfer-term method uses a decaying weight instead of permanently forcing the target task to follow the source task.

**Q: What did you personally implement?**

A: I built the MATLAB maze experiments, implemented baseline Q-learning, direct Q-table transfer, and transfer-term Q-learning, designed source and target tasks for different maze scales, generated visual results, and completed the thesis analysis and defense.

**Q: How would you improve this project now?**

A: I would modularize the MATLAB scripts, add reproducible experiment configuration files, compare more random seeds, and extend the method to DQN or a ROS/Gazebo robot navigation simulation.

## Resume Bullet Suggestions

- Implemented a MATLAB-based reinforcement learning path-planning system using Q-learning on 4x4, 8x8, and 12x12 grid mazes.
- Designed transfer-learning experiments that reuse source-task Q-table knowledge to accelerate target-task path planning.
- Proposed and evaluated a decaying transfer-term Q-learning update to balance source-task experience inheritance and target-task adaptation.
- Compared baseline and transfer strategies using path visualization, reward curves, step curves, heatmaps, and AUC-style metrics.
