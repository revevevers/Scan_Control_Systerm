function grid_scan(serialPort, baudRate, xRange, yRange, gridSpacing, focalLength, pauseTime)
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
    %     - laserSerialPort: 激光器串口名称 (如 'COM4')
    %     - laserVoltage: 激光器电压 (默认: 590)
    %     - laserFrequency: 激光器频率 (默认: 20)
    
    
    % 声明全局变量用于控制扫描中断
    global SCAN_STOP_FLAG;
    SCAN_STOP_FLAG = false;
    
    % 创建停止扫描的按钮
    fprintf('扫描开始！按 Ctrl+C 或调用 stop_grid_scan() 函数来停止扫描\n');

    % 计算网格点数
    numXSteps = abs(xRange) / abs(gridSpacing); % X方向步数
    numYSteps = abs(yRange) / abs(gridSpacing); % Y方向步数

    % 初始化起始位置
    xStart = (xRange / 2) + 2; % X方向起始点
    yStart = yRange / 2; % Y方向起始点

    try
        % 主循环：遍历网格
        for yStep = 0:numYSteps
            % 检查扫描停止标志
            if SCAN_STOP_FLAG
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
                if SCAN_STOP_FLAG
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

                % 打印当前位置信息
                fprintf('当前位置：X=%.2f mm, Y=%.2f mm\n', currentX, currentY);

                % 如果move_to_position运行时间不足50ms，则等待
                if moveElapsedTime < 0.05
                    pause(0.05 - moveElapsedTime);
                end
                
                pause(pauseTime);
                % 计算循环总时间
                loopElapsedTime = toc(loopStartTime);

                % 输出本次循环总时间
                fprintf('本次循环总时间：%.4f 秒\n', loopElapsedTime);
                fprintf('第%.4f 个点\n', xStep);
            end
        end
    catch ME
        % 捕获异常并输出错误信息
        warning(ME.identifier, "发生错误: %s", ME.message);
    end
    
    SCAN_STOP_FLAG = true;

    % 如果扫描被中断，发送停止激光的命令
    if SCAN_STOP_FLAG
        fprintf('扫描已停止，正在关闭激光器...\n');
        try
            % 使用传入的激光器参数
            laser_control('COM4', 595, 20, 'QSwitch_close');
            fprintf('激光器已关闭\n');
        catch laserError
            fprintf('关闭激光器时发生错误: %s\n', laserError.message);
        end
    end

    % 关闭串口
    clear s;
end