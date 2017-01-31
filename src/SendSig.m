%%Set Up SDR Coefs
addpath(genpath('../drivers'));
clear all;
% Public, non-tunable properties.
sdr = PlutoSDR;
%mode Transceiver mode of SDR
ch_size = 8192*32;
Fs = 5e6;
%in_ch_size Input data channel size [samples]
sdr.in_ch_size = ch_size;
%out_ch_size Output data channel size [samples]
sdr.out_ch_size = ch_size;
%rx_center_freq Center frequency of RX chain(s) [Hz]
sdr.rx_center_freq = 2.4e9;          % RX_LO_FREQ
%rx_sample_rate Sample rate of RX chain(s) [Hz]
sdr.rx_sample_rate = Fs;        % RX_SAMPLING_FREQ
%rx_rf_bandwidth Bandwidth of receive filter [Hz]
sdr.rx_rf_bandwidth = 18.0e6;         % RX_RF_BANDWIDTH
%rx_gain_mode AGC mode
sdr.rx_gain_mode = 'fast-attack';       % RX_GAIN_MODE
%rx_gain Gain of RX chain(s) [dB]
sdr.rx_gain = 10;             % RX_GAIN
%tx_center_freq Center frequency of TX chain(s) [Hz]
sdr.tx_center_freq = 915e6;         % TX_LO_FREQ
%tx_sample_rate Sample rate of TX chain(s) [Hz]
sdr.tx_sample_rate = Fs;       % TX_SAMPLING_FREQ
%tx_rf_bandwidth Bandwidth of transmit filter [Hz]
sdr.tx_rf_bandwidth = 10e6;         % TX_RF_BANDWIDTH

sdr.mode = 'transmit';

%% Generate Signal
tsym = 1/Fs:1/Fs:ch_size/4/Fs;
tFilt = 1/Fs:1/Fs:ch_size/8/Fs;

Fmod = 200e3;
amplitude = 1024*8;

gaussFiltRight = exp(-tFilt .^ 2 / (2 * .002 ^ 2));
gaussFilt = [fliplr(gaussFiltRight) gaussFiltRight];

sig1 = sin(2*pi*(1000+Fmod)*tsym).*amplitude;
sig0 = sin(2*pi*(10000+Fmod)*tsym).*amplitude;

sig1 = sig1.*gaussFilt;
sig0 = sig0.*gaussFilt;

frame1 = [sig1 sig1 sig1 sig1];
frame0 = [sig0 sig0 sig0 sig0];

frame1 = hilbert(frame1);
frame0 = hilbert(frame0);


%% Transceive with SDR

frames = 10;
prev = 0;
for frame = 1:frames
    % Call radio
    if(mod(frame,2))    
        sdr.transmit(frame1);
    else
        sdr.transmit(frame0);
    end
    % Save data
    indx = (frame-1)*ch_size+1 : frame*ch_size;
    % Info
    s = strcat({'Frame '}, int2str(frame), {' of '}, int2str(frames));
    disp(s)
end

clear sdr;