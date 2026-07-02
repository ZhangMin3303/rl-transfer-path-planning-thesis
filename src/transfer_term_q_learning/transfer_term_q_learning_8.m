% 清除工作区
clear; close all; clc;

%% 迷宫环境定义（源任务与三个目标任务）
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

%% 通用参数设置
start_pos = [1, 1];  % 起点坐标（行，列）
end_pos = [8, 8];    % 终点坐标
gamma = 0.9;        % 折扣因子
alpha = 0.25;         % 学习率
epsilon_start = 1;       % 初始探索概率
epsilon_min = 0.3;  % 最小探索概率
epsilon_decay = 0.995; % 探索率递减因子
lambda = 0.35;        % 迁移权重系数
num_episodes = 400;  % 训练回合数
max_steps = 80;     % 单回合最大步数

%% 第一阶段：源任务Q训练
Q_source = zeros(64, 4);  % 64个状态，每个状态4个动作
rewards_source = zeros(num_episodes, 1);

fprintf('第一阶段：源任务训练...\n');
for episode = 1:num_episodes
    [i, j] = deal(start_pos(1), start_pos(2));
    done = false;
    total_reward = 0;
    epsilon = max(epsilon_min, epsilon_start * epsilon_decay^episode);  % 自适应探索率

    for current_step = 1:max_steps
        state = (i-1)*8 + j;
        
        valid_actions = get_valid_actions(i, j, maze0);
        if isempty(valid_actions), break; end
        
        if rand < epsilon
            action = valid_actions(randi(length(valid_actions)));
        else
            [~, idx] = max(Q_source(state, valid_actions));
            action = valid_actions(idx);
        end
        
        [next_i, next_j, reward, done] = make_step(maze0, i, j, action);
        next_state = (next_i-1)*8 + next_j;
        
        td_error = reward + gamma*max(Q_source(next_state, :)) - Q_source(state, action);
        Q_source(state, action) = Q_source(state, action) + alpha * td_error;
        
        [i, j] = deal(next_i, next_j);
        total_reward = total_reward + reward;
        if done, break; end
    end
    rewards_source(episode) = total_reward;
end

%% 第二阶段：目标任务训练（无迁移）
epsilon = epsilon_start; % 重置探索率
Q_nt1 = 0.1*randn(64, 4); % nt表示无迁移
Q_nt2 = 0.1*randn(64, 4);
Q_nt3 = 0.1*randn(64, 4);
rewards_nt1 = zeros(num_episodes, 1);
rewards_nt2 = zeros(num_episodes, 1);
rewards_nt3 = zeros(num_episodes, 1);

% 新增：损失和步数记录
losses_nt1 = zeros(num_episodes, max_steps); % 目标任务1无迁移损失
losses_nt2 = zeros(num_episodes, max_steps); % 目标任务2无迁移损失
losses_nt3 = zeros(num_episodes, max_steps); % 目标任务3无迁移损失
steps_nt1 = zeros(num_episodes, 1); % 目标任务1无迁移步数
steps_nt2 = zeros(num_episodes, 1); % 目标任务2无迁移步数
steps_nt3 = zeros(num_episodes, 1); % 目标任务3无迁移步数

fprintf('\n第二阶段：目标任务无迁移训练...\n');
for episode = 1:num_episodes
    epsilon = max(epsilon_min, epsilon_start * epsilon_decay^episode);  % 自适应探索率
    
    % 目标任务1
    [i, j] = deal(start_pos(1), start_pos(2));
    done = false;
    total_reward = 0;
    for current_step = 1:max_steps
        state = (i-1)*8 + j;
        valid_actions = get_valid_actions(i, j, maze1);
        if isempty(valid_actions), break; end
        
        if rand < epsilon
            action = valid_actions(randi(length(valid_actions)));
        else
            [~, idx] = max(Q_nt1(state, valid_actions));
            action = valid_actions(idx);
        end
        
        [next_i, next_j, reward, done] = make_step(maze1, i, j, action);
        next_state = (next_i-1)*8 + next_j;
        
        td_error = reward + gamma*max(Q_nt1(next_state, :)) - Q_nt1(state, action);
        Q_nt1(state, action) = Q_nt1(state, action) + alpha * td_error;
        losses_nt1(episode, current_step) = td_error; % 记录损失
        
        total_reward = total_reward + reward;
        [i, j] = deal(next_i, next_j);
        if done, break; end
    end
    rewards_nt1(episode) = total_reward;
    steps_nt1(episode) = current_step; % 记录步数
    
    % 目标任务2
    [i, j] = deal(start_pos(1), start_pos(2));
    done = false;
    total_reward = 0;
    for current_step = 1:max_steps
        state = (i-1)*8 + j;
        valid_actions = get_valid_actions(i, j, maze2);
        if isempty(valid_actions), break; end
        
        if rand < epsilon
            action = valid_actions(randi(length(valid_actions)));
        else
            [~, idx] = max(Q_nt2(state, valid_actions));
            action = valid_actions(idx);
        end
        
        [next_i, next_j, reward, done] = make_step(maze2, i, j, action);
        next_state = (next_i-1)*8 + next_j;
        
        td_error = reward + gamma*max(Q_nt2(next_state, :)) - Q_nt2(state, action);
        Q_nt2(state, action) = Q_nt2(state, action) + alpha * td_error;
        losses_nt2(episode, current_step) = td_error; % 记录损失
        
        total_reward = total_reward + reward;
        [i, j] = deal(next_i, next_j);
        if done, break; end
    end
    rewards_nt2(episode) = total_reward;
    steps_nt2(episode) = current_step; % 记录步数
    
    % 目标任务3
    [i, j] = deal(start_pos(1), start_pos(2));
    done = false;
    total_reward = 0;
    for current_step = 1:max_steps
        state = (i-1)*8 + j;
        valid_actions = get_valid_actions(i, j, maze3);
        if isempty(valid_actions), break; end
        
        if rand < epsilon
            action = valid_actions(randi(length(valid_actions)));
        else
            [~, idx] = max(Q_nt3(state, valid_actions));
            action = valid_actions(idx);
        end
        
        [next_i, next_j, reward, done] = make_step(maze3, i, j, action);
        next_state = (next_i-1)*8 + next_j;
        
        td_error = reward + gamma*max(Q_nt3(next_state, :)) - Q_nt3(state, action);
        Q_nt3(state, action) = Q_nt3(state, action) + alpha * td_error;
        losses_nt3(episode, current_step) = td_error; % 记录损失
        
        total_reward = total_reward + reward;
        [i, j] = deal(next_i, next_j);
        if done, break; end
    end
    rewards_nt3(episode) = total_reward;
    steps_nt3(episode) = current_step; % 记录步数
end

%% 第三阶段：目标任务训练（带迁移）
epsilon = epsilon_start; % 重置探索率
Q_t1 = 0.1*randn(64, 4); % t表示带迁移
Q_t2 = 0.1*randn(64, 4);
Q_t3 = 0.1*randn(64, 4);
rewards_t1 = zeros(num_episodes, 1);
rewards_t2 = zeros(num_episodes, 1);
rewards_t3 = zeros(num_episodes, 1);

% 新增：损失和步数记录
losses_t1 = zeros(num_episodes, max_steps); % 目标任务1带迁移损失
losses_t2 = zeros(num_episodes, max_steps); % 目标任务2带迁移损失
losses_t3 = zeros(num_episodes, max_steps); % 目标任务3带迁移损失
steps_t1 = zeros(num_episodes, 1); % 目标任务1带迁移步数
steps_t2 = zeros(num_episodes, 1); % 目标任务2带迁移步数
steps_t3 = zeros(num_episodes, 1); % 目标任务3带迁移步数

fprintf('\n第三阶段：目标任务带迁移训练...\n');
for episode = 1:num_episodes
    current_lambda = lambda * (1 - episode/num_episodes); % 线性衰减迁移权重
    epsilon = max(epsilon_min, epsilon_start * epsilon_decay^episode);  % 自适应探索率
    
    % 目标任务1
    [i, j] = deal(start_pos(1), start_pos(2));
    done = false;
    total_reward = 0;
    for current_step = 1:max_steps
        state = (i-1)*8 + j;
        valid_actions = get_valid_actions(i, j, maze1);
        if isempty(valid_actions), break; end
        
        if rand < epsilon
            action = valid_actions(randi(length(valid_actions)));
        else
            [~, idx] = max(Q_t1(state, valid_actions));
            action = valid_actions(idx);
        end
        
        [next_i, next_j, reward, done] = make_step(maze1, i, j, action);
        next_state = (next_i-1)*8 + next_j;
        
        td_error = reward + gamma*max(Q_t1(next_state, :)) - Q_t1(state, action);
        migration_term = current_lambda * (Q_source(state, action) - Q_t1(state, action));
        Q_t1(state, action) = Q_t1(state, action) + alpha*(td_error + migration_term);
        losses_t1(episode, current_step) = td_error; % 记录损失
        
        total_reward = total_reward + reward;
        [i, j] = deal(next_i, next_j);
        if done, break; end
    end
    rewards_t1(episode) = total_reward;
    steps_t1(episode) = current_step; % 记录步数
    
    % 目标任务2
    [i, j] = deal(start_pos(1), start_pos(2));
    done = false;
    total_reward = 0;
    for current_step = 1:max_steps
        state = (i-1)*8 + j;
        valid_actions = get_valid_actions(i, j, maze2);
        if isempty(valid_actions), break; end
        
        if rand < epsilon
            action = valid_actions(randi(length(valid_actions)));
        else
            [~, idx] = max(Q_t2(state, valid_actions));
            action = valid_actions(idx);
        end
        
        [next_i, next_j, reward, done] = make_step(maze2, i, j, action);
        next_state = (next_i-1)*8 + next_j;
        
        td_error = reward + gamma*max(Q_t2(next_state, :)) - Q_t2(state, action);
        migration_term = current_lambda * (Q_source(state, action) - Q_t2(state, action));
        Q_t2(state, action) = Q_t2(state, action) + alpha*(td_error + migration_term);
        losses_t2(episode, current_step) = td_error; % 记录损失
        
        total_reward = total_reward + reward;
        [i, j] = deal(next_i, next_j);
        if done, break; end
    end
    rewards_t2(episode) = total_reward;
    steps_t2(episode) = current_step; % 记录步数
    
    % 目标任务3
    [i, j] = deal(start_pos(1), start_pos(2));
    done = false;
    total_reward = 0;
    for current_step = 1:max_steps
        state = (i-1)*8 + j;
        valid_actions = get_valid_actions(i, j, maze3);
        if isempty(valid_actions), break; end
        
        if rand < epsilon
            action = valid_actions(randi(length(valid_actions)));
        else
            [~, idx] = max(Q_t3(state, valid_actions));
            action = valid_actions(idx);
        end
        
        [next_i, next_j, reward, done] = make_step(maze3, i, j, action);
        next_state = (next_i-1)*8 + next_j;
        
        td_error = reward + gamma*max(Q_t3(next_state, :)) - Q_t3(state, action);
        migration_term = current_lambda * (Q_source(state, action) - Q_t3(state, action));
        Q_t3(state, action) = Q_t3(state, action) + alpha*(td_error + migration_term);
        losses_t3(episode, current_step) = td_error; % 记录损失
        
        total_reward = total_reward + reward;
        [i, j] = deal(next_i, next_j);
        if done, break; end
    end
    rewards_t3(episode) = total_reward;
    steps_t3(episode) = current_step; % 记录步数
end

%% 路径规划演示
fprintf('\n=== 源任务路径演示 ===\n');
show_path(maze0, Q_source);

fprintf('\n=== 目标任务1（无迁移）路径演示 ===\n');
show_path(maze1, Q_nt1);

fprintf('\n=== 目标任务1（带迁移）路径演示 ===\n');
show_path(maze1, Q_t1);

%% 奖励曲线对比
avg_no_transfer = (rewards_nt1 + rewards_nt2 + rewards_nt3) / 3;  % 无迁移
avg_transfer = (rewards_t1 + rewards_t2 + rewards_t3) / 3;        % 带迁移

figure('Position', [100 100 800 500]);
plot(1:num_episodes, avg_no_transfer, 'b-', 'LineWidth', 2, 'DisplayName', 'Q训练目标任务的平均总奖励');
hold on;
plot(1:num_episodes, avg_transfer, 'r-', 'LineWidth', 2, 'DisplayName', 'TL训练目标任务的平均总奖励');
xlabel('回合');
ylabel('总奖励');
title('每轮总奖励对比');
legend('Location', 'southeast');
grid on;
box off;

%% 可视化算法损失函数
lossesQ = mean([losses_nt1, losses_nt2, losses_nt3], 2); % 无迁移平均损失
lossesTL = mean([losses_t1, losses_t2, losses_t3], 2);   % 带迁移平均损失

figure;
hold on;
plot(1:num_episodes, lossesQ, 'b', 'LineWidth', 1.5, 'DisplayName', 'Q训练平均损失');
plot(1:num_episodes, lossesTL, 'r', 'LineWidth', 1.5, 'DisplayName', 'TL训练平均损失');
title('每轮损失对比');
xlabel('回合');
ylabel('平均损失');
legend('Location', 'northeast');
grid on;
hold off;

%% 可视化每轮步数
stepsQ = (steps_nt1 + steps_nt2 + steps_nt3) / 3; % 无迁移平均步数
stepsTL = (steps_t1 + steps_t2 + steps_t3) / 3;   % 带迁移平均步数

figure;
hold on;
plot(1:num_episodes, stepsQ, 'b', 'LineWidth', 1.5, 'DisplayName', 'Q训练平均步数');
plot(1:num_episodes, stepsTL, 'r', 'LineWidth', 1.5, 'DisplayName', 'TL训练平均步数');
title('每轮步数对比');
xlabel('回合');
ylabel('平均步数');
legend('Location', 'northeast');
grid on;
hold off;

%% 可视化AUC

% 计算曲线下面积并绘制柱状图
AUC1 = trapz(avg_no_transfer-28); % 使用梯形积分计算面积
AUC2 = trapz(avg_transfer-28); % 使用梯形积分计算另一个面积

% 计算 AUC（0~0.5~1）
AUC1 = (160000-abs(AUC1))/160000;
AUC2 = (160000-abs(AUC2))/160000;

figure;
hold on; % 保持图形，允许叠加绘制

% 绘制两组柱状图
bar(1, AUC1, 'FaceColor', 'b', 'EdgeColor', 'k'); % 第一组柱状图
bar(3, AUC2, 'FaceColor', 'r', 'EdgeColor', 'k'); % 第二组柱状图

title('曲线下面积 (AUC)');
ylabel('面积值');
set(gca, 'XTick', [1, 3], 'XTickLabel', {'Q训练目标任务的平均AUC', 'TL训练目标任务的平均AUC'}); % 设置x轴标签

% 添加AUC值文本
text(1, AUC1, sprintf('AUC = %.2f', AUC1), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);
text(3, AUC2, sprintf('AUC = %.2f', AUC2), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 10);

hold off; % 释放图形

%% 辅助函数
function [next_i, next_j, reward, done] = make_step(maze, i, j, action)
    [next_i, next_j] = move_pos(i, j, action);
    done = false;
    
    if ~is_valid_pos(next_i, next_j, maze)
        next_i = i;
        next_j = j;
        reward = -3;
    else
        reward = -1;
    end
    
    if next_i == 8 && next_j == 8
        reward = 30;
        done = true;
    end
end

function [i, j] = move_pos(i, j, action)
    switch action
        case 1, i = max(1, i-1);  % 上
        case 2, i = min(8, i+1);  % 下
        case 3, j = max(1, j-1);  % 左
        case 4, j = min(8, j+1);  % 右
    end
end

function valid = is_valid_pos(i, j, maze)
    valid = true;
    if i < 1 || i > 8 || j < 1 || j > 8 || maze(i,j) == 1
        valid = false;
    end
end

function valid_actions = get_valid_actions(i, j, maze)
    valid_actions = [];
    for action = 1:4
        [test_i, test_j] = move_pos(i, j, action);
        if is_valid_pos(test_i, test_j, maze)
            valid_actions(end+1) = action;
        end
    end
    if isempty(valid_actions)
        error('没有可行动作！');
    end
end

function show_path(maze, Q)
    [i, j] = deal(1, 1);
    path = [i, j];
    done = false;
    step_count = 0;
    
    while ~done && step_count < 30
        state = (i-1)*8 + j;
        valid_actions = get_valid_actions(i, j, maze);
        if isempty(valid_actions)
            fprintf('路径规划失败！\n');
            return;
        end
        
        [~, idx] = max(Q(state, valid_actions));
        action = valid_actions(idx);
        
        [next_i, next_j, ~, done] = make_step(maze, i, j, action);
        path = [path; next_i, next_j];
        [i, j] = deal(next_i, next_j);
        step_count = step_count + 1;
    end
    
    fprintf('路径坐标：\n');
    disp(path);
    visualize_maze(maze, path);
end

function visualize_maze(maze, path)
    fig = figure;
    set(fig, 'Position', [200 200 600 600]);
    
    imagesc(maze);
    colormap([1 1 1; 0.4 0.4 0.4]);
    hold on;
    
    plot(path(:,2), path(:,1), 'r-s', 'LineWidth',2, 'MarkerSize',10);
    plot(1,1, 'go', 'MarkerSize',15, 'LineWidth',3);
    plot(8,8, 'bx', 'MarkerSize',15, 'LineWidth',3);
    
    axis equal;
    set(gca, 'XTick',1:8, 'YTick',1:8, ...
            'XTickLabel',1:8, 'YTickLabel',1:8, ...
            'GridLineStyle','-', 'LineWidth',1.5);
    grid on;
    title('8×8迷宫');
end