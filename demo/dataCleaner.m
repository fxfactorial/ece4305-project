function [rx_data_clean] = dataCleaner(rxsig_filt)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    rx_data_dirty = downsample(rxsig_filt,100);

    rx_data_clean = [];

    for i = 1:(length(rx_data_dirty) - 10)
        rx_data_clean(i) = mode(rx_data_dirty(i:i+10));
    end
end

