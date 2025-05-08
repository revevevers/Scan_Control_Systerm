% 串口数据发送函数，原理：±10°映射到65535位上
function send_serial_data(s, angleX, angleY)
    % send_serial_data: 将角度数据映射并以十六进制格式发送到串口
    % 参数：
    %   s: 串口对象
    %   angleX: X轴角度 (单位：度)
    %   angleY: Y轴角度 (单位：度)

    % 角度映射函数（-10°~10° → 0~65535）
    function mappedValue = mapAngleToValue(angle)
        mappedValue = uint16((angle + 10) * 65535 / 20);
    end

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
    disp(['发送的十六进制数据: ', hexString]);

    % 方法2：以十六进制字符串形式发送数据
    write(s, data, "uint8");  % 以二进制形式发送
end