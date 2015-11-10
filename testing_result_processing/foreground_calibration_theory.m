clear all;
close all;
% normrnd('seed', 3)
vin=1;
vrefp=1.25;
vrefn=0.75;
vcm=1;
v0=1;

C_unit=16; %pF
sigma=0.64/C_unit;
sigma=0.04;
bit=11;
lsb=5;
msb=bit-lsb;
number_c=2^msb+2^lsb+1;%lsb:[1 1 2 4 8 16]; msb[1 2 4 8 16 30] bridge:2
b_extra=4; % extra bits for foreground cali
N=bit+b_extra;
M=1;
for m=1:M;
    % add mismatch factors to dac array
    delta_p=normrnd(C_unit,1*sigma*C_unit,[1 number_c]);
    delta_n=normrnd(C_unit,1*sigma*C_unit,[1 number_c]);
    for i=1:lsb;
        cp(i)=sum(delta_p(2^(i-1):(2^(i)-1)));
        cn(i)=sum(delta_n(2^(i-1):(2^(i)-1)));
    end
    cp(lsb)=sum(delta_p(2^(lsb-1):(2^(lsb)-2))); %make sure c6>c5_eff
    cn(lsb)=sum(delta_n(2^(lsb-1):(2^(lsb)-2)));
    cp_bridge=sum(delta_p(end-2:end-1));
    cn_bridge=sum(delta_n(end-2:end-1));
    cp_dummpy=delta_p(end);
    cn_dummpy=delta_n(end);
    for i=1:msb;
        cp(i+lsb)=sum(delta_p(2^(i-1)+2^lsb-1:(2^(i)-1)+2^lsb-1));
        cn(i+lsb)=sum(delta_n(2^(i-1)+2^lsb-1:(2^(i)-1)+2^lsb-1));
    end
    ctot_p=sum(cp(lsb+1:bit))+1/(1/cp_bridge+1/(sum(cp(1:lsb))+cp_dummpy));
    ctot_n=sum(cn(lsb+1:bit))+1/(1/cn_bridge+1/(sum(cn(1:lsb))+cn_dummpy));
    clsb_p=sum(cp(1:lsb))+cp_dummpy;
    clsb_n=sum(cn(1:lsb))+cn_dummpy;
    for i=1:lsb;
        cp(i)=cp(i)/clsb_p/(1/cp_bridge+1/clsb_p);
        cn(i)=cn(i)/clsb_n/(1/cn_bridge+1/clsb_n);
    end
     cp = [1   2   3.875    7.6250  14.75   16   31.75 63.5  127.3750  255.1250  480.6250];
    % cn =  [  1    2    3.75   7.6250   14.8750   16.2500   32.1250 64.5000  128.1250  256.1250  481.5];
     cn = cp;
     ctot_p = sum(cp)+1;
     ctot_n = sum(cn)+1;
    p(m,:)=cp;
    n(m,:)=cn;
    j=1;
    k=0;
    k=2^N+1;
    pp=0;
    while j<=bit;

        pp=pp+1;
        din=k;
        vin=(din/2^N)*2*(vrefp-vrefn)+v0-(vrefp-vrefn);
%         vx(1)=vcm-vin+cp(bit)/ctot_p*vrefp+(ctot_p-cp(bit))/ctot_p*vrefn;
%         vy(1)=vcm-v0+cn(bit)/ctot_n*vrefn+(ctot_n-cn(bit))/ctot_n*vrefp;
        vx(1)=vcm-vin+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit))/ctot_p*vrefp;
        vy(1)=vcm-v0+cn(bit)/ctot_n*vrefp+(ctot_n-cn(bit))/ctot_n*vrefn;        
        for i=1:bit;

            if vx(i)>=vy(i);
                dout(i)=0;
                if i<bit;
%                     vx(i+1)=vx(i)-(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefp+(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefn;
%                     vy(i+1)=vy(i)-(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefn+(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefp;
                    vx(i+1)=vx(i)-cp(bit-i)/ctot_p*vrefp+cp(bit-i)/ctot_p*vrefn;
                    vy(i+1)=vy(i)-cn(bit-i)/ctot_n*vrefn+cn(bit-i)/ctot_n*vrefp;
                end
            else
                dout(i)=1;
                if i<bit;
%                     vx(i+1)=vx(i)+cp(bit-i)/ctot_p*vrefp-cp(bit-i)/ctot_p*vrefn;
%                     vy(i+1)=vy(i)+cn(bit-i)/ctot_n*vrefn-cn(bit-i)/ctot_n*vrefp;
                    vx(i+1)=vx(i)+(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefp-(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefn;
                    vy(i+1)=vy(i)+(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefn-(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefp;
                end
            end
        end
       
        dout_dec=0;
        for i=1:bit;
            
            dout_dec=dout_dec+2^(bit-i)*dout(i);
        end
        din_val(pp)=dout_dec;
%         dout_dec
        if (2047-dout_dec)==2^(j-1);
           c(j)=din; 
%             c(j)=(din-1)/2^(b_extra);

            j=j+1;
        else
%             k=k+1;
            k = k-1;
        end

    end
    
     c=c(1)-c+2^(b_extra+1);
     c=c/c(1)*2;
     c= c-c(1)+c(2)-c(1)
    
    NN=1024;
    for j=1:NN;
        vin_test(j)=0.5*sin(2*pi*j/NN)+v0;
        vx(1)=vcm-vin_test(j)+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit))/ctot_p*vrefp;
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
        dout_dec=0;
        for i=1:bit;
            dout_dec=dout_dec+2^(bit-i)*dout(i);
        end
        dout_test(j)=dout_dec/2^bit;
        dout_rev(j)=dout*(fliplr(c))'/(sum(c)+c(1));
    end  
     figure;
     plot(dout_test);
     hold on;
     plot(dout_rev,'r');
    dout_ideal=dec2bin((vin-0.15)*2^bit)
    %c

    spectrum = abs(fft(dout_test(1:end)));
    spectrum = 2/NN*spectrum(1:NN/2+1);
    spectrum(1)=0;
    spectrumdb = 20*log10(spectrum+eps);
    frequency = 1/NN * (0:length(spectrumdb)-1);

    [fund, fundidx] = max(spectrum);
    funddb=20*log10(fund);
    spec_nodc_nofund = [spectrum(2:fundidx-1); spectrum(fundidx+1:end)];
    [spur, spuridx] = max (spec_nodc_nofund);
    
    sfdrdb = funddb-20*log10(spur);
    sndr = norm(fund)/norm(spec_nodc_nofund);
    sndrdb=20*log10(sndr);
    funddb=20*log10(norm(fund));
    nofunddb=20*log(norm(spec_nodc_nofund));
    norm(fund);
    norm(spec_nodc_nofund);
    HD2=spectrumdb(2*8);
    HD3=spectrumdb(3*8);
    HD4=spectrumdb(4*8);
    figure;
    plot(frequency, spectrumdb, '*-', 'linewidth', 2);
    string1=sprintf('w/o cali SDR=%0.3gdB',sndrdb);
%     string = sprintf('Fundamental=%0.3gdBV, SNDR=%0.3gdB, SFDR=%0.3gdB \n HD2=%0.3gdBV, HD3=%0.3gdBV, HD4=%0.3gdBV', funddb, sndrdb, sfdrdb, HD2, HD3, HD4)
%     title(string);
    xlabel('Frequency [f/fs]');
    ylabel('Amplitude [dBV]');
    axis([0 0.5 -120 0]);
    grid;
    sndr_ori(m)=sndrdb;

    spectrum = abs(fft(dout_rev(1:end)));
    spectrum = 2/NN*spectrum(1:NN/2+1);
    spectrum(1)=0;
    spectrumdb = 20*log10(spectrum+eps);
    frequency = 1/NN * (0:length(spectrumdb)-1);

    [fund, fundidx] = max(spectrum);
    funddb=20*log10(fund);
    spec_nodc_nofund = [spectrum(2:fundidx-1); spectrum(fundidx+1:end)];
    [spur, spuridx] = max (spec_nodc_nofund);
    
    sfdrdb = funddb-20*log10(spur);
    sndr = norm(fund)/norm(spec_nodc_nofund);
    sndrdb=20*log10(sndr);
    funddb=20*log10(norm(fund));
    nofunddb=20*log(norm(spec_nodc_nofund));
    norm(fund);
    norm(spec_nodc_nofund);
    HD2=spectrumdb(2*8);
    HD3=spectrumdb(3*8);
    HD4=spectrumdb(4*8);
    spectrumdb_rec=spectrumdb;
%     figure;
    hold on;
    plot(frequency, spectrumdb_rec, '*-r', 'linewidth', 2);
    string2=sprintf('w cali SDR=%0.3gdB',sndrdb);
    h=legend(string1,string2,'fontweight','bold','fontSize',13);
    set(h,'FontSize',12,'fontweight','bold');
%     string = sprintf('Fundamental=%0.3gdBV, SNDR=%0.3gdB, SFDR=%0.3gdB \n HD2=%0.3gdBV, HD3=%0.3gdBV, HD4=%0.3gdBV', funddb, sndrdb, sfdrdb, HD2, HD3, HD4)
%     title(string);
    xlabel('Frequency [f/fs]','fontweight','bold','fontSize',13);
    ylabel('Amplitude [dBV]','fontweight','bold','fontSize',13);

    axis([0 0.5 -120 0]);
    sndr_cor(m)=sndrdb;
end

NN=9000;
sigma =0.25e-3;
%sigma = 0;
clear vin_test dout_test ana_rev dout_rev;
for j=1:NN;  
    vin_test(j)=v0-(vrefp-vrefn)+j/NN;
    for k = 1:50
        vx(1)=vcm-vin_test(j)+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit))/ctot_p*vrefp+normrnd(0,sigma);
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

        dout_dec=0;
        for i=1:bit;
            dout_dec=dout_dec+2^(bit-i)*dout(i);
        end
        dout_test(j,k)=dout_dec;
        ana_rev(j,k)=dout*(fliplr(c))'/(sum(c)+c(1))+v0-(vrefp-vrefn);
        dout_rev(j,k)=floor(dout*(fliplr(c))');
    end 
    ana_rev_avg(j) = mean(ana_rev(j,:));
    dout_test_avg(j)=mean(dout_test(j,:));
    dout_rev_avg(j)=mean(dout_rev(j,:));
end
 lsb = 1/(sum(c)/2+1);
 figure;
 subplot(3,1,1);
 stairs(vin_test,dout_test_avg);
 hold on;
 stairs(vin_test,dout_rev_avg,'r');
 ylabel('dout','FontSize',18); 
 legend('Dout','Dout_{Cali}');
 subplot(3,1,2);
 error = (vin_test-ana_rev_avg)/lsb;
 plot(vin_test,error);
 ylabel('vin - vout_{cali} / LSB','FontSize',18);
 title(sprintf('Error is %0.3g LSB',(max(abs(error)))),'FontSize',18);
 subplot(3,1,3);
 error_diff = error(2:end)-error(1:end-1);
 plot(vin_test(2:end),error_diff);
 title(sprintf('Error DNL =%0.3g LSB',max(abs(error_diff))),'FontSize',18);
 xlabel('vin /v','FontSize',18);
 c2=c/sum(c)*(sum(c)+c(1));
 cp = c/c(1); cn = cp; ctot_p=sum(cp)+cp(1); ctot_n=ctot_p;
for j=1:NN;
    vin_test(j)=v0-(vrefp-vrefn)+j/NN;
    vx(1)=vcm-vin_test(j)+cp(bit)/ctot_p*vrefn+(ctot_p-cp(bit))/ctot_p*vrefp;
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

    dout_dec=0;
    for i=1:bit;
        dout_dec=dout_dec+2^(bit-i)*dout(i);
    end
    dout_rec(j)=dout_dec;
    %ana_rev(j)=dout*(fliplr(c))'/(sum(c)+c(1))+v0-(vrefp-vrefn);
    %dout_rev(j)=floor(dout*(fliplr(c))');
end 

figure;
stairs(vin_test,dout_test);
hold on;
stairs(vin_test,dout_rec,'r');
 