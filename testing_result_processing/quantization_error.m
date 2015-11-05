clear all;
close all;
cp= [1 2 4 8 16 32 64 128 256 512 1024];
cp = [1   2   3.875    7.6250  14.75   16   31.75 63.5  127.3750  255.1250  480.6250];
cn = cp;
ctot_p = 1+sum(cp); ctot_n= ctot_p;
vrefp=1.25;
vrefn = 0.75;
v0 = 1;
vcm = 1;
weight = cp/ctot_p;
lsb = 1/ctot_p;
bit = 11;
N=4738;
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
plot((vin-vin_rec)/lsb);
max_error=max((vin-vin_rec)/lsb)
ylabel('Error/LSB');
