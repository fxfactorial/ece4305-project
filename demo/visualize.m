function [dataArray] = visualize(data, dataArray)
% Takes in data and visualizes it in an updating waterfall plot.

% Before this function is called, dataArray has to be preallocated as an
% empty array. In the main script, set it to 'zeros(20, 120)'

%% Validate input
assert(isequal(size(data),[1 240]));
assert(isequal(size(dataArray), [20 240]));

%% Define constants
fMin = 0.7; % 1GHz
fStep = 0.005; % 5MHz = 0.005GHz
fMax = 1.9 - fStep; % just less then 1.6GHz to get 120 samples.

numEventsToPlot = 20; % How many sensing events to plot in one graph?

XFreqVector = fMin:fStep:fMax; % X-axis of waterfall
YEventVector = 1:numEventsToPlot; % Y-axis of waterfall

%% Shift and store new data
dataArray = circshift(dataArray, 1); % Shift all rows down
dataArray(1,:) = data; % First row is now new data

%% Plot
surf(XFreqVector, YEventVector, dataArray);
title('PlutoSDR Spectrum Waterfall')
xlabel('Frequency (GHz)')
ylabel('Measurement #')
zlabel('Power (dB)')
ylim([1 20])
colormap jet
colorbar

end