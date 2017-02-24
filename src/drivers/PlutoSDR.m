classdef PlutoSDR < handle
    %PlutoSDR Transceiver
    
    properties (Access = public, SetObservable)
        % Public, non-tunable properties.
        %mode Transceiver mode of SDR
        mode = 'transceive';
        %ip_address IP address
        ip_address = '192.168.2.1';
        %dev_name Device name
        dev_name = 'ad9364';
        %in_ch_size Input data channel size [samples]
        in_ch_size = 8192;
        %out_ch_size Output data channel size [samples]
        out_ch_size = 8192;
        %rx_center_freq Center frequency of RX chain(s) [Hz]
        rx_center_freq = 2.4e9;          % RX_LO_FREQ
        %rx_sample_rate Sample rate of RX chain(s) [Hz]
        rx_sample_rate = 30.72e6;        % RX_SAMPLING_FREQ
        %rx_rf_bandwidth Bandwidth of receive filter [Hz]
        rx_rf_bandwidth = 18.0e6;         % RX_RF_BANDWIDTH
        %rx_gain_mode AGC mode
        rx_gain_mode = 'slow-attack';       % RX_GAIN_MODE
        %rx_gain Gain of RX chain(s) [dB]
        rx_gain = 10;             % RX_GAIN
        %tx_center_freq Center frequency of TX chain(s) [Hz]
        tx_center_freq = 2.4e9 ;         % TX_LO_FREQ
        %tx_sample_rate Sample rate of TX chain(s) [Hz]
        tx_sample_rate = 30.72e6;        % TX_SAMPLING_FREQ
        %tx_rf_bandwidth Bandwidth of transmit filter [Hz]
        tx_rf_bandwidth = 18.0e6;         % TX_RF_BANDWIDTH
    end
    
    properties (Access = private)
        input_struct = struct;
        device_setup = false;
        device_ran = false;
        radio = [];
        config = [];
        %out_ch_no Number of output data channels
        out_ch_no = 2;
        %in_ch_no Number of input data channels
        in_ch_no = 2;
    end
    
    methods
        %% Constructor
        function obj = PlutoSDR(varargin)
            % Construct the libiio interface objects
            obj.radio = obj.setupdev();
            obj.config = obj.setupconfig();
            % Add listeners for all properties
            p = properties(obj);
            for prop = p
                addlistener(obj,prop,'PostSet',@obj.DefaultCallback);
            end
        end
        
        function DefaultCallback(obj,~,~)
            % Update
            if obj.device_ran
                error('Cannot update device once active.  Clear object and setup with desired config or setup another.');
            end
            %disp('Updating Config');
            obj.radio.releaseImpl();
            switch obj.mode
                case 'transmit'
                    obj.in_ch_no = 2;
                    obj.out_ch_no = 0;
                    obj.out_ch_size = 0;
                case 'receive'
                    obj.in_ch_no = 0;
                    obj.out_ch_no = 2;
                    obj.in_ch_size = 0;
                case 'transceive'
                    obj.in_ch_no = 2;
                    obj.out_ch_no = 2;
                otherwise
                    error('Unknown mode chosen');
            end
            obj.radio = obj.setupdev();
            obj.config = obj.setupconfig();
        end
        
        function cfg = setupconfig(obj)
            % Setup configuration
            cfg = cell(1, obj.radio.in_ch_no + length(obj.radio.iio_dev_cfg.cfg_ch));
            
            % Create blank entries for tx signals
            cfg{1} = [];
            cfg{2} = [];
            
            % Setup radio config
            cfg{obj.radio.in_ch_no+1} = obj.rx_center_freq;% RX_LO_FREQ
            cfg{obj.radio.in_ch_no+2} = obj.rx_sample_rate;        % RX_SAMPLING_FREQ
            cfg{obj.radio.in_ch_no+3} = obj.rx_rf_bandwidth;         % RX_RF_BANDWIDTH
            cfg{obj.radio.in_ch_no+4} = obj.rx_gain_mode;       % RX_GAIN_MODE
            cfg{obj.radio.in_ch_no+5} = obj.rx_gain;             % RX_GAIN
            cfg{obj.radio.in_ch_no+6} = obj.tx_center_freq ;         % TX_LO_FREQ
            cfg{obj.radio.in_ch_no+7} = obj.tx_sample_rate;        % TX_SAMPLING_FREQ
            cfg{obj.radio.in_ch_no+8} = obj.tx_rf_bandwidth;         % TX_RF_BANDWIDTH
        end
        
        function radio = setupdev(obj)
            s = iio_sys_obj_matlab; % Constructor
            s.ip_address = obj.ip_address;
            s.dev_name = 'ad9364';
            s.in_ch_no = obj.in_ch_no;
            s.out_ch_no = obj.out_ch_no;
            s.in_ch_size = obj.in_ch_size;
            s.out_ch_size = obj.out_ch_size;
            radio = s.setupImpl();
            %device_setup = true;
        end
        
        function data = transceive(obj,data)
            if ~strcmp(obj.mode,'transceive');
                error('Must call transceive in transceive mode');
            end
            input = obj.config;
            input{1} = real(data);
            input{2} = imag(data);
            output = obj.radio.stepImpl(input);
            data = complex(output{1},output{2});
            obj.device_ran = true;
        end
        
        function transmit(obj,data)
            if ~strcmp(obj.mode,'transmit');
                error('Must call transmit in transmit mode');
            end
            input = obj.config;
            input{1} = real(data);
            input{2} = imag(data);
            obj.radio.stepImpl(input);
            obj.device_ran = true;
        end
        
        function data = receive(obj)
            if ~strcmp(obj.mode,'receive');
                error('Must call receive in receive mode');
            end
            input = obj.config;
            input{1} = [];
            input{2} = [];
            output = obj.radio.stepImpl(input);
            data = complex(output{1},output{2});
            obj.device_ran = true;
        end
    end
    
    %     methods (Static)
    %         function DefaultCallback(~,eventData)
    %             disp('Called');
    %         end
    %
    %     end
    
end












