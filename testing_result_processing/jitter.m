% Jitter estimation technique proposed by Hummels, ISCAS 1995
% x is a vector that contains an integer number of cycles of a sampled sine wave
function [sigma_jitter_est, sigma_noise_est, fsin] = jitter(x, show_plot)
% take fft, remove DC, signal and harmonics
N = length(x);
s = fft(x);
[sigamp, sigbin]=max(abs(s));
A_est = sigamp/N*2;
cycles = sigbin-1;
fsin = cycles/N;
harmbins = 1 + abs([2:8]*cycles - N*round([2:8]*cycles/N));
sn=s;
sn(1)=eps;
sn(sigbin)=eps;
sn(N+2-sigbin)=eps;
sn(harmbins) =eps;
sn(N+2-harmbins)=eps;
% inverse fft, compute jitter and noise estimates
xinv = ifft(sn, 'symmetric');
s_inv = abs(fft(xinv.^2));
jitterbin = 1 + abs(2*cycles - N*round(2*cycles/N));
sigma_jitter_est = sqrt(2*2*s_inv(jitterbin)/N/(2*pi*fsin)^2/A_est^2);
sigma_noise_est = sqrt(s_inv(1)/N-2*s_inv(jitterbin)/N);