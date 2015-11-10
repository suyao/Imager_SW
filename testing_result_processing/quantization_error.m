clear all;
%close all;
cp= [1 2 4 8 16 32 64 128 256 512 1024];
%cp = [1   2   3.875    7.6250  14.75   16   31.75 63.5  127.3750  255.1250  480.6250];
cp = [1.0000    1.8750    3.9375    7.6875   14.9062 16.2500   32.0625   64.2500  127.9062  255.8125 480.9688];
cn = cp;
%cn =  [  1    2    3.75   7.6250   14.8750   16.2500   32.1250 64.5000  128.1250  256.1250  481.5];
ctot_p = 1+sum(cp); 
ctot_n = 1+sum(cn);
vrefp=1.25;
vrefn = 0.75;
v0 = 1;
vcm = 1;
weight = cp/ctot_p;
%c =[2    4    7.875  15.5  30 32.5 64.6250  129.3750  259.6250  520 979.75];
%weight = c/(sum(c)+c(1));
lsb = 1/ctot_p;
bit = 11;
N=1024*8;
for k=1:N;
    vin(k) = k /N+v0-(vrefp-vrefn);
    vx(1)=vcm-vin(k)+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit))/ctot_p*vrefp;
    vy(1)=vcm-v0+cn(bit)/ctot_n*vrefp+(ctot_n-cn(bit))/ctot_n*vrefn;

    for i=1:bit;
        if vx(i)>=vy(i);
            dout(i)=0;
            if i<bit;
                vx(i+1)=vx(i)-cp(bit-i)/ctot_p*vrefp+cp(bit-i)/ctot_p*vrefn;
                vy(i+1)=vy(i)-cn(bit-i)/ctot_n*vrefn+cn(bit-i)/ctot_n*vrefp;
                
            end
        else
            dout(i)=1;
            if i<bit;
                vx(i+1)=vx(i)+(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefp-(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefn;
                vy(i+1)=vy(i)+(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefn-(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefp;
            end
        end
        
        
    end
    dout_dec(k)=0;
    for i=1:bit;
        dout_dec(k)=dout_dec(k)+2^(bit-i)*dout(i);
    end
    vin_rec(k) = dout*(fliplr(weight))'+v0-(vrefp-vrefn);
end
figure;
subplot(2,1,1);
plot((vin-vin_rec)/lsb);
max_error=max((vin-vin_rec)/lsb)
ylabel('Error/LSB');
title(sprintf('Max Error = %0.3gLSB',max_error));
subplot(2,1,2);
plot(vin,dout_dec);
