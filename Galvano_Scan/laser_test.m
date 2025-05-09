%% Define serial communication parameters
% RS232
baudRate = 19200; % Baud rate for the serial communication
serialPortName = 'COM2'; % Replace with your serial port name (e.g., 'COM3' on Windows or '/dev/ttyUSB0' on Linux/Mac)

% Define a 10-byte hexadecimal data packet

% 输入十进制电压值，转化为十六进制提取高位和低位
V = 620;
decimalValue_uint16 = uint16(V);
V1H = bitshift(decimalValue_uint16, -8); % 高 8 位
V1L = bitand(decimalValue_uint16, 255);  % 低 8 位
% 输入十进制频率值，转化为十六进制提取高位和低位
F = 10;
decimalValue_uint16 = uint16(F);
freqQH = bitshift(decimalValue_uint16, -8); % 高 8 位
freqQL = bitand(decimalValue_uint16, 255);  % 低 8 位

online_download = double([0x01, 0x11, 0x00, 0x00, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
online_download_close = double([0x01, 0x11, 0x00, 0x11, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
V_download = double([0x01, 0x22, V1H, V1L, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
F_download = double([0x01, 0x44, freqQH, freqQL, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
stand_by = double([0x01, 0x55, 0x00, 0x55, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
stand_by_close = double([0x01, 0x55, 0x00, 0x00, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
Flash = double([0x01, 0x66, 0x00, 0x66, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
Flash_close = double([0x01, 0x66, 0x00, 0x00, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
QSwitch = double([0x01, 0xbb, 0x00, 0xbb, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
QSwitch_close = double([0x01, 0xbb, 0x00, 0x00, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
outside_clk = double([0x01, 0x77, 0x00, 0x77, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);
inside_clk = double([0x01, 0x77, 0x00, 0x00, 0x00, 0x00, 0xcc, 0x33, 0xc3, 0x3c]);


%% Send the data packet to the serial port
% 联机下传-》设置参数（或者提前在控制面板设置好）-》stand_by-》Flash-》QSwitch-》QSwitch_close-》Flash_close-》stand_by_close

dataPacket = online_download;

% 串口初始化，显示可用的串口
closeup();
availablePorts = serialportlist;
disp("Available Ports:");
disp(availablePorts);
try

    % 创建并打开串口对象
    s = serialport(serialPortName, baudRate);
    fprintf('串口已打开：%s\n', serialPortName);
    write(s, dataPacket, "uint8");
    pause(1); % 等待1秒钟以确保数据发送完成
    while true
        if s.NumBytesAvailable > 0
            % 从串口读取数据
            % 注意发送的是几位十六进制数，接收也是几位十六进制数
            receivedData = read(s, s.NumBytesAvailable, "uint8");
            disp(class(receivedData)); % 显示数据类型
            disp(size(receivedData)); % 显示数组大小
            disp(receivedData); % 显示接收到的数据
            disp(dec2hex(receivedData));
            break; % 退出循环
        end
    end
catch ME
    % 错误处理
    fprintf('发生错误：%s\n', ME.message);
    
end


% send_serial_data(s, dataPacket);

% 清理串口对象
clear s;
