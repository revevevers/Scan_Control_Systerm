%% 激光器预燃
% 主函数入口
closeup(); % 清理串口

% 调用 laser_control 函数
serialPortName = 'COM5';
V = 620; % 示例电压值
F = 10; % 示例频率值
% 'online_download', 'V_download', 'F_download', 'stand_by', 'Flash'

% 调用 laser_control 并获取返回的变量名称
returnedVariableName = laser_control(serialPortName, V, F, dataPacketType);

% 检查返回的变量名称是否为 'Flash'
if strcmp(returnedVariableName, 'Flash')
    % 如果返回值为 'Flash'，调用 move_to_angle 函数
%    angleX = 1; % 示例 X 轴角度
%    angleY = -1; % 示例 Y 轴角度
%    move_to_angle(serialPortName, 115200, angleX, angleY);
    send_serial_data('COM1', 'COM2', 9600, 138)
else
    fprintf('返回的变量名称为: %s，未调用 move_to_angle。\n', returnedVariableName);
end

%% 调用主函数
main(dataPacketType);