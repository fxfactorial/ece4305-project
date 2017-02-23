function [frames] = data2frames(data, scalingFactor)
% Converts data into a 5x256 bit array, representing frames.

% Frame structure:
% ----HEADER----
% FIELD             BITS
% Preamble          16
% Scaling Factor    16 
% Data CRCs         32*4 = 128
% Zero Padding      64
% Header CRC        32
% -----DATA-----
% FIELD             BITS
% Preamble          16
% Data              8*30 = 240

%% Define constants
preamble = [1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
numDataFrames = 4;
samplesPerFrame = 30;
lenZeroPad = 64;

%% Validate input
assert(length(data) == 120);
assert(scalingFactor < 2^16);

%% Fill data frames
dataFrames = []; % Empty frames
for i = 1:numDataFrames
    frame = preamble; % Start with preamble
    for j = 1:samplesPerFrame
        dataLocation = (i-1)*samplesPerFrame + j; % Find current datapoint
        dataBinary = de2bi(data(dataLocation), 8, 'left-msb');
        frame = [frame dataBinary]; % Append datapoint to frame, in binary
    end
    dataFrames = [dataFrames; frame]; % Append frame as next row of array
end

%% Fill header frame
% Preamble & scaling factor
header = [preamble de2bi(scalingFactor, 16, 'left-msb')];
for i = 1:numDataFrames % Each data frame's CRC
    header = [header crc(dataFrames(i,:))];
end
header = [header zeros(1,lenZeroPad)]; % Zero padding
header = [header crc(header)]; % Header CRC

%% Combine all frames
frames = [header; dataFrames];

end