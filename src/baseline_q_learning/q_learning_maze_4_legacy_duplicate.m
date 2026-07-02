clear; clc; close all;

% 设置随机数种子
rng(1);

% 定义迷宫
maze = [0 0 0 0;
        1 1 0 1;
        0 0 0 0;
        0 1 1 0];

numRows = size(maze, 1);
numCols = size(maze, 2);
numStates = numRows * numCols;

% Q-Learning 参数
numEpisodes = 200;  % 训练回合数
gamma = 0.9;         % 折扣因子
alpha = 0.1;         % 学习率
epsilon = 1;         % 探索率（初始高探索）

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
        reward = (newState == numStates) * 10; % 到达终点奖励10
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
    [row, col] = ind2sub([numRows, numCols], state);
    newRow = row + actions(action, 1);
    newCol = col + actions(action, 2);
    state = sub2ind([numRows, numCols], newRow, newCol); % 更新状态
end
path = [path; state]; % 添加终点

% 输出最佳路径
disp('最佳路径的状态:');
disp(path);

%% 可视化每轮总奖励
figure;
plot(totalRewards);
title('每轮总奖励');
xlabel('回合');
ylabel('总奖励');
grid on;

%% 可视化小人走迷宫的路径
figure;
hold on;
% 绘制迷宫
imagesc(maze == 1); % 绘制障碍物
colormap(gray);
axis equal;
set(gca, 'YDir', 'reverse'); % 设置Y轴方向为反向
title('小人走迷宫的路径');
xlabel('列');
ylabel('行');

% 创建视频写入对象
v = VideoWriter('maze_path', 'MPEG-4'); % 设置视频文件名
v.FrameRate = 2; % 设置帧率为10帧/秒
open(v); % 打开写入

% 计算每一帧的持续时间，以确保总时长至少为3秒
frameDuration = 3 / length(path); % 每帧持续时间（秒）

% 在路径上绘制小人
for i = 1:length(path)
    [row, col] = ind2sub([numRows, numCols], path(i));
    plot(col, row, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); % 绘制小人
    
    % 暂停对应帧的持续时间
    pause(frameDuration); 
    
    frame = getframe(gcf); % 获取当前帧
    writeVideo(v, frame); % 将帧写入视频
end

hold off;
close(v); % 关闭视频写入对象
disp('路径动态图已保存为 maze_path.mp4');