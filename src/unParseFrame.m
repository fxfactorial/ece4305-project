function [data] = unParseFrame(stream)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    %header Structure
    %Preamble          - 16 bits
    %Quant Factor      - 16 bits
    %Data CRCs         - 32*4 bits
    %Zero Padding      - 64 bits
    %Header CRC        - 32  bits
    
    preambleRef = repmat([1 0], 1, 8);
    
    headerFrame = stream(1,:);
    dataFrames = stream(2:5,:);
    
    assert(isequal(headerFrame(1:16), preambleRef));
    assert(isequal(headerFrame(161:224), zeros(1,64)));
    
    for i = 1 : 4
        assert(isequal(dataFrames(i,1:16), preambleRef));
    end
    
    headerContent = headerFrame(1:224);
    headerCRCcheck = crc32(headerContent);
    assert(isequal(headerCRCcheck, headerFrame(end-31:end)));
    
    for     i = 1 : 4
        crcLoc = 32*(i-1) + 33;
        dataCRCcheck = crc32(dataFrames(i,:));
        dataCRC = headerFrame(crcLoc:crcLoc+31);
        assert(isequal(dataCRCcheck, dataCRC));
    end
    
    scalingFactor = bi2de(headerFrame(17:32),'left-msb');
    
    data = zeros(1,120);
    
    for i = 1 : 4
        dataContent = dataFrames(i,17:end);
        for j = 1 : 30
            lowEnd = (j - 1)*8 + 1;
            highEnd = j*8;
            sampleBin = dataContent(lowEnd:highEnd);
            sampleDec = bi2de(sampleBin, 'left-msb');
            sampleScaled = sampleDec/scalingFactor;
            dataLoc = (i-1)*30 + j;
            data(dataLoc) = sampleScaled;
        end
    end
    
%     details = [];
%     for i = 2 : length(headerStarts) - 1
%         nextDetail = rawDetails(headerStarts(i):(headerStarts(i+1)-1));
%         details = [details bi2de(fliplr(nextDetail))];
%     end
%     
%     samplesPerFrame = (dataFrameLength - 16)/ 8;
%     
%     data = [];
%     rawData = stream(headerFrameLength+1:end);
%     for i = 1 : details(1)
%        nextFrame = rawData((1+ (i - 1)*dataFrameLength) : i*dataFrameLength);
%        for j = 1 : samplesPerFrame
%           nextSample = nextFrame((17+(j-1)*8) : (16+j*8));
%           data = [data bi2de(fliplr(nextSample))];  
%        end
%     end



end

