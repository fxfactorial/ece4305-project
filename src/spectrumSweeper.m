classdef spectrumSweeper <handle
    
    %% properties
    
    properties (Access = public)
        % bandwidth of major sweep in Hz
        sweep_range     = 600e6;   
        % minimum frequency Hz
        freq_min        = 1900e6;  
        % rf bandwidth of minor sweeps
        rf_bw           = 5e6;
        % num major sweeps
        major_sweeps    = 1;                     
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
            
            % num minor sweeps
            minor_sweeps    = this.sweep_range / this.rf_bw;  
            % num freq bins
            freq_bins       = 1; 
            % sampling rate
            Fs              = this.rf_bw; 
            % data of size sweepData x major sweeps
            data = zeros(this.sweep_range/this.rf_bw, this.major_sweeps);    
            
            for i = 1:this.major_sweeps
                sweep_data = [];
                for n = 1:minor_sweeps
                    Fc = this.freq_min + this.rf_bw*n - this.rf_bw/2;
                    disp(['Receving at carrier ', num2str(Fc/1000000), 'MHz'])
                    sdr = this.createRadio(Fc, this.rf_bw, Fs);
                    signal = sdr.receive();
                    freqData = sum(abs(signal).^2);
                    sweep_data = [sweep_data freqData.'];
                     x_axis = (this.freq_min : this.rf_bw : ...
                        ((length(sweep_data) - 1)*this.rf_bw + this.freq_min))./1e6;
                    figure(1), semilogy(x_axis,sweep_data), xlabel('Frequency(MHz)')
                    
                    drawnow

                end
                data(:,i) = sweep_data;
            end
            
            % average all the major sweeps

            % get avg spectrum
            spectrum = mean(data, 2).';                
            % get log spectrum
            spectrum = log(spectrum);
        end
        
        function [spectrum_q, scaling_factor] = scaleToInteger(this, spectrum, n)
            num_bits = n;
            max_num = 2^num_bits - 1;

            % get max magnitude in spectrum for scaling
            max_mag = max(spectrum);
            % get factor to scale spectrum to fit in data type
            scaling_factor = max_num/max_mag;
            % scale spectrum
            spectrum_scaled = spectrum * scaling_factor;
            % quantize scaled spectrum to data type
            spectrum_q = uint8(spectrum_scaled);
            scaling_factor = uint8(scaling_factor);
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
            sdr.rx_sample_rate = rx_sample_rate/2;        % RX_SAMPLING_FREQ
            %rx_rf_bandwidth Bandwidth of receive filter [Hz]
            sdr.rx_rf_bandwidth = rx_rf_bandwidth;         % RX_RF_BANDWIDTH
            %rx_gain_mode AGC mode
            sdr.rx_gain_mode = 'slow-attack';       % RX_GAIN_MODE
            %rx_gain Gain of RX chain(s) [dB]
            sdr.rx_gain = 10;             % RX_GAIN
            %tx_center_freq Center frequency of TX chain(s) [Hz]
            sdr.tx_center_freq = rx_center_freq ;         % TX_LO_FREQ
            %tx_sample_rate Sample rate of TX chain(s) [Hz]
            sdr.tx_sample_rate = rx_sample_rate/2;        % TX_SAMPLING_FREQ
            %tx_rf_bandwidth Bandwidth of transmit filter [Hz]
            sdr.tx_rf_bandwidth = rx_rf_bandwidth;         % TX_RF_BANDWIDTH
        end

    end
end

