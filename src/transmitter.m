%take in 5x256bits convert to transmits of the pluto 
function [out] = transmitter(dataBin)
%% Set up SDR
    data_len = length(dataBin);
    assert(data_len > 0, 'Transmit() was passed empty data');
    
    % initalize SDR
    disp('Configure SDR to transmit...');
    sdr = initSdr(2^20,2^20, 30.72e6, 816e6, 916e6, 2e6, 5e6, 15, 'manual', 'transceive');
    
    numFrames = size(dataBin,1);
%% Create Waveforms from the data
    disp('Create waveforms from data');
    dataWave = [];
    disp('Applying Tx Filter...');
    disp('Shaping Tx data with Hilbert...');
    for i = 1 : numFrames
        frameWave = bin2waveform(dataBin(i,:), sdr.in_ch_size, sdr.rx_sample_rate);
        dataWave = [dataWave; frameWave];
    end
out = [];
%pause
%% Transmit Data
    dataRec = [];
    
    for frame = 1:numFrames % should output 1-5 
        % Transceive with SDR
        transmitFrame = dataWave(frame,:);
        o = sdr.transceive(transmitFrame);
        
        % Info
        out = [out o];
        s = strcat({'Frame '}, int2str(frame), {' of '}, int2str(numFrames));
        disp(s)
    end
    clear sdr;

    finished = 1;
end
