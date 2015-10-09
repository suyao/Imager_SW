clear all;
close all;
% fid=fopen('data/adc_tb/cmp_adc_layout_4n_dnl.csv');
% fgetl(fid);
% buffer=fread(fid, Inf);
% fclose(fid);
% fid=fopen('data/adc_tb/cmp_data.csv','w');
% fwrite(fid,buffer);
% fclose(fid);
% clear all;
% fid=fopen('data/adc_tb/cmp_adc_layout_4n_dnl2.csv');
% fgetl(fid);
% buffer=fread(fid, Inf);
% fclose(fid);
% fid=fopen('data/adc_tb/cmp_data2.csv','w');
% fwrite(fid,buffer);
% fclose(fid);
% clear all;
% fid=fopen('data/adc_tb/in_adc_layout_4n_dnl.csv');
% fgetl(fid);
% buffer=fread(fid, Inf);
% fclose(fid);
% fid=fopen('data/adc_tb/in_data.csv','w');
% fwrite(fid,buffer);
% fclose(fid);
% clear all;
% fid=fopen('data/adc_tb/in_adc_layout_4n_dnl2.csv');
% fgetl(fid);
% buffer=fread(fid, Inf);
% fclose(fid);
% fid=fopen('data/adc_tb/in_data2.csv','w');
% fwrite(fid,buffer);
% fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load sim output
clear all;
fid=importdata('data/adc_tb/cmp_data.csv');
fid2=importdata('data/adc_tb/cmp_data2.csv');
fin=importdata('data/adc_tb/in_data.csv');
fin2=importdata('data/adc_tb/in_data2.csv');
clk_per=4e-9; smp_per=20*clk_per;  fsig=7/128/smp_per;   %slow case when fs=250k fsig=2.5M

N=5000;
v0=1.15;
data_cmp=fid(:,2);
data_cmp2=fid2(:,2);
data_in=fin(:,2);
data2_in=fin2(:,2);
tr=fid(:,1);
bit=11;
lsb=5;
msb=bit-lsb;
number_c=2^msb+2^lsb;
t_start=24.8e-9+1*smp_per*2;
t_serial=61.5e-9-24.8e-9;
%3.3n
t_start=34e-9+smp_per*2;
t_serial=68e-9-t_start+smp_per*2;
%4n
t_start=28.1e-9+smp_per*2;
t_serial=82e-9-t_start+smp_per*2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% dac parameters
cp=[1,2,4,8,16,1,2,4,8,16,30]*16;
cn=[1,2,4,8,16,1,2,4,8,16,30]*16;
cp=cp+[3.39623,6.472,12.639,25.317,46.481,3.4,6.472,12.89,25.2126,49.922,91.901];
cn=cn+[3.64911,6.974,13.66,27.3285,50.4664,3.649,6.974,13.889,27.224,53.968,99.431];
cp_bridge=2*16;%you can change the ratio here to 2
cp_bridge=cp_bridge+6.44829;
cn_bridge=2*16;
cn_bridge=cn_bridge+6.9498;
cp_dummpy=1*16;
cp_dummpy=cp_dummpy+3.39623;
cn_dummpy=1*16;
cn_dummpy=cn_dummpy+3.64911;
cp_lsb_gnd=16.051;
cn_lsb_gnd=16.0746;

ctot_p=sum(cp(lsb+1:bit))+1/(1/cp_bridge+1/(sum(cp(1:lsb))+cp_dummpy+cp_lsb_gnd));
ctot_n=sum(cn(lsb+1:bit))+1/(1/cn_bridge+1/(sum(cn(1:lsb))+cn_dummpy+cn_lsb_gnd));
clsb_p=sum(cp(1:lsb))+cp_dummpy+cp_lsb_gnd;
clsb_n=sum(cn(1:lsb))+cn_dummpy+cn_lsb_gnd;
for i=1:lsb;
    cp(i)=cp(i)/clsb_p/(1/cp_bridge+1/clsb_p);
    cn(i)=cn(i)/clsb_n/(1/cn_bridge+1/clsb_n);
end
weights=fliplr((cp+cn)/(ctot_p+ctot_n));
weights=weights/weights(end)
num_levels=sum(weights)/weights(end)
vin_min=0.65;
%% generate dout,vin array
j=1;
for i=1:length(tr);
    if abs(tr(i)-t_start-(j-1)*smp_per)<=0.08*clk_per      
        vin(j)=data_in(i);
        vin2(j)=data2_in(i);
        j=j+1;
    end
end 
j=1;
k=1;
m=bit;
for i=1:length(tr);
    if tr(i)-t_start-t_serial-1*smp_per*(k-1)>0
        if tr(i)-t_start-t_serial-1*smp_per*(k-1)-(j-1)*clk_per<=0.1*clk_per && tr(i)-t_start-t_serial-1*smp_per*(k-1)-(j-1)*clk_per>=0
            tt(j)=tr(i);
            dig(j)=floor(abs(data_cmp(i)));
            dig2(j)=floor(abs(data_cmp2(i)));
            j=j+1;
            if j==bit+1;
                dout(k)=0;
                dout2(k)=0;
                t(k)=tt(1);
                 for j=1:bit
                     dout(k)=dout(k)+2^(bit-j)*dig(j);
                     dout2(k)=dout2(k)+2^(bit-j)*dig2(j);
                 end

                d_adc(k)=dig*weights';
                d_adc2(k)=dig2*weights';
                j=1;
                k=k+1;
            end

        end
    end
end

figure;
plot(dout(1:N),vin(1:N));
hold on;
plot(dout2(1:N),vin2(1:N));

%% combine vin and vin2, dout and out2
k=4803; %vin(4804)=vin2(1);
for i=1:N
    vin(i+k)=vin2(i);
    dout(i+k)=dout2(i);
    d_adc(i+k)=d_adc2(i);
end
vin_dnl=vin;
dout_dnl=dout/2;
dout_dnl_cali=d_adc;
dout=fliplr(dout);
vin=fliplr(vin);
%% find weights
k=1;
for i=1:length(dout)
    if dout(i)>=2^(k-1)
        dout(i)
        vin(i)
        c(k)=(v0+0.5-vin(i))*2^bit;
        k=k+1;
        if k==bit+1
            break;
        end
    end
end
c=c/c(1);
weights=fliplr(c);

%% compute dnl
j=0;
for i=1:N-1
    if dout_dnl_cali(i+1)<dout_dnl_cali(i)-0.35
        if j==0
            vin_edge=vin_dnl(i+1);
            j=j+1;
        else          
            w_cali(j)=vin_dnl(i+1)-vin_edge;
            vin_edge=vin_dnl(i+1);
            edge(j)=vin_edge;
            j=j+1;
        end
%     else
%         dout_dnl_cali(i+1)=dout_dnl_cali(i);
    end
end

w_avg_cali=sum(w_cali)/length(w_cali);
for i=1:j-1
    dnl_cali(i)=(w_cali(i)-w_avg_cali)/w_avg_cali;
end

j=0;
for i=1:N-1
    if dout_dnl(i+1)<dout_dnl(i)-0.35
        if j==0
            vin_edge=vin_dnl(i+1);
            j=j+1;
        else          
            w(j)=vin_dnl(i+1)-vin_edge;
            vin_edge=vin_dnl(i+1);
            edge(j)=vin_edge;
            j=j+1;
        end
    end
end
w_avg=sum(w)/length(w);
k=0;
for i=1:j-1
    dnl(i)=(w(i)-w_avg)/w_avg;

end
% num_levels=k
figure;
plot(1:length(dnl),dnl);
hold on;
plot(1:length(dnl_cali),dnl_cali,'r');
title(sprintf('DNL=+ %1.3f / %1.3f LSB w/o cali /n DNL=+ %1.3f / %1.3f LSB w cali',max(dnl),min(dnl),max(dnl_cali),min(dnl_cali)));
% INL
inl(1)=0;
for i=2:length(dnl)
    inl(i)=sum(dnl(1:i-1));
end
inl_cali(1)=0;
for i=2:length(dnl_cali)
    inl_cali(i)=sum(dnl_cali(1:i-1));
end
figure;
plot(1:length(inl),inl);
hold on;
plot(1:length(inl_cali),inl_cali,'r');
title(sprintf('INL=+ %1.3f / %1.3f LSB w/o cali /n INL=+ %1.3f / %1.3f LSB w cali',max(inl),min(inl),max(inl_cali),min(inl_cali)));
figure;
stairs(vin_dnl,dout_dnl);
hold on;
stairs(vin_dnl,dout_dnl_cali,'r');
%stairs(vin_dnl,fliplr(dout_dnl_cali_raw)*1067/max(dout_dnl_cali_raw),'g');
figure;
hist(w)
%plot(1:length(w),w);

    
        
        
        
        
        
        