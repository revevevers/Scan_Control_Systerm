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

    % 计算网格点数
    numXSteps = ceil(xRange / gridSpacing); % X方向步数
    numYSteps = ceil(yRange / gridSpacing); % Y方向步数

    % 初始化起始位置
    xStart = -xRange / 2; % X方向起始点
    yStart = -yRange / 2; % Y方向起始点

    try
        % 主循环：遍历网格
        for yStep = 0:numYSteps
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
                % 记录循环开始时间
                loopStartTime = tic;

                % 计算当前X坐标
                currentX = xStart + xStep * gridSpacing;

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

                % 计算循环总时间
                loopElapsedTime = toc(loopStartTime);

                % 如果循环总时间不足pauseTime，则等待
                if loopElapsedTime < pauseTime
                    pause(pauseTime - loopElapsedTime);
                end
            end
        end
    catch ME
        % 捕获异常并输出错误信息
        warning(ME.identifier, "发生错误: %s", ME.message);
    end

    % 关闭串口
    clear s;
end