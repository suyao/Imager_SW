%clear all;
%close all;
% normrnd('seed', 3)
clear dout;
%vin=0.52204;
vin=0.5234;
vrefp=1.25;
vrefn=0.75;
vcm=1;
v0=1;
C_unit=1; %pF
bit=11;
lsb=5;
msb=bit-lsb;
number_c=2^msb+2^lsb;
figure;
hold on;

    cp = [1 2 4 8 16 17 34 68 136 272 510];
    cp = [1.0000    2.0000    3.875    7.7500   14.8750   16.2500   32.0000 64.3750  128.3750  256.3750  481.7500];
    cp = [1 2 4 7.7500   14.8750  1.8824*8 1.8824*16 1.8824*32 1.8824*64 1.8824*128 1.8824*256]
    cp = [  1    2    3.75   7.6250   14.8750   16.2500   32.1250 64.5000  128.1250  256.1250  481.5]
    cp = [1   2   3.875    7.6250  14.75   16   31.75 63.5  127.3750  255.1250  480.6250]

    cn = cp;
    ctot_p=sum(cp)+1;
    ctot_n = ctot_p;
for vin = 0.5:1e-5:0.52
    %vx(1)=vcm-vin+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit))/ctot_p*vrefp;
 
    %vy(1)=vcm-v0+cn(bit)/ctot_n*vrefp+(ctot_n-cn(bit))/ctot_n*vrefn;
    vx(1)=vcm-vin+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit))/ctot_p*vrefp;
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
     %    d(k)=d(k)+2^(bit-i)*(1-dout(i));
    end
    d = bi2de(fliplr(dout));
    plot(vin,d);
end
% stairs(1:length(vx),vx);
% hold on;
% stairs(1:length(vy),vy,'r');
%  

  

    

    
