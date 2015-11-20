clear all;
close all;
fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/jitter_measurement/jitter_p100n_p21_left_144deg_1116_1122_0-4mVps.csv','r');

c = fgetl(fid); 
f = fscanf(fid, '%f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d, %d, %d', [15 inf] );
t = f(1,:)';
dout= [ f(2,:);f(3,:);f(4,:);f(5,:);f(6,:);f(7,:);f(8,:);f(9,:);f(10,:);f(11,:);f(12,:)]';
clk_smp = [f(15,:)]';
[r,nbits] = size(dout);
fclose(fid);

weights = adc_calibration(0);
%%
%close all;

N=100000;
fs = 1/100e-9;
lsb = 1/(weights(1)+sum(weights));
idx = 1;
data=zeros(1,N);
weights_bi = [1 2 4 8 16 32 64 128 256 512 1024];
for i = 2:r
    if (clk_smp(i-1) == 1 && clk_smp(i)==0)
        data_raw(idx) = dout(i,:)*weights_bi';
        data(idx)=dout(i,:)*weights';  
        idx= idx +1;
    end
    if idx > N
        break;
    end
end
sig = mean(data);

figure;
subplot(2,1,1);
plot(data);
subplot(2,1,2);
plot(data_raw);

figure;
subplot(1,2,1);
xbins = [min(data):1:max(data)];
hist(data,xbins);
[count,value]=hist(data,xbins);
title('Measurement Histogram','FontSize', 18);
xlabel('Output Code','FontSize', 18);
subplot(1,2,2);
% xbins2 = [min(data_raw):1:max(data_raw)];
% hist(data_raw,xbins2);

%%
sigma = 7;
clear diff;
for i = 1:N
    v1(i) = normrnd(598, sigma);
    diff(i) = round(v1(i));
end
%figure(4);
subplot(1,2,2);
xbins = 598+[-25:1:25];
hist(diff,xbins)
[cnt, val]= hist(diff,xbins)
per2 = cnt/sum(cnt)
ylim([0 12000])
title('Gaussian distribution with sigma = 7 lsb','FontSize', 18);
xlabel('Output Code','FontSize', 18);