clear; clc; close all;

% 设置随机数种子
rng(1);

% 定义第一个迷宫（源任务）
maze0 =[0 0 0 1 0 0 0 0;
        1 0 0 0 0 1 0 0;
        0 0 0 1 0 0 0 1;
        0 1 0 0 0 0 1 0;
        0 0 1 0 1 0 0 0;
        0 0 0 0 0 1 0 0;
        0 1 0 0 0 0 1 0;
        0 0 0 1 0 0 0 0];
% 定义第二个迷宫（目标任务1）
maze1 =[0 0 0 1 0 0 0 0;
        1 0 0 0 0 1 0 0;
        0 0 0 1 0 0 0 1;
        0 1 0 0 0 0 1 0;
        0 0 0 1 1 0 0 0;
        0 0 0 1 0 1 0 0;
        0 1 0 0 0 0 0 0;
        0 0 0 1 0 0 0 0];
% 定义第三个迷宫（目标任务2）
maze2 =[0 0 0 1 0 0 0 0;
        1 0 0 0 0 1 0 0;
        0 0 1 0 0 0 0 1;
        0 0 0 0 0 0 1 0;
        0 0 1 0 0 0 0 0;
        0 0 0 0 1 1 0 0;
        0 1 0 0 0 0 1 0;
        0 0 0 1 0 0 0 0];
% 定义第四个迷宫（目标任务3）
maze3 =[0 0 0 0 1 0 0 0;
        1 0 0 0 0 1 0 0;
        0 0 0 0 0 0 0 1;
        0 1 0 1 0 0 1 0;
        0 0 0 0 1 0 0 0;
        0 0 0 0 0 0 0 1;
        0 1 0 0 0 1 0 0;
        0 0 0 1 0 0 0 0];

numRows0 = size(maze0, 1);
numCols0 = size(maze0, 2);
numStates0 = numRows0 * numCols0;

numRows1 = size(maze1, 1);
numCols1 = size(maze1, 2);
numStates1 = numRows1 * numCols1;

numEpisodes = 200;  % 训练回合数
gamma = 0.95;         % 折扣因子
alpha = 0.15;         % 学习率
epsilon = 1;         % 探索率（初始高探索）

% 初始化 Q 表（源任务和目标任务）
Q0 = zeros(numStates0, 4); % 源任务的 Q 表
Q11 = zeros(numStates1, 4); % 目标任务1的 Q 表1
Q12 = zeros(numStates1, 4); % 目标任务1的 Q 表2
Q21 = zeros(numStates1, 4); % 目标任务2的 Q 表1
Q22 = zeros(numStates1, 4); % 目标任务2的 Q 表2
Q31 = zeros(numStates1, 4); % 目标任务3的 Q 表1
Q32 = zeros(numStates1, 4); % 目标任务3的 Q 表2

% 用于记录每轮总奖励
totalRewards0 = zeros(numEpisodes, 1);
totalRewards11 = zeros(numEpisodes, 1);
totalRewards12 = zeros(numEpisodes, 1);
totalRewards21 = zeros(numEpisodes, 1);
totalRewards22 = zeros(numEpisodes, 1);
totalRewards31 = zeros(numEpisodes, 1);
totalRewards32 = zeros(numEpisodes, 1);

% 定义动作
actions = [ -1, 0;  % 上
             1, 0;  % 下
             0, -1; % 左
             0, 1]; % 右

% 初始化访问频率
visitCount0 = zeros(numRows0, numCols0);
visitCount1 = zeros(numRows1, numCols1);
visitCount2 = zeros(numRows1, numCols1);
visitCount3 = zeros(numRows1, numCols1);

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
        reward = (newState == numStates0) * 20; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q0(state, action) = Q0(state, action) + alpha * (reward + gamma * max(Q0(newState, :)) - Q0(state, action));

        % 更新状态
        state = newState;

        if state == numStates0
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards0(episode) = totalReward; % 记录每轮总奖励

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
        reward = (newState == numStates1) * 20; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q11(state, action) = Q11(state, action) + alpha * (reward + gamma * max(Q11(newState, :)) - Q11(state, action));

        % 更新状态
        state = newState;

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards11(episode) = totalReward; % 记录每轮总奖励

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

% 创建一个图窗，用于显示热图
figure;

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
        reward = (newState == numStates1) * 20; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q12(state, action) = Q12(state, action) + alpha * (reward + gamma * max(Q12(newState, :)) - Q12(state, action));

        % 更新访问频率
        [row, col] = ind2sub([numRows1, numCols1], state);
        visitCount1(row, col) = visitCount1(row, col) + 1;

        % 更新状态
        state = newState;

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards12 (episode) = totalReward; % 记录每轮总奖励

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1

     % 每 50 轮绘制一次热图
  if mod(episode, 50) == 0
    subplot(2, 2, episode / 50); % 在 2x2 网格中选择子图
    imagesc(visitCount1, [0, 200]); % 设置颜色尺度范围
    colorbar;
    title(sprintf('Episode %d - Visit Count', episode));
    xlabel('Columns');
    ylabel('Rows');
  end
end

hold off;

% 打印学习到的目标任务 Q 表
disp('TL训练目标任务1 Q表:');
disp(Q12);
 
% 从起点到终点找到最佳路径
path1 = [];
state = 1; % 从(1,1)开始
while state ~= numStates1
    path1 = [path1; state]; % 记录路径
    [~, action] = max(Q12(state, :)); % 选择最优动作

    % 获取当前的行和列
    [row, col] = ind2sub([numRows1, numCols1], state);
    newRow = row + actions(action, 1); % 计算新行
    newCol = col + actions(action, 2); % 计算新列

    % 检查新状态是否有效
    if newRow >= 1 && newRow <= numRows1 && newCol >= 1 && newCol <= numCols1 && maze1(newRow, newCol) == 0
        state = sub2ind([numRows1, numCols1], newRow, newCol); % 更新状态
    else
        % 如果无效，选择一个随机有效动作
        validActions = [];
        for a = 1:4
            testRow = row + actions(a, 1);
            testCol = col + actions(a, 2);
            if testRow >= 1 && testRow <= numRows1 && testCol >= 1 && testCol <= numCols1 && maze1(testRow, testCol) == 0
                validActions = [validActions; a];
            end
        end
        if ~isempty(validActions)
            action = validActions(randi(length(validActions))); % 随机选择一个有效动作
            state = sub2ind([numRows1, numCols1], row + actions(action, 1), col + actions(action, 2));
        else
            disp('无有效动作，保持当前状态。');
        end
    end
end
path1 = [path1; state]; % 添加终点到路径

% 打印路径
disp('目标任务1-最佳路径状态:');
disp(path1);

%% Q训练目标任务2

for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    
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
        reward = (newState == numStates1) * 20; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q21(state, action) = Q21(state, action) + alpha * (reward + gamma * max(Q21(newState, :)) - Q21(state, action));

        % 更新状态
        state = newState;

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards21(episode) = totalReward; % 记录每轮总奖励

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

% 创建一个图窗，用于显示热图
figure;

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
        reward = (newState == numStates1) * 20; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q22(state, action) = Q22(state, action) + alpha * (reward + gamma * max(Q22(newState, :)) - Q22(state, action));

        % 更新访问频率
        [row, col] = ind2sub([numRows1, numCols1], state);
        visitCount2(row, col) = visitCount2(row, col) + 1;

        % 更新状态
        state = newState;

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards22 (episode) = totalReward; % 记录每轮总奖励

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1

    % 每 50 轮绘制一次热图
  if mod(episode, 50) == 0
    subplot(2, 2, episode / 50); % 在 2x2 网格中选择子图
    imagesc(visitCount2, [0, 300]); % 设置颜色尺度范围
    colorbar;
    title(sprintf('Episode %d - Visit Count', episode));
    xlabel('Columns');
    ylabel('Rows');
  end
end

hold off;

% 打印学习到的目标任务 Q 表
disp('TL训练目标任务2 Q表:');
disp(Q22);
 
% 从起点到终点找到最佳路径
path2 = [];
state = 1; % 从(1,1)开始
while state ~= numStates1
    path2 = [path2; state]; % 记录路径
    [~, action] = max(Q22(state, :)); % 选择最优动作

    % 获取当前的行和列
    [row, col] = ind2sub([numRows1, numCols1], state);
    newRow = row + actions(action, 1); % 计算新行
    newCol = col + actions(action, 2); % 计算新列

    % 检查新状态是否有效
    if newRow >= 1 && newRow <= numRows1 && newCol >= 1 && newCol <= numCols1 && maze2(newRow, newCol) == 0
        state = sub2ind([numRows1, numCols1], newRow, newCol); % 更新状态
    else
        % 如果无效，选择一个随机有效动作
        validActions = [];
        for a = 1:4
            testRow = row + actions(a, 1);
            testCol = col + actions(a, 2);
            if testRow >= 1 && testRow <= numRows1 && testCol >= 1 && testCol <= numCols1 && maze2(testRow, testCol) == 0
                validActions = [validActions; a];
            end
        end
        if ~isempty(validActions)
            action = validActions(randi(length(validActions))); % 随机选择一个有效动作
            state = sub2ind([numRows1, numCols1], row + actions(action, 1), col + actions(action, 2));
        else
            disp('无有效动作，保持当前状态。');
        end
    end
end
path2 = [path2; state]; % 添加终点到路径

% 打印路径
disp('目标任务2-最佳路径状态:');
disp(path2);

%% Q训练目标任务3
for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    
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
        reward = (newState == numStates1) * 20; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q31(state, action) = Q31(state, action) + alpha * (reward + gamma * max(Q31(newState, :)) - Q31(state, action));

        % 更新状态
        state = newState;

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards31(episode) = totalReward; % 记录每轮总奖励

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

% 创建一个图窗，用于显示热图
figure;

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
        reward = (newState == numStates1) * 20; % 到达终点奖励10
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q32(state, action) = Q32(state, action) + alpha * (reward + gamma * max(Q32(newState, :)) - Q32(state, action));

        % 更新访问频率
        [row, col] = ind2sub([numRows1, numCols1], state);
        visitCount3(row, col) = visitCount3(row, col) + 1;

        % 更新状态
        state = newState;

        if state == numStates1
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards32 (episode) = totalReward; % 记录每轮总奖励

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1

    % 每 50 轮绘制一次热图
  if mod(episode, 50) == 0
    subplot(2, 2, episode / 50); % 在 2x2 网格中选择子图
    imagesc(visitCount3, [0, 300]); % 设置颜色尺度范围
    colorbar;
    title(sprintf('Episode %d - Visit Count', episode));
    xlabel('Columns');
    ylabel('Rows');
  end
end

hold off;

% 打印学习到的目标任务 Q 表
disp('TL训练目标任务3 Q表:');
disp(Q32);
 
% 从起点到终点找到最佳路径
path3 = [];
state = 1; % 从(1,1)开始
while state ~= numStates1
    path3 = [path3; state]; % 记录路径
    [~, action] = max(Q32(state, :)); % 选择最优动作

    % 获取当前的行和列
    [row, col] = ind2sub([numRows1, numCols1], state);
    newRow = row + actions(action, 1); % 计算新行
    newCol = col + actions(action, 2); % 计算新列

    % 检查新状态是否有效
    if newRow >= 1 && newRow <= numRows1 && newCol >= 1 && newCol <= numCols1 && maze3(newRow, newCol) == 0
        state = sub2ind([numRows1, numCols1], newRow, newCol); % 更新状态
    else
        % 如果无效，选择一个随机有效动作
        validActions = [];
        for a = 1:4
            testRow = row + actions(a, 1);
            testCol = col + actions(a, 2);
            if testRow >= 1 && testRow <= numRows1 && testCol >= 1 && testCol <= numCols1 && maze3(testRow, testCol) == 0
                validActions = [validActions; a];
            end
        end
        if ~isempty(validActions)
            action = validActions(randi(length(validActions))); % 随机选择一个有效动作
            state = sub2ind([numRows1, numCols1], row + actions(action, 1), col + actions(action, 2));
        else
            disp('无有效动作，保持当前状态。');
        end
    end
end
path3 = [path3; state]; % 添加终点到路径

% 打印路径
disp('目标任务3-最佳路径状态:');
disp(path3);
