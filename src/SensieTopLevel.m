clear all;
addpath(genpath('../drivers'));

FREQ_MIN = 1900e6;
kHz = 1000; % Hz
Tx_INT = 4; % Minutes

while (0 == 0)
    % create sweeper object (could also use constructor)
    sweeper = spectrumSweeper;
    sweeper.freq_min = FREQ_MIN;
    
    % get spectrum
    spectrum = sweeper.getSpectrum();
    % scale to 8 bit integer
    [spectrum_q , scaling_factor] = sweeper.scaleToInteger (spectrum, 8);
    
    
    % wait until next Tx syncronization time
    while ~(mod(minute(datetime('now')), Tx_INT) == 0 && round(second(datetime('now'))) == 0)
    end

    %transmitter = AgletTransmitter;
    
    %transmitter.transmit(spectrum_q);
end
