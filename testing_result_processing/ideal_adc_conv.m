%clear all;
%close all;
% normrnd('seed', 3)
clear all;
vin=1;
vrefp=1.25;
vrefn=0.75;
vcm=1;
v0=1;
C_unit=1; %pF
bit=11;
lsb=5;
msb=bit-lsb;
number_c=2^msb+2^lsb;


    c=0;
    cp=[1,2,4,8,16,1,2,4,8,16,30]*16;
    cn=[1,2,4,8,16,1,2,4,8,16,30]*16;
    cp_bridge=2*16;
    cn_bridge=2*16;
    cp_dummpy=1*16;
    cn_dummpy=1*16;
    
    cp_msb_gnd=25.27*1;
    cn_msb_gnd=25.27*1;
    cp_lsb_gnd=16.055*1;
    cn_lsb_gnd=16.124*1;
    cp=cp+[3.39623,6.472,12.639,25.317,46.477,3.396,6.472,12.89,25.2126,49.922,91.901];
    cn=cn+[3.6491,6.974,13.66,27.328,50.4657,3.649,6.974,13.889,27.224,53.968,99.431];
    cp_bridge=cp_bridge+6.44829;
    cn_bridge=cn_bridge+6.9498;
    cp_dummpy=cp_dummpy+3.39623;
    cn_dummpy=cn_dummpy+3.6491;
    ctot_p=sum(cp(lsb+1:bit))+cp_msb_gnd+1/(1/cp_bridge+1/(sum(cp(1:lsb))+cp_dummpy+cp_lsb_gnd));
    ctot_n=sum(cn(lsb+1:bit))+cn_msb_gnd+1/(1/cn_bridge+1/(sum(cn(1:lsb))+cn_dummpy+cn_lsb_gnd));
    clsb_p=sum(cp(1:lsb))+cp_dummpy+cp_lsb_gnd;
    clsb_n=sum(cn(1:lsb))+cn_dummpy+cn_lsb_gnd;
    for i=1:lsb;
        cp(i)=cp(i)/clsb_p/(1/cp_bridge+1/clsb_p);
        cn(i)=cn(i)/clsb_n/(1/cn_bridge+1/clsb_n);
    end
    weights=fliplr((cp+cn)/(ctot_p+ctot_n))*2^bit
    p=cp;
    n=cn;  

    %vx(1)=vcm-vin+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit))/ctot_p*vrefp;
 
    %vy(1)=vcm-v0+cn(bit)/ctot_n*vrefp+(ctot_n-cn(bit))/ctot_n*vrefn;
    vx(1)=vcm-vin+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit)-cp_lsb_gnd/clsb_p/(1/cp_bridge+1/clsb_p))/ctot_p*vrefp
    vy(1)=vcm-v0+cn(bit)/ctot_n*vrefp+(ctot_n-cn(bit)-cn_lsb_gnd/clsb_n/(1/cn_bridge+1/clsb_n))/ctot_n*vrefn

    for i=1:bit;
        if vx(i)>=vy(i);
            dout(i)=1;
            if i<bit;
                vx(i+1)=vx(i)-cp(bit-i)/ctot_p*vrefp+cp(bit-i)/ctot_p*vrefn;
                vy(i+1)=vy(i)-cn(bit-i)/ctot_n*vrefn+cn(bit-i)/ctot_n*vrefp;
                
            end
        else
            dout(i)=0;
            if i<bit;
                vx(i+1)=vx(i)+(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefp-(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefn;
                vy(i+1)=vy(i)+(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefn-(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefp;
            end
        end
%         d(k)=d(k)+2^(bit-i)*(1-dout(i));
    end

     vx
     vy
     dout
     vx-vy

  

    

    
