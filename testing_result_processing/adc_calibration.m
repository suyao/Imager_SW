function weight= adc_calibration()
    clear all;
    vin=1;
    vrefp=1.25;
    vrefn=0.75;
    vcm=1;
    v0=1;
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_output_b3.txt','r');
    %fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_left2b_20151009_1309.txt','r');
    fin = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/CalibrateADC/ADC_ramp_right3b_20151011_1807.txt','r');

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
2047-value


