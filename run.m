
closeup();
%% 
clear s;
move_to_position('COM3', 115200, 50, 0, 163);
% move_to_position(serialPort, baudRate, focusX, focusY, focalLength)
%% 
main(dataPacketType);
% 使用前记得修改main.m函数中对应的激光器和振镜的串口号
% 不确定电压和频率参数有没有载入，可以先在控制板模式调好，然后不发送这两条串口命令即默认为控制板设置的参数
% 运行顺序为：`'online_download'`  `'V_download'`  `'F_download'` `'stand_by'` `'Flash'` `'QSwitch'#此时出光，同时振镜开始偏转` `'QSwitch_close'`  `'Flash_close'` `'stand_by_close'` `'online_download_close'`