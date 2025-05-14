
#  *函数使用手册*
-  `function closeup(portName)`
   -  在运行发送命令程序前运行此函数用于关闭串口，防止串口被占用，可指定串口，若不指定默认关闭所有找到的串口，会显示当前可用的串口。
-  `function laser_control()`
   -  激光器出光控制函数，自行输入指令名称，与激光器触控板控制相似。
   -  发送成功串口命令后激光器会返回相同的命令，程序会转换成对应名称，说明激光器成功接收到了指令。
-  `move_to_position(serialPort, baudRate, focusX, focusY, focalLength)`
   -  让振镜移动到某个位置（前提是激光点位于工作平面上）。工作范围是X方向+55mm~-55mm，Y方向+55mm~-55mm的方形区域。振镜不会返回状态信息，只能根据模拟协议判断振镜的偏转角度，但通过示波器验证过模拟电压输出。
-  `grid_scan(serialPort, baudRate, xRange, yRange, gridSpacing, focalLength, pauseTime)`
   -  网格扫描，输入参数有X方向和Y方向区间，网格间距，场镜焦距以及每个点停留时间。
   -  应当在接收到激光器开启命令时启动此函数。