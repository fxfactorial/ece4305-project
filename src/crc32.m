function crc = crc32(data)
crcGen = comm.CRCGenerator('z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1');
crc = step(crcGen, data');
crc = crc(end-31:end)';
end