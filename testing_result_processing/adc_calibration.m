function weight= adc_calibration(lr)
vin=1;
vrefp=1.25;
vrefn=0.75;
vcm=1;
v0=1;
if (lr==0)
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s2slowleft3b_20151013_1036.txt'; %s2 best calibration

   % filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_left3b_20151019_1015.txt'; %vcm = 1 
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_left3b_20151021_1348.txt'; %vcm = 0.75
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_left3b_20151021_2126.txt'; %vcm = 0.75
%    filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_left3b_20151021_2154.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_left3b_20151022_0934.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_left3b_20151022_1647.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_left3b_20151028_2005.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1p21slow_left3b_20151028_2054.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1p21slow_left3b_20151102_1807.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1p21slow_left3b_20151103_1152.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1p21slow_left4b_20151103_1700.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1p21slow_left5b_20151106_1150.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_left5b_20151119_1504.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_left5b_20151124_1020.txt'; %vcm = 1
    filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b3p21slow_left5b_20151125_1149.txt'; %vcm = 1
    
elseif (lr==1)
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slowright3b_20151016_1519.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_right3b_20151022_1816.txt'; %vcm = 1
    filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC//ADC_ramp_b1p21slow_right3b_20151029_1549.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_right5b_20151106_1940.txt'; %vcm = 1
    %filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_b1s3slow_right5b_20151119_1654.txt'; %vcm = 1
   
end

fin = fopen(filename,'r'); %s2 left fast clk on board 1

f = fscanf(fin, '%i %x' ,[2 inf]);
din = f(1,:);
dout = f(2,:);
d0 = din(1);
r = 1; c =1;
data(1,1) = din(1);
for i = 1: length(din)
    if din(i) == d0
        c = c + 1;
    else
        r = r + 1;
        data(r ,1) = din(i); 
        d0 = din(i);
        c = 2;
    end
    data(r,c) = dout (i);   
end

[r,c] = size(data);
data_mean(:,1) = data(:,1);
data_maj(:,1) = data(:,1);
for i = 1:r
   % data_mean(i,2) = mean(data(i,2:end));
    data_maj(i,2) = mode(data(i,2:end));
end

figure;

plot(data_maj(:,1),data_maj(:,2),'r');

k = 1;
for i = r:-1:1;
    if ((2047-data_maj(i,2)) >= 2^(k-1) && (2047-data_maj(i,2)) <= 2^(k-1)+5);
        key(k) = data_maj(i,1);
        value(k) = data_maj(i,2);
        k = k +1;
    end
end

key = key(1) - key + 2^5;
for bit = 1:11;
    weight(bit) = key(bit) / key(1);
end
weight= (weight-weight(1)+weight(2)-weight(1))/weight(1);
weight;
2047-value;
for i = 1:r
    %data_mean(i,2) = mean(data(i,2:end));
    for k=2:c
        ana(i,k-1)= double(dec2bin(data(i,k),11)-'0')*(fliplr(weight))';
    end
    data_mean(i,2)=mean(ana(i,:))*2;
end
hold on;
%plot(data_mean(:,1),data_mean(:,2));



