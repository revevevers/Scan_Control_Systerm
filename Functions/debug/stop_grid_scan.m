function stop_grid_scan()
    % 停止网格扫描函数
    % 调用此函数可以停止正在运行的 grid_scan 函数
    
    % 声明全局变量
    global SCAN_STOP_FLAG;
    
    % 设置停止标志
    SCAN_STOP_FLAG = true;
    
    % 同时在基础工作区设置变量（确保能被读取到）
    try
        assignin('base', 'SCAN_STOP_FLAG', true);
    catch
        % 如果assignin失败，忽略错误
    end
    
    fprintf('已发送停止扫描信号\n');
    fprintf('注意：如果扫描仍在运行，请按 Ctrl+C 强制中断\n');
end
