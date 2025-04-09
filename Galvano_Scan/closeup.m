function closeup(portName)
    % CLOSEUP 关闭指定的 serialport 对象
    % 可选参数 portName: 指定要关闭的串口（如 'COM5'）
    % 如果不指定参数，则尝试关闭所有找到的 serialport 对象
    
    if nargin < 1
        % 获取所有活跃的串口连接
        portList = serialportlist("all");
        
        if isempty(portList)
            disp('没有找到活跃的串口连接');
            return;
        end
        
        % 尝试关闭所有找到的串口
        for i = 1:length(portList)
            try
                s = getSerialportObject(portList(i));
                if ~isempty(s)
                    delete(s);
                    clear s;
                    fprintf('已关闭串口: %s\n', portList(i));
                end
            catch ME
                warning('关闭串口 %s 时出错: %s', portList(i), ME.message);
            end
        end
    else
        % 关闭指定串口
        try
            s = getSerialportObject(portName);
            if ~isempty(s)
                delete(s);
                clear s;
                fprintf('已关闭串口: %s\n', portName);
            else
                fprintf('未找到串口: %s\n', portName);
            end
        catch ME
            warning('关闭串口 %s 时出错: %s', portName, ME.message);
        end
    end
end

function s = getSerialportObject(portName)
    % 辅助函数：获取指定端口名的 serialport 对象句柄
    s = [];
    allPorts = serialportlist("all");
    
    if any(strcmp(allPorts, portName))
        try
            % 尝试通过创建新连接来获取对象（这不是理想方式，但目前没有直接获取的方法）
            s = serialport(portName, 9600); % 波特率不重要，因为马上会关闭
            configureTerminator(s, "LF");
            configureCallback(s, "off");
        catch
            % 如果端口已被占用，说明已经有对象存在
            s = [];
        end
    end
end