clear all;
close all;
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_slow_p5u_b1s3_1019_1138.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_fast_p5u_b1s3_1019_1158.csv','r');
%fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_slow_p7ov2048_b1s3_1021_1054.csv','r');
fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ext_sine_slow_p7ov2048_b1s3_1021_1214_vcm075.csv','r');

c = fgetl(fid); 
f = fscanf(fid, '%f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d, %d', [13 inf] );
t = f(1,:)';
dout= [ f(2,:);f(3,:);f(4,:);f(5,:);f(6,:);f(7,:);f(8,:);f(9,:);f(10,:);f(11,:);f(12,:)]';
clk_smp = [f(13,:)]';
[r,nbits] = size(dout);
fclose(fid);

weights = adc_calibration(0);
%%
close all;
%N = 28087;
N = 2048*4 ;
%fs = 1/96e-9;
%N = 5000*20;
fs = 1/200e-9;
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


figure;
plot(data);
snr=SNR(data,fs)
enob = (snr-1.76)/6.02
%%
% clear all;
% close all;
% f=1e6;
% fs= 1/96e-9;
% for i = 1:1000
%     t = i/fs;
%     S(i) = sin(2*pi*f*t)+normrnd(0,0.3e-3);
% end
% snr = SNR(S,fs);
