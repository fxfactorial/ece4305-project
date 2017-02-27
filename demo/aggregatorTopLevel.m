%% Clean the workspace
clearvars; close all; clc;

%% Define constants
% Stores data; necessary for 'visualize.m'
dataArray = zeros(20, 240);
data = [];

timeMod = 2; % The zeroth minute occurs at datetime % timeMod == 0

% Aggregator loops every 5 minutes, as below:
%
% MIN.  EVENT
% ----------
% 0     IDLE
% 1-3   RX1 -> FRAMES1
% 3-6   RX2 -> FRAMES2 -> PLOT
% 6-8   RX1 -> FRAMES1
% 8-10  RX2 -> FRAMES2 -> PLOT
rxTimeBGN1  = 60*1;
rxTimeBGN2  = 60*3;
loopTime    = 60*5;

%% Wait for the zeroth minute
while true
    currTime = datetime('now');
    isMinuteValid = ~mod(minute(currTime), timeMod);
    isSecondValid = ~round(second(currTime));
    if isMinuteValid && isSecondValid
        break
    end
end

%% Timestamp and enter while loop
startPoint = datetime('now');
while true
    %% Wait, then RX1
    while mod(round(seconds(datetime('now')-startPoint)), loopTime) ...
            ~= rxTimeBGN1;
    end
    frames1 = reciever();
    %% Wait, then RX2
    while mod(round(seconds(datetime('now')-startPoint)), loopTime) ...
            ~= rxTimeBGN2;
    end
    frames2 = reciever();
    %% Plot, then wait
    data1 = unParseFrames(frames1);
    data2 = unParseFrames(frames2);
    dataArray = visualize([data1 data2], dataArray);
    while mod(round(seconds(datetime('now')-startPoint)), loopTime) ~= 0;
    end
end