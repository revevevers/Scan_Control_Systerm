function stop_grid_scan()
    % 停止网格扫描函数
    % 调用此函数可以停止正在运行的 grid_scan 函数
    
    % 声明全局变量
    global SCAN_STOP_FLAG;
    
    % 设置停止标志
    SCAN_STOP_FLAG = true;
    
    fprintf('已发送停止扫描信号\n');
end
