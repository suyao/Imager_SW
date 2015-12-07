clear all;
close all;
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3slow_right_20151016_1609.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3fastright_20151016_1633.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3left_20151016_1451.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3slow_left_20151019_1104.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3slow_left_20151021_1313.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3slow_left_20151021_2224.txt','r'); %vcm = 0.75
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3slow_left_20151022_0904.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s2left_20151013_1323.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s2slow_left_20151022_1454.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3slow_left_20151022_1715.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3slow_right_20151022_1843.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3fast_left_20151023_1151.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3fast_right_20151023_1217.txt','r');

%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1p21slow_left_20151028_2121.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1p21slow_right_20151028_2148.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1p21slow_left_20151106_1431.txt','r');
fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1p21slow_left_20151109_1955.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1p21slow_right_20151109_2023.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1p21fast_left_20151110_1122.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1p21fast_right_20151110_1149.txt','r');





c = fgetl(fin);
weights = adc_calibration(1);
f = fscanf(fin, '%f %x' ,[2 inf]);
vin = f(1,:);
dout = f(2,:);

fclose(fin);

% combine same input
v0 = vin(1);
r = 1; c =1;
data(1,1) = vin(1);
for i = 1: length(vin)
    if vin(i) == v0
        c = c + 1;
    else
        r = r + 1;
        data(r ,1) = vin(i); 
        v0 = vin(i);
        c = 2;
    end
    data(r,c) = dout (i);   
end

[N, itr] = size(data);
%N=256*2;
dout_bin_mean = zeros(N,11);
%N=1024*2;
%N=1024*1;
ana = zeros(N,itr-1);
for i = 1:N
    for k=2:itr
        ana(i,k-1)= double(dec2bin(data(i,k),11)-'0')*(fliplr(weights))';
    end
    dout_mean_rec(i)=mean(ana(i,:))/(sum(weights)+weights(1));
    
    dout_single(i) = data(i,end-1);
    dout_bin_single(i,:) = double(dec2bin(dout_single(i),11)-'0');
    dout_single_rec(i) = floor(dout_bin_single(i,:) * (fliplr(weights))')/(sum(weights)+weights(1));
end
figure;
plot(dout_mean_rec)
snr=SNR(dout_single(1:end)/(sum(weights)+weights(1)),1)
snr_rec_avg=SNR(dout_mean_rec(1:end),1)
enob_avg = (snr_rec_avg-1.76)/6.02
snr_rec = SNR(dout_single_rec(1:end),1)
enob_avg = (snr_rec-1.76)/6.02
