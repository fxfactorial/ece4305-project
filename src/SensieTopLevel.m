clear all;
addpath(genpath('../drivers'));

while (1 == 2)
    % create sweeper object (could also use constructor)
    sweeper = spectrumSweeper;
    sweeper.freq_min = 1900e6;
    
    % get spectrum
    spectrum = sweeper.getSpectrum();
    [spectrum_q , scaling_factor] = scaleToInt (spectrum, 8);
    
    %transmitter = AgletTransmitter;
    
    %transmitter.transmit(spectrum_q);
end
