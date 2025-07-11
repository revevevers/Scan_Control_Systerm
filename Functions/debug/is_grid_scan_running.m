function status = is_grid_scan_running()
    % 查询网格扫描是否正在运行
    % 返回值：
    %   true - 扫描正在运行
    %   false - 扫描已停止或未开始
    
    % 声明全局变量
    global SCAN_STOP_FLAG;
    
    % 如果变量不存在，说明扫描未开始
    if isempty(SCAN_STOP_FLAG)
        status = false;
    else
        % 如果停止标志为false，说明扫描正在运行
        status = ~SCAN_STOP_FLAG;
    end
end
