function main(dataPacketType)

    %% 激光器预燃
    % 主函数入口
    closeup(); % 清理串口
    % wait('1'); % 等待1秒，确保串口清理完成

    % 调用 laser_control 函数
    laser_serialPortName = 'COM4';
    galvano_serialPortName = 'COM3';
    V = 600; % 示例电压值
    F = 20; % 示例频率值
    % 'online_download', 'V_download', 'F_download', 'stand_by', 'Flash','QSwitch'

    % 调用 laser_control 并获取返回的变量名称
    returnedVariableName = laser_control(laser_serialPortName, V, F, dataPacketType);

    % 检查返回的变量名称是否为 'QSwitch'
    if strcmp(returnedVariableName, 'QSwitch')
        % 如果返回值为 'QSwitch'，调用 grid_scan 函数，并传递激光器参数以便中断时关闭激光器
        grid_scan(galvano_serialPortName, 115200, 100, 0, -1, 174, 9.78);
        % grid_scan(serialPort, baudRate, xRange, yRange, gridSpacing, focalLength, pauseTime, varargin)
    else
        fprintf('返回的变量名称为: %s，未调用 grid_scan。\n', returnedVariableName);
    end

end

