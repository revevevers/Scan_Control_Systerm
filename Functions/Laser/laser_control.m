function dataPackerName = laser_control(serialPortName, V, F, dataPacketType)
%% Define serial communication parameters

    % 清理串口对象
    clear s;
    % RS232
    baudRate = 19200; % Baud rate for the serial communication
    % Define a 10-byte hexadecimal data packet
    % 输入十进制电压值，转化为十六进制提取高位和低位
    decimalValue_uint16 = uint16(V);
    V1H = bitshift(decimalValue_uint16, -8); % 高 8 位
    V1L = bitand(decimalValue_uint16, 255);  % 低 8 位
    % 输入十进制频率值，转化为十六进制提取高位和低位
    decimalValue_uint16 = uint16(F);
    freqQH = bitshift(decimalValue_uint16, -8); % 高 8 位
    freqQL = bitand(decimalValue_uint16, 255);  % 低 8 位

    % 定义数据包类型，指令名称：
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

    % 根据输入选择数据包
    switch dataPacketType
        case 'online_download'
            dataPacket = online_download;
        case 'online_download_close'
            dataPacket = online_download_close;
        case 'V_download'
            dataPacket = V_download;
        case 'F_download'
            dataPacket = F_download;
        case 'stand_by'
            dataPacket = stand_by;
        case 'stand_by_close'
            dataPacket = stand_by_close;
        case 'Flash'
            dataPacket = Flash;
        case 'Flash_close'
            dataPacket = Flash_close;
        case 'QSwitch'
            dataPacket = QSwitch;
        case 'QSwitch_close'
            dataPacket = QSwitch_close;
        case 'outside_clk'
            dataPacket = outside_clk;
        case 'inside_clk'
            dataPacket = inside_clk;
        otherwise
            error('Invalid dataPacketType specified.');
    end

%% Send the data packet to the serial port
    % 联机下传-》设置参数（或者提前在控制面板设置好）-》stand_by-》Flash-》QSwitch-》QSwitch_close-》Flash_close-》stand_by_close

    % 串口初始化，显示可用的串口
    closeup();
    try

        % 创建并打开串口对象
        s = serialport(serialPortName, baudRate);
        fprintf('串口已打开：%s\n', serialPortName);
        write(s, dataPacket, "uint8");
        while true
            if s.NumBytesAvailable > 0
                % 从串口读取数据
                % 注意发送的是几位十六进制数，接收也是几位十六进制数
                receivedData = read(s, s.NumBytesAvailable, "uint8");
                disp(class(receivedData)); % 显示数据类型
                disp(size(receivedData)); % 显示数组大小
                disp(receivedData); % 显示接收到的数据
                
                % 查询接收到的命令对应的变量名称
                dataPackerName = findMatchingVariable(receivedData, ...
                    online_download, online_download_close, V_download, F_download, ...
                    stand_by, stand_by_close, Flash, Flash_close, QSwitch, ...
                    QSwitch_close, outside_clk, inside_clk);
                break; % 退出循环
            end
        end
    catch ME
        % 错误处理
        fprintf('发生错误：%s\n', ME.message);
        
    end
end

function variableName = findMatchingVariable(receivedData, varargin)
    
    % 查询接收到的命令对应的变量名称
    variableName = 'Unknown';
    for i = 1:length(varargin)
        if isequal(receivedData, varargin{i})
            variableName = inputname(i + 1); % 获取变量名称
            return;
        end
    end
end
