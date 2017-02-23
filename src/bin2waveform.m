function [waveFrame] = bin2waveform(binFrame, ch_size, Fs)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    numBits = length(binFrame);
    
    tsym = 1/Fs:1/Fs:ch_size/numBits/Fs;
    
    % Baseband Modulation Frequency and Amplitude, the Modulation Fmod may not be needed
    Fmod = 30e3;
    amplitude = 1024*3.5;

    %actual FSK frequencies
    freqLow = 10000;
    freqHigh = 30000;
    freqdelt = abs(freqHigh-freqLow);
    
    %%Generate two test signals that are modulated in the baseband to Fmod+Signal
    sig1 = sin(2*pi*(freqLow+Fmod)*tsym).*amplitude;
    sig0 = sin(2*pi*(freqHigh+Fmod)*tsym).*amplitude;

    txFilt = designfilt('bandpassfir', ...
                        'FilterOrder',120, ...
                        'CutoffFrequency1',abs(Fmod + freqLow  - freqdelt/2), ...
                        'CutoffFrequency2',abs(Fmod + freqHigh + freqdelt/2), ...
                        'SampleRate',Fs);

    waveFrame = [];
    for i = 1:numBits
        switch(binFrame(i))
            case 0
                waveFrame = [waveFrame sig0];
            case 1
                waveFrame = [waveFrame sig1];
        end
    end
                    
    
    waveFrame = filter(txFilt, waveFrame); 

    %%Hilbert transform removes the unwanted lower sideband and gives good transmit performance
    waveFrame = hilbert(waveFrame);

end

