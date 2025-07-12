%% 扫描控制系统GUI启动脚本
% 运行此脚本启动扫描控制系统的图形用户界面

% 清理工作区
clear;
clc;

% 添加必要的路径
addpath('Functions');
addpath('Functions/debug');
addpath('Functions/Laser');
addpath('Functions/Galvano');

% 启动GUI
fprintf('正在启动扫描控制系统GUI...\n');
ScanControlGUI();
fprintf('GUI启动完成！\n');
