clear; clc; close all;

% 设置随机数种子
rng(1);

% 定义第一个迷宫（源任务）
maze0 =[0 0 0 1 0 0 0 0 0 0 0 0;
        1 0 0 0 0 1 0 0 1 0 0 0;
        0 0 0 1 0 0 0 1 0 0 0 0;
        0 1 0 0 0 0 1 0 0 0 0 0;
        0 0 1 0 0 0 0 0 1 0 0 0; 
        0 0 0 0 1 1 0 0 1 0 0 0;
        0 1 0 0 0 0 0 1 0 0 1 0;
        0 0 0 1 0 0 0 0 0 0 0 0;
        0 1 0 0 0 1 0 1 1 0 0 0;
        0 0 0 1 0 0 0 0 0 0 0 1;
        0 1 0 0 0 1 0 1 1 1 0 1;
        0 0 0 1 0 0 0 0 0 0 0 0];
% 定义第二个迷宫（目标任务1）
maze1 =[0 0 0 1 0 0 0 0 0 0 0 0;
        1 0 0 0 0 0 1 0 1 0 0 0;
        0 0 0 1 1 0 0 1 0 0 0 0;
        0 1 0 0 0 0 1 0 0 0 0 0;
        0 0 1 0 0 0 1 0 1 0 0 0; 
        0 0 0 0 1 0 0 0 1 0 0 0;
        0 1 0 0 0 0 0 1 0 0 1 0;
        0 0 0 1 1 0 0 0 0 0 0 0;
        0 1 0 0 0 1 0 0 0 1 0 0;
        0 0 0 1 0 0 0 0 0 0 0 1;
        0 1 0 0 0 1 0 1 0 1 0 0;
        0 0 0 1 0 0 0 0 0 0 0 0];
% 定义第三个迷宫（目标任务2）
maze2 =[0 0 0 0 1 0 0 0 0 0 0 0;
        0 1 0 0 0 1 0 0 1 0 0 0;
        0 1 0 0 1 0 0 1 0 0 0 0;
        0 0 0 0 0 0 1 0 0 0 0 0;
        0 1 1 0 0 0 0 0 1 0 0 0; 
        0 0 0 0 0 0 1 0 1 0 0 0;
        0 1 0 1 0 0 1 1 0 0 1 0;
        0 0 0 0 0 0 0 0 0 0 0 0;
        0 1 0 0 0 0 0 1 1 0 0 0;
        0 0 0 1 1 0 0 0 0 0 0 1;
        0 1 0 0 0 1 1 0 0 1 0 1;
        0 0 0 1 0 0 0 0 0 1 0 0];
% 定义第四个迷宫（目标任务3）
maze3 =[0 0 0 1 0 0 0 0 0 0 0 0;
        1 0 0 0 0 1 0 0 1 0 0 0;
        0 0 1 1 0 0 0 1 0 1 0 0;
        0 0 0 0 0 0 1 0 0 0 0 0;
        0 0 1 0 0 0 0 0 1 0 0 0; 
        0 0 1 0 0 1 1 0 1 0 0 0;
        0 1 0 0 0 0 0 1 0 0 1 0;
        0 0 0 1 0 1 0 0 0 0 0 0;
        0 1 0 0 0 1 0 1 1 1 0 1;
        0 0 0 1 0 0 0 0 0 0 0 0;
        0 1 0 0 0 1 0 1 0 1 0 0;
        0 0 0 1 0 0 0 0 0 0 0 0];

numRows0 = size(maze0, 1);
numCols0 = size(maze0, 2);
numStates0 = numRows0 * numCols0;

numRows1 = size(maze1, 1);
numCols1 = size(maze1, 2);
numStates1 = numRows1 * numCols1;

%% Q-Learning 参数
numEpisodes = 250;  % 训练回合数
gamma = 0.95;         % 折扣因子
alpha = 0.2;         % 学习率
epsilon = 1;         % 探索率（初始高探索）

% 初始化 Q 表（源任务和目标任务）
Q0 = zeros(numStates0, 4); % 源任务的 Q 表
Q11 = zeros(numStates1, 4); % 目标任务1的 Q 表1
Q12 = zeros(numStates1, 4); % 目标任务1的 Q 表2
Q21 = zeros(numStates1, 4); % 目标任务2的 Q 表1
Q22 = zeros(numStates1, 4); % 目标任务2的 Q 表2
Q31 = zeros(numStates1, 4); % 目标任务3的 Q 表1
Q32 = zeros(numStates1, 4); % 目标任务3的 Q 表2

% 用于记录每轮总奖励、损失和步数
totalRewards0 = zeros(numEpisodes, 1);
totalRewards11 = zeros(numEpisodes, 1);
totalRewards12 = zeros(numEpisodes, 1);
totalRewards21 = zeros(numEpisodes, 1);
totalRewards22 = zeros(numEpisodes, 1);
totalRewards31 = zeros(numEpisodes, 1);
totalRewards32 = zeros(numEpisodes, 1);

losses0 = zeros(numEpisodes, 1);
losses11 = zeros(numEpisodes, 1);
losses12 = zeros(numEpisodes, 1);
losses21 = zeros(numEpisodes, 1);
losses22 = zeros(numEpisodes, 1);
losses31 = zeros(numEpisodes, 1);
losses32 = zeros(numEpisodes, 1);

steps0 = zeros(numEpisodes, 1);
steps11 = zeros(numEpisodes, 1);
steps12 = zeros(numEpisodes, 1);
steps21 = zeros(numEpisodes, 1);
steps22 = zeros(numEpisodes, 1);
steps31 = zeros(numEpisodes, 1);
steps32 = zeros(numEpisodes, 1);

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
    episodeSteps = 0; % 初始化步数
    episodeLoss = 0; % 初始化损失

    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q0(state, :)); % 利用
        end

        % 计算新状态
        [row, col] = ind2sub([numRows0, numCols0], state);
        newRow = row + actions(action, 1);
        newCol = col + actions(action, 2);
        
        % 检查新状态是否有效
        if newRow >= 1 && newRow <= numRows0 && newCol >= 1 && newCol <= numCols0 && maze0(newRow, newCol) == 0
            newState = sub2ind([numRows0, numCols0], newRow, newCol);
        else
            newState = state; % 如果无效，保持在当前状态
        end

        % 奖励设定
        reward = (newState == numStates0) * 50; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励

        % 计算损失：Q值更新的变化
        loss = abs(Q0(state, action) - (reward + gamma * max(Q0(newState, :))));
        episodeLoss = episodeLoss + loss; % 累加损失
        
        % 更新 Q 值
        Q0(state, action) = Q0(state, action) + alpha * (reward + gamma * max(Q0(newState, :)) - Q0(state, action));

        % 更新状态
        state = newState;
        episodeSteps = episodeSteps + 1; % 步数加1

        if state == numStates0
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards0(episode) = totalReward; % 记录每轮总奖励
    losses0(episode) = episodeLoss; % 记录每轮损失
    steps0(episode) = episodeSteps; % 记录每轮步数

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的源任务 Q 表
disp('Q训练源任务 Q表:');
disp(Q0);

%% Q训练目标任务1
for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    episodeSteps = 0; % 初始化步数
    episodeLoss = 0; % 初始化损失
    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q11(state, :)); % 利用
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
        reward = (newState == numStates1) * 50; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 计算损失：Q值更新的变化
        loss = abs(Q11(state, action) - (reward + gamma * max(Q11(newState, :))));
        episodeLoss = episodeLoss + loss; % 累加损失

        % 更新 Q 值
        Q11(state, action) = Q11(state, action) + alpha * (reward + gamma * max(Q11(newState, :)) - Q11(state, action));

        % 更新状态
        state = newState;
        episodeSteps = episodeSteps + 1; % 步数加1

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards11(episode) = totalReward; % 记录每轮总奖励
    losses11(episode) = episodeLoss; % 记录每轮损失
    steps11(episode) = episodeSteps; % 记录每轮步数

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的源任务 Q 表
disp('Q训练目标任务1 Q表:');
disp(Q11);

%% TL学习到目标任务1
% 利用源任务的 Q 表初始化目标任务的 Q 表
% 将源任务 Q 表的 Q 值根据目标任务的状态映射进行转移
Q12 = Q0;

% 训练目标任务
epsilon = 1; % 重新设置 epsilon

for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    episodeSteps = 0; % 初始化步数
    episodeLoss = 0; % 初始化损失

    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q12(state, :)); % 利用
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
        reward = (newState == numStates1) * 50; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 计算损失：Q值更新的变化
        loss = abs(Q12(state, action) - (reward + gamma * max(Q12(newState, :))));
        episodeLoss = episodeLoss + loss; % 累加损失

        % 更新 Q 值
        Q12(state, action) = Q12(state, action) + alpha * (reward + gamma * max(Q12(newState, :)) - Q12(state, action));

        % 更新状态
        state = newState;
        episodeSteps = episodeSteps + 1; % 步数加1

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards12 (episode) = totalReward; % 记录每轮总奖励
    losses12(episode) = episodeLoss; % 记录每轮损失
    steps12(episode) = episodeSteps; % 记录每轮步数

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的目标任务 Q 表
disp('TL训练目标任务1 Q表:');
disp(Q12);
 
% 从起点到终点找到最佳路径
path1 = [];
state = 1; % 从(1,1)开始
while state ~= numStates1
    path1 = [path1; state]; % 记录路径
    [~, action] = max(Q12(state, :)); % 选择最优动作
    [row, col] = ind2sub([numRows1, numCols1], state);
    newRow = row + actions(action, 1);
    newCol = col + actions(action, 2);
    state = sub2ind([numRows1, numCols1], newRow, newCol); % 更新状态
end
path1 = [path1; state]; % 添加终点

% 输出最佳路径
disp('目标任务1-最佳路径状态:');
disp(path1);

%% Q训练目标任务2
for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    episodeSteps = 0; % 初始化步数
    episodeLoss = 0; % 初始化损失

    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q21(state, :)); % 利用
        end

        % 计算新状态
        [row, col] = ind2sub([numRows1, numCols1], state);
        newRow = row + actions(action, 1);
        newCol = col + actions(action, 2);
        
        % 检查新状态是否有效
        if newRow >= 1 && newRow <= numRows1 && newCol >= 1 && newCol <= numCols1 && maze2(newRow, newCol) == 0
            newState = sub2ind([numRows1, numCols1], newRow, newCol);
        else
            newState = state; % 如果无效，保持在当前状态
        end

        % 奖励设定
        reward = (newState == numStates1) * 50; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 计算损失：Q值更新的变化
        loss = abs(Q21(state, action) - (reward + gamma * max(Q21(newState, :))));
        episodeLoss = episodeLoss + loss; % 累加损失

        % 更新 Q 值
        Q21(state, action) = Q21(state, action) + alpha * (reward + gamma * max(Q21(newState, :)) - Q21(state, action));

        % 更新状态
        state = newState;
        episodeSteps = episodeSteps + 1; % 步数加1

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards21(episode) = totalReward; % 记录每轮总奖励
    losses21(episode) = episodeLoss; % 记录每轮损失
    steps21(episode) = episodeSteps; % 记录每轮步数

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的源任务 Q 表
disp('Q训练目标任务2 Q表:');
disp(Q21);

%% 迁移学习到目标任务2
% 利用源任务的 Q 表初始化目标任务的 Q 表
% 将源任务 Q 表的 Q 值根据目标任务的状态映射进行转移
Q22 = Q0;

% 训练目标任务
epsilon = 1; % 重新设置 epsilon

for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    episodeSteps = 0; % 初始化步数
    episodeLoss = 0; % 初始化损失

    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q22(state, :)); % 利用
        end

        % 计算新状态
        [row, col] = ind2sub([numRows1, numCols1], state);
        newRow = row + actions(action, 1);
        newCol = col + actions(action, 2);
        
        % 检查新状态是否有效
        if newRow >= 1 && newRow <= numRows1 && newCol >= 1 && newCol <= numCols1 && maze2(newRow, newCol) == 0
            newState = sub2ind([numRows1, numCols1], newRow, newCol);
        else
            newState = state; % 如果无效，保持在当前状态
        end

        % 奖励设定
        reward = (newState == numStates1) * 50; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 计算损失：Q值更新的变化
        loss = abs(Q22(state, action) - (reward + gamma * max(Q22(newState, :))));
        episodeLoss = episodeLoss + loss; % 累加损失

        % 更新 Q 值
        Q22(state, action) = Q22(state, action) + alpha * (reward + gamma * max(Q22(newState, :)) - Q22(state, action));

        % 更新状态
        state = newState;
        episodeSteps = episodeSteps + 1; % 步数加1

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards22 (episode) = totalReward; % 记录每轮总奖励
    losses22(episode) = episodeLoss; % 记录每轮损失
    steps22(episode) = episodeSteps; % 记录每轮步数

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的目标任务 Q 表
disp('TL训练目标任务2 Q表:');
disp(Q22);
 
% 从起点到终点找到最佳路径
path2 = [];
state = 1; % 从(1,1)开始
while state ~= numStates1
    path2 = [path2; state]; % 记录路径
    [~, action] = max(Q22(state, :)); % 选择最优动作
    [row, col] = ind2sub([numRows1, numCols1], state);
    newRow = row + actions(action, 1);
    newCol = col + actions(action, 2);
    state = sub2ind([numRows1, numCols1], newRow, newCol); % 更新状态
end
path2 = [path2; state]; % 添加终点

% 输出最佳路径
disp('目标任务2-最佳路径状态:');
disp(path2);

%% Q训练目标任务3
for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    episodeSteps = 0; % 初始化步数
    episodeLoss = 0; % 初始化损失

    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q31(state, :)); % 利用
        end

        % 计算新状态
        [row, col] = ind2sub([numRows1, numCols1], state);
        newRow = row + actions(action, 1);
        newCol = col + actions(action, 2);
        
        % 检查新状态是否有效
        if newRow >= 1 && newRow <= numRows1 && newCol >= 1 && newCol <= numCols1 && maze3(newRow, newCol) == 0
            newState = sub2ind([numRows1, numCols1], newRow, newCol);
        else
            newState = state; % 如果无效，保持在当前状态
        end

        % 奖励设定
        reward = (newState == numStates1) * 50; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 计算损失：Q值更新的变化
        loss = abs(Q31(state, action) - (reward + gamma * max(Q31(newState, :))));
        episodeLoss = episodeLoss + loss; % 累加损失

        % 更新 Q 值
        Q31(state, action) = Q31(state, action) + alpha * (reward + gamma * max(Q31(newState, :)) - Q31(state, action));

        % 更新状态
        state = newState;
        episodeSteps = episodeSteps + 1; % 步数加1

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards31(episode) = totalReward; % 记录每轮总奖励
    losses31(episode) = episodeLoss; % 记录每轮损失
    steps31(episode) = episodeSteps; % 记录每轮步数

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的源任务 Q 表
disp('Q训练目标任务3 Q表:');
disp(Q31);

%% 迁移学习到目标任务3
% 利用源任务的 Q 表初始化目标任务的 Q 表
% 将源任务 Q 表的 Q 值根据目标任务的状态映射进行转移
Q32 = Q0;

% 训练目标任务
epsilon = 1; % 重新设置 epsilon

for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    episodeSteps = 0; % 初始化步数
    episodeLoss = 0; % 初始化损失

    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q32(state, :)); % 利用
        end

        % 计算新状态
        [row, col] = ind2sub([numRows1, numCols1], state);
        newRow = row + actions(action, 1);
        newCol = col + actions(action, 2);
        
        % 检查新状态是否有效
        if newRow >= 1 && newRow <= numRows1 && newCol >= 1 && newCol <= numCols1 && maze3(newRow, newCol) == 0
            newState = sub2ind([numRows1, numCols1], newRow, newCol);
        else
            newState = state; % 如果无效，保持在当前状态
        end

        % 奖励设定
        reward = (newState == numStates1) * 50; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 计算损失：Q值更新的变化
        loss = abs(Q32(state, action) - (reward + gamma * max(Q32(newState, :))));
        episodeLoss = episodeLoss + loss; % 累加损失

        % 更新 Q 值
        Q32(state, action) = Q32(state, action) + alpha * (reward + gamma * max(Q32(newState, :)) - Q32(state, action));

        % 更新状态
        state = newState;
        episodeSteps = episodeSteps + 1; % 步数加1

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards32 (episode) = totalReward; % 记录每轮总奖励
    losses32(episode) = episodeLoss; % 记录每轮损失
    steps32(episode) = episodeSteps; % 记录每轮步数

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的目标任务 Q 表
disp('TL训练目标任务3 Q表:');
disp(Q32);
 
% 从起点到终点找到最佳路径
path3 = [];
state = 1; % 从(1,1)开始
while state ~= numStates1
    path3 = [path3; state]; % 记录路径
    [~, action] = max(Q32(state, :)); % 选择最优动作
    [row, col] = ind2sub([numRows1, numCols1], state);
    newRow = row + actions(action, 1);
    newCol = col + actions(action, 2);
    state = sub2ind([numRows1, numCols1], newRow, newCol); % 更新状态
end
path3 = [path3; state]; % 添加终点

% 输出最佳路径
disp('目标任务3-最佳路径状态:');
disp(path3);

%% 可视化小人走迷宫路径（修改后版本）
% 创建一个包含3个子图的图形窗口
figure('Position', [200 200 1200 400]); % 调整窗口大小

% 子图1：目标任务1的迷宫路径
subplot(1, 3, 1);
hold on;
% 绘制迷宫（0=白色通路，1=灰色障碍物）
maze_img = maze1;
maze_img(end,end) = 0; % 确保终点不被显示为障碍物
imagesc(maze_img);
colormap(gca, [1 1 1; 0.4 0.4 0.4]); % 设置颜色映射
axis equal tight;
set(gca, 'YDir', 'reverse', 'XTick', 1:numCols1, 'YTick', 1:numRows1, ...
         'XTickLabel', [], 'YTickLabel', [], 'GridAlpha', 1, 'LineWidth', 1.5);
grid on;

% 绘制起点和终点
plot(1, 1, 'go', 'MarkerSize', 12, 'LineWidth', 3);  % 绿色起点
plot(numCols1, numRows1, 'bx', 'MarkerSize', 12, 'LineWidth', 3);  % 蓝色终点

% 绘制路径并连接相邻点
if length(path1) > 1
    path_x = zeros(length(path1), 1);
    path_y = zeros(length(path1), 1);
    for i = 1:length(path1)
        [row, col] = ind2sub([numRows1, numCols1], path1(i));
        path_x(i) = col;
        path_y(i) = row;
    end
    plot(path_x, path_y, 'r-', 'LineWidth', 2); % 连接路径点的红线
    plot(path_x, path_y, 'rs', 'MarkerSize', 10, 'LineWidth', 2); % 路径点标记
end

title('目标任务1-迁移学习路径');
hold off;

% 子图2：目标任务2的迷宫路径（相同格式修改）
subplot(1, 3, 2);
hold on;
maze_img = maze2;
maze_img(end,end) = 0;
imagesc(maze_img);
colormap(gca, [1 1 1; 0.4 0.4 0.4]);
axis equal tight;
set(gca, 'YDir', 'reverse', 'XTick', 1:numCols1, 'YTick', 1:numRows1, ...
         'XTickLabel', [], 'YTickLabel', [], 'GridAlpha', 1, 'LineWidth', 1.5);


% 绘制起点和终点
plot(1, 1, 'go', 'MarkerSize', 12, 'LineWidth', 3);
plot(numCols1, numRows1, 'bx', 'MarkerSize', 12, 'LineWidth', 3);

% 绘制路径并连接相邻点
if length(path2) > 1
    path_x = zeros(length(path2), 1);
    path_y = zeros(length(path2), 1);
    for i = 1:length(path2)
        [row, col] = ind2sub([numRows1, numCols1], path2(i));
        path_x(i) = col;
        path_y(i) = row;
    end
    plot(path_x, path_y, 'r-', 'LineWidth', 2);
    plot(path_x, path_y, 'rs', 'MarkerSize', 10, 'LineWidth', 2);
end

title('目标任务2-迁移学习路径');
hold off;

% 子图3：目标任务3的迷宫路径（相同格式修改）
subplot(1, 3, 3);
hold on;
maze_img = maze3;
maze_img(end,end) = 0;
imagesc(maze_img);
colormap(gca, [1 1 1; 0.4 0.4 0.4]);
axis equal tight;
set(gca, 'YDir', 'reverse', 'XTick', 1:numCols1, 'YTick', 1:numRows1, ...
         'XTickLabel', [], 'YTickLabel', [], 'GridAlpha', 1, 'LineWidth', 1.5);
grid on;

% 绘制起点和终点
plot(1, 1, 'go', 'MarkerSize', 12, 'LineWidth', 3);
plot(numCols1, numRows1, 'bx', 'MarkerSize', 12, 'LineWidth', 3);

% 绘制路径并连接相邻点
if length(path3) > 1
    path_x = zeros(length(path3), 1);
    path_y = zeros(length(path3), 1);
    for i = 1:length(path3)
        [row, col] = ind2sub([numRows1, numCols1], path3(i));
        path_x(i) = col;
        path_y(i) = row;
    end
    plot(path_x, path_y, 'r-', 'LineWidth', 2);
    plot(path_x, path_y, 'rs', 'MarkerSize', 10, 'LineWidth', 2);
end

title('目标任务3-迁移学习路径');
hold off;
%% 可视化算法损失函数
figure;
hold on;

%计算目标任务1~3的Q训练损失和TL训练损失的平均值
lossesQ = (losses11 + losses21 + losses31) / 3;
lossesTL = (losses12 + losses22 + losses32) / 3;

% 绘制两条曲线，分别使用不同的颜色
plot(lossesQ, 'b', 'LineWidth', 1.5); % 'r'表示红色
plot(lossesTL, 'r', 'LineWidth', 1.5); % 'g'表示红色

%测试是否取平均
% plot(totalRewards21, 'y', 'LineWidth', 1.5); % 'y'表示黄色

% 添加标题和标签
title('每轮损失对比');
xlabel('回合');
ylabel('损失');

% 添加图例，标明不同曲线的意义legend('Q训练源任务', 'Q训练目标任务的平均', 'TL训练目标任务的平均');
legend('Q训练目标任务的平均损失', 'TL训练目标任务的平均损失');
%legend('Q训练目标任务的平均', 'TL训练目标任务的平均');

grid on;  % 显示网格
hold off; % 释放当前图形

%% 可视化每轮步数
figure;
hold on;

%计算目标任务1~3的Q训练损失和TL训练损失的平均值
stepsQ = (steps11 + steps21 + steps31) / 3;
stepsTL = (steps12 + steps22 + steps32) / 3;

% 绘制两条曲线，分别使用不同的颜色
plot(stepsQ, 'b', 'LineWidth', 1.5); % 'r'表示红色
plot(stepsTL, 'r', 'LineWidth', 1.5); % 'g'表示红色

%测试是否取平均
% plot(totalRewards21, 'y', 'LineWidth', 1.5); % 'y'表示黄色

% 添加标题和标签
title('每轮步数对比');
xlabel('回合');
ylabel('步数');

% 添加图例，标明不同曲线的意义legend('Q训练源任务', 'Q训练目标任务的平均', 'TL训练目标任务的平均');
legend('Q训练目标任务的平均步数', 'TL训练目标任务的平均步数');
%legend('Q训练目标任务的平均', 'TL训练目标任务的平均');

grid on;  % 显示网格
hold off; % 释放当前图形

%% 可视化平均总奖励
figure;
hold on;  % 保持当前图形，使得后续的曲线可以绘制在同一张图上

%计算目标任务1~3的Q训练奖励和TL训练奖励的平均值
totalRewardsQ = (totalRewards11 + totalRewards21 + totalRewards31) / 3;
totalRewardsTL = (totalRewards12 + totalRewards22 + totalRewards32) / 3;

% 绘制三条曲线，分别使用不同的颜色
plot(totalRewardsQ, 'b', 'LineWidth', 1.5); % 'b'表示蓝色
plot(totalRewardsTL, 'r', 'LineWidth', 1.5); % 'r'表示红色

%测试是否取平均
% plot(totalRewards21, 'y', 'LineWidth', 1.5); % 'y'表示黄色

% 添加标题和标签
title('每轮总奖励对比');
xlabel('回合');
ylabel('总奖励');

% 添加图例，标明不同曲线的意义legend('Q训练源任务', 'Q训练目标任务的平均', 'TL训练目标任务的平均');
legend( 'Q训练目标任务的平均总奖励', 'TL训练目标任务的平均总奖励');
%legend('Q训练目标任务的平均', 'TL训练目标任务的平均');

grid on;  % 显示网格
hold off; % 释放当前图形

%% 可视化AUC

% 计算曲线下面积并绘制柱状图
AUC1 = trapz(totalRewardsQ-28); % 使用梯形积分计算面积
AUC2 = trapz(totalRewardsTL-28); % 使用梯形积分计算另一个面积

% 计算 AUC（0~0.5~1）
AUC2 = (360000-abs(AUC2))/360000;
AUC1 = (360000-abs(AUC1))/360000;

figure;
hold on; % 保持图形，允许叠加绘制

% 绘制两组柱状图
bar(1, AUC1, 'FaceColor', 'b', 'EdgeColor', 'k'); % 第一组柱状图
bar(3, AUC2, 'FaceColor', 'r', 'EdgeColor', 'k'); % 第二组柱状图

title('曲线下面积 (AUC)');
ylabel('面积值');
set(gca, 'XTick', [1, 3], 'XTickLabel', {'Q训练目标任务的平均AUC', 'TL训练目标任务的平均AUC'}); % 设置x轴标签

% 添加AUC值文本
text(1, AUC1 , sprintf('AUC = %.2f', AUC1), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
text(3, AUC2 , sprintf('AUC = %.2f', AUC2), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);

hold off; % 释放图形