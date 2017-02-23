%% frames2data.m, data2frames.m

% Define constants
dataTX = 1:1:120;
scaling = 50;

% Convert data to frames, then TX->RX
frames = data2frames(dataTX,scaling);
dataRX = frames2data(frames)*scaling;

% Assert that dataTX/RX are approximately equal
assert(all(abs(dataTX-dataRX) < 1e-3));
disp('frame2data.m and data2frames.m passed tests!');

