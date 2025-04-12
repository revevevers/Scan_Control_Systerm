function straight_pattern()
    % 控制某一个轴以一定步长偏转一定角度范围
    % 串口设置
    serialPort = 'COM5';   % 根据实际端口修改
    baudRate = 115200;     % 波特率需与设备匹配
    axis = 'X';            % 选择控制轴：'X' 或 'Y'
    stepSize = 0.1;        % 角度步长（度）
    maxAngle = 2;          % 最大偏转角度（度）
    pauseTime = 1;         % 每步停留时间（秒）
    
    % 打开串口
    s = serialport(serialPort, baudRate);

    % 初始化角度
    angleX = 0;          % X轴初始角度
    angleY = 0;          % Y轴初始角度
    currentAngle = -maxAngle;  % 起始角度

    try
        % 主循环（扫描完整范围后退出）
        while true
            % 更新目标轴角度
            if strcmpi(axis, 'X')
                angleX = currentAngle;
            elseif strcmpi(axis, 'Y')
                angleY = currentAngle;
            else
                error('轴参数错误：请设置为 "X" 或 "Y"');
            end

            % 发送当前角度数据
            send_serial_data(s, angleX, angleY);
            fprintf('当前角度：%s=%.2f°\n', axis, currentAngle);

            % 检查是否完成扫描
            if currentAngle >= maxAngle
                break;  % 扫描完成，退出循环
            end

            % 更新角度（确保不超过maxAngle）
            currentAngle = min(currentAngle + stepSize, maxAngle);

            % 停留时间
            pause(pauseTime);
        end
        
        fprintf('扫描完成：%s轴从 -%.2f° 到 +%.2f°\n', axis, maxAngle, maxAngle);
        
    catch ME
        warning(ME.identifier, "发生错误: %s", ME.message);
    end

    % 关闭串口
    clear s;
end