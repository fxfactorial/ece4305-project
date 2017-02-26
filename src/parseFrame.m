function [frames] = parseFrame(data, scalingFactor)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    preamble = [1 1 1 1 1 0 0 1 1 0 1 0 1];
    numFrames = 4;
    samplesPerFrame = 30;
    
    dataFrames = [];
    for i = 1 : numFrames
        frame = [preamble de2bi(i+1,3,'left-msb')];
        for j = 1 : samplesPerFrame
            dataPos = (i-1)*30 + j;
            dataDec = data(dataPos);
            dataBin = de2bi(dataDec, 8, 'left-msb');
            frame = [frame dataBin];
        end
        dataFrames = [dataFrames; frame];
    end
    
    header = [preamble de2bi(1,3,'left-msb') de2bi(scalingFactor,16, 'left-msb')];
    
    for i = 1 : numFrames
        header = [header crc32(dataFrames(i,:))];
    end
    
    header = [header zeros(1,64)];
    header = [header crc32(header)];
    
    frames = [header; dataFrames];
    
end