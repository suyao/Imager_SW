%clear all;
%close all;
% normrnd('seed', 3)
clear all;
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
for vin = 0.50:1e-4:0.55
    
    cp = [1.0000    2.0000    3.875    7.7500   14.8750   16.2500   32.0000 64.3750  128.3750  256.3750  481.7500];
    cn = cp;
    ctot_p=sum(cp)+1;
    ctot_n = ctot_p;

    %vx(1)=vcm-vin+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit))/ctot_p*vrefp;
 
    %vy(1)=vcm-v0+cn(bit)/ctot_n*vrefp+(ctot_n-cn(bit))/ctot_n*vrefn;
    vx(1)=vcm-vin+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit))/ctot_p*vrefp
    vy(1)=vcm-v0+cn(bit)/ctot_n*vrefp+(ctot_n-cn(bit))/ctot_n*vrefn

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
 

  

    

    
