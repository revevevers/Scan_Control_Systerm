%% 参数设置

% 振镜参数设置
GalvanoSerialPort = 'COM3'; % 振镜串口
baudRate = 115200; % 波特率
XRange = 100; % X轴区间(mm)，若为100，则表示0：100共101个点
YRange = 0; % Y轴区间(mm)
Step = 1; % 步长(mm)，若为1，则表示每个点之间间隔1mm
PauseTime = 5.3816; % 每个点之间的暂停时间(秒)
XStart = 0; % X轴起始位置(mm)
YStart = 1; % Y轴起始位置(mm)
focalLength = 174; % 场镜焦距(mm)，实际焦距为163

% 激光器参数设置
LaserSerialPort = 'COM4'; % 激光器串口
V =  600; % 激光器电压(V)
F = 20; % 激光器频率(Hz)

%% 清理串口
closeup();
clear s;

%% 设置激光器进入闪光状态
download('online_download'); % 激光器预燃%
download('stand_by'); % 激光器待机
download('Flash'); % 激光器启动

%% 开启激光器
download('QSwitch');
%% 关闭激光器
download('QSwitch_close'); 

%% 开始扫描
download('QSwitch', LaserSerialPort, V, F);
grid_scan(GalvanoSerialPort, baudRate, XRange, YRange, Step, focalLength, PauseTime, 'StartX', XStart, 'StartY', YStart);


%% 中断扫描
stop_grid_scan(); % 停止网格扫描

%% 关闭PC控制模式，可以手动调整电压
download('Flash_close'); % 激光器闪光关闭
download('stand_by_close'); % 激光器待机关闭
download('online_download_close'); % 激光器在线下载关闭

%% 调整振镜到某个位置

focusX = 0; % 聚焦点X坐标(mm)
focusY = 0; % 聚焦点Y坐标(mm)

move_to_position(GalvanoSerialPort, baudRate, focusX, focusY, focalLength);


