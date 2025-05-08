function send_serial_data(s, dataToSend)

    % MATLAB 脚本：通过串口发送和接收数据

    try
        % 要发送的数据
        % dataToSend = 'Hello, Serial Communication!';
        fprintf('发送数据：%s\n', dataToSend);

        % 开始计时
        tic;

        % 通过串口发送数据
        write(s, dataToSend, "char");

        % 循环检测是否收到反馈数据
        while true
            if s.NumBytesAvailable > 0
                % 从串口读取数据
                receivedData = read(s, s.NumBytesAvailable, "char");

                % 停止计时并计算时间
                elapsedTime = toc;

                fprintf('接收到的数据：%s\n', receivedData);
                fprintf('从发送到接收的时间：%.4f 秒\n', elapsedTime);
                break; % 退出循环
            end
        end

    catch ME
        % 错误处理
        fprintf('发生错误：%s\n', ME.message);
    end

end

