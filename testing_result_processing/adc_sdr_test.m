clear all;
close all;
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_left_20151009_1400.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_right_20151012_1600.txt','r'); %s2 right slow clk on board 1
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_left_20151013_1125.txt','r'); %s2 left slow clk on board 1
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s2left_20151013_1323.txt','r'); %s2 left fast clk on board 1
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3slow_right_20151016_1609.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3fastright_20151016_1633.txt','r');
%fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3left_20151016_1451.txt','r');
fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_SNR_b1s3slow_left_20151019_1104.txt','r');

weights = adc_calibration(0);
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

dout_bin_mean = zeros(N,11);


ana = zeros(N,itr-1);
for i = 1:N
    for k=2:itr
        ana(i,k-1)= dec2bin(data(i,k),11)*(fliplr(weights))';
    end
    dout_mean_rec(i)=mean(ana(i,:))/2^9;
    
    dout_single(i) = data(i,end);
    dout_bin_single(i,:) = dec2bin(dout_single(i),11);
    dout_single_rec(i) = floor(dout_bin_single(i,:) * (fliplr(weights))')/2^9;
end
figure;
plot(dout_mean_rec)
snr=SNR(dout_single(257:end)/2^9,1)
snr_rec_avg=SNR(dout_mean_rec(257:end),1)
enob_avg = (snr_rec_avg-1.76)/6.02
snr_rec = SNR(dout_single_rec(257:end),1)
enob_avg = (snr_rec-1.76)/6.02
