function returnedVariableName = download(dataPacketType, laser_serialPortName, V, F)

    %% 激光器预燃
    % 主函数入口

    % 调用 laser_control 并获取返回的变量名称
    returnedVariableName = laser_control(laser_serialPortName, V, F, dataPacketType);

    fprintf('返回的变量名称为: %s。\n', returnedVariableName);

end

