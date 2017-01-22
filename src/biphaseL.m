function output = biphaseL(data, mode)
% Encodes or decodes data using Biphase-L line code: 1<->10, 0<->01
%
% Input(s):
% data      The data to be either encoded or decoded
% mode      Valid modes are 'encode', 'decode'
%
% Output(s):
% output    The now-encoded or -decoded data

data_len = length(data);
assert(data_len > 0, 'biphaseL() was passed an empty vector')

switch mode
    case 'encode'
        % Preinitialize then fill the output vector
        output = zeros(1, 2*data_len);
        for idx = 1:data_len
            output(2*idx-1 : 2*idx) = encode(data(idx));
        end
    case 'decode'
        assert(mod(data_len,2)==0, ...
            'biphaseL() attempted to decode odd-length data')
        % Preinitialize then fill the output vector
        output = zeros(1, data_len/2);
        for idx = 1:2:data_len
            output((idx+1)/2) = decode(data(idx : idx+1));
        end
    otherwise
        error('biphaseL() was passed an invalid mode %s', mode)
end
end

% Local, helper functions below

function y = encode(x)
% Encoding process; 0 -> 01, 1 -> 10
switch x
    case 0
        y = [0 1];
    case 1
        y = [1 0];
    otherwise
        error('biphaseL() attempted to encode a non-binary digit')
end
end

function x = decode(y)
% Decoding process; 01 -> 0, 10 -> 1
if isequal(y, [0 1])
    x = 0;
elseif isequal(y, [1 0])
    x = 1;
else
    error('biphaseL() attempted to decode an invalid symbol')   
end
end
