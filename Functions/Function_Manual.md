
#  *函数使用方法说明*
-  `function closeup(portName)`
   -  在运行发送命令程序前运行此函数用于关闭串口，防止串口被占用，可指定串口，若不指定默认关闭所有找到的串口。
-  `function laser_control()`
   -  激光器出光控制函数，可选外部时钟控制和串口命令控制，两种方法都需要发送串口命令，还没有写好。
   -  仍需要验证并编写代码接收激光器返回的数据，这个数据很有用，可以用来控制振镜。
-  `function move_to_angle(serialPort, baudRate, angleX, angleY)`
   -  让振镜移动到某个角度。
-  `function send_angel_data(s, angleX, angleY)`
   -  角度串口数据发送函数，原理：±10°映射到65535位上,将角度数据映射并以十六进制格式发送到串口。