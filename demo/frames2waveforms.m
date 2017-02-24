function [waveforms] = frames2waveforms(frames, channelSize, Fs)
% Converts a 5x256 bit array to 5 continuous baseband FSK waveforms

%% Validate inputs
assert(isequal(size(frames), [5 256]));
% Make sure the number of bits evenly divides the channel size
assert(mod(channelSize,256)==0);

%% Initialize constants
txFilterOrder = 120;
numBitsInFrame = size(frames,2);
numFrames = size(frames,1);
bitTimeVector = (1:1:channelSize/numBitsInFrame)/Fs;
sinAmplitude = 2^12 * 7/8; % Max amplitude is 2^12=4096, so go under that

% FSK frequency choices
fMod = 30e3; % 30kHz
fLow = 10e3; % 10kHz
fHigh = 30e3; % 30kHz
fDelta = abs(fHigh-fLow); % 20kHz

% Create a transmit filter to improve behavior
txFilter = designfilt('bandpassfir', ...
    'FilterOrder',txFilterOrder, ...
    'CutoffFrequency1',abs(fMod + fLow  - fDelta/2), ...
    'CutoffFrequency2',abs(fMod + fHigh + fDelta/2), ...
    'SampleRate',Fs);

%% Generate bit-representation signals
% Note that 1 is the low frequency, and 0 is the high frequency
sig1 = sinAmplitude * sin(2*pi*(fLow+fMod)*bitTimeVector);
sig0 = sinAmplitude * sin(2*pi*(fHigh+fMod)*bitTimeVector);

%% Create the waveform frames
waveforms = []; % Fill this with all waveforms
for i = 1:numFrames
    waveFrame = [];
    for j = 1:numBitsInFrame
        switch frames(i,j)
            case 0
            	waveFrame = [waveFrame sig0];
            case 1
                waveFrame = [waveFrame sig1];
        end
    end
    waveforms = [waveforms; waveFrame];
end

%% Filter everything for better behavior
% Bandpass FIR
for i = 1:numFrames
    waveforms(i,:) = filter(txFilter, waveforms(i,:));
end

%% Validate output
assert(isequal(size(waveforms), [numFrames channelSize]));

end

