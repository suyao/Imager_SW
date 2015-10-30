clear all;
close all;
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_slow_p5u_b1s3_1019_1138.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_p5u_b1s3_1019_1158.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_slow_p7ov2048_b1s3_1021_1054.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_slow_p7ov2048_b1s3_1021_1214_vcm075.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_slow_p58d514_b1s3_1022_1754_vcm1.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_p7ov2048_b1s3_1022_1814_vcm1.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_p7ov2048_b1s3_1023_1054_vcm1.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_p7ov2048_b1s3_1023_1058_vcm1-1.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_p7ov2048_b1s3_1023_1058_vcm1-05.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_p7ov2048_b1s3_1023_1058_vcm0-95.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_p7ov2048_b1s3_1023_1058_vcm0-9.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_p7ov2048_b1s3_1023_1058_vcm0-97.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_slow_b1s3_1023_1058_vcm1-1.csv','r');
fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_b1s3_1023_1353_vcm0-95.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_halfsine_fast_b1s3_1023_1353_vcm0-95.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/current_4_14_4_3.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/timing_1_2_1.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_b1s3_1026_1045_vcm0-95_jitter.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_b1s3_1026_1353_vcm0-95.csv','r');



c = fgetl(fid); 
f = fscanf(fid, '%f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d, %d', [13 inf] );
t = f(1,:)';
dout= [ f(2,:);f(3,:);f(4,:);f(5,:);f(6,:);f(7,:);f(8,:);f(9,:);f(10,:);f(11,:);f(12,:)]';
clk_smp = [f(13,:)]';
[r,nbits] = size(dout);
fclose(fid);

weights = adc_calibration(0);
%%
%close all;

N = 2048*8 ;
fs = 1/96e-9;
%fs = 1/200e-9;
idx = 1;
data=zeros(1,N);
for i = 2:r
    if (clk_smp(i-1) == 1 && clk_smp(i)==0)
        data(idx)=dout(i,:)*weights'/(sum(weights+1));  
        idx= idx +1;
    end
    if idx > N
        break;
    end
end

sig = max(data)-min(data);
lsb = 1/(1+sum(weights));
figure;
plot(data);
snr=SNR(data,fs)
enob = (snr-1.76)/6.02
thermal_noise = sqrt(1/2*(sig/2)^2/10^(snr/10)-lsb^2/12)
[sigma_jitter_est, sigma_noise_est, fsin, xinv] = jitter(data, fs);
sigma_jitter_est
sigma_noise_est
fsin
figure;
plot((1:N)/N,xinv/lsb);
hold on;
plot((1:N)/N,data-0.5,'--r');
xlabel('Normalized Sample Phase t/T_{in}');
ylabel('error/LSB');
title(sprintf('Jitter Measurement: jitter = %0.3gns, noise = %0.3glsb', sigma_jitter_est*1e9,sigma_noise_est/lsb ));
%%
% clear all;
% close all;
% fs = 1/96e-9;
% t=1/fs:1/fs:4*2048/fs;
% dt = normrnd(0,1e-9,[1,4*2048]);
% dn = normrnd(0,1e-4,[1,4*2048]);
% data=1/2*sin(2*pi*fs*3/2048*(t + dt) ) + dn ;
% figure; plot(t,data)
% snr=SNR(data,fs)
% [sigma_jitter_est, sigma_noise_est, fsin] = jitter(data, fs)


