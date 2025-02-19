clear all;
close all;
vin=1;
vrefp=1.25;
vrefn=0.75;
vcm=1;
v0=1;
cp = [1 1.875 4 7.875 14.75 15.875 31.75 65.875 127.375 255 480.5];
cp = [1 2 4 8 14.75 15.875 31.75 65.875 127.375 255 480.5];
cp = [1 2 3.875 7.625 14.875 16.25 32 64.125 127.875 255.875 481.75];
cn = cp;
ctot_p = sum(cp) +1;
ctot_n = ctot_p;
noise_sigma = 0.2e-3;
bit=11;
lsb=5;
msb=bit-lsb;
number_c=2^msb+2^lsb+1;%lsb:[1 1 2 4 8 16]; msb[1 2 4 8 16 30] bridge:2
b_extra=3; % extra bits for foreground cali
N=bit+b_extra;

    j=1;
    k=0;
    while j<=bit;
        din=k;
        vin=(din/2^N)*2*(vrefp-vrefn)+v0-(vrefp-vrefn)+normrnd(0,0.2e-3);
        vx(1)=vcm-vin+cp(bit)/ctot_p*vrefp+(ctot_p-cp(bit))/ctot_p*vrefn;
        vy(1)=vcm-v0+cn(bit)/ctot_n*vrefn+(ctot_n-cn(bit))/ctot_n*vrefp;
        for i=1:bit;

            if vx(i)>=vy(i);
                dout(i)=0;
                if i<bit;
                    vx(i+1)=vx(i)-(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefp+(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefn;
                    vy(i+1)=vy(i)-(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefn+(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefp;
                end
            else
                dout(i)=1;
                if i<bit;
                    vx(i+1)=vx(i)+cp(bit-i)/ctot_p*vrefp-cp(bit-i)/ctot_p*vrefn;
                    vy(i+1)=vy(i)+cn(bit-i)/ctot_n*vrefn-cn(bit-i)/ctot_n*vrefp;
                end
            end
        end
        dout_dec=0;
        for i=1:bit;
            dout_dec=dout_dec+2^(bit-i)*dout(i);
        end
        %dout_dec
        if dout_dec>=2^(j-1);
            c(j)=din/2^b_extra;
    %         if 2^b_extra*2^(j-1)-201>=1
    %             k=k+2^b_extra*2^(j-1)-201;
    %         end
            j=j+1;
        else
            k=k+1;
        end
    end
    c
    NN=256;
    for j=1:NN;
        vin_test(j)=0.5*sin(2*pi*j/NN)+v0+normrnd(0,noise_sigma);
        vx(1)=vcm-vin_test(j)+cp(bit)/ctot_p*vrefp+(ctot_p-cp(bit))/ctot_p*vrefn;
        vy(1)=vcm-v0+cn(bit)/ctot_n*vrefn+(ctot_n-cn(bit))/ctot_n*vrefp;
        for i=1:bit;
            if vx(i)>=vy(i);
                dout(i)=0;
                if i<bit;
                    vx(i+1)=vx(i)-(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefp+(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefn;
                    vy(i+1)=vy(i)-(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefn+(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefp;
                end
            else
                dout(i)=1;
                if i<bit;
                    vx(i+1)=vx(i)+cp(bit-i)/ctot_p*vrefp-cp(bit-i)/ctot_p*vrefn;
                    vy(i+1)=vy(i)+cn(bit-i)/ctot_n*vrefn-cn(bit-i)/ctot_n*vrefp;
                end
            end
        end
        dout_dec=0;
        for i=1:bit;
            dout_dec=dout_dec+2^(bit-i)*dout(i);
        end
        dout_test(j)=dout_dec/2^bit;
        dout_rev(j)=floor(dout*(fliplr(c))')/2^bit;
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
    sndr_ori(1)=sndrdb;

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
    sndr_cor(1)=sndrdb;

NN=1024*4;
for j=1:NN;
    vin_test(i)=v0-(vrefp-vrefn)+j/NN+normrnd(0,350e-6);
    vx(1)=vcm-vin_test(i)+cp(bit)/ctot_p*vrefp+(ctot_p-cp(bit))/ctot_p*vrefn;
    vy(1)=vcm-v0+cn(bit)/ctot_n*vrefn+(ctot_n-cn(bit))/ctot_n*vrefp;
    for i=1:bit;
        if vx(i)>=vy(i);
            dout(i)=0;
            if i<bit;
                vx(i+1)=vx(i)-(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefp+(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefn;
                vy(i+1)=vy(i)-(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefn+(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefp;
            end
        else
            dout(i)=1;
            if i<bit;
                vx(i+1)=vx(i)+cp(bit-i)/ctot_p*vrefp-cp(bit-i)/ctot_p*vrefn;
                vy(i+1)=vy(i)+cn(bit-i)/ctot_n*vrefn-cn(bit-i)/ctot_n*vrefp;
            end
        end
    end
    dout_dec=0;
    for i=1:bit;
        dout_dec=dout_dec+2^(bit-i)*dout(i);
    end
    dout_test(j)=dout_dec;
    dout_rev(j)=floor(dout*(fliplr(c))');
end  
 figure;
 stairs(1:NN,dout_test);
 hold on;
 stairs(1:NN,dout_rev,'r');
 xlabel('vin');
 ylabel('dout');
 xlim([1 NN]);
 legend('Dout','Dout_{Cali}');
% figure;
% bar(1:m,sndr_cor,'r');
% hold on;
% bar(1:m,sndr_ori);
% 
% cor_mean=sum(sndr_cor)/M
% stdev_cor = sqrt(sum((sndr_cor-cor_mean).^2/M))
% ori_mean=sum(sndr_ori)/M
% stdev_ori = sqrt(sum((sndr_ori-ori_mean).^2/M))