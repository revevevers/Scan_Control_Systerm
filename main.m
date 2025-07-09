function main(dataPacketType)

    %% 激光器预燃
    % 主函数入口
    closeup(); % 清理串口

    % 调用 laser_control 函数
    laser_serialPortName = 'COM5';
    galvano_serialPortName = 'COM3';
    V = 590; % 示例电压值
    F = 20; % 示例频率值
    % 'online_download', 'V_download', 'F_download', 'stand_by', 'Flash','QSwitch'

    % 调用 laser_control 并获取返回的变量名称
    returnedVariableName = laser_control(laser_serialPortName, V, F, dataPacketType);

    % 检查返回的变量名称是否为 'Flash'
    if strcmp(returnedVariableName, 'Flash')
        % 如果返回值为 'Flash'，调用 grid_scan(serialPort, baudRate, xRange, yRange, gridSpacing, focalLength, pauseTime)函数
        grid_scan(galvano_serialPortName, 115200, 50, 50, 1, 163, 0.2);
    else
        fprintf('返回的变量名称为: %s，未调用 move_to_angle。\n', returnedVariableName);
    end

end

