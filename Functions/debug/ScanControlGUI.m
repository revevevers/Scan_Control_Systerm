function ScanControlGUI()
    % 扫描控制系统GUI界面
    % 实现激光器和振镜的完整控制流程
    
    % 创建主窗口
    fig = uifigure('Name', '扫描控制系统', 'Position', [100, 100, 1000, 700]);
    
    % 定义全局状态变量
    appData = struct();
    appData.isPortCleaned = false;
    appData.isFlashState = false;
    appData.isScanning = false;
    appData.isPCModeOn = false;
    appData.isLaserOn = false;  % 添加激光器状态标志
    

    % 振镜参数
    paramPanel = uipanel(fig, 'Title', '振镜参数', 'Position', [20, 400, 300, 300]);
    uilabel(paramPanel, 'Text', '振镜串口:', 'Position', [10, 250, 80, 22]);
    galvanoPortEdit = uieditfield(paramPanel, 'text', 'Value', 'COM3', 'Position', [100, 250, 100, 22]);
    
    uilabel(paramPanel, 'Text', '波特率:', 'Position', [10, 220, 80, 22]);
    baudRateEdit = uieditfield(paramPanel, 'numeric', 'Value', 115200, 'Position', [100, 220, 100, 22]);
    
    uilabel(paramPanel, 'Text', 'X轴区间(mm):', 'Position', [10, 190, 80, 22]);
    xRangeEdit = uieditfield(paramPanel, 'numeric', 'Value', 100, 'Position', [100, 190, 100, 22]);
    
    uilabel(paramPanel, 'Text', 'Y轴区间(mm):', 'Position', [10, 160, 80, 22]);
    yRangeEdit = uieditfield(paramPanel, 'numeric', 'Value', 0, 'Position', [100, 160, 100, 22]);
    
    uilabel(paramPanel, 'Text', '步长(mm):', 'Position', [10, 130, 80, 22]);
    stepEdit = uieditfield(paramPanel, 'numeric', 'Value', 1, 'Position', [100, 130, 100, 22]);
    
    uilabel(paramPanel, 'Text', '暂停时间(s):', 'Position', [10, 100, 80, 22]);
    pauseTimeEdit = uieditfield(paramPanel, 'numeric', 'Value', 5.3816, 'Position', [100, 100, 100, 22]);
    
    uilabel(paramPanel, 'Text', '起始X(mm):', 'Position', [10, 70, 80, 22]);
    xStartEdit = uieditfield(paramPanel, 'numeric', 'Value', 0, 'Position', [100, 70, 100, 22]);
    
    uilabel(paramPanel, 'Text', '起始Y(mm):', 'Position', [10, 40, 80, 22]);
    yStartEdit = uieditfield(paramPanel, 'numeric', 'Value', 1, 'Position', [100, 40, 100, 22]);
    
    uilabel(paramPanel, 'Text', '场镜焦距(mm):', 'Position', [10, 10, 80, 22]);
    focalLengthEdit = uieditfield(paramPanel, 'numeric', 'Value', 174, 'Position', [100, 10, 100, 22]);

    % 激光器参数
    laserPanel = uipanel(fig, 'Title', '激光器参数', 'Position', [340, 530, 300, 150]);
    
    uilabel(laserPanel, 'Text', '激光器串口:', 'Position', [10, 100, 80, 22]);
    laserPortEdit = uieditfield(laserPanel, 'text', 'Value', 'COM4', 'Position', [100, 100, 100, 22]);
    
    uilabel(laserPanel, 'Text', '电压(V):', 'Position', [10, 70, 80, 22]);
    voltageEdit = uieditfield(laserPanel, 'numeric', 'Value', 600, 'Position', [100, 70, 100, 22]);
    
    uilabel(laserPanel, 'Text', '频率(Hz):', 'Position', [10, 40, 80, 22]);
    frequencyEdit = uieditfield(laserPanel, 'numeric', 'Value', 20, 'Position', [100, 40, 100, 22]);
    
    
    % 振镜位置控制面板
    positionPanel = uipanel(fig, 'Title', '振镜位置控制', 'Position', [340, 400, 300, 130]);
    
    uilabel(positionPanel, 'Text', '目标X(mm):', 'Position', [10, 80, 80, 22]);
    targetXEdit = uieditfield(positionPanel, 'numeric', 'Value', 0, 'Position', [100, 80, 100, 22]);
    
    uilabel(positionPanel, 'Text', '目标Y(mm):', 'Position', [10, 50, 80, 22]);
    targetYEdit = uieditfield(positionPanel, 'numeric', 'Value', 0, 'Position', [100, 50, 100, 22]);
    
    uibutton(positionPanel, 'Text', '调整振镜位置', 'Position', [50, 10, 120, 30], ...
        'ButtonPushedFcn', @(btn, event) moveToPosition());
    
    % 控制按键面板
    controlPanel = uipanel(fig, 'Title', '控制操作', 'Position', [660, 400, 320, 280]);
    
    uibutton(controlPanel, 'Text', '1. 清理串口', 'Position', [20, 220, 120, 35], ...
        'ButtonPushedFcn', @(btn, event) cleanPort());
    
    enterFlashBtn = uibutton(controlPanel, 'Text', '2. 进入闪光状态', 'Position', [170, 220, 120, 35], ...
        'ButtonPushedFcn', @(btn, event) enterFlashState(), 'Enable', 'off');
    
    startScanBtn = uibutton(controlPanel, 'Text', '3. 开始扫描', 'Position', [20, 170, 120, 35], ...
        'ButtonPushedFcn', @(btn, event) startScan(), 'Enable', 'off');
    
    stopScanBtn = uibutton(controlPanel, 'Text', '4. 中断扫描', 'Position', [170, 170, 120, 35], ...
        'ButtonPushedFcn', @(btn, event) stopScan(), 'Enable', 'off');
    
    closePCModeBtn = uibutton(controlPanel, 'Text', '5. 关闭PC模式', 'Position', [20, 120, 120, 35], ...
        'ButtonPushedFcn', @(btn, event) closePCMode(), 'Enable', 'off');
    
    % 添加激光器开启/关闭按键
    laserToggleBtn = uibutton(controlPanel, 'Text', '开启激光器', 'Position', [170, 120, 120, 35], ...
        'ButtonPushedFcn', @(btn, event) toggleLaser(), 'Enable', 'off', ...
        'BackgroundColor', [0.2, 0.8, 0.2]);  % 绿色背景表示可以开启
    
    % 状态显示
    statusLabel = uilabel(controlPanel, 'Text', '状态: 等待清理串口', 'Position', [20, 80, 280, 22], ...
        'FontWeight', 'bold', 'FontColor', 'blue');
    
    % 添加扫描进度显示
    uilabel(controlPanel, 'Text', '扫描进度:', 'Position', [20, 50, 80, 22]);
    progressLabel = uilabel(controlPanel, 'Text', '未开始', 'Position', [100, 50, 200, 22]);
    
    % 信息显示面板
    infoPanel = uipanel(fig, 'Title', '系统信息', 'Position', [20, 20, 960, 360]);
    
    % 创建文本区域显示命令行输出
    infoTextArea = uitextarea(infoPanel, 'Position', [10, 10, 940, 320], ...
        'Editable', 'off', 'FontName', 'Consolas', 'FontSize', 10);
    
    % 添加清除信息按钮
    uibutton(infoPanel, 'Text', '清除信息', 'Position', [850, 300, 80, 25], ...
        'ButtonPushedFcn', @(btn, event) clearInfo());
    
    % 更新显示信息的函数
    function updateInfo(message)
        currentTime = datestr(now, 'HH:MM:SS');
        newMessage = sprintf('[%s] %s', currentTime, message);
        currentText = infoTextArea.Value;
        if ischar(currentText)
            currentText = {currentText};
        end
        infoTextArea.Value = [currentText; {newMessage}];
        % 滚动到底部
        scroll(infoTextArea, 'bottom');
        drawnow;
    end
    
    % 清除信息函数
    function clearInfo()
        infoTextArea.Value = '';
    end
    
    % 更新状态和按钮状态
    function updateButtonStates()
        if ~appData.isPortCleaned
            enterFlashBtn.Enable = 'off';
            startScanBtn.Enable = 'off';
            stopScanBtn.Enable = 'off';
            closePCModeBtn.Enable = 'off';
            laserToggleBtn.Enable = 'off';
            statusLabel.Text = '状态: 等待清理串口';
            statusLabel.FontColor = 'red';
        elseif ~appData.isFlashState && ~appData.isPCModeOn
            enterFlashBtn.Enable = 'on';
            startScanBtn.Enable = 'off';
            stopScanBtn.Enable = 'off';
            closePCModeBtn.Enable = 'off';
            laserToggleBtn.Enable = 'off';
            statusLabel.Text = '状态: 可以进入闪光状态';
            statusLabel.FontColor = 'blue';
        elseif appData.isFlashState && ~appData.isScanning
            enterFlashBtn.Enable = 'off';
            startScanBtn.Enable = 'on';
            stopScanBtn.Enable = 'off';
            closePCModeBtn.Enable = 'on';
            laserToggleBtn.Enable = 'on';  % 在闪光状态下可以控制激光器
            statusLabel.Text = '状态: 闪光状态 - 可以开始扫描';
            statusLabel.FontColor = 'green';
        elseif appData.isScanning
            enterFlashBtn.Enable = 'off';
            startScanBtn.Enable = 'off';
            stopScanBtn.Enable = 'on';
            closePCModeBtn.Enable = 'off';
            laserToggleBtn.Enable = 'off';  % 扫描时禁用激光器控制
            statusLabel.Text = '状态: 扫描中...';
            statusLabel.FontColor = 'orange';
        end
        
        % 更新激光器按钮状态
        updateLaserButtonState();
    end
    
    % 清理串口功能
    function cleanPort()
        try
            updateInfo('开始清理串口...');
            addpath('Functions');
            addpath('Functions/debug');
            addpath('Functions/Laser');
            addpath('Functions/Galvano');
            
            closeup();
            evalin('base', 'clear s');
            
            appData.isPortCleaned = true;
            appData.isFlashState = false;
            appData.isScanning = false;
            appData.isPCModeOn = false;
            appData.isLaserOn = false;  % 重置激光器状态
            
            updateInfo('串口清理完成');
            updateButtonStates();
        catch ME
            updateInfo(['串口清理失败: ' ME.message]);
        end
    end
    
    % 进入闪光状态功能
    function enterFlashState()
        try
            updateInfo('开始进入闪光状态...');
            
            % 获取激光器参数
            laserPort = laserPortEdit.Value;
            voltage = voltageEdit.Value;
            frequency = frequencyEdit.Value;
            
            updateInfo('执行 online_download...');
            download('online_download', laserPort, voltage, frequency);
            
            updateInfo('执行 stand_by...');
            download('stand_by', laserPort, voltage, frequency);
            
            updateInfo('执行 Flash...');
            download('Flash', laserPort, voltage, frequency);
            
            appData.isFlashState = true;
            appData.isPCModeOn = true;
            appData.isLaserOn = false;  % 重置激光器状态
            
            updateInfo('进入闪光状态完成');
            updateButtonStates();
        catch ME
            updateInfo(['进入闪光状态失败: ' ME.message]);
        end
    end
    
    % 开始扫描功能
    function startScan()
        try
            updateInfo('开始扫描...');
            progressLabel.Text = '准备中...';
            
            % 获取参数
            laserPort = laserPortEdit.Value;
            voltage = voltageEdit.Value;
            frequency = frequencyEdit.Value;
            galvanoPort = galvanoPortEdit.Value;
            baudRate = baudRateEdit.Value;
            xRange = xRangeEdit.Value;
            yRange = yRangeEdit.Value;
            step = stepEdit.Value;
            focalLength = focalLengthEdit.Value;
            pauseTime = pauseTimeEdit.Value;
            xStart = xStartEdit.Value;
            yStart = yStartEdit.Value;
            
            appData.isScanning = true;
            updateButtonStates();
            
            % 如果激光器还没开启，则开启激光器
            if ~appData.isLaserOn
                updateInfo('发送 QSwitch 命令...');
                returnedCommand = download('QSwitch', laserPort, voltage, frequency);
                if strcmp(returnedCommand, 'QSwitch')
                    appData.isLaserOn = true;
                    updateInfo('激光器已自动开启');
                end
            else
                updateInfo('激光器已开启，开始扫描...');
            end
            
            progressLabel.Text = '扫描中...';
            updateInfo('开始网格扫描...');
            
            % 在后台运行扫描
            updateInfo('注意：扫描开始后，可以点击"中断扫描"按钮停止');
            grid_scan(galvanoPort, baudRate, xRange, yRange, step, focalLength, pauseTime, ...
                'StartX', xStart, 'StartY', yStart);
            
            % 扫描完成
            appData.isScanning = false;
            progressLabel.Text = '扫描完成';
            updateInfo('扫描完成');
            updateButtonStates();
            
        catch ME
            appData.isScanning = false;
            progressLabel.Text = '扫描出错';
            updateInfo(['扫描出错: ' ME.message]);
            updateButtonStates();
        end
    end
    
    % 中断扫描功能
    function stopScan()
        try
            updateInfo('发送中断扫描信号...');
            stop_grid_scan();
            
            % 等待一段时间让扫描停止
            pause(1);
            
            appData.isScanning = false;
            appData.isLaserOn = false;  % 扫描中断后激光器会自动关闭
            progressLabel.Text = '扫描已中断';
            updateInfo('扫描已中断，激光器已自动关闭');
            updateButtonStates();
        catch ME
            updateInfo(['中断扫描失败: ' ME.message]);
        end
    end
    
    % 关闭PC模式功能
    function closePCMode()
        try
            updateInfo('开始关闭PC模式...');
            
            % 获取激光器参数
            laserPort = laserPortEdit.Value;
            voltage = voltageEdit.Value;
            frequency = frequencyEdit.Value;
            
            updateInfo('执行 Flash_close...');
            download('Flash_close', laserPort, voltage, frequency);
            
            updateInfo('执行 stand_by_close...');
            download('stand_by_close', laserPort, voltage, frequency);
            
            updateInfo('执行 online_download_close...');
            download('online_download_close', laserPort, voltage, frequency);
            
            appData.isFlashState = false;
            appData.isPCModeOn = false;
            appData.isLaserOn = false;  % 重置激光器状态
            progressLabel.Text = '未开始';
            
            updateInfo('PC模式关闭完成');
            updateButtonStates();
        catch ME
            updateInfo(['关闭PC模式失败: ' ME.message]);
        end
    end
    
    % 调整振镜位置功能
    function moveToPosition()
        try
            galvanoPort = galvanoPortEdit.Value;
            baudRate = baudRateEdit.Value;
            targetX = targetXEdit.Value;
            targetY = targetYEdit.Value;
            focalLength = focalLengthEdit.Value;
            
            updateInfo(sprintf('调整振镜位置到 X=%.2f, Y=%.2f...', targetX, targetY));
            move_to_position(galvanoPort, baudRate, targetX, targetY, focalLength);
            updateInfo('振镜位置调整完成');
        catch ME
            updateInfo(['调整振镜位置失败: ' ME.message]);
        end
    end
    
    % 更新激光器按钮状态
    function updateLaserButtonState()
        if appData.isLaserOn
            laserToggleBtn.Text = '关闭激光器';
            laserToggleBtn.BackgroundColor = [0.8, 0.2, 0.2];  % 红色背景表示可以关闭
        else
            laserToggleBtn.Text = '开启激光器';
            laserToggleBtn.BackgroundColor = [0.2, 0.8, 0.2];  % 绿色背景表示可以开启
        end
    end
    
    % 激光器开启/关闭功能
    function toggleLaser()
        try
            % 获取激光器参数
            laserPort = laserPortEdit.Value;
            voltage = voltageEdit.Value;
            frequency = frequencyEdit.Value;
            
            if ~appData.isLaserOn
                % 开启激光器
                updateInfo('正在开启激光器...');
                returnedCommand = download('QSwitch', laserPort, voltage, frequency);
                
                % 检查返回命令确认激光器已开启
                if strcmp(returnedCommand, 'QSwitch')
                    appData.isLaserOn = true;
                    updateInfo('激光器已开启');
                else
                    updateInfo(['激光器开启失败，返回命令: ' returnedCommand]);
                end
            else
                % 关闭激光器
                updateInfo('正在关闭激光器...');
                returnedCommand = download('QSwitch_close', laserPort, voltage, frequency);
                
                % 检查返回命令确认激光器已关闭
                if strcmp(returnedCommand, 'QSwitch_close')
                    appData.isLaserOn = false;
                    updateInfo('激光器已关闭');
                else
                    updateInfo(['激光器关闭失败，返回命令: ' returnedCommand]);
                end
            end
            
            updateLaserButtonState();
            
        catch ME
            updateInfo(['激光器控制失败: ' ME.message]);
        end
    end
    
    % 初始化界面状态
    updateButtonStates();
    updateInfo('扫描控制系统启动完成');
    updateInfo('请按顺序操作：1.清理串口 -> 2.进入闪光状态 -> 3.开始扫描');
    updateInfo('在闪光状态下，可以使用右下角的按钮独立控制激光器开启/关闭');
    updateInfo('调整振镜位置功能随时可用');
    
end
