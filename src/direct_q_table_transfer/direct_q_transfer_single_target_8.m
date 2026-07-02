clear; clc; close all;

% 设置随机数种子
rng(1);

% 定义第一个迷宫（源任务）
maze1 =[0 0 0 1 0 0 0 0;
        1 0 0 0 0 1 0 0;
        0 0 0 1 0 0 0 1;
        0 1 0 0 0 0 1 0;
        0 0 1 0 1 0 0 0;
        0 0 0 0 0 1 0 0;
        0 1 0 0 0 0 1 0;
        0 0 0 1 0 0 0 0];

% 定义第二个迷宫（目标任务）
maze2 =[0 0 0 1 0 0 0 0;
        1 0 0 0 0 1 0 0;
        0 0 0 1 0 0 0 1;
        0 1 0 0 0 0 1 0;
        0 0 0 1 1 0 0 0;
        0 0 0 1 0 1 0 0;
        0 1 0 0 0 0 0 0;
        0 0 0 1 0 0 0 0];

numRows1 = size(maze1, 1);
numCols1 = size(maze1, 2);
numStates1 = numRows1 * numCols1;

numRows2 = size(maze2, 1);
numCols2 = size(maze2, 2);
numStates2 = numRows2 * numCols2;

% Q-Learning 参数
numEpisodes = 250;  % 训练回合数
gamma = 0.9;         % 折扣因子
alpha = 0.1;         % 学习率
epsilon = 1;         % 探索率（初始高探索）

% 初始化 Q 表（源任务和目标任务）
Q1 = zeros(numStates1, 4); % 源任务的 Q 表
Q2 = zeros(numStates2, 4); % 目标任务的 Q 表1
Q3 = zeros(numStates2, 4); % 目标任务的 Q 表2

% 用于记录每轮总奖励
totalRewards1 = zeros(numEpisodes, 1);
totalRewards2 = zeros(numEpisodes, 1);
totalRewards3 = zeros(numEpisodes, 1);

% 定义动作
actions = [ -1, 0;  % 上
             1, 0;  % 下
             0, -1; % 左
             0, 1]; % 右

%% Q训练源任务
for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    
    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q1(state, :)); % 利用
        end

        % 计算新状态
        [row, col] = ind2sub([numRows1, numCols1], state);
        newRow = row + actions(action, 1);
        newCol = col + actions(action, 2);
        
        % 检查新状态是否有效
        if newRow >= 1 && newRow <= numRows1 && newCol >= 1 && newCol <= numCols1 && maze1(newRow, newCol) == 0
            newState = sub2ind([numRows1, numCols1], newRow, newCol);
        else
            newState = state; % 如果无效，保持在当前状态
        end

        % 奖励设定
        reward = (newState == numStates1) * 20; % 到达终点奖励20
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q1(state, action) = Q1(state, action) + alpha * (reward + gamma * max(Q1(newState, :)) - Q1(state, action));

        % 更新状态
        state = newState;

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards1(episode) = totalReward; % 记录每轮总奖励

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的源任务 Q 表
disp('Q训练源任务 Q表:');
disp(Q1);

%% Q训练目标任务
for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    
    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q2(state, :)); % 利用
        end

        % 计算新状态
        [row, col] = ind2sub([numRows1, numCols1], state);
        newRow = row + actions(action, 1);
        newCol = col + actions(action, 2);
        
        % 检查新状态是否有效
        if newRow >= 1 && newRow <= numRows1 && newCol >= 1 && newCol <= numCols1 && maze1(newRow, newCol) == 0
            newState = sub2ind([numRows1, numCols1], newRow, newCol);
        else
            newState = state; % 如果无效，保持在当前状态
        end

        % 奖励设定
        reward = (newState == numStates1) * 20; % 到达终点奖励20
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q2(state, action) = Q2(state, action) + alpha * (reward + gamma * max(Q2(newState, :)) - Q2(state, action));

        % 更新状态
        state = newState;

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards2(episode) = totalReward; % 记录每轮总奖励

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的源任务 Q 表
disp('Q训练源任务 Q表:');
disp(Q2);

%% 迁移学习到目标任务
% 利用源任务的 Q 表初始化目标任务的 Q 表
% 将源任务 Q 表的 Q 值根据目标任务的状态映射进行转移
Q3 = Q1;

% 训练目标任务
epsilon = 1; % 重新设置 epsilon

for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    
    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q3(state, :)); % 利用
        end

        % 计算新状态
        [row, col] = ind2sub([numRows2, numCols2], state);
        newRow = row + actions(action, 1);
        newCol = col + actions(action, 2);
        
        % 检查新状态是否有效
        if newRow >= 1 && newRow <= numRows2 && newCol >= 1 && newCol <= numCols2 && maze2(newRow, newCol) == 0
            newState = sub2ind([numRows2, numCols2], newRow, newCol);
        else
            newState = state; % 如果无效，保持在当前状态
        end

        % 奖励设定
        reward = (newState == numStates2) * 20; % 到达终点奖励20
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q3(state, action) = Q3(state, action) + alpha * (reward + gamma * max(Q3(newState, :)) - Q3(state, action));

        % 更新状态
        state = newState;

        if state == numStates2
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards3(episode) = totalReward; % 记录每轮总奖励

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的目标任务 Q 表
disp('Q训练目标任务 Q表:');
disp(Q3);

% 从起点到终点找到最佳路径
path = [];
state = 1; % 从(1,1)开始
while state ~= numStates2
    path = [path; state]; % 记录路径
    [~, action] = max(Q2(state, :)); % 选择最优动作

    % 获取当前的行和列
    [row, col] = ind2sub([numRows2, numCols2], state);
    newRow = row + actions(action, 1); % 计算新行
    newCol = col + actions(action, 2); % 计算新列

    % 检查新状态是否有效
    if newRow >= 1 && newRow <= numRows2 && newCol >= 1 && newCol <= numCols2 && maze2(newRow, newCol) == 0
        state = sub2ind([numRows2, numCols2], newRow, newCol); % 更新状态
    else
        % 如果无效，选择一个随机有效动作
        validActions = [];
        for a = 1:4
            testRow = row + actions(a, 1);
            testCol = col + actions(a, 2);
            if testRow >= 1 && testRow <= numRows2 && testCol >= 1 && testCol <= numCols2 && maze2(testRow, testCol) == 0
                validActions = [validActions; a];
            end
        end
        if ~isempty(validActions)
            action = validActions(randi(length(validActions))); % 随机选择一个有效动作
            state = sub2ind([numRows2, numCols2], row + actions(action, 1), col + actions(action, 2));
        else
            disp('无有效动作，保持当前状态。');
        end
    end
end
path = [path; state]; % 添加终点到路径

% 打印路径
disp('从起点到终点的最佳路径状态:');
disp(path);

%% 可视化每轮总奖励
figure;
hold on;  % 保持当前图形，使得后续的曲线可以绘制在同一张图上

% 绘制三条曲线，分别使用不同的颜色
plot(totalRewards1, 'k', 'LineWidth', 1.5); % 'k'表示黑色
plot(totalRewards2, 'b', 'LineWidth', 1.5); % 'b'表示蓝色
plot(totalRewards3, 'r', 'LineWidth', 1.5); % 'r'表示红色

% 添加标题和标签
title('每轮总奖励对比');
xlabel('回合');
ylabel('总奖励');

% 添加图例，标明不同曲线的意义
legend('Q训练源任务', 'Q训练目标任务', 'TL训练目标任务');

grid on;  % 显示网格
hold off; % 释放当前图形

%% 可视化小人走迷宫的路径
figure;
hold on;
% 绘制目标任务的迷宫
imagesc(maze2 == 1); % 绘制障碍物
colormap(gray);
axis equal;
set(gca, 'YDir', 'reverse'); % 设置Y轴方向为反向
title('小人走迷宫的路径');
xlabel('列');
ylabel('行');

% 在路径上绘制小人
for i = 1:length(path)
    [row, col] = ind2sub([numRows2, numCols2], path(i));
    plot(col, row, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); % 绘制小人
    pause(0.5); % 暂停0.5秒以显示每一步
end

hold off;