%take in 5x256bits convert to transmits of the pluto 
function [finished] = transmitter(dataBin)
%% Set up SDR
    data_len = length(dataBin);
    assert(data_len > 0, 'Transmit() was passed empty data');
    
    % initalize SDR
    sdr = initSdr(2^20, 30.72e6, 916e6, 2e6, 5e6, 15, 'fast-attack', 'transmit');
    
    numFrames = size(dataBin,1);
    
%% Create Waveforms from the data
    dataWave = [];
    for i = 1 : numFrames
        frameWave = bin2waveform(dataBin(i,:), sdr.in_ch_size, sdr.rx_sample_rate);
        dataWave = [dataWave; frameWave];
    end

%% Transmit Data
    dataRec = [];
    pause
    for frame = 1:numFrames % should output 1-5 
        % Transceive with SDR
        transmitFrame = dataWave(frame,:);
        sdr.transmit(transmitFrame);
        
        % Info
        s = strcat({'Frame '}, int2str(frame), {' of '}, int2str(numFrames));
        disp(s)
    end

    clear sdr;

    finished = 1;
end
