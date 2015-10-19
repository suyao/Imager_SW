clear all;
close all;
fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s2left1fF_20151014_1402.txt'); 
c = fgetl(fin);  
f = (fscanf(fin, '%f %x' ,[2 inf]))';
vin_raw = f(:,1);
dout = f(:,2);
fclose(fin);
fit_order = 3;
lsb = 1/1024;
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
weights = adc_calibration();
dout_bin_mean = zeros(N,11);

ana = zeros(N,itr-1);
for i = 1:N
    for k=2:itr
        ana(i,k-1)= double(dec2bin(data(i,k),11)-'0')*(fliplr(weights))';
    end
    dout_mean_rec(i)=mean(ana(i,:))/2^9;
    
    dout_single(i) = data(i,end);
    dout_bin_single(i,:) = dec2bin(dout_single(i),11);
    dout_single_rec(i) = floor(dout_bin_single(i,:) * (fliplr(weights))')/2^9;
end

dout_mean_rec=dout_mean_rec';
figure;
plot(vin,dout_mean_rec);
xlabel('vin');
ylabel('dout mean calibrated');


f=figure('Name','Inf Norm Fit: vin=f(vout)');
for i=1:1
    a=dout_mean_rec(1:end,i);
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
    plot(a,vin(1:end,i)-vin_lin_fit(1:end,i));
    leg1=legend(sprintf('residule with lin_{fit}=%0.3fvout_n+%0.3f',linear_fit(2,i),linear_fit(1,i)));
    set(leg1,'color','none');
    legend('boxoff');
    
    str=strcat(str,sprintf('\nfitting error=%0.2fLSB',max(abs(vin_fit(1:end,i)-vin(1:end,i)))/lsb));
    title(str);
    ylabel('vin');
    if i<=3
        xlabel(strcat(sprintf('vout at %i',i),'\tau'));
    else
        xlabel('vout when fully settled');
    end  
    %ylim([min(vin(1:end,i)-vin_lin_fit(1:end,i)) max(vin(1:end,i)-vin_lin_fit(1:end,i))]);
end
%[ax,h]=suplabel('Inf Fit fit: vin=f(vout)','t',SupAxes);
%set(h,'FontSize',TitleLabelSize);
