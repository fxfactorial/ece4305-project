function [spectrum] = GetSpectrum()
    %% Example Loopback
    clear all;
%     addpath(genpath('../drivers'));
    %% Setup PlutoSDR and constants
%     sdr = PlutoSDR;
%     sdr.mode = 'receive';
%     sdr.rx_gain = 10;
%     sdr.rx_gain_mode = 'fast-attack';
%     ch_size = 1e6;
%     sdr.in_ch_size = ch_size;
%     sdr.out_ch_size = ch_size;

    sweepRange = 600e6;
    BW = 20e6;
    Fs = 2.205 * BW;
%     sdr.rx_sample_rate = Fs;
    minFreq = 100e6;
    maxFreq = minFreq + sweepRange;
%     sdr.tx_rf_bandwidth = 2*BW;

    numSweeps = 1;
    N = sweepRange/BW*2;
    minFreq = 100e6;
%     num = 22050;
    numBin = (Fs/2) / 1000;
    sweepData = zeros(sweepRange/1000, 1);
    data = zeros(sweepRange/1000, numSweeps);
%     n=1;
%     sdr.tx_center_freq = minFreq - BW/2 + BW*n;

    %% Run Averaging
    for i = 1:numSweeps
        for n = 1:N
            signal = setupSDR(n, minFreq);
            freqData = fft(signal, numBin);
            freqData = abs(freqData(1:(BW/1000)));
            idx = (n-1)*BW/1000 + 1;
            sweepData(idx:idx + BW/1000 - 1) = freqData;
        end
        data(:,i) = sweepData;
    end

    spectrum = mean(data, 2);
    %% TX

    %txData(data, freqRange)
end


function [data] = setupSDR(n, minFreq)
    %% Setup PlutoSDR and constants
    addpath(genpath('../drivers'));
    sdr = PlutoSDR;
    sdr.mode = 'receive';
    sdr.rx_gain = 10;
    sdr.rx_gain_mode = 'fast-attack';
    ch_size = 1e6;
    sdr.in_ch_size = ch_size;
    sdr.out_ch_size = ch_size;
    BW = 20e6;
    Fs = 2.205 * BW;
    sdr.rx_sample_rate = Fs;
    sdr.tx_rf_bandwidth = 2*BW;
    sdr.rx_center_freq = minFreq + BW/2*(n-1);
    sdr.tx_center_freq = minFreq + BW/2*(n-1);
    data = sdr.receive();
    clear sdr
end
