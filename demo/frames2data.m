function [data] = frames2data(frames)
% Converts a 5x256 bit array to PSD data.

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
numFrames = 5;
numDataFrames = 4;
samplesPerFrame = 30;
numSamples = numDataFrames * samplesPerFrame;

preambleRange = 1:16;
scalingRange = 17:32;
zeroPadRange = 161:224;
dataRange = 17:256;

%% Validate inputs

% Make sure frame is valid size
assert(isequal(size(frames),[5 256]));

% Validate all preambles
preambleReference = repmat([1 0], 1, 8);
for i = 1:numFrames
    assert(isequal(frames(i,preambleRange), preambleReference));
end

% Get header, data frames
header = frames(1,:);
dataFrames = frames(2:5,:);

% Validate header CRC
headerCRCReceived = header(end-31:end);
headerCRCComputed = crc(header(1:end-32));
assert(isequal(headerCRCReceived, headerCRCComputed));

% Validate data CRC
for i = 1:numDataFrames
    crcRange = 32*i+1:32*i+32;
    dataCRCReceived = header(crcRange);
    dataCRCComputed = crc(dataFrames(i,:));
    assert(isequal(dataCRCReceived, dataCRCComputed));
end

% Validate header zero-padding
assert(isequal(header(zeroPadRange), zeros(1,64)));

%% Extract data
data = zeros(1,numSamples); % Preallocate
scalingFactor = bi2de(header(scalingRange),'left-msb'); % Scaling factor

for i = 1:numDataFrames
    sampleBits = dataFrames(i,dataRange); % Get non-preamble bits
    for j = 1:samplesPerFrame
        sampleRange = 8*j-7:8*j; % read from here
        dataLocation = (i-1)*30 + j; % write to there
        sampleDatapoint = bi2de(sampleBits(sampleRange), 'left-msb');
        sampleScaled = sampleDatapoint/scalingFactor;
        data(dataLocation) = sampleScaled;
    end
end
end

