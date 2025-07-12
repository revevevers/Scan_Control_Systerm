function stop_grid_scan_file()
    % 通过文件标志停止网格扫描函数
    % 这是一个备用方案，通过创建文件来发送停止信号
    
    % 创建停止标志文件
    stopFile = 'grid_scan_stop.flag';
    
    try
        % 创建文件
        fid = fopen(stopFile, 'w');
        if fid > 0
            fprintf(fid, 'STOP');
            fclose(fid);
            fprintf('已创建停止扫描标志文件: %s\n', stopFile);
        else
            error('无法创建停止标志文件');
        end
    catch ME
        fprintf('创建停止文件时发生错误: %s\n', ME.message);
    end
    
    % 同时设置全局变量
    global SCAN_STOP_FLAG;
    SCAN_STOP_FLAG = true;
    
    fprintf('已发送停止扫描信号（文件方式）\n');
    fprintf('注意：如果扫描仍在运行，请按 Ctrl+C 强制中断\n');
end
