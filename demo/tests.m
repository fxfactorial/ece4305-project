%% frames2data.m, data2frames.m

% Define constants
dataTX = 1:120;
scaling = 50;

% Convert data to frames, then TX->RX
frames = data2frames(dataTX,scaling);
dataRX = frames2data(frames)*scaling;

% Assert that dataTX/RX are approximately equal
assert(all(abs(dataTX-dataRX) < 1e-3));
disp('frame2data.m and data2frames.m passed tests!');

%% visualize.m

% Define constants
dataArray = zeros(20,120);

% Plot
for i = 1:20
    pause(0.5);
    
    % Random data with three peaks
    data        = zeros(1,120)  + 5*rand(1,120);
    data(20:35) = 30*ones(1,16) + 5*rand(1,16);
    data(65:80) = 20*ones(1,16) + 5*rand(1,16);
    data(80:95) = 10*ones(1,16) + 5*rand(1,16);
    
    dataArray = visualize(data,dataArray);
end
disp('visualize.m passed tests!');

%% frames2waveforms.m

% Define constants
dataTX = 1:120;
scaling = 50;
frames = data2frames(dataTX,scaling);
ch_size = 2^20;
Fs = 30.72e6; % grabbed value from some other script

% Convert to waveforms
waveforms = frames2waveforms(frames,ch_size,Fs);
plot(waveforms(1,(1:ch_size)));
disp('frames2waveforms.m passed tests!');