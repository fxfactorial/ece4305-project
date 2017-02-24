function [sdr] = initSdr(ch_size, Fs, center_freq, rx_bw, tx_bw, rx_gain, agc_mode, sdr_mode)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    assert(isequal('transmit', sdr_mode) || isequal('receive', sdr_mode) || isequal('transceive', sdr_mode), ...
                   'Incorrect sdr_mode');
               
    assert(isequal('fast-attack', agc_mode) || isequal('slow-attack', agc_mode) || isequal('manual', agc_mode), ...
                   'Incorrect agc_mode');
    
    % Public, non-tunabe properties.
    sdr = PlutoSDR;
    %in_ch_size Input data channel size [samples]
    sdr.in_ch_size = ch_size;
    %out_ch_size Output data channel size [samples]
    sdr.out_ch_size = ch_size;
    %rx_center_freq Center frequency of RX chain(s) [Hz]
    sdr.rx_center_freq = center_freq - 100e6;          % RX_LO_FREQ
    %rx_sample_rate Sample rate of RX chain(s) [Hz]
    sdr.rx_sample_rate = Fs;        % RX_SAMPLING_FREQ
    %rx_rf_bandwidth Bandwidth of receive filter [Hz]
    sdr.rx_rf_bandwidth = rx_bw;         % RX_RF_BANDWIDTH
    %rx_gain_mode AGC mode
    sdr.rx_gain_mode = agc_mode;       % RX_GAIN_MODE
    %rx_gain Gain of RX chain(s) [dB]
    sdr.rx_gain = rx_gain;             % RX_GAIN
    %tx_center_freq Center frequency of TX chain(s) [Hz]
    sdr.tx_center_freq = center_freq;         % TX_LO_FREQ
    %tx_sample_rate Sample rate of TX chain(s) [Hz]
    sdr.tx_sample_rate = Fs;       % TX_SAMPLING_FREQ
    %tx_rf_bandwidth Bandwidth of transmit filter [Hz]
    sdr.tx_rf_bandwidth = tx_bw;         % TX_RF_BANDWIDTH

    sdr.mode = sdr_mode;

end

