function [checksum] = crc(data)
% Returns a 1x32 vector representing the CRC32 of the data.

%% Instantiate CRC object
polynomial = [32 26 23 22 16 12 11 10 8 7 5 4 2 1 0]; % CRC32 polynomial
crcGen = comm.CRCGenerator(polynomial);

%% Compute the CRC
dataPlusCRC = step(crcGen, data'); % Append CRC to data
checksum = dataPlusCRC(end-31:end)'; % Grab the last 32 bits only

end