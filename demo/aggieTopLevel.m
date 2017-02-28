%% Clean the workspace
clearvars; close all; clc;

%% Define constants
% Stores data; necessary for 'visualize.m'
dataArray = zeros(20, 240);
dataArray(1:20,1:240) = nan;
data = [];

timeMod = 5; % The zeroth minute occurs at datetime % timeMod == 0

% Aggregator loops every 5 minutes, as below:
%
% MIN.  EVENT
% ----------
% 0-2   RX1 -> FRAMES1
% 2-4   RX2 -> FRAMES2
% 4-5   FRAMES 
rxTimeBGN1  = 60*0;
rxTimeBGN2  = 60*2;
loopTime    = 60*5;

disp('Waiting for start point')
while true
    startPoint = datetime('now');
    isMinuteValid = ~mod(minute(startPoint), timeMod);
    isSecondValid = ~round(second(startPoint));
    if isMinuteValid && isSecondValid
        break
    end
end
disp('About to begin main while loop')

%% Timestamp and enter while loop
while true 
    %% RX1
    disp('RX1 phase')
    disp(datetime('now'))
    frames1 = receiver();
    %% Wait
    disp('Wait phase 1')
    disp(datetime('now'))
    while mod(round(seconds(datetime('now')-startPoint)), loopTime) ~= rxTimeBGN2;
    end
    %% RX2
    disp('RX2 phase')
    disp(datetime('now'))
    frames2 = receiver();
    %% Plot
    disp('Plot phase')
    disp(datetime('now'))
    data1 = unParseFrame(frames1);
    data2 = unParseFrame(frames2);
    
    if isequal(data1, zeros(1,120)) 
        data1(1:120) = nan; 
    end
    if isequal(data2, zeros(1,120)) 
        data2(1:120) = nan; 
    end
    
    dataArray = visualize([data1 data2], dataArray);
    %% Wait
    disp('Wait phase 2')
    disp(datetime('now'))
    while mod(round(seconds(datetime('now')-startPoint)), loopTime) ~= rxTimeBGN1;
    end
end