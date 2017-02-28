function [dataBin] = clean2bin(rx_clean_data, symbolWidth)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    
    edges = [];
    
    for i = 1 : (length(rx_clean_data) - 1)
        current = rx_clean_data(i);
        
        if rx_clean_data(i + 1) ~= current
            edges = [edges i];
        end
    end
    
    edges = [edges length(rx_clean_data)];
    
    dataBin = [];
    
    for i = 1 : (length(edges) - 1) 
        
        position = symbolWidth/2 + edges(i);
        
        while position < edges(i + 1)
            dataBin = [dataBin rx_clean_data(position)];
            position = position + symbolWidth;
        end
    end
    
end

