clear all;
close all;
fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/PartialSettling/b1s2left1fF_20151014_1328.txt'); 
c = fgetl(fin);  
f = (fscanf(fin, '%f %x' ,[2 inf]))';
vin_raw = f(:,1);
dout = f(:,2);
fclose(fin);
fit_order = 4;
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


if (1==0)
% load sim output
% fp1=importdata('p1.csv');
% fp1_b=importdata('p1_b.csv');
% fp2=importdata('p2.csv');
% fvout=importdata('output.csv');
% fadc=importdata('v_adc.csv');
% vout=fvout(:,2);
% t_vout=fvout(:,1);
% p1=fp1(:,2);
% p1_b=fp1_b(:,2);
% t_p1=fp1(:,1);
% p2=fp2(:,2);
% t_p2=fp2(:,1);
% v_adc=fadc(:,2);
% figure;
% hold on;
% %plot(t_vout,v_adc,'r');
% plot(t_vout,vout);
% plot(t_vout,v_adc,'r');
% figure;
% plot(t_p1,p1_b,'r')
% hold on;
% plot(t_p2,p2)
% %plot(t_p1,p1_b,'green')

lsb=1/1024;
fit_order=3;
ft1=importdata('output_t1.txt');
ft2=importdata('output_t2.txt');
ft3=importdata('output_t3.txt');
ftfull=importdata('output_tfull.txt');
vout_t=[ft1(:,2),ft2(:,2),ft3(:,2),ftfull(:,2)];
vin_t=[ft1(:,1),ft2(:,1),ft3(:,1),ftfull(:,1)];
leng_data=length(ft1(:,2));



%nomalize to [-0.5,0.5]
vout_t_norm=[];
vin_t_norm=(vin_t-min(vin_t(1:end,1)))/(max(vin_t(1:end,1))-min(vin_t(1:end,1)))-0.5;
for i=1:4
    vout_t_norm(1:leng_data,i)=(vout_t(1:end,i)-min(vout_t(1:end,i)))/(max(vout_t(1:end,i))-min(vout_t(1:end,i)))-0.5;
end
TitleLabelSize=15;
SupAxes=[0.08 0.08 0.84 0.875];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f=figure('Name','Mean Square Fit: vout(t)=f(vin_{norm})');
set(f,'Position',[100,100,1049,2000]);
p_fit=[];
linear_fit=[];
for i=1:4
    p_fit(1:fit_order+1,i)=polyfit(vin_t_norm(1:leng_data,i),vout_t(1:leng_data,i),fit_order);
    vout_fit(1:leng_data,i)=zeros(leng_data,1);
    
    str='fitting function: vout= ';
    for order=1:fit_order+1
        vout_fit(1:leng_data,i)=p_fit(order,i).*(vin_t_norm(1:end,i).^(fit_order+1-order))+vout_fit(1:leng_data,i);
        if p_fit(order,i)<0
            str=strcat(str,sprintf('%0.2evin_n^{%i}',p_fit(order,i),fit_order+1-order));
        else
            str=strcat(str,sprintf('+%0.2evin_n^{%i}',p_fit(order,i),fit_order+1-order));
        end
    end
    vout_lin_fit(1:leng_data,i)=zeros(leng_data,1);
    linear_fit(1:2,i)=polyfit(vin_t_norm(1:leng_data,i),vout_t(1:leng_data,i),1);
    for order=1:2
        vout_lin_fit(1:leng_data,i)=linear_fit(order,i).*(vin_t_norm(1:end,i).^(2-order))+vout_lin_fit(1:leng_data,i);
    end    
    subplot(4,1,i);
    plot(vin_t_norm(1:end,i),vout_t(1:end,i)-vout_lin_fit(1:end,i))
    leg1=legend(sprintf('residule with lin_{fit}=%0.3fvin_n+%0.3f',linear_fit(1:2,i)));
    set(leg1,'color','none');
    legend('boxoff');
    str=strcat(str,sprintf('\nfitting error=%0.2fLSB',max(abs(vout_fit(1:end,i)-vout_t(1:end,i)))/lsb));
    title(str);

    if i<=3
        ylabel(strcat(sprintf('vout at %i',i),'\tau'));
    else
        ylabel('vout when fully settled');
    end
    ylim([min(vout_t(1:end,i)-vout_lin_fit(1:end,i)) max(vout_t(1:end,i)-vout_lin_fit(1:end,i))]);
end
xlabel('vin (nomalized)');
[ax,h]=suplabel('MSQ fit: vout=f(vin_{norm})','t',SupAxes);
set(h,'FontSize',TitleLabelSize);
saveas(f,'MSQ_vout_f(vin_norm)','jpg');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%inf norm fitting
f=figure('Name','Inf Norm Fit: vout(t)=f(vin_{norm})');
set(f,'Position',[100,100,1049,2000]);
% p_fit=[];
% A=bsxfun(@power,(vin_t_norm(1:end,1)),0:1:fit_order);
% LB=[-inf*ones(1,length(0:1:fit_order)) 0 0]';
% A_LP=[A -1*ones(leng_data,1) zeros(leng_data,1);-A zeros(leng_data,1) -1*ones(leng_data,1)];
% for i=1:4
%     vout_LP=[vout_t(1:leng_data,i);-vout_t(1:leng_data,i)];
%     f=[zeros(1,length(0:1:fit_order)) 1 1]';
%     soln=linprog(f,A_LP,vout_LP,[],[],LB,[]);
for i=1:4
    a=vin_t_norm(1:leng_data,i);
    b=vout_t(1:end,i);
    A=[ones(100,1) a a.^2 a.^3 a.^4 a.^5 a.^6];
    n=7;
    cvx_begin
        variable x(7)
        minimize (norm(A*x-vout_t(1:end,i),Inf))
        subject to
        for high_order=fit_order+2:7
            x(high_order)>=0
            x(high_order)<=0
        end
    cvx_end
    x
    p_fit(1:fit_order+1,i)=x(1:fit_order+1);
        vout_fit(1:leng_data,i)=zeros(leng_data,1);
    %p_fit(1:fit_order+1,i)=linprog(f,A_LP,vout_LP,[],[],LB,[]);
    str='fitting function: vout= ';
    for order=1:fit_order+1
        vout_fit(1:leng_data,i)=p_fit(order,i)*(vin_t_norm(1:end,i).^(order-1))+vout_fit(1:leng_data,i);
        if p_fit(fit_order+2-order,i)>=0
            str=strcat(str,sprintf('+%0.2evin_n^{%i}',p_fit(fit_order+2-order,i),fit_order+1-order));
        else
            str=strcat(str,sprintf('%0.2evin_n^{%i}',p_fit(fit_order+2-order,i),fit_order+1-order));
        end
    end
    
    vout_lin_fit(1:leng_data,i)=zeros(leng_data,1);
    cvx_begin
        variable x(7)
        minimize (norm(A*x-vout_t(1:end,i),Inf))
        subject to
        for high_order=3:7
            x(high_order)>=0
            x(high_order)<=0
        end
    cvx_end
    
    linear_fit(1:2,i)=x(1:2)
    for order=1:2
        vout_lin_fit(1:leng_data,i)=linear_fit(order,i).*(vin_t_norm(1:end,i).^(order-1))+vout_lin_fit(1:leng_data,i);
    end    
    subplot(4,1,i);
    plot(vin_t_norm(1:end,i),vout_t(1:end,i)-vout_lin_fit(1:end,i))
    leg1=legend(sprintf('residule with lin_{fit}=%0.3fvin_n+%0.3f',linear_fit(2,i),linear_fit(1,i)));
    set(leg1,'color','none');
    legend('boxoff');

    str=strcat(str,sprintf('\nfitting error=%0.2fLSB',max(abs(vout_fit(1:end,i)-vout_t(1:end,i)))/lsb));
    title(str);
    
    if i<=3
        ylabel(strcat(sprintf('vout at %i',i),'\tau'));
    else
        ylabel('vout when fully settled');
    end
    ylim([min(vout_t(1:end,i)-vout_lin_fit(1:end,i)) max(vout_t(1:end,i)-vout_lin_fit(1:end,i))]);
end
xlabel('vin (nomalized)');
[ax,h]=suplabel('Inf Norm vout=f(vin_{norm})','t',SupAxes);
set(h,'FontSize',TitleLabelSize);
saveas(f,'InfNorm_vout_f(vin_norm)','jpg');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_fit=[];
f=figure('Name','Mean Square Fit: vin=f(vout_norm(t))');
set(f,'Position',[100,100,1049,2000]);
for i=1:4
    p_fit(1:fit_order+1,i)=polyfit(vout_t_norm(1:leng_data,i),vin_t(1:leng_data,i),fit_order);
    vin_fit(1:leng_data,i)=zeros(leng_data,1);
    str='fitting function: vin= ';
    for order=1:fit_order+1
        vin_fit(1:leng_data,i)=p_fit(order,i).*(vout_t_norm(1:end,i).^(fit_order+1-order))+vin_fit(1:leng_data,i);
        if p_fit(order,i)<0
            str=strcat(str,sprintf('%0.2evout^{%i}',p_fit(order,i),fit_order+1-order));
        else
            str=strcat(str,sprintf('+%0.2evout^{%i}',p_fit(order,i),fit_order+1-order));
        end
    end
    vin_lin_fit(1:leng_data,i)=zeros(leng_data,1);
    linear_fit(1:2,i)=polyfit(vout_t_norm(1:leng_data,i),vin_t(1:leng_data,i),1);
    for order=1:2
        vin_lin_fit(1:leng_data,i)=linear_fit(order,i).*(vout_t_norm(1:end,i).^(2-order))+vin_lin_fit(1:leng_data,i);
    end    
    subplot(4,1,i);
    plot(vout_t_norm(1:end,i),vin_t(1:end,i)-vin_lin_fit(1:end,i))
    leg1=legend(sprintf('residule with lin_{fit}=%0.3fvout_n+%0.3f',linear_fit(1:2,i)));
    set(leg1,'color','none');
    legend('boxoff');
    str=strcat(str,sprintf('\nfitting error=%0.2fLSB',max(abs(vin_fit(1:end,i)-vin_t(1:end,i)))/lsb));
    title(str);
    %title(sprintf('fitting function: vin_fit= %1f %1f %1f %1f %1f\nfitting error=%1fLSB', ...
    %p_fit(1:end,i),max(vin_fit(1:end,i)-vin_t(1:end,i))/lsb));
    ylabel('vin');
    if i<=3
        xlabel(strcat(sprintf('vout_{norm} at %i',i),'\tau'));
    else
        xlabel('vout_{norm} when fully settled');
    end
    ylim([min(vin_t(1:end,i)-vin_lin_fit(1:end,i)) max(vin_t(1:end,i)-vin_lin_fit(1:end,i))]);
end
[ax,h]=suplabel('MSQ fit: vin=f(vout_{norm})','t',SupAxes);
set(h,'FontSize',TitleLabelSize);
saveas(f,'MSQ_vin_f(vout_norm)','jpg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p_fit=[];
f=figure('Name','Mean Square Fit: vout(t)=f(vout_norm{full_settle})');
set(f,'Position',[100,100,1049,2000]);
for i=1:3
    p_fit(1:fit_order+1,i)=polyfit(vout_t_norm(1:leng_data,4),vout_t(1:leng_data,i),fit_order);
    vout_fit(1:leng_data,i)=zeros(leng_data,1);
    str='fitting function: vout= ';
    for order=1:fit_order+1
        vout_fit(1:leng_data,i)=p_fit(order,i).*(vout_t_norm(1:end,4).^(fit_order+1-order))+vout_fit(1:leng_data,i);
        if p_fit(order,i)<0
            str=strcat(str,sprintf('%0.2evfs^{%i}',p_fit(order,i),fit_order+1-order));
        else
            str=strcat(str,sprintf('+%0.2evfs^{%i}',p_fit(order,i),fit_order+1-order));
        end
    end
    vout_lin_fit(1:leng_data,i)=zeros(leng_data,1);
    linear_fit(1:2,i)=polyfit(vout_t_norm(1:leng_data,4),vout_t(1:leng_data,i),1);
    for order=1:2
        vout_lin_fit(1:leng_data,i)=linear_fit(order,i).*(vout_t_norm(1:end,4).^(2-order))+vout_lin_fit(1:leng_data,i);
    end    
    subplot(3,1,i);
    plot(vout_t_norm(1:end,4),vout_t(1:end,i)-vout_lin_fit(1:end,i))
    leg1=legend(sprintf('residule with lin_{fit}=%0.3fvout_{nfs}+%0.3f',linear_fit(1:2,i)));
    set(leg1,'color','none');
    legend('boxoff');
    str=strcat(str,sprintf('\nfitting error=%0.2fLSB',max(abs(vout_fit(1:end,i)-vout_t(1:end,i)))/lsb));
    title(str);
    %title(sprintf('fitting function: vin_fit= %1f %1f %1f %1f %1f\nfitting error=%1fLSB', ...
    %p_fit(1:end,i),max(vin_fit(1:end,i)-vin_t(1:end,i))/lsb));    
    ylabel(strcat(sprintf('vout at %i',i),'\tau'));  
    ylim([min(vout_t(1:end,i)-vout_lin_fit(1:end,i)) max(vout_t(1:end,i)-vout_lin_fit(1:end,i))]);
end
xlabel('vout_{norm} full settling');
[ax,h]=suplabel('MSQ fit: vout=f(vout_{fs norm})','t',SupAxes);
set(h,'FontSize',TitleLabelSize);
saveas(f,'MSQ_vout_f(vout_norm_fullsettle)','jpg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f=figure('Name','Inf Norm Fit: vout(t)=f(vout_fullsettle_norm)');
set(f,'Position',[100,100,1049,2000]);
for i=1:3
    a=vout_t_norm(1:leng_data,4);
    b=vout_t(1:end,i);
    A=[ones(100,1) a a.^2 a.^3 a.^4 a.^5 a.^6];
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
        vout_fit(1:leng_data,i)=zeros(leng_data,1);
    %p_fit(1:fit_order+1,i)=linprog(f,A_LP,vout_LP,[],[],LB,[]);
    str='fitting function: vout= ';
    for order=1:fit_order+1
        vout_fit(1:leng_data,i)=p_fit(order,i)*a.^(order-1)+vout_fit(1:leng_data,i);
        if p_fit(fit_order+2-order,i)<0
            str=strcat(str,sprintf('%0.2evfs^{%i}',p_fit(fit_order+2-order,i),fit_order+1-order));
        else
            str=strcat(str,sprintf('+%0.2evfs^{%i}',p_fit(fit_order+2-order,i),fit_order+1-order));
        end
    end
    vout_lin_fit(1:leng_data,i)=zeros(leng_data,1);
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
        vout_lin_fit(1:leng_data,i)=linear_fit(order,i).*(a.^(order-1))+vout_lin_fit(1:leng_data,i);
    end    
    subplot(3,1,i);
    plot(a,vout_t(1:end,i)-vout_lin_fit(1:end,i))
    leg1=legend(sprintf('residule with lin_{fit}=%0.3fvout_{nfs}+%0.3f',linear_fit(2,i),linear_fit(1,i)));
    set(leg1,'color','none');
    legend('boxoff');
    
    str=strcat(str,sprintf('\nfitting error=%0.2fLSB',max(abs(vout_fit(1:end,i)-vout_t(1:end,i)))/lsb));
    title(str);

    ylabel(strcat(sprintf('vout at %i',i),'\tau'));
    ylim([min(vout_t(1:end,i)-vout_lin_fit(1:end,i)) max(vout_t(1:end,i)-vout_lin_fit(1:end,i))]);
end
xlabel('vout (full settled)');
[ax,h]=suplabel('Inf Norm fit: vout=f(vout_{fs norm})','t',SupAxes);
set(h,'FontSize',TitleLabelSize);
saveas(f,'InfNorm_vout_f(vout_fullsettle_norm)','jpg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f=figure('Name','Inf Norm Fit: vin=f(vout_norm)');
set(f,'Position',[100,100,1049,2000]);
for i=1:4
    a=vout_t_norm(1:end,i);
    b=vin_t(1:end,i);
    A=[ones(100,1) a a.^2 a.^3 a.^4 a.^5 a.^6];
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
        vin_fit(1:leng_data,i)=zeros(leng_data,1);
    %p_fit(1:fit_order+1,i)=linprog(f,A_LP,vout_LP,[],[],LB,[]);
    str='fitting function: vin=';
    for order=1:fit_order+1
        vin_fit(1:leng_data,i)=p_fit(order,i)*a.^(order-1)+vin_fit(1:leng_data,i);
        if p_fit(fit_order+2-order,i)<0
            str=strcat(str,sprintf('%0.2evout^{%i}',p_fit(fit_order+2-order,i),fit_order+1-order));
        else
            str=strcat(str,sprintf('+%0.2evout^{%i}',p_fit(fit_order+2-order,i),fit_order+1-order));
        end
    end
    vin_lin_fit(1:leng_data,i)=zeros(leng_data,1);
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
        vin_lin_fit(1:leng_data,i)=linear_fit(order,i).*(a.^(order-1))+vin_lin_fit(1:leng_data,i);
    end    
    subplot(4,1,i);
    plot(a,vin_t(1:end,i)-vin_lin_fit(1:end,i));
    leg1=legend(sprintf('residule with lin_{fit}=%0.3fvout_n+%0.3f',linear_fit(2,i),linear_fit(1,i)));
    set(leg1,'color','none');
    legend('boxoff');
    
    str=strcat(str,sprintf('\nfitting error=%0.2fLSB',max(abs(vin_fit(1:end,i)-vin_t(1:end,i)))/lsb));
    title(str);
    ylabel('vin');
    if i<=3
        xlabel(strcat(sprintf('vout at %i',i),'\tau'));
    else
        xlabel('vout when fully settled');
    end  
    ylim([min(vin_t(1:end,i)-vin_lin_fit(1:end,i)) max(vin_t(1:end,i)-vin_lin_fit(1:end,i))]);
end
[ax,h]=suplabel('Inf Fit fit: vin=f(vout_{norm})','t',SupAxes);
set(h,'FontSize',TitleLabelSize);
saveas(f,'InfNorm_vin_f(vout_norm)','jpg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f=figure('Name','Inf Norm Fit: vin=f(vout)');
set(f,'Position',[100,100,1049,2000]);
for i=1:4
    a=vout_t(1:end,i);
    b=vin_t(1:end,i);
    A=[ones(100,1) a a.^2 a.^3 a.^4 a.^5 a.^6];
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
        vin_fit(1:leng_data,i)=zeros(leng_data,1);
    %p_fit(1:fit_order+1,i)=linprog(f,A_LP,vout_LP,[],[],LB,[]);
    str='fitting function: vin=';
    for order=1:fit_order+1
        vin_fit(1:leng_data,i)=p_fit(order,i)*a.^(order-1)+vin_fit(1:leng_data,i);
        if p_fit(fit_order+2-order,i)<0
            str=strcat(str,sprintf('%0.2evout^{%i}',p_fit(fit_order+2-order,i),fit_order+1-order));
        else
            str=strcat(str,sprintf('+%0.2evout^{%i}',p_fit(fit_order+2-order,i),fit_order+1-order));
        end
    end
    vin_lin_fit(1:leng_data,i)=zeros(leng_data,1);
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
        vin_lin_fit(1:leng_data,i)=linear_fit(order,i).*(a.^(order-1))+vin_lin_fit(1:leng_data,i);
    end    
    subplot(4,1,i);
    plot(a,vin_t(1:end,i)-vin_lin_fit(1:end,i));
    leg1=legend(sprintf('residule with lin_{fit}=%0.3fvout_n+%0.3f',linear_fit(2,i),linear_fit(1,i)));
    set(leg1,'color','none');
    legend('boxoff');
    
    str=strcat(str,sprintf('\nfitting error=%0.2fLSB',max(abs(vin_fit(1:end,i)-vin_t(1:end,i)))/lsb));
    title(str);
    ylabel('vin');
    if i<=3
        xlabel(strcat(sprintf('vout at %i',i),'\tau'));
    else
        xlabel('vout when fully settled');
    end  
    ylim([min(vin_t(1:end,i)-vin_lin_fit(1:end,i)) max(vin_t(1:end,i)-vin_lin_fit(1:end,i))]);
end
[ax,h]=suplabel('Inf Fit fit: vin=f(vout)','t',SupAxes);
set(h,'FontSize',TitleLabelSize);
saveas(f,'InfNorm_vin_f(vout)','jpg');

end