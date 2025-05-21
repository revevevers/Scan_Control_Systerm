
closeup();
%% 
clear s;
move_to_position('COM3', 115200, 50, 0, 163);
% move_to_position(serialPort, baudRate, focusX, focusY, focalLength)
%% 
main(dataPacketType);
