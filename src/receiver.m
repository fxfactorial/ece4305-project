%take in 5x256bits convert to transmits of the pluto
function [rx_dataBin] = receiver()
%% Set up SDR
% initalize SDR
sdr = initSdr(2^21, 2^19, 30.72e6, 916e6, 2.4e9, 2e6, 5e6, 60, 'fast-attack', 'transceive');

close all;

frame = repmat([0 0], 1,128);

framewave = bin2waveform(frame, sdr.in_ch_size, sdr.rx_sample_rate);

%% Transceive Data
dataRec = [];
pause;
numFrames = 20;
for frame = 1:numFrames % should output 1-5
    % Transceive with SDR
    
    o = sdr.transceive(framewave);
    
    %store transceived data
    dataRec = [dataRec; o];
    
    % Info
    s = strcat({'Frame '}, int2str(frame), {' of '}, int2str(numFrames));
    disp(s)
end

% figure(1)
% plot(abs(fft(dataRec)));

Fmod = 30e3;
%actual FSK frequencies
freqLow  = 10000;
freqHigh = 30000;
freqBuff = 100;
freqDelt = freqHigh - freqLow;


%% Filter Signal
bFilt = designfilt('bandpassfir', ...
    'FilterOrder',120, ...
    'CutoffFrequency1',abs(Fmod - freqBuff), ...
    'CutoffFrequency2',abs(Fmod + freqHigh + freqLow + freqBuff), ...
    'SampleRate',sdr.rx_sample_rate);

dataFilter = filter(bFilt, real(dataRec));

% figure(2)
% plot(abs(fft(dataFilter)));


rxsig = fmdemod(real(dataFilter), Fmod, sdr.rx_sample_rate, freqDelt);

%Lowpass filter
bFilt = designfilt('lowpassfir', ...
    'FilterOrder',150, ...
    'CutoffFrequency',100, ...
    'SampleRate',sdr.rx_sample_rate);

rxsig_filt = filtfilt(bFilt, rxsig);

for k = 1:length(rxsig_filt)
    if rxsig_filt(k) <  1.75 &&  rxsig_filt(k) > 1.25
        rxsig_filt(k) = 0;
    elseif rxsig_filt(k) < .75 &&  rxsig_filt(k) > .25
        rxsig_filt(k) = 1;
    elseif k == 1
        rxsig_filt(k) = 0;
    else
        rxsig_filt(k) = rxsig_filt(k-1);
    end
end

preamble = [1 1 1 1 1 0 0 1 1 0 1 0 1];

rx_clean_data = dataCleaner(rxsig_filt);

symbolWidth = 40;

rx_dataBin = clean2bin(rx_clean_data, symbolWidth);

preambleLoc = strfind(rx_dataBin, preamble);

framesReceived = [];
frameReceivedNumber = 1;

for i = 1:(length(preambleLoc)-1)
    
    if (preambleLoc(i+1) - preambleLoc(i)) >= 256
        
        lowLoc  = preambleLoc(i);
        highLoc = preambleLoc(i) + 255;
        frame = rx_dataBin(lowLoc:highLoc);
        
        frameNum = bi2de(frame(14:16), 'left-msb')
        
        if (frameNum == frameReceivedNumber)
            framesReceived = [framesReceived; frame];
            frameReceivedNumber = frameReceivedNumber + 1;
        end
    end
end

% figure(3)
% plot(rxsig_filt);
% title('Filtered Data');
% 
% figure(4)
% plot((1:length(rxsig)), rxsig, 'LineWidth', 1);
% hold on;
% plot((1:length(rxsig_filt)), rxsig_filt, 'LineWidth', 3);
% title('Unfiltered Data');
% clear sdr;

rx_dataBin = framesReceived;
end
