function move_to_angle(serialPort, baudRate, angleX, angleY)
    % move_to_angle: 控制振镜偏转到指定的角度
    % 参数：
    %   serialPort: 串口端口 (如 'COM7')
    %   baudRate: 串口波特率 (如 115200)
    %   angleX: X轴目标角度 (单位：度)
    %   angleY: Y轴目标角度 (单位：度)

    % 创建串口对象（新版MATLAB方式）
    s = serialport(serialPort, baudRate);
    
    try
        % 配置串口（根据需要添加）
        configureTerminator(s, "LF"); % 设置终止符
        configureCallback(s, "off");  % 关闭回调
        
        % 发送目标角度
        send_angel_data(s, angleX, angleY);

        % 输出确认信息
        fprintf('振镜已偏转到角度：X=%.2f°, Y=%.2f°\n', angleX, angleY);
    catch ME
        % 捕获异常并输出错误信息
        warning(ME.identifier, "发生错误: %s", ME.message);
    end

    % 关闭并清理串口
    clear s;
end