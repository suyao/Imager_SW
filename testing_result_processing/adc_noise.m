% by shorting v0 and ana18, measure the output to estimate the noise
% Time[s], Channel 0, Channel 1, Channel 2, clk_smp
clear all;
close all;
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1009.csv';
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1013_b1s2_left_fast.csv'; %input shorted
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1015_1711_b1s2_left_fast.csv'; %1V
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1015_1656_b1s2_left_inputshorted_fast.csv'; %input shorted
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1015_1716_lowV_b1s2_left_fast.csv'; %1.1V
fid = fopen(filename,'r');
c = fgetl(fid); 
f = fscanf(fid, '%f,%d,%d,%d,%d', [5 inf] );
bits= [f(4,:);f(3,:); f(2,:)]';
clk_smp = f(5,:);
[r,c] = size(bits);
idx = 1;
for i = 2:r
    if (clk_smp(i-1) == 1 && clk_smp(i)==0)
        data(idx)=bits(i,1)*4 + bits(i,2)*2 + bits(i,3);
        idx = idx + 1;
    end
end
data_sort = sort(data);
xbins = [0 1 2 3 4 5 6 7];

[counts, value]=hist(data,xbins);
hist(data,xbins)
xlabel('last 3 digits of dout');
ylabel('counts');
title('histogram of ADC outputs')
per=counts/sum(counts)
%per(5)+per(6)
%% cdf 
per=counts/sum(counts)
%sigma = 0.34; %short
%x0=-0.377; x1 = x0+1; 
%sigma = 0.341; %noise_ana_1009 (long)
%x0 = -0.3575; x1 = x0 +1;
sigma = 0.24; %noise_ana_1013_b1s2_left_fast
x0= -0.6256; x1 = x0+1; 
cdf0 = 1/2*(erf((x0-0.5)/sqrt(2)/sigma)-erf((x0-1.5)/sqrt(2)/sigma))
cdf1 = 1/2*(erf((x0+0.5)/sqrt(2)/sigma)-erf((x0-0.5)/sqrt(2)/sigma))
cdf2 = 1/2*(erf((x1+0.5)/sqrt(2)/sigma)-erf((x1-0.5)/sqrt(2)/sigma))
cdf3 = 1/2*(erf((x1+1.5)/sqrt(2)/sigma)-erf((x1+0.5)/sqrt(2)/sigma))

%% test snr
for i =1:256;
    y(i)=0.5*sin(2*pi*i/128)+0.5+normrnd(0,0.24/1e3);
    z(i)=round(2^10*y(i));
end
snr = SNR(z)