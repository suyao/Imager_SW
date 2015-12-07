clear all;
close all;
filename = ('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PVT/PartialSettling/');
filename = strcat(filename,'Voltage/b3p21left0pF_fast118_pwsmp44ns_20151130_2256_scale1_25deg.txt'); %fast
fin = fopen(filename);
c = fgetl(fin);  
f = (fscanf(fin, '%f %x' ,[2 inf]))';
vin_raw = f(:,1);
dout = f(:,2);
fclose(fin);

fit_order = 1;
if (strfind(filename,'left')>1)
    lr = 1;
elseif (strfind(filename,'right')>1)
    lr = 2;
end

if (strfind(filename,'0-9_')>1)
    Vscale = ' Supply Scale = 0.9';
    Vstr = 'Scale_0-9';
elseif (strfind(filename,'0-95')>1)
   Vscale = ' Supply Scale = 0.95';
    Vstr = 'Scale_0-95';
elseif (strfind(filename,'scale1_')>1)
   Vscale = ' Supply Scale = 1';
   Vstr = 'Scale_1';
elseif (strfind(filename,'1-05')>1)
   Vscale = ' Supply Scale = 1.05';
    Vstr = 'Scale_1-05';
elseif (strfind(filename,'1-1')>1)
   Vscale = ' Supply Scale = 1.1';
    Vstr = 'Scale_1-1';
end

if (strfind(filename,'n25deg')>1)
    Temp = '-25C';
elseif (strfind(filename,'_0deg')>1)
    Temp = '0C';
elseif (strfind(filename,'25deg')>1)
    Temp = '25C';
elseif (strfind(filename,'50deg')>1)
    Temp = '50C';
elseif (strfind(filename,'75deg')>1)
    Temp = '75C';
end
%weights = adc_calibration(lr-1);
weights = [    0.9375    1.8750    3.7812    7.5000   14.7500 16.1562   31.9062   64.0312  127.5625  255.0625  480.3438]; %p21
%weights = [0.9062    1.8125    3.6875    7.4688   14.5625 16.0938   31.9375   63.7812  127.5312  255.1875 480.7500]; %p12

lsb = 1/(sum(weights)+weights(1));
%fit_coeff{lr} = partial_settling_fitting(fit_order,lr);
fit_coeff{lr} = [  1.0357 ;1.7046]; %p21 scale 1 at room temp
%fit_coeff{lr} = [  1.044 ;1.676]; %p12 scale 1 at room temp
% combine same input
v0 = vin_raw(1);
vin(1) = v0;
r = 1; c =1;
data(1,1) = vin_raw(1);
for i = 1:length(vin_raw)
    if vin_raw(i) == v0
        c = c + 1;
    else
        r = r + 1;
        data(r ,1) = vin_raw(i); 
        v0 = vin_raw(i);
        vin(r) = v0;
        c = 2;
    end
    data(r,c) = dout (i);   
end
% vin = vin';
[N, itr] = size(data);
dout_bin_mean = zeros(N,11);

ana = zeros(N,itr-1);
for i = 1:N
    for k=2:itr
        ana(i,k-1)= double(dec2bin(data(i,k),11)-'0')*(fliplr(weights))'; 
    end
    dout_mean_rec(i)=mean(ana(i,:))/(sum(weights)+weights(1));
    vin_mean_calib(i)=partial_settling_calib(dout_mean_rec(i),fit_coeff{lr}); 
    
    dout_single(i) = data(i,end);
    vin_single_calib(i)= partial_settling_calib(ana(i,2)/(sum(weights)+weights(1)),fit_coeff{lr}); 
    
    dout_bin_single(i,:) = double(dec2bin(dout_single(i),11)-'0');
    dout_single_rec(i) = floor(dout_bin_single(i,:) * (fliplr(weights))')/(sum(weights)+weights(1));
end   

vin_err_avg = vin - vin_mean_calib;
vin_dnl_err_avg = vin_err_avg(2:end)-vin_err_avg(1:end-1);

f=figure('Name',strcat('Partial Settling Fitting Error @',Temp,Vscale));
set(f, 'Position', [200, 100, 1049, 1049]);
subplot(3,1,1);
plot(1:length(vin),vin,'b',1:length(vin_mean_calib),vin_mean_calib,'r');
legend('input source','calibrated input');
title(strcat('Partial Settling fitting Error Analysis @',Vscale,',     ',Temp),'Fontsize',18);
ylabel('Input Voltage');
subplot(3,1,2);
plot(vin_err_avg/lsb);
title(sprintf('absolute input error, max value = %0.4gLSB',max(abs(vin_err_avg/lsb))),'FontSize',15);
ylabel('Fitting Error/LSB');
% subplot(4,1,3);
% plot(vin_dnl_err_avg/lsb);
% xbins=[-3:1:3];
% [hist_counts,value_rst]=hist(vin_dnl_err_avg*5/lsb/fit_coeff{lr}(2),xbins);
% ratio_p0_p1 = hist_counts(4)/(hist_counts(3)+hist_counts(5))*2;
% input_referred_fitting_error = (0.0807./ratio_p0_p1.^2+0.1035./ratio_p0_p1+0.04166);
% input_referred_fitting_error = fit_coeff{lr}(2)*sqrt(input_referred_fitting_error^2-0.0665^2);
% title(sprintf('Differential fitting error w/o noise, max value = %0.3gLSB',max(abs(vin_dnl_err_avg/lsb))),'FontSize',15);
% xlabel('input step');
% ylabel('Fitting Error/LSB');
subplot(3,1,3);
vin_err_single = vin - vin_single_calib;
vin_dnl_err_single = vin_err_single(2:end)-vin_err_single(1:end-1);
plot(vin_dnl_err_single/lsb);
ylabel('Error/LSB');

xbins=[-3:1:3];
[hist_counts,value_rst]=hist(vin_dnl_err_single/lsb/fit_coeff{lr}(2),xbins);
ratio_p0_p1 = hist_counts(4)/(hist_counts(3)+hist_counts(5))*2;
input_referred_total_error = sqrt(2)*fit_coeff{lr}(2)*(0.5129*exp(-0.2553*ratio_p0_p1)+2.686*exp(-1.623*ratio_p0_p1)+0.1107)
title(sprintf('Differential input error w noise, max value = %0.3gLSB, RMS = %0.3gLSB',max(abs(vin_dnl_err_single/lsb)),input_referred_total_error),'FontSize',15);
fod = ('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PVT/PartialSettling/results/p21/');
fod = strcat(fod,Vstr,'_',Temp,'.png');
saveas(f,fod);

%%
if (1==0)
nMon = 20000;  % number of Monte Carlo trials for each point
sigma_list = [0.15:0.0008:0.6];
P0 = zeros(1, length(sigma_list));
P1 = P0;
P2 = P0;
for i = 1 : length(sigma_list)
    sigma = sigma_list(i);
    for mon = 1: nMon
        v = rand() - 0.5;  % generate Unif(-0.5, 0.5)
        z1 = sigma* randn();  % generate i.i.d. Gaussian noise w/ variance sigma^2
        z2 = sigma* randn();

        Q1 = round(v+z1);  % Quantize
        Q2 = round(v+z2);
        
        if Q1 - Q2 == 0
            P0(i) = P0(i) + 1;  % empirical probability that Q1 - Q2 = 0
        elseif Q1 - Q2 == 1
            P1(i) = P1(i) + 1;  % empirical probability that Q1 - Q2 = 1
        elseif Q1 - Q2 == 2;
            P2(i) = P2(i) + 1;
        end
    end
end
figure;
%subplot(1,2,1);
plot(sigma_list, P0./P1)
hold on;
plot(sigma_list, ratio_p0_p1*ones(1,length(sigma_list)),'r');
ylabel('P0/P1','FontSize', 18);
xlabel('sigma_{noise}','FontSize', 18);
grid on;
figure;
exp3='a*exp(b*x)+c*exp(d*x)+e';
f = fit( (P0./P1)',sigma_list',exp3,'StartPoint',[0.44 -0.1183 1.74, -1.2,0])
plot(f, (P0./P1)',sigma_list')
grid on;
end