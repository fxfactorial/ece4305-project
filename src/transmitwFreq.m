%%Set Up SDR Coefs
addpath(genpath('../drivers'));
clear all;
% Public, non-tunable properties.
sdr = PlutoSDR;
%mode Transceiver mode of SDR
ch_size = 2.^18;
Fs = 10e6;
%in_ch_size Input data channel size [samples]
sdr.in_ch_size = ch_size;
%out_ch_size Output data channel size [samples]
sdr.out_ch_size = ch_size;
%rx_center_freq Center frequency of RX chain(s) [Hz]
sdr.rx_center_freq = 916e6;          % RX_LO_FREQ
%rx_sample_rate Sample rate of RX chain(s) [Hz]
sdr.rx_sample_rate = Fs;        % RX_SAMPLING_FREQ
%rx_rf_bandwidth Bandwidth of receive filter [Hz]
sdr.rx_rf_bandwidth = Fs/2;         % RX_RF_BANDWIDTH
%rx_gain_mode AGC mode
sdr.rx_gain_mode = 'fast-attack';       % RX_GAIN_MODE
%rx_gain Gain of RX chain(s) [dB]
sdr.rx_gain = 10;             % RX_GAIN
%tx_center_freq Center frequency of TX chain(s) [Hz]
sdr.tx_center_freq = 916e6;         % TX_LO_FREQ
%tx_sample_rate Sample rate of TX chain(s) [Hz]
sdr.tx_sample_rate = Fs;       % TX_SAMPLING_FREQ
%tx_rf_bandwidth Bandwidth of transmit filter [Hz]
sdr.tx_rf_bandwidth = Fs/16;         % TX_RF_BANDWIDTH

sdr.mode = 'transceive';

%% Generate Signal
tsym = 1/Fs:1/Fs:ch_size/4/Fs;
tFilt = 1/Fs:1/Fs:ch_size/8/Fs;

%%Baseband Modulation Frequency and Amplitude, the Modulation Fmod may not be needed
Fmod = 200e3;
amplitude = 1024;

%%Gaussian Filter that pulse shapes the transmit signal for less wideband noise
gaussFiltRight = exp(-tFilt .^ 2 / (2 * .002 ^ 2));
gaussFilt = [fliplr(gaussFiltRight) gaussFiltRight];

%TxFlt = comm.RaisedCosineTransmitFilter('OutputSamplesPerSymbol', 1, 'FilterSpanInSymbols', 8);

%%Generate two test signals that are modulated in the baseband to Fmod+Signal
sig1 = sin(2*pi*(700+Fmod)*tsym).*amplitude;
sig0 = sin(2*pi*(200+Fmod)*tsym).*amplitude;

%%This is where the the pulse shape filter actually shapes the data symbol
sig1 = sig1.*gaussFilt;
sig0 = sig0.*gaussFilt;

%sig1 = step(TxFlt, sig1);
%sig0 = step(TxFlt, sig0);

%%create mulitple fsk signals in the same frame
frame1 = [sig1 sig1 sig1 sig1];
frame0 = [sig0 sig0 sig0 sig0];

%%Hilbert transform removes the unwanted lower sideband and gives good transmit performance
frame1 = hilbert(frame1);
frame0 = hilbert(frame0);

%% Transceive with SDR

frames = 10;
data = [];
for frame = 1:frames
    % Call radio
    if(mod(frame,2))
        o = sdr.transceive(frame1);
    else
        o = sdr.transceive(frame0);
    end
    
    data = [data; o];
    
    % Info
    s = strcat({'Frame '}, int2str(frame), {' of '}, int2str(frames));
    disp(s)
end

%% Filter Signal
bFilt = designfilt('bandpassfir', ...
                   'FilterOrder',100, ...
                   'CutoffFrequency1',2.0009e5, ...
                   'CutoffFrequency2',2.0501e5, ...
                   'SampleRate',Fs);
               
dataFilter = filter(bFilt, data);

figure(1)
plot(real(dataFilter))

fftData = abs(fft(dataFilter, Fs));
[~, fMax] = max(fftData);

if(fftData(fMax - 356) < fftData(fMax + 356))
    lowFreq = fMax;
    highFreq = fMax + 356;
else
    lowFreq = fMax - 356;
    highFreq = fMax;
end

figure(2)

low = 1;%2e5;
high = 1e6;%2.01e5;

freqs = 1000.*(low/Fs:1/Fs:high/Fs);
plot(freqs,fftData(low:high))
xlabel('kHz');
clear sdr;