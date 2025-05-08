function snake_pattern(serialPort, baudRate, xStepSize, yStepSize, maxAngle, pauseTime)
    % 蛇形偏转函数
    % 参数：
    %   serialPort: 串口端口 (如 'COM7')
    %   baudRate: 串口波特率 (如 115200)
    %   xStepSize: X轴步长 (单位：度)
    %   yStepSize: Y轴步长 (单位：度)
    %   maxAngle: 最大偏转角度范围 [-maxAngle, maxAngle]
    %   pauseTime: 每次偏转后停留时间 (单位：秒)

    % 打开串口
    s = serialport(serialPort, baudRate);

    % 初始化角度
    angleX = -maxAngle;  % X轴初始角度
    angleY = -maxAngle;  % Y轴初始角度
    direction = 1;       % X轴偏转方向 (1: 正向, -1: 反向)

    try
        % 主循环
        while angleY <= maxAngle
            % 发送当前角度数据
            send_serial_data(s, angleX, angleY);

            % 更新X轴角度
            angleX = angleX + direction * xStepSize;

            % 判断是否需要反向
            if angleX > maxAngle || angleX < -maxAngle
                % 超出范围，反向
                direction = -direction;

                % Y轴增加步长
                angleY = angleY + yStepSize;

                % 确保Y轴不超过范围
                if angleY > maxAngle
                    break;
                end
            end

            % 停留一定时间
            pause(pauseTime);
        end
    catch ME
        warning(ME.identifier, "发生错误: %s", ME.message);
    end

    % 关闭串口
    clear s;
end