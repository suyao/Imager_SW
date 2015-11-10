% by shorting v0 and ana18, measure the output to estimate the noise
% Time[s], Channel 0, Channel 1, Channel 2, clk_smp
clear all;
close all;
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1009.csv';
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1013_b1s2_left_fast.csv'; %input shorted
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1015_1711_b1s2_left_fast.csv'; %1V
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1015_1656_b1s2_left_inputshorted_fast.csv'; %input shorted
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1015_1716_lowV_b1s2_left_fast.csv'; %1.1V
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1021_1110_short_b1s3_left_slow.csv';
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1021_1110_mid_b1s3_left_slow.csv'; 
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1021_1110_low_b1s3_left_slow.csv';
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1021_1110_high_b1s3_left_slow.csv';

%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1021_1110_low_b1s3_left_slow_vcm075.csv';
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1021_1110_high_b1s3_left_slow_vcm075.csv';
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1021_1110_mid_b1s3_left_slow_vcm075.csv';
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1022_1447_low2_b1s2_left_slow_vcm1-05.csv';
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1022_1447_high2_b1s2_left_slow_vcm1-05.csv';

filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1023_1009_low_b1s3_left_slow_vcm1.csv';
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1023_1025_high2_b1s3_left_slow_vcm1.csv';
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1109_1447_high_b1s3_left_slow_vcm1.csv';
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/noise_ana_1109_1447_mid_b1s3_left_fast_vcm1.csv';



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

%s3
%sigma = 0.235; x0= 0.163; % low at vcm = 0.75
%sigma = 0.2305;x0= -0.075;   %high at vcm=0.75
%sigma = 0.18;x0= -0.0;   %mid at vcm=0.75

%s2
sigma = 0.287; x0 = -0.4365; %high with vcm = 1 
%sigma = 0.25; x0 = -0.4313; %low with vcm = 1.1 
%sigma = 0.15; x0 = 0.273; %high with vcm = 1.1
sigma = 0.16; x0 = 0; %low with vcm = 1.05
sigma = 0.287; x0 = -0.564; %high2 with vcm = 1.05

sigma = 0.164; x0 = -0.094; %low 0.506 with vcm = 1
sigma = 0.277; x0 = -0.028; % high 1.5 with vcm = 1
%sigma = 0.2; x0 = -0.165; % high 1.501 with vcm = 1

sigma = 0.243; x0 = 0.3136; %high 1.492, vcm = 1, p21 chip slow
sigma = 0.277; x0 = 0.186; %high 1.492, vcm = 1, p21 chip fast
sigma = 0.2; x0 = 0.261; %mid 1.2, vcm = 1, p21 chip fast
x1 = x0+1; 
cdf0 = 1/2*(erf((x0-0.5)/sqrt(2)/sigma)-erf((x0-1.5)/sqrt(2)/sigma))
cdf1 = 1/2*(erf((x0+0.5)/sqrt(2)/sigma)-erf((x0-0.5)/sqrt(2)/sigma))
cdf2 = 1/2*(erf((x1+0.5)/sqrt(2)/sigma)-erf((x1-0.5)/sqrt(2)/sigma))
cdf3 = 1/2*(erf((x1+1.5)/sqrt(2)/sigma)-erf((x1+0.5)/sqrt(2)/sigma))

lsb= 1/1008;
snr = 1/2*(0.49)^2/(lsb^2/12+1e-6*sigma^2);
snr = db(snr)/2;
enob = (snr-1.76)/6.02
