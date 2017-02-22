%%Set Up SDR Coefs
addpath(genpath('../drivers'));
clear all;
% Public, non-tunabe properties.
sdr = PlutoSDR;
%mode Transceiver mode of SDR
ch_size = 2.^20;
Fs = 30.72e6;
%in_ch_size Input data channel size [samples]
sdr.in_ch_size = ch_size;
%out_ch_size Output data channel size [samples]
sdr.out_ch_size = ch_size;
%rx_center_freq Center frequency of RX chain(s) [Hz]
sdr.rx_center_freq = 916e6;          % RX_LO_FREQ
%rx_sample_rate Sample rate of RX chain(s) [Hz]
sdr.rx_sample_rate = Fs;        % RX_SAMPLING_FREQ
%rx_rf_bandwidth Bandwidth of receive filter [Hz]
sdr.rx_rf_bandwidth = 2e6;         % RX_RF_BANDWIDTH
%rx_gain_mode AGC mode
sdr.rx_gain_mode = 'manual';       % RX_GAIN_MODE
%rx_gain Gain of RX chain(s) [dB]
sdr.rx_gain = 15;             % RX_GAIN
%tx_center_freq Center frequency of TX chain(s) [Hz]
sdr.tx_center_freq = 916e6;         % TX_LO_FREQ
%tx_sample_rate Sample rate of TX chain(s) [Hz]
sdr.tx_sample_rate = Fs;       % TX_SAMPLING_FREQ
%tx_rf_bandwidth Bandwidth of transmit filter [Hz]
sdr.tx_rf_bandwidth = 5e6;         % TX_RF_BANDWIDTH

sdr.mode = 'transceive';

%% Generate Signal
numberofbits = 16;
% finaltxupsamplepersymbol = 8;
% numberofbits = ch_size/finaltxupsamplepersymbol;
% bit_vector = round(rand(1,numberofbits));
tsym = 1/Fs:1/Fs:ch_size/numberofbits/Fs;
 
%tsym = linspace(0,(1/Fs)*upsample, 10); 




%%Baseband Modulation Frequency and Amplitude, the Modulation Fmod may not be needed
Fmod = 30e3;
amplitude = 1024*3.5;



%actual FSK frequencies
freq1 = 10000;
freq2 = 30000;
freqdelt = abs(freq2-freq1);

%%Generate two test signals that are modulated in the baseband to Fmod+Signal
sig1 = sin(2*pi*(freq1+Fmod)*tsym).*amplitude;
sig0 = sin(2*pi*(freq2+Fmod)*tsym).*amplitude;


txFilt = designfilt('bandpassfir', ...
                   'FilterOrder',30, ...
                   'CutoffFrequency1',abs(Fmod-freqdelt/2), ...
                   'CutoffFrequency2',abs(Fmod+freqdelt/2), ...
                   'SampleRate',Fs);
               
 

%%create mulitple fsk signals in the same frame

%randomdata = round(rand(1,numberofbits));
randomdata = repmat([1 1 0 1 0 1 0 1],1, numberofbits/8);
frame1 = [];
for i = 1:length(randomdata)
    switch randomdata(i)
        case 0
            frame1 = [frame1 sig0];
        case 1
            frame1 = [frame1 sig1];
    end
end

frame1 = filter(txFilt, frame1); 
%frame0 = filter(txFilt, frame0);
%%Hilbert transform removes the unwanted lower sideband and gives good transmit performance
frame1 = hilbert(frame1);
%frame0 = hilbert(frame0);



%% Transceive with SDR

frames = 10;
data = [];
for frame = 1:frames
     o = sdr.transceive(frame1);
%     % Call radio
%     if(mod(frame,2))
%         o = sdr.transceive(frame1);
%     else
%         o = sdr.transceive(frame0);
%     end
    disp(sum(o));
    data = [data; o];
    
    % Info
    s = strcat({'Frame '}, int2str(frame), {' of '}, int2str(frames));
    disp(s)
end
clear sdr;
%% Filter Signal

%Poor mans high pass
% i = 1;
% len = 50;
% while i < length(data) - (len + 1)
%     data(i:(i+len)) = data(i:(i+len))-mean(data(i:(i+len)));
%     i = i + len + 1;
% end

bFilt = designfilt('bandpassfir', ...
                   'FilterOrder',30, ...
                   'CutoffFrequency1',abs(Fmod-freqdelt/2), ...
                   'CutoffFrequency2',abs(Fmod+freqdelt/2), ...
                   'SampleRate',Fs);
               
dataFilter = filter(bFilt, data);              

figure(1)
plot(real(dataFilter))


rxsig = fmdemod(real(dataFilter), Fmod, Fs, freqdelt);

%Create Lowpass Filter
Fpass = 1000;        % Passband Frequency
Fstop = 10000;       % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 80;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
bFilt = design(h, 'butter', 'MatchExactly', match);

%Run the data through the lowpass filter
rxsig_filt = filter(bFilt, rxsig);

%duplicate (for plotting)
rxsig_filt1 = rxsig_filt;
avg = 0;

%map data to 0s and 1s
for k = 1:length(rxsig_filt)
   if rxsig_filt(k) <  1.75 &&  rxsig_filt(k) > 1.25
        rxsig_filt(k) = 0;
   elseif rxsig_filt(k) < .75 &&  rxsig_filt(k) > .25
        rxsig_filt(k) = 1;
   elseif k == 1 || rxsig_filt(k) > 10 || rxsig_filt(k) < -10
       rxsig_filt(k) = -1;
   else
       rxsig_filt(k) = rxsig_filt(k-1);
   end
end


figure(3)
plot(rxsig_filt);
title('Filtered Data');

figure(4)
plot(rxsig);
title('Unfiltered Data');
clear sdr;