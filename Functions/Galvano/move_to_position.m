function move_to_position(serialPort, baudRate, focusX, focusY, focalLength)
    % move_to_angle: 控制振镜偏转到指定的聚焦点位置
    % 参数：
    %   serialPort: 串口端口 (如 'COM7')
    %   baudRate: 串口波特率 (如 115200)
    %   focusX: 聚焦点的 X 坐标 (单位：mm)
    %   focusY: 聚焦点的 Y 坐标 (单位：mm)
    %   focalLength: 场镜焦距 (单位：mm)

    % 关闭并清理串口
    clear s;

    % 角度转换函数（-11°~11° → 0~32767）
    function mappedValue = mapAngleToValue(angle)
        % 将角度从 -11°~11° 映射到 ADC 对应的 ±5V 电压范围（16384~49152）
        
        % 限制输入范围，防止超出
        angle = max(min(angle, 11), -11);
        
        % 线性映射从 [-11, 11] 到 [16384, 49152]，跨度为 32768
        mappedValue = uint16(round((angle + 11) * 32768 / 22 + 16384));
    end


    % 电压转换函数（0~32767 → -5V~5V）
    function voltage = mapValueToVoltage(value)
        % 将 0~32767 映射到 -5V~5V
        voltage = (double(value) / 65535) * 20 - 10;
    end

    % 计算偏转角度（弧度制）
    angleX = atan(focusX / focalLength) / 2; % X 方向偏转角度 (弧度)，除以 2
    angleY = atan(focusY / focalLength) / 2; % Y 方向偏转角度 (弧度)，除以 2

    % 将弧度转换为角度（度制）
    angleX = rad2deg(angleX);
    angleY = rad2deg(angleY);

    % 创建串口对象（新版 MATLAB 方式）
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

        % 字节7-14填充0x00
        data(7:14) = hex2dec('00');
        data(15) = hex2dec('55');   % 包尾 (0x55)

        % 转换为十六进制字符串
        hexString = sprintf('%02X', data);  % 将每个字节转换为两位十六进制
        fprintf(['发送的十六进制数据: ', hexString]);

        % 发送数据包
        write(s, data, "uint8");

        % 计算对应的电压值
        voltageX = mapValueToVoltage(mappedX);
        voltageY = mapValueToVoltage(mappedY);

        % 输出确认信息
        fprintf('振镜已偏转到聚焦点：X=%.2f mm, Y=%.2f mm\n', focusX, focusY);
        fprintf('对应的偏转角度：X=%.2f°, Y=%.2f°\n', angleX, angleY);
        fprintf('对应的电压值：X=%.2f V, Y=%.2f V\n', voltageX, voltageY);
    catch ME
        % 捕获异常并输出错误信息
        fprintf('发生错误: %s\n', ME.message);
    end
end