function [finished] = waveforms2transmit(waveforms)
% Take in a 5x256 bit array of frames, and transmit it with the Pluto

%% Validate inputs
assert(isequal(size(waveforms), [5 2^20]));

%% Define constants
numFrames = size(waveforms, 1);

% Initalize the SDR -- need to make sure we duplicate these settings if
% they're used somewhere else.
sdr = PlutoSDR( ...
    'ch_size',          2^20, ...
    'rx_sample_rate',   30.72e6, ...
    'rx_center_freq',   916e6, ...
    'rx_rf_bandwidth',  2e6, ...
    'tx_rf_bandwidth',  5e6, ...
    'rx_gain',          15, ...
    'rx_gain_mode',     'manual', ...
    'mode',             'transmit');

%% Transmit Data
% Can comment out the below line if you want to auto-operate
disp('<Enter> to start transmission'); pause;
for i = 1:numFrames
    sdr.transmit(waveforms(i,:));
    disp(['Frame ' int2str(i) ' of ' int2str(numFrames)]);
end

%% Clean up and return 
clear sdr;
finished = 1;

end