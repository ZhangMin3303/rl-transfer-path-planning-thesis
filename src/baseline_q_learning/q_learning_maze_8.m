clear; clc; close all;

% 设置随机数种子
rng(1);

% 定义迷宫
maze = [0 0 0 1 0 0 0 0;
        1 0 0 0 0 1 0 0;
        0 0 0 1 0 0 0 1;
        0 1 0 0 0 0 1 0;
        0 0 1 0 1 0 0 0;
        0 0 0 0 0 1 0 0;
        0 1 0 0 0 0 1 0;
        0 0 0 1 0 0 0 0];

numRows = size(maze, 1);
numCols = size(maze, 2);
numStates = numRows * numCols;

% Q-Learning 参数
numEpisodes = 250;  % 训练回合数
gamma = 0.9;         % 折扣因子
alpha = 0.1;         % 学习率
epsilon = 1;       % 初始探索率

% 初始化 Q 表
Q = zeros(numStates, 4); % 4个动作: 上, 下, 左, 右

% 用于记录每轮总奖励
totalRewards = zeros(numEpisodes, 1);

% 定义动作
actions = [ -1, 0;  % 上
             1, 0;  % 下
             0, -1; % 左
             0, 1]; % 右

% 训练 Q-Learning
for episode = 1:numEpisodes
    % 初始化状态
    state = 1;  % 从(1,1)开始
    totalReward = 0; % 初始化每轮总奖励
    
    while true
        % 选择动作
        if rand < epsilon
            action = randi(4); % 探索
        else
            [~, action] = max(Q(state, :)); % 利用
        end

        % 计算新状态
        [row, col] = ind2sub([numRows, numCols], state);
        newRow = row + actions(action, 1);
        newCol = col + actions(action, 2);
        
        % 检查新状态是否有效
        if newRow >= 1 && newRow <= numRows && newCol >= 1 && newCol <= numCols && maze(newRow, newCol) == 0
            newState = sub2ind([numRows, numCols], newRow, newCol);
        else
            newState = state; % 如果无效，保持在当前状态
        end

        % 奖励设定
        reward = (newState == numStates) * 30; % 到达终点奖励20
        if newState ~= state
            reward = reward - 1; % 每次有效移动给予-1的惩罚
        end
        
        totalReward = totalReward + reward; % 累加总奖励
        
        % 更新 Q 值
        Q(state, action) = Q(state, action) + alpha * (reward + gamma * max(Q(newState, :)) - Q(state, action));

        % 更新状态
        state = newState;

        if state == numStates
            break; % 到达终点，结束回合
        end
    end
    
    totalRewards(episode) = totalReward; % 记录每轮总奖励

    % 随着训练进展逐步减少 epsilon
    epsilon = max(0.1, epsilon * 0.99); % 保证 epsilon 不小于 0.1
end

% 打印学习到的 Q 表
disp('Q表:');
disp(Q);

% 从起点到终点找到最佳路径
path = [];
state = 1; % 从(1,1)开始
while state ~= numStates
    path = [path; state]; % 记录路径
    [~, action] = max(Q(state, :)); % 选择最优动作

    % 获取当前的行和列
    [row, col] = ind2sub([numRows, numCols], state);
    newRow = row + actions(action, 1); % 计算新行
    newCol = col + actions(action, 2); % 计算新列

    % 检查新状态是否有效
    if newRow >= 1 && newRow <= numRows && newCol >= 1 && newCol <= numCols && maze(newRow, newCol) == 0
        state = sub2ind([numRows, numCols], newRow, newCol); % 更新状态
    else
        % 如果无效，选择一个随机有效动作
        validActions = [];
        for a = 1:4
            testRow = row + actions(a, 1);
            testCol = col + actions(a, 2);
            if testRow >= 1 && testRow <= numRows && testCol >= 1 && testCol <= numCols && maze(testRow, testCol) == 0
                validActions = [validActions; a];
            end
        end
        if ~isempty(validActions)
            action = validActions(randi(length(validActions))); % 随机选择一个有效动作
            state = sub2ind([numRows, numCols], row + actions(action, 1), col + actions(action, 2));
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
plot(totalRewards);
title('每轮总奖励');
xlabel('回合');
ylabel('总奖励');
grid on;

%% 可视化小人走迷宫路径
% 创建一个图形窗口
figure('Position', [200 200 600 600]); % 调整窗口大小

% 绘制迷宫
hold on;
maze_img = maze;  % 使用给定的迷宫矩阵
maze_img(end,end) = 0; % 确保终点不被显示为障碍物
imagesc(maze_img);
colormap(gca, [1 1 1; 0.4 0.4 0.4]); % 设置颜色映射，0为白色通路，1为灰色障碍物
axis equal tight;
set(gca, 'YDir', 'reverse', 'XTick', 1:numCols, 'YTick', 1:numRows, ...
         'XTickLabel', [], 'YTickLabel', [], 'GridAlpha', 1, 'LineWidth', 1.5);
grid on;

% 绘制起点和终点
plot(1, 1, 'go', 'MarkerSize', 12, 'LineWidth', 3);  % 绿色起点
plot(numCols, numRows, 'bx', 'MarkerSize', 12, 'LineWidth', 3);  % 蓝色终点

% 绘制路径并连接相邻点
if length(path) > 1
    path_x = zeros(length(path), 1);
    path_y = zeros(length(path), 1);
    for i = 1:length(path)
        [row, col] = ind2sub([numRows, numCols], path(i));
        path_x(i) = col;
        path_y(i) = row;
    end
    plot(path_x, path_y, 'r-', 'LineWidth', 2); % 连接路径点的红线
    plot(path_x, path_y, 'rs', 'MarkerSize', 10, 'LineWidth', 2); % 路径点标记
end

title('小人走迷宫路径');
hold off;