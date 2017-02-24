clear all;
addpath(genpath('../drivers'));

FREQ_MIN = 700e6;
kHz = 1000; % Hz
Tx_INT = 2; % Minutes

while (0 == 0)
    % create sweeper object (could also use constructor)
   
    sweeper = spectrumSweeper;
    sweeper.freq_min = FREQ_MIN;
    
    % get spectrum
    disp('Beginning spectrum sweep...')
    spectrum = sweeper.getSpectrum();
    % scale to 8 bit integer
    disp('Scaling data...');
    [spectrum_q , scaling_factor] = sweeper.scaleToInteger (spectrum, 8); 
    
    % wait until next Tx syncronization time
    disp('Waiting to transmit...')
    while ~(mod(minute(datetime('now')), Tx_INT) == 0 && round(second(datetime('now'))) == 0)
    end
    
    % build frames
    disp('Building Frames...')
    frames = parseFrame(spectrum_q, scaling_factor);
    
    % transmit frames
    disp('Transmitting Frames')
    transmitter(frames);
    disp('Transmission complete')
end
