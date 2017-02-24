function [waveFrame] = binary2waveform(binaryFrame, channelSize, Fs)
% Converts a binary vector to a continuous baseband FSK waveform

%% Validate inputs
assert(~isempty(binaryFrame));
% Make sure the number of bits evenly divides the channel size
assert(mod(channelSize,length(binaryFrame))==0);

%% Initialize constants
txFilterOrder = 120;
numBitsInFrame = length(binaryFrame);
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
sigLen = length(sig0); % also the same as length(sig1)

%% Create the waveform frame
waveFrame = zeros(1,numBitsInFrame*sigLen); % Preallocate

for i = 1:numBitsInFrame
    sigRange = sigLen*(i-1)+1 : sigLen*i; % Find where we're updating
    switch binaryFrame(i) % Update depending on what bit we choose
        case 0
            waveFrame(sigRange) = sig0;
        case 1
            waveFrame(sigRange) = sig1;
    end
end

%% Filter for better behavior
% Bandpass FIR
waveFrame = filter(txFilter, waveFrame);

%% Validate output
assert(length(waveFrame)==channelSize);

end

