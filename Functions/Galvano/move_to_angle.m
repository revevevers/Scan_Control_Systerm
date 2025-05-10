function move_to_angle(serialPort, baudRate, angleX, angleY)
    % move_to_angle: 控制振镜偏转到指定的角度
    % 参数：
    %   serialPort: 串口端口 (如 'COM7')
    %   baudRate: 串口波特率 (如 115200)
    %   angleX: X轴目标角度 (单位：度)
    %   angleY: Y轴目标角度 (单位：度)
    %   角度转换函数（-10°~10° → 0~65535）
    function mappedValue = mapAngleToValue(angle)
        mappedValue = uint16((angle + 10) * 65535 / 20);
    end
    % 创建串口对象（新版MATLAB方式）
    s = serialport(serialPort, baudRate);
    
    try
        % 配置串口（根据需要添加）
        configureTerminator(s, "LF"); % 设置终止符
        configureCallback(s, "off");  % 关闭回调
    
        % 生成数据包（显式十六进制处理）
        data = zeros(1, 15, 'uint8');
        data(1) = hex2dec('55');    % 包头1 (0x55)
        data(2) = hex2dec('55');    % 包头2 (0x55)
    
        % 映射角度并拆分高低字节
        mappedX = mapAngleToValue(angleX);
        mappedY = mapAngleToValue(angleY);
        data(3) = uint8(bitshift(mappedX, -8));    % X角度高字节
        data(4) = uint8(bitand(mappedX, 255));     % X角度低字节
        data(5) = uint8(bitshift(mappedY, -8));    % Y角度高字节
        data(6) = uint8(bitand(mappedY, 255));     % Y角度低字节
    
        % 字节7-12填充0x00
        data(7:14) = hex2dec('00');
        data(15) = hex2dec('55');   % 包尾 (0x55)
    
        % 转换为十六进制字符串
        hexString = sprintf('%02X', data);  % 将每个字节转换为两位十六进制
        fprintf(['发送的十六进制数据: ', hexString]);
    
        write(s, data, "uint8");  % 以二进制形式发送数据
        % 发送目标角度
        send_angel_data(s, angleX, angleY);

        % 输出确认信息
        fprintf('振镜已偏转到角度：X=%.2f°, Y=%.2f°\n', angleX, angleY);
    catch ME
        % 捕获异常并输出错误信息
        fprintf('发生错误: %s\n', ME.message);
    end

    % 关闭并清理串口
    clear s;
end