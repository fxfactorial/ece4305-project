function [rate, minLoc] = buadRateDetector(data)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    count = 0;
    previous = data(1);
    min = 0;
    minLoc = 0;
    
    for i = 1 : length(data)
        count = count + 1;
        if data(i) ~= previous
            
            if min == 0
                min = count;
            elseif count < min
                min = count;
                minLoc = i;
            end
            
            count = 0;
            previous = data(i);
        end
        
    end

    rate = min;
end

