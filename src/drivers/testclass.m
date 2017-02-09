

clear all;
sdr = PlutoSDR;
sdr.mode = 'receive';
o = sdr.receive();

clear all;
sdr = PlutoSDR;
sdr.mode = 'transmit';
sdr.in_ch_size = 8192;
sdr.transmit(ones(1,8192));
 
clear all;
sdr = PlutoSDR;
sdr.mode = 'transceive';
o = sdr.transceive(ones(1,8192));

%% Example Loopback
clear all;
sdr = PlutoSDR;
sdr.mode = 'transceive';
ch_size = (2^13);
sdr.in_ch_size = ch_size;
sdr.out_ch_size = ch_size;
% Generate transmit signal for each input
Fs = 30.72e6;
Fc = 1e6;
t = 1/Fs:1/Fs:ch_size/Fs;
amplitude = 1024;
sigR = sin(2*pi*Fc*t+(1-1)*pi/2).*amplitude;
sigC = sin(2*pi*Fc*t+(2-1)*pi/2).*amplitude;
sig = complex(sigR,sigC);
%%
frames = 30;
ts = dsp.TimeScope('SampleRate', Fs, ...
    'TimeSpan', ch_size*frames/Fs, ...
    'YLimits',10.*[-amplitude amplitude], ...
    'ShowLegend', true,...
    'BufferLength', ch_size*frames );
%%
for x=1:frames
    o = sdr.transceive(sig);
    %o = complex(amplitude*0.5*randn(ch_size,1),amplitude*0.5*randn(ch_size,1));
    ts.step(o);
    %pause(0.1);
end
%%
plot(t,real(o),t,imag(o));
xlabel('Sample');
ylabel('Amplitude');
xlim([0 t(300)])

