closeup();
clear s;

%%
main('online_download'); % 激光器预燃%
%%
% wait(1); % 等待1秒，确保激光器预燃完成
main('V_download'); % 设置电压
%%
main('F_download'); % 设置频率
% wait(1); % 等待1秒，确保电压和频率设置完成
%%
main('stand_by'); % 激光器待机
% wait(1); % 等待1秒，确保激光器待机完成
%%
main('Flash'); % 激光器启动
% wait(1); % 等待1秒，确保激光器启动完成


%%
main('QSwitch'); % 激光器预燃并开始网格扫描
%%
stop_grid_scan(); % 停止网格扫描
%%

main('QSwitch_close'); % 激光器预燃并关闭
%%
grid_scan('COM3', 115200, 100, 0, -1, 163, 10);

%%
main('Flash_close'); % 激光器闪光关闭
%%
% wait(1); % 等待1秒，确保激光器闪光关闭完成
main('stand_by_close'); % 激光器待机关闭
%%
% wait(1); % 等待1秒，确保激光器待机关闭完成
main('online_download_close'); % 激光器在线下载关闭

%%
laser_control('COM4', 600, 20, 'QSwitch');
grid_scan('COM3', 115200, 100, 0, 1, 174, 5.3816);

