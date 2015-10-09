function weight= adc_calibration()
    clear all;
    vin=1;
    vrefp=1.25;
    vrefn=0.75;
    vcm=1;
    v0=1;
    fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_output_b3.txt','r');
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_output_cali0_3b.txt','r');
    f = fscanf(fin, '%i %x' ,[2 inf]);
    din = f(1,:);
    dout = f(2,:);
    d0 = din(1);
    r = 1; c =1;
    data(1,1) = din(1);
    for i = 1: length(din)
        if din(i) == d0
            c = c + 1;
        else
            r = r + 1;
            data(r ,1) = din(i); 
            d0 = din(i);
            c = 2;
        end
        data(r,c) = dout (i);   
    end

    [r,c] = size(data);
    data_mean(:,1) = data(:,1);
    data_maj(:,1) = data(:,1);
    for i = 1:r
        data_mean(i,2) = mean(data(i,2:end));
        data_maj(i,2) = mode(data(i,2:end));
    end

    figure;
    plot(data_mean(:,1),data_mean(:,2));
    hold on;
    plot(data_maj(:,1),data_maj(:,2),'r');

    k = 1;
    for i = r:-1:1;
        if (2047-data_maj(i,2)) >= 2^(k-1);
            key(k) = data_maj(i,1);
            value(k) = data_maj(i,2);
            k = k +1;
        end
    end

    key = key(1) - key + 2^5;

    for bit = 1:11;
        weight(bit) = key(bit) / 2 ^5;
    end
weight


% C_unit=16; %pF
% sigma=0.64/C_unit;
% sigma=0.04;
% bit=11;
% lsb=5;
% msb=bit-lsb;
% number_c=2^msb+2^lsb+1;%lsb:[1 1 2 4 8 16]; msb[1 2 4 8 16 30] bridge:2
% b_extra=3; % extra bits for foreground cali
% N=bit+b_extra;
% M=1;
% for m=1:M;
%     % add mismatch factors to dac array
%     delta_p=normrnd(C_unit,1*sigma*C_unit,[1 number_c]);
%     delta_n=normrnd(C_unit,1*sigma*C_unit,[1 number_c]);
%     for i=1:lsb;
%         cp(i)=sum(delta_p(2^(i-1):(2^(i)-1)));
%         cn(i)=sum(delta_n(2^(i-1):(2^(i)-1)));
%     end
%     cp(lsb)=sum(delta_p(2^(lsb-1):(2^(lsb)-2))); %make sure c6>c5_eff
%     cn(lsb)=sum(delta_n(2^(lsb-1):(2^(lsb)-2)));
%     cp_bridge=sum(delta_p(end-2:end-1));
%     cn_bridge=sum(delta_n(end-2:end-1));
%     cp_dummpy=delta_p(end);
%     cn_dummpy=delta_n(end);
%     for i=1:msb;
%         cp(i+lsb)=sum(delta_p(2^(i-1)+2^lsb-1:(2^(i)-1)+2^lsb-1));
%         cn(i+lsb)=sum(delta_n(2^(i-1)+2^lsb-1:(2^(i)-1)+2^lsb-1));
%     end
%     ctot_p=sum(cp(lsb+1:bit))+1/(1/cp_bridge+1/(sum(cp(1:lsb))+cp_dummpy));
%     ctot_n=sum(cn(lsb+1:bit))+1/(1/cn_bridge+1/(sum(cn(1:lsb))+cn_dummpy));
%     clsb_p=sum(cp(1:lsb))+cp_dummpy;
%     clsb_n=sum(cn(1:lsb))+cn_dummpy;
%     for i=1:lsb;
%         cp(i)=cp(i)/clsb_p/(1/cp_bridge+1/clsb_p);
%         cn(i)=cn(i)/clsb_n/(1/cn_bridge+1/clsb_n);
%     end
% %     cp
% %     cn
%     p(m,:)=cp;
%     n(m,:)=cn;
%     j=1;
%     k=0;
%     while j<=bit;
%         din=k;
%         vin=(din/2^N)*(vrefp-vrefn)+v0-(vrefp-vrefn);
%         vx(1)=vcm-vin+cp(bit)/ctot_p*vrefp+(ctot_p-cp(bit))/ctot_p*vrefn;
%         vy(1)=vcm-v0+cn(bit)/ctot_n*vrefn+(ctot_n-cn(bit))/ctot_n*vrefp;
%         for i=1:bit;
% 
%             if vx(i)>=vy(i);
%                 dout(i)=0;
%                 if i<bit;
%                     vx(i+1)=vx(i)-(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefp+(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefn;
%                     vy(i+1)=vy(i)-(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefn+(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefp;
%                 end
%             else
%                 dout(i)=1;
%                 if i<bit;
%                     vx(i+1)=vx(i)+cp(bit-i)/ctot_p*vrefp-cp(bit-i)/ctot_p*vrefn;
%                     vy(i+1)=vy(i)+cn(bit-i)/ctot_n*vrefn-cn(bit-i)/ctot_n*vrefp;
%                 end
%             end
%         end
%         dout_dec=0;
%         for i=1:bit;
%             dout_dec=dout_dec+2^(bit-i)*dout(i);
%         end
%         if dout_dec==2^(j-1);
%             c(j)=din/2^b_extra;
%     %         if 2^b_extra*2^(j-1)-201>=1
%     %             k=k+2^b_extra*2^(j-1)-201;
%     %         end
%             j=j+1;
%         else
%             k=k+1;
%         end
% 
%     end
%     NN=256;
%     for j=1:NN;
%         vin_test(j)=0.5*sin(2*pi*j/NN)+v0;
%         vx(1)=vcm-vin_test(j)+cp(bit)/ctot_p*vrefp+(ctot_p-cp(bit))/ctot_p*vrefn;
%         vy(1)=vcm-v0+cn(bit)/ctot_n*vrefn+(ctot_n-cn(bit))/ctot_n*vrefp;
%         for i=1:bit;
%             if vx(i)>=vy(i);
%                 dout(i)=0;
%                 if i<bit;
%                     vx(i+1)=vx(i)-(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefp+(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefn;
%                     vy(i+1)=vy(i)-(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefn+(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefp;
%                 end
%             else
%                 dout(i)=1;
%                 if i<bit;
%                     vx(i+1)=vx(i)+cp(bit-i)/ctot_p*vrefp-cp(bit-i)/ctot_p*vrefn;
%                     vy(i+1)=vy(i)+cn(bit-i)/ctot_n*vrefn-cn(bit-i)/ctot_n*vrefp;
%                 end
%             end
%         end
%         dout_dec=0;
%         for i=1:bit;
%             dout_dec=dout_dec+2^(bit-i)*dout(i);
%         end
%         dout_test(j)=dout_dec/2^bit;
%         dout_rev(j)=floor(dout*(fliplr(c))')/2^bit;
%     end  
%      figure;
%      plot(dout_test);
%      hold on;
%      plot(dout_rev,'r');
%     dout_ideal=dec2bin((vin-0.15)*2^bit)
%     %c
% 
%     spectrum = abs(fft(dout_test(1:end)));
%     spectrum = 2/NN*spectrum(1:NN/2+1);
%     spectrum(1)=0;
%     spectrumdb = 20*log10(spectrum+eps);
%     frequency = 1/NN * (0:length(spectrumdb)-1);
% 
%     [fund, fundidx] = max(spectrum);
%     funddb=20*log10(fund);
%     spec_nodc_nofund = [spectrum(2:fundidx-1); spectrum(fundidx+1:end)];
%     [spur, spuridx] = max (spec_nodc_nofund);
%     
%     sfdrdb = funddb-20*log10(spur);
%     sndr = norm(fund)/norm(spec_nodc_nofund);
%     sndrdb=20*log10(sndr);
%     funddb=20*log10(norm(fund));
%     nofunddb=20*log(norm(spec_nodc_nofund));
%     norm(fund);
%     norm(spec_nodc_nofund);
%     HD2=spectrumdb(2*8);
%     HD3=spectrumdb(3*8);
%     HD4=spectrumdb(4*8);
%     figure;
%     plot(frequency, spectrumdb, '*-', 'linewidth', 2);
%     string1=sprintf('w/o cali SDR=%0.3gdB',sndrdb);
% %     string = sprintf('Fundamental=%0.3gdBV, SNDR=%0.3gdB, SFDR=%0.3gdB \n HD2=%0.3gdBV, HD3=%0.3gdBV, HD4=%0.3gdBV', funddb, sndrdb, sfdrdb, HD2, HD3, HD4)
% %     title(string);
%     xlabel('Frequency [f/fs]');
%     ylabel('Amplitude [dBV]');
%     axis([0 0.5 -120 0]);
%     grid;
%     sndr_ori(m)=sndrdb;
% 
%     spectrum = abs(fft(dout_rev(1:end)));
%     spectrum = 2/NN*spectrum(1:NN/2+1);
%     spectrum(1)=0;
%     spectrumdb = 20*log10(spectrum+eps);
%     frequency = 1/NN * (0:length(spectrumdb)-1);
% 
%     [fund, fundidx] = max(spectrum);
%     funddb=20*log10(fund);
%     spec_nodc_nofund = [spectrum(2:fundidx-1); spectrum(fundidx+1:end)];
%     [spur, spuridx] = max (spec_nodc_nofund);
%     
%     sfdrdb = funddb-20*log10(spur);
%     sndr = norm(fund)/norm(spec_nodc_nofund);
%     sndrdb=20*log10(sndr);
%     funddb=20*log10(norm(fund));
%     nofunddb=20*log(norm(spec_nodc_nofund));
%     norm(fund);
%     norm(spec_nodc_nofund);
%     HD2=spectrumdb(2*8);
%     HD3=spectrumdb(3*8);
%     HD4=spectrumdb(4*8);
%     spectrumdb_rec=spectrumdb;
% %     figure;
%     hold on;
%     plot(frequency, spectrumdb_rec, '*-r', 'linewidth', 2);
%     string2=sprintf('w cali SDR=%0.3gdB',sndrdb);
%     h=legend(string1,string2,'fontweight','bold','fontSize',13);
%     set(h,'FontSize',12,'fontweight','bold');
% %     string = sprintf('Fundamental=%0.3gdBV, SNDR=%0.3gdB, SFDR=%0.3gdB \n HD2=%0.3gdBV, HD3=%0.3gdBV, HD4=%0.3gdBV', funddb, sndrdb, sfdrdb, HD2, HD3, HD4)
% %     title(string);
%     xlabel('Frequency [f/fs]','fontweight','bold','fontSize',13);
%     ylabel('Amplitude [dBV]','fontweight','bold','fontSize',13);
% 
%     axis([0 0.5 -120 0]);
%     sndr_cor(m)=sndrdb;
% end
% NN=1024*4;
% for j=1:NN;
%     vin_test(i)=v0-(vrefp-vrefn)+j/NN;
%     vx(1)=vcm-vin_test(i)+cp(bit)/ctot_p*vrefp+(ctot_p-cp(bit))/ctot_p*vrefn;
%     vy(1)=vcm-v0+cn(bit)/ctot_n*vrefn+(ctot_n-cn(bit))/ctot_n*vrefp;
%     for i=1:bit;
%         if vx(i)>=vy(i);
%             dout(i)=0;
%             if i<bit;
%                 vx(i+1)=vx(i)-(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefp+(cp(bit-i+1)-cp(bit-i))/ctot_p*vrefn;
%                 vy(i+1)=vy(i)-(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefn+(cn(bit-i+1)-cn(bit-i))/ctot_n*vrefp;
%             end
%         else
%             dout(i)=1;
%             if i<bit;
%                 vx(i+1)=vx(i)+cp(bit-i)/ctot_p*vrefp-cp(bit-i)/ctot_p*vrefn;
%                 vy(i+1)=vy(i)+cn(bit-i)/ctot_n*vrefn-cn(bit-i)/ctot_n*vrefp;
%             end
%         end
%     end
%     dout_dec=0;
%     for i=1:bit;
%         dout_dec=dout_dec+2^(bit-i)*dout(i);
%     end
%     dout_test(j)=dout_dec;
%     dout_rev(j)=floor(dout*(fliplr(c))');
% end  
%  figure;
%  stairs(1:NN,dout_test);
%  hold on;
%  stairs(1:NN,dout_rev,'r');
%  xlabel('vin');
%  ylabel('dout');
%  xlim([1 NN]);
%  legend('Dout','Dout_{Cali}');
% % figure;
% % bar(1:m,sndr_cor,'r');
% % hold on;
% % bar(1:m,sndr_ori);
% % 
% % cor_mean=sum(sndr_cor)/M
% % stdev_cor = sqrt(sum((sndr_cor-cor_mean).^2/M))
% % ori_mean=sum(sndr_ori)/M
% % stdev_ori = sqrt(sum((sndr_ori-ori_mean).^2/M))