%function coeff = partial_settling_fitting(fit_order,lr);
 close all;
clear all;
lr = 1;
fit_order = 3;
if lr == 1
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3left0fF_20151019_1539.txt'); %slow
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3left1fF_fast_20151023_1638.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3left1fF_slow__20151023_1627.txt'); %slow
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3left1fF_fast_20151026_1154.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21left1fF_slow_20151102_1920.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21left1fF_fast_20151102_1950.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21left1fF_fast_20151102_2013.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21left1fF_slow_20151106_1411.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21left1fF_slow_20151106_1500.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21left1fF_fast_20151106_1623.txt'); %fast
%   fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21left1fF_slow_20151109_1228.txt'); %slow
    fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21left1fF_fast_20151109_1751.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21left0fF_fast_20151116_1341.txt'); %slow
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b2p21left0fF_slow_20151116_1515.txt'); %slow
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3left1fF_slow_20151119_1851.txt'); %slow
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3left1fF_slow39_20151120_1210.txt'); %slow
    
elseif lr == 2
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3right2fF_20151019_1547.txt'); %slow
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3right4fF_fast_20151023_1650.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3right4fF_slow__20151023_1630.txt'); %slow
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3right4fF_fast_20151026_1205.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21right4fF_fast_20151110_1220.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21right2fF_fast_20151116_1344.txt'); %fast
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1p21right4fF_fast_20151116_1434.txt'); %fast
    fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3right4fF_slow_20151119_1913.txt'); %slow
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s3right4fF_slow158_20151120_1159.txt'); %slow
    
end
c = fgetl(fin);  
f = (fscanf(fin, '%f %x' ,[2 inf]))';
vin_raw = f(:,1);
dout = f(:,2);
fclose(fin);
weights = adc_calibration(lr-1);
lsb = 1/(sum(weights)+weights(1));
% combine same input
v0 = vin_raw(1);
vin(1) = v0;
r = 1; c =1;
data(1,1) = vin_raw(1);
for i = 1: length(vin_raw)
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
vin = vin';
[N, itr] = size(data);
dout_bin_mean = zeros(N,11);

ana = zeros(N,itr-1);
for i = 1:N
    for k=2:itr
        ana(i,k-1)= double(dec2bin(data(i,k),11)-'0')*(fliplr(weights))'; 
    end
    dout_mean_rec(i)=mean(ana(i,:))/(sum(weights)+weights(1));
    
    dout_single(i) = data(i,end);
    dout_bin_single(i,:) = double(dec2bin(dout_single(i),11)-'0');
    dout_single_rec(i) = floor(dout_bin_single(i,:) * (fliplr(weights))')/(sum(weights)+weights(1));
end

dout_mean_rec=dout_mean_rec';
dout_single_rec = dout_single_rec';
figure;
plot(vin,dout_mean_rec);
xlabel('SF Gate Voltage/V','FontSize', 18);
ylabel('ADC readout','FontSize', 18);
title('Dout vs sf Gate','FontSize', 18);
value_raw =dout_mean_rec;

f=figure('Name','Inf Norm Fit: vin=f(vout)');
p_fit = zeros(fit_order+1, 1);
error = 0;
for i=1:1
    a=dout_mean_rec(1:end,i);
    %a=dout_single_rec(1:end,i);
    b=vin(1:end,i);
    A=[ones(N,1) a a.^2 a.^3 a.^4 a.^5 a.^6];
    n=7;
    cvx_begin
        variable x(n)
        minimize (norm(A*x-b,Inf))
        subject to
        for high_order=fit_order+2:7
            x(high_order)>=0
            x(high_order)<=0
        end
    cvx_end
    
    p_fit(1:fit_order+1,i)=x(1:fit_order+1);
        vin_fit(1:N,i)=zeros(N,1);
    %p_fit(1:fit_order+1,i)=linprog(f,A_LP,vout_LP,[],[],LB,[]);
    str='fitting function: vin=';
    for order=1:fit_order+1
        vin_fit(1:N,i)=p_fit(order,i)*a.^(order-1)+vin_fit(1:N,i);
        if p_fit(fit_order+2-order,i)<0
            str=strcat(str,sprintf('%0.2evout^{%i}',p_fit(fit_order+2-order,i),fit_order+1-order));
        else
            str=strcat(str,sprintf('+%0.2evout^{%i}',p_fit(fit_order+2-order,i),fit_order+1-order));
        end
    end
    vin_lin_fit(1:N,i)=zeros(N,1);
    cvx_begin
        variable x(7)
        minimize (norm(A*x-b,Inf))
        subject to
        for high_order=3:7
            x(high_order)>=0
            x(high_order)<=0
        end
    cvx_end
    
    linear_fit(1:2,i)=x(1:2);
    for order=1:2
        vin_lin_fit(1:N,i)=linear_fit(order,i).*(a.^(order-1))+vin_lin_fit(1:N,i);
    end    
    %subplot(4,1,i);
    plot(a,(vin(1:end,i)-vin_lin_fit(1:end,i))/lsb);
    leg1=legend(sprintf('residule with lin_{fit}=%0.3fvout_n+%0.3f',linear_fit(2,i),linear_fit(1,i)));
    set(leg1,'color','none');
    legend('boxoff');
    
    str=strcat(str,sprintf('\nfitting error=+/-%0.2fLSB',max(abs(vin_fit(1:end,i)-vin(1:end,i)))/lsb));
    title(str,'FontSize', 18);
    ylabel('Linear Fitting error/LSB','FontSize', 18);
    if i<=3
        xlabel(strcat(sprintf('vout at %i',i),'\tau'),'FontSize', 18);
    else
        xlabel('vout when fully settled','FontSize', 18);
    end  
    error = max(abs(vin_fit(1:end,i)-vin(1:end,i)))/lsb;
end
coeff =  p_fit(:,1);
result = partial_settling_calib(value_raw, coeff);
% result = 0;
% for i = 1:fit_order+1
%     result = coeff(i)*(value_raw.^(i-1)) + result;
% end
if fit_order == 1;
    str = 'st';
elseif fit_order ==2 
    str = 'nd';
elseif fit_order ==3;
    str = 'rd';
else
    str = 'th';
end

figure;
plot(vin , (vin - result)/lsb);
xlabel('sf Gate Voltage/V','FontSize', 18);
ylabel('fitting error/mV','FontSize', 18);
title(sprintf('%1g%s Order Fitting Error = +/-%0.2fLsb',fit_order,str, error),'FontSize', 18);
figure;
subplot(4,1,1);
plot(1:length(vin),(vin - result)/lsb);
ylabel('fitting error/mV','FontSize', 18)
title(sprintf('%1g%s Order Fitting Error = +/-%0.2fLsb',fit_order,str, error),'FontSize', 18);
subplot(4,1,2);
for i =1:N
    data_maj(i) = mode(data(i,2:end));
end
plot(1:length(vin),data_maj);
ylabel('ADC output','FontSize', 18);
subplot(4,1,3);
error = (vin - result)/lsb;
error_dnl = error(2:end)-error(1:end-1);
plot(1:length(error_dnl),error_dnl);
title(sprintf('%1g%s Order Fitting differential Error = %0.2fLsb',fit_order,str, max(error_dnl)),'FontSize', 18);

hold on ;
x=1:10:length(error_dnl);
plot(x,0.5*ones(1,length(x)),'--r');
plot(x,-0.5*ones(1,length(x)),'--r');
ylabel('Error/LSB','FontSize', 18);
subplot(4,1,4);
for i = 1:N
    result_single(i)=partial_settling_calib(ana(i,2)/(sum(weights)+weights(1)),coeff);
end
error_single = (vin - result_single')/lsb;
error_single_dnl = error_single(2:end)-error_single(1:end-1);
plot(1:length(error_single_dnl),error_single_dnl);
xlabel('ramp step index','FontSize', 18);
title(sprintf('%1g%s Order Fitting differential Error w/o avg',fit_order,str),'FontSize', 18);
ylabel('Error/LSB','FontSize', 18);

figure;
xbins=[min(error_dnl):0.1:max(error_dnl)];
subplot(2,1,1);
hist(error_dnl,xbins);
title(sprintf('%1g%s Order Fitting differential Error Histogram',fit_order,str),'FontSize', 18);
subplot(2,1,2);
xbins=[-3:1:3];
hist(error_single_dnl,xbins);
title(sprintf('%1g%s Order Fitting differential Error w/o Avg Histogram',fit_order,str),'FontSize', 18);

