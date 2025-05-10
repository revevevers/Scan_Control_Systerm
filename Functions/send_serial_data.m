function send_serial_data(sendPortName, receivePortName, baudRate, dataToSend)
    % MATLAB 脚本：通过两个不同的串口发送和接收数据
    % 输入:
    %   sendPortName - 用于发送数据的串口名称 (如 "COM1")
    %   receivePortName - 用于接收数据的串口名称 (如 "COM2")
    %   baudRate - 串口波特率 (如 9600)
    %   dataToSend - 要发送的十进制数数组

    % 打开发送和接收串口
    s = serialport(sendPortName, baudRate);
    r = serialport(receivePortName, baudRate);

    try
        % 打印发送数据
        fprintf('发送数据（十进制）：%s\n', mat2str(dataToSend));

        % 确保数据为 uint8 类型
        dataToSend = uint8(dataToSend);

        % 开始计时
        tic;

        % 通过发送串口发送数据
        write(s, dataToSend, "uint8");

        % 循环检测接收串口是否收到反馈数据
        while true
            if r.NumBytesAvailable > 0
                % 从接收串口读取数据
                receivedData = read(r, r.NumBytesAvailable, "uint8");

                % 停止计时并计算时间
                elapsedTime = toc;

                fprintf('接收到的数据（十进制）：%s\n', mat2str(receivedData));
                fprintf('从发送到接收的时间：%.4f 秒\n', elapsedTime);
                break; % 退出循环
            end
        end

    catch ME
        % 错误处理
        fprintf('发生错误：%s\n', ME.message);
    end

    % 关闭串口
    clear s r;
end
