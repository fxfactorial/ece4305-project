clear all;
addpath(genpath('../drivers'));

i = 0
while (i == 0)
    i = i + 1;
    % create sweeper object (could also use constructor)
    sweeper = spectrumSweeper;
    sweeper.freq_min = 1900e6;
    
    % get spectrum
    spectrum = sweeper.getSpectrum();
    [spectrum_q , scaling_factor] = sweeper.scaleToInteger (spectrum, 8);
    
    %transmitter = AgletTransmitter;
    
    %transmitter.transmit(spectrum_q);
end
