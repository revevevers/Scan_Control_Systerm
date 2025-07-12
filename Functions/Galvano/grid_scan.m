function grid_scan(serialPort, baudRate, xRange, yRange, gridSpacing, focalLength, pauseTime, varargin)
    % 蛇形偏转函数
    % 参数：
    %   serialPort: 串口端口 (如 'COM7')
    %   baudRate: 串口波特率 (如 115200)
    %   xRange: X方向的总距离 (单位：mm)
    %   yRange: Y方向的总距离 (单位：mm)
    %   gridSpacing: 网格间距 (单位：mm)
    %   focalLength: 场镜焦距 (单位：mm)
    %   pauseTime: 每次循环的总时间 (单位：秒)
    %   varargin: 可选参数
    %     - 'StartX': X方向起始位置 (默认: xRange/2 + 2)
    %     - 'StartY': Y方向起始位置 (默认: yRange/2)
    %     - 'LaserSerialPort': 激光器串口名称 (默认: 'COM4')
    %     - 'LaserVoltage': 激光器电压 (默认: 595)
    %     - 'LaserFrequency': 激光器频率 (默认: 20)
    
    % 解析可选参数
    p = inputParser;
    addParameter(p, 'StartX', (xRange / 2) + 2, @isnumeric);
    addParameter(p, 'StartY', yRange / 2, @isnumeric);
    addParameter(p, 'LaserSerialPort', 'COM4', @ischar);
    addParameter(p, 'LaserVoltage', 595, @isnumeric);
    addParameter(p, 'LaserFrequency', 20, @isnumeric);
    parse(p, varargin{:});
    
    % 声明全局变量用于控制扫描中断
    global SCAN_STOP_FLAG;
    SCAN_STOP_FLAG = false;
    
    % 清理可能存在的停止标志文件
    stopFile = 'grid_scan_stop.flag';
    if exist(stopFile, 'file')
        delete(stopFile);
    end
    
    % 创建停止扫描的按钮
    fprintf('扫描开始！按 Ctrl+C 或调用 stop_grid_scan() 函数来停止扫描\n');
    fprintf('也可以调用 stop_grid_scan_file() 作为备用停止方法\n');

    % 计算网格点数
    numXSteps = abs(xRange) / abs(gridSpacing); % X方向步数
    numYSteps = abs(yRange) / abs(gridSpacing); % Y方向步数

    % 使用解析后的起始位置
    xStart = p.Results.StartX; % X方向起始点
    yStart = p.Results.StartY; % Y方向起始点
    
    fprintf('起始位置: X=%.2f mm, Y=%.2f mm\n', xStart, yStart);

    try
        % 主循环：遍历网格
        for yStep = 0:numYSteps
            % 检查扫描停止标志
            if SCAN_STOP_FLAG || exist(stopFile, 'file')
                fprintf('检测到停止信号，正在停止扫描...\n');
                break;
            end
            
            % 计算当前Y坐标
            currentY = yStart + yStep * gridSpacing;

            % X方向的扫描
            if mod(yStep, 2) == 0
                % 偶数行：从左到右
                xSteps = 0:numXSteps;
            else
                % 奇数行：从右到左
                xSteps = numXSteps:-1:0;
            end

            for xStep = xSteps
                % 检查扫描停止标志
                if SCAN_STOP_FLAG || exist(stopFile, 'file')
                    fprintf('检测到停止信号，正在停止扫描...\n');
                    break;
                end
                
                % 记录循环开始时间
                loopStartTime = tic;

                % 计算当前X坐标
                currentX = xStart - xStep * gridSpacing;

                % 在前50ms内运行move_to_position函数
                moveStartTime = tic;
                move_to_position(serialPort, baudRate, currentX, currentY, focalLength);
                moveElapsedTime = toc(moveStartTime);

                % 再次检查停止标志（move_to_position执行后）
                if SCAN_STOP_FLAG || exist(stopFile, 'file')
                    fprintf('检测到停止信号，正在停止扫描...\n');
                    break;
                end

                % 打印当前位置信息
                fprintf('当前位置：X=%.2f mm, Y=%.2f mm\n', currentX, currentY);
                fprintf('第%.0f 个点\n', xStep);

                % 如果move_to_position运行时间不足50ms，则等待
                if moveElapsedTime < 0.05
                    pause(0.05 - moveElapsedTime);
                end
                
                % 将长时间的pause分解为多个短暂的pause，以便及时响应中断
                remainingPauseTime = pauseTime;
                while remainingPauseTime > 0 && ~SCAN_STOP_FLAG && ~exist(stopFile, 'file')
                    pauseStep = min(0.1, remainingPauseTime); % 每次暂停最多0.1秒
                    pause(pauseStep);
                    remainingPauseTime = remainingPauseTime - pauseStep;
                end
                
                % 检查是否在pause期间收到停止信号
                if SCAN_STOP_FLAG || exist(stopFile, 'file')
                    fprintf('检测到停止信号，正在停止扫描...\n');
                    break;
                end
                % 计算循环总时间
                loopElapsedTime = toc(loopStartTime);

                % 输出本次循环总时间
                fprintf('本次循环总时间：%.4f 秒\n', loopElapsedTime);
            end
        end
    catch ME
        % 捕获异常并输出错误信息
        warning(ME.identifier, "发生错误: %s", ME.message);
    end
    
    SCAN_STOP_FLAG = true;

    % 如果扫描被中断，发送停止激光的命令
    if SCAN_STOP_FLAG || exist(stopFile, 'file')
        fprintf('扫描已停止，正在关闭激光器...\n');
        try
            % 使用传入的激光器参数
            download('QSwitch_close', 'COM4', 600, 20);
            fprintf('激光器已关闭\n');
        catch laserError
            fprintf('关闭激光器时发生错误: %s\n', laserError.message);
        end
    end

    % 清理停止标志文件
    if exist(stopFile, 'file')
        delete(stopFile);
    end

    % 关闭串口
    clear s;
end