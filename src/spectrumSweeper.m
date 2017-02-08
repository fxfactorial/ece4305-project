classdef spectrumSweeper <handle
    
    %% properties
    
    properties (Access = public)
        % bandwidth of major sweep in Hz
        sweep_range     = 600e6;   
        % minimum frequency Hz
        freq_min        = 1900e6;  
        % rf bandwidth of minor sweeps
        rf_bw           = 40e6;
        % num major sweeps
        major_sweeps    = 3;                     
    end
    
    %% methods
    
    methods (Access = public)
        
        % constructor
        function this = SpectrumSweeper(sweep_range, freq_min, rf_bw, major_sweeps)
            this.freq_min = freq_min;
            this.sweep_range = sweep_range;
            this.rf_bw = rf_bw;
            this.major_sweep = major_sweeps;
        end
        
        % getSpectrum
        function spectrum = getSpectrum(this)
            
            % bandwidth of minor sweep in Hz
            bb_bw           = this.rf_bw / 2;  
            % num minor sweeps
            minor_sweeps    = this.sweep_range / this.rf_bw;  
            % num freq bins
            freq_bins       = this.rf_bw / 1000; 
            % sampling rate
            Fs              = 2 * bb_bw; 
            % data of size sweepData x major sweeps
            data = zeros(this.sweep_range/1000, this.major_sweeps);    
            
            for i = 1:this.major_sweeps
                sweep_data = [];
                for n = 1:minor_sweeps
                    Fc = this.freq_min + this.rf_bw*n - bb_bw;
                    sdr = createRadio(Fc, this.rf_bw, Fs);
                    signal = sdr.receive();
                    freqData = abs(fft(signal, freq_bins));
                    sweep_data = [sweep_data freqData.'];
                end
                data(:,i) = sweep_data;
            end
            
            % average all the major sweeps

            % get avg spectrum
            spectrum = mean(data, 2).';                
            % get log spectrum
            spectrum = log(spectrum);
        end
        
        function [spectrum_q, scaling_factor] = scaleToInteger(spectrum, n)
            num_bits = n;
            max = 2^num_bits - 1;
            UINT = numerictype(0, num_bits);


            % get max magnitude in spectrum for scaling
            max_mag = max(spectrum);
            % get factor to scale spectrum to fit in data type
            scaling_factor = max/max_mag;
            % scale spectrum
            spectrum_scaled = spec_log * scaling_factor;
            % quantize scaled spectrum to data type
            spectrum_q = quantize (spectrum_scaled, UINT);
        end
    end
    
    
    methods (Access = private)
        
        % createRadio
        function sdr = createRadio(this, rx_center_freq, rx_rf_bandwidth, rx_sample_rate)
            sdr = PlutoSDR;
            %mode Transceiver mode of SDR
            sdr.mode = 'receive';
            %ip_address IP address
            sdr.ip_address = '192.168.2.1';
            %dev_name Device name
            sdr.dev_name = 'ad9364';
            %in_ch_size Input data channel size [samples]
            sdr.in_ch_size = 1024;
            %out_ch_size Output data channel size [samples]
            sdr.out_ch_size = 1024;
            %rx_center_freq Center frequency of RX chain(s) [Hz]
            sdr.rx_center_freq = rx_center_freq;          % RX_LO_FREQ
            %rx_sample_rate Sample rate of RX chain(s) [Hz]
            sdr.rx_sample_rate = rx_sample_rate;        % RX_SAMPLING_FREQ
            %rx_rf_bandwidth Bandwidth of receive filter [Hz]
            sdr.rx_rf_bandwidth = rx_rf_bandwidth;         % RX_RF_BANDWIDTH
            %rx_gain_mode AGC mode
            sdr.rx_gain_mode = 'slow-attack';       % RX_GAIN_MODE
            %rx_gain Gain of RX chain(s) [dB]
            sdr.rx_gain = 10;             % RX_GAIN
            %tx_center_freq Center frequency of TX chain(s) [Hz]
            sdr.tx_center_freq = rx_center_freq ;         % TX_LO_FREQ
            %tx_sample_rate Sample rate of TX chain(s) [Hz]
            sdr.tx_sample_rate = rx_sample_rate;        % TX_SAMPLING_FREQ
            %tx_rf_bandwidth Bandwidth of transmit filter [Hz]
            sdr.tx_rf_bandwidth = rx_rf_bandwidth;         % TX_RF_BANDWIDTH
        end

    end
end

