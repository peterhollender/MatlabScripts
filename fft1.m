%[Y f] = fft1(y,Fs_or_t,N)

function [Y f] = fft1(y,Fs_or_t,N)
if ~exist('Fs_or_t','var');
    Fs_or_t = 1:size(y,1);
end
y = squeeze(y);
if any(isnan(y(:)))
    y(isnan(y)) = 0;
end
if size(y,1)==1 && length(y)>1
L = length(y);
else
L = size(y,1);
end
if length(Fs_or_t) == L;
    Fs = 1/mean(diff(Fs_or_t));
elseif length(Fs_or_t)==1
    Fs = Fs_or_t;
else
    error('unknown Fs specification')
end
T = 1/Fs;
if ~exist('N','var')
    NFFT = 2^nextpow2(L);
else
    NFFT = N;
end
%NFFT = max(2^nextpow2(L),N);
if sum(size(y)~=1)>1
    Y = circshift(fft(y,NFFT)/L,[-NFFT/2 0]);
else
    Y = fftshift(fft(y,NFFT)/L);
end
    
f = Fs/2*linspace(-1,1,NFFT);
%Y = 2*abs(Y(1:NFFT/2,:));
