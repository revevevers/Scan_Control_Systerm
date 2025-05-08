
closeup();

straight_pattern(serialPort, baudRate, axis, maxAngle, pauseTime);

%% 

closeup();

snake_pattern('COM5', 115200, 0.1, 0.1, 0.5, 0.5);
% snake_pattern(serialPort, baudRate, xStepSize, yStepSize, maxAngle, pauseTime)

%% 

closeup();

move_to_angle('COM5', 115200, 1 , -1);
% move_to_angle(serialPort, baudRate, angleX, angleY)

%%
closeup();