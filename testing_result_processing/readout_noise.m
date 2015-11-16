%image capture
%Time[s], Channel 0, Channel 1, Channel 2, Channel 3, Channel 4, Channel 5, Channel 6, Channel 7, Channel 8, Channel 9, Channel 10, 
%New Row, New Frame, clk_smp
clear all;
close all;

 
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_slow_ana33_0-95_1pF_smp116n_1028_1944.csv'; 
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_slow_ana33_0-95_1pF_smp116n_1028_1920.csv'; 
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_ana33_0-95_1pF_smp116n_1028_1920.csv'; 
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_slow_ana33_1-45_1pF_smp116n_1028_2011.csv'; 
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_low_1pF_row1-3_1030_1706.csv'; 
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_low_1pF_row1-3_1102_1546.csv'; %inte time is 1 row
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_low_1pF_row1-3_1102_1555.csv'; %inte time is 3 rows
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_low_1pF_row1-3_1102_1714_extrst_3-2.csv'; %inte time is 3 row
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_low_1pF_row1-3_1102_1714_extrst_2-3.csv'; %inte time is 3 row
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_low_0pF_row1-3_1102_1714_extrst_3-2.csv'; %inte time is 3 row
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1102_1714_extrst_3-3.csv'; %inte time is 3 row
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1102_2103_extrst_3-3.csv'; %inte time is 3 row
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1102_2112_extrst_3-3.csv'; %pvdd=2.8, ana33=2.4, v0=1, rst/tx=3.3
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1102_2117_extrst_3-3.csv'; %pvdd=2.9, ana33=2.4, v0=1, rst/tx=3.3
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1102_2124_extrst_3-3.csv'; %pvdd=3,ana33=2.4,v0=1,rst/tx=3.3
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1103_1026_pvdd2-8.csv'; %pvdd=2.8, ana33=2.4, v0=1, rst/tx=3.3
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1103_1026_pvdd3.csv'; %pvdd=3, ana33=2.4, v0=1, rst/tx=3.3
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1103_1026_pvdd3-3.csv'; %pvdd=3.3, ana33=2.4, v0=1, rst/tx=3.3
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1103_1026_pvdd2-8.csv'; %pvdd=3.3, ana33=2.4, v0=1, rst/tx=3.3
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1109_1606_pvdd2-8_rst2-8.csv'; %pvdd=3, ana33=2.4, v0=1, rst/tx=3.3
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1109_1606_pvdd2-8_rst2-8_longrst.csv'; %pvdd=3, ana33=2.4, v0=1, rst/tx=3.3
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_row1-3_1109_1606_pvdd2-8_rst3-3_longrst.csv'; %pvdd=3, ana33=2.4, v0=1, rst/tx=3.3


fid = fopen(filename,'r');
c = fgetl(fid); 
f = fscanf(fid, '%f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d, %d, %d', [15 inf] );
time = f(1,:);
new_frame = f(14,:);
new_row = f(13,:);
clk_smp = f(15,:);
data= [ f(2,:);f(3,:);f(4,:);f(5,:);f(6,:);f(7,:);f(8,:);f(9,:);f(10,:);f(11,:); f(12,:)]';
fclose(fid);
vmin = 0.0;
weights{1} = adc_calibration(0);
%weights{2} = adc_calibration(1);
wbi = [1 2 4 8 16 32 64 128 256 512 1024];
row_num = 3;
col_num = 240/2;

%% close all;
close all;
lr = 1;
lsb = 1/(sum(weights{lr})+weights{lr}(1));
xbins = [-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7];
row = 2;
for col = 1:120;
    col 
    idx_row = 0;
    wait_col = 28;
    count = 0;
    flag = 0;
    for i = 2:length(new_frame)
        if (new_row(i-1) == 1 && new_row(i) == 0 )
            idx_row = idx_row + 1;
            if (mod(idx_row,row_num) == row)      
                count = count +1;
                idx_col = 0; 
                flag = 1;
            end

        end
        if ( flag == 1 && clk_smp(i-1) == 1 && clk_smp(i) == 0)             
            if (idx_col ==col)                  
                rst_hex(count) = (data(i,:)*wbi');
                rst_raw(count) = data(i,:)*weights{lr}'/(sum(weights{lr})+1)+vmin;  
                rst_time(count) = time(i);
            end

            if (idx_col == col_num + wait_col + col )
                px_hex(count) = (data(i,:)*wbi');
                px_raw(count) = data(i,:)*weights{lr}'/(sum(weights{lr})+1)+vmin;
                px_time(count) = time(i);
                flag = 0;
            end 
            idx_col = idx_col + 1;
        end
    end
    cds = rst_raw(1:length(px_raw))-px_raw;
    cds = cds/lsb;
    px_mean(col) = mean(px_raw);
    xbins = [floor(min(cds)):1:ceil(max(cds))];
    [hist_counts, value]=hist(cds,xbins);
    per = hist_counts/sum(hist_counts);
   
    mid_per(col) = max(per); 
    maj_rst_hex(col)=mode(rst_hex);
    [hmax,hmidx]=max(hist_counts);
    hist_0(col)=hist_counts(hmidx);
    hist_n1(col)=hist_counts(hmidx-1);
    hist_1(col)=hist_counts(hmidx+1);
    %hist_n2(col)=hist_counts(hmidx-2);
    %hist_2(col)=hist_counts(hmidx+2);
%     hist_0(col)=hist_counts(8);
%     hist_n1(col)=hist_counts(7);
%     hist_1(col)=hist_counts(9);
%     hist_n2(col)=hist_counts(6);
%     hist_2(col)=hist_counts(10);
    
    rst_bins = [min(rst_raw/lsb):1:max(rst_raw/lsb)];
   
    [hist_rst_counts,value_rst]=hist(rst_raw/lsb,rst_bins);
    [max_val,max_idx]=max(hist_rst_counts);
    if (max_idx<length(hist_rst_counts) && max_idx>1)
        hist_rst_0(col) = hist_rst_counts(max_idx);
        hist_rst_1(col) = hist_rst_counts(max_idx+1);
        hist_rst_n1(col) = hist_rst_counts(max_idx-1);
    end
end
xbins2 = [min(rst_hex):1:max(rst_hex)];
figure;
subplot(1,3,1)
hist(rst_hex,xbins2);
ylabel('1st readout','FontSize', 18);
subplot(1,3,2)
xbins_px = [min(px_hex):1:max(px_hex)];
hist(px_hex,xbins_px);
ylabel('2nd readout','FontSize', 18);
subplot(1,3,3);
hist(cds,xbins);
ylabel('cds result','FontSize', 18);

figure;
subplot(2,1,1)
plot(mid_per);

grid;
ylabel('probability at center','FontSize', 18)
subplot(2,1,2);
xlabel('col index','FontSize', 18);
plot(maj_rst_hex,'r');
ylabel('Single readout w/o cds','FontSize', 18);
grid on;
ratio_cds = sum(hist_0)/(sum(hist_1)+sum(hist_n1))*2
ratio2=sum(hist_0)/(sum(hist_2)+sum(hist_n2))*2;


figure;
hist(rst_raw/lsb,rst_bins);
title('RST Readout Histogram');
ratio_rst = sum(hist_rst_0)/(sum(hist_rst_1)+sum(hist_rst_n1))*2

%%
nMon = 20000;  % number of Monte Carlo trials for each point
sigma_list = [0.1:0.001:1.5];
P0 = zeros(1, length(sigma_list));
P1 = P0;
P2 = P0;
for i = 1 : length(sigma_list)
    sigma = sigma_list(i);
    for mon = 1: nMon
        v = rand() - 0.5;  % generate Unif(-0.5, 0.5)
        z1 = sigma* randn();  % generate i.i.d. Gaussian noise w/ variance sigma^2
        z2 = sigma* randn();

        Q1 = round(v+z1);  % Quantize
        Q2 = round(v+z2);
        
        if Q1 - Q2 == 0
            P0(i) = P0(i) + 1;  % empirical probability that Q1 - Q2 = 0
        elseif Q1 - Q2 == 1
            P1(i) = P1(i) + 1;  % empirical probability that Q1 - Q2 = 1
        elseif Q1 - Q2 == 2;
            P2(i) = P2(i) + 1;
        end
    end
end
figure;
%subplot(1,2,1);
plot(sigma_list, P0./P1)
hold on;
plot(sigma_list, ratio_cds*ones(1,length(sigma_list)),'r');
plot(sigma_list, ratio_rst*ones(1,length(sigma_list)),'g');
ylabel('P0/P1','FontSize', 18);
xlabel('sigma_{noise}','FontSize', 18);
grid on;
%subplot(1,2,2);
%plot(sigma_list, P0./P2);
%hold on;
%plot(sigma_list, ratio2*ones(1,length(sigma_list)),'r');
%ylabel('P0/P2','FontSize', 18);
%xlabel('sigma_{noise}','FontSize', 18);
%grid on;
%%
[hist_counts, value]=hist(cds,xbins);
per = hist_counts/sum(hist_counts)
sigma = 1; x0 = -0; 
x1 = x0+1; 
cdf0 = 1/2*(erf((x0-0.5)/sqrt(2)/sigma)-erf((x0-1.5)/sqrt(2)/sigma))
cdf1 = 1/2*(erf((x0+0.5)/sqrt(2)/sigma)-erf((x0-0.5)/sqrt(2)/sigma))
cdf2 = 1/2*(erf((x1+0.5)/sqrt(2)/sigma)-erf((x1-0.5)/sqrt(2)/sigma))
cdf3 = 1/2*(erf((x1+1.5)/sqrt(2)/sigma)-erf((x1+0.5)/sqrt(2)/sigma))

lsb= 1/(sum(weights{lr})+1);
snr = 1/2*(0.49)^2/(lsb^2/12+1e-6*sigma^2);
snr = db(snr)/2;
enob = (snr-1.76)/6.02

%%
sigma = 0.31;
clear diff;
for i = 1:11740
    v1(i) = normrnd(0.0, sigma);
    v2(i) = normrnd(0.0 , sigma);
    diff(i) = round(v1(i)) - round(v2(i));
end
figure(4);
xbins = [-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7];
hist(diff,xbins)
[cnt, val]= hist(diff,xbins)
per2 = cnt/sum(cnt)
ylim([0 6000])

%% 
clear all;
close all;
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_debug_singlerow_1106_1106_pvdd2-8.csv'; 
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_debug_singlerow_1106_1106_pvdd3-1.csv'; 
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_debug_singlerow_1104_1526_pvdd2-8_cold.csv'; 
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_debug_singlerow_1104_1526_pvdd2-8_shortcdstime.csv'; 
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_debug_singlerow_1104_1526_pvdd3-1_shortcdstime.csv'; 
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/ReadNoise/readnoise_fast_high_1pF_debug_dummyrow2-6_1106_1106_pvdd2-6.csv'; 

lr=1;
fid = fopen(filename,'r');
c = fgetl(fid); 
f = fscanf(fid, '%f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d, %d, %d', [15 inf] );
time = f(1,:);
new_row = f(13,:);
clk_smp = f(15,:);
data= [ f(2,:);f(3,:);f(4,:);f(5,:);f(6,:);f(7,:);f(8,:);f(9,:);f(10,:);f(11,:); f(12,:)]';
fclose(fid);
vmin = 0.0;
weights{1} = adc_calibration(0);
wbi = [1 2 4 8 16 32 64 128 256 512 1024];
lsb = 1/(sum(weights{lr})+1);
xbins = [-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7];

%%
k=1;
for i =2:length(clk_smp);
    if (clk_smp(i-1)==0 && clk_smp(i)==1 && data(i,11)==1)
        if mod(k,2)==1
            count = (k+1)/2;
            rst_hex(count) = (data(i,:)*wbi');
            rst_raw(count) = data(i,:)*weights{lr}'/(sum(weights{lr})+1)+vmin;  
            rst_time(count) = time(i); 
            k = k+1;
        else
            count = k/2;
            px_hex(count) = (data(i,:)*wbi');
            px_raw(count) = data(i,:)*weights{lr}'/(sum(weights{lr})+1)+vmin;
            px_time(count) = time(i);
            k=k+1;
        end
    end
end

cds = rst_raw(1:length(px_raw))-px_raw;
cds = cds/lsb;
px_mean = mean(px_raw);

[hist_counts, value]=hist(cds,xbins);
per = hist_counts/sum(hist_counts);

mid_per = max(per); 
maj_rst_hex=mode(rst_hex);
hist_0=hist_counts(8);
hist_n1=hist_counts(7);
hist_1=hist_counts(9);

rst_bins = [min(rst_hex):1:max(rst_hex)]; 
[hist_rst_counts,value_rst]=hist(rst_hex,rst_bins);
[max_val,max_idx]=max(hist_rst_counts);
if (max_idx<length(hist_rst_counts) && max_idx>1)
    hist_rst_0 = hist_rst_counts(max_idx);
    hist_rst_1 = hist_rst_counts(max_idx+1);
    hist_rst_n1 = hist_rst_counts(max_idx-1);
end

xbins2 = [min(rst_hex):1:max(rst_hex)];
figure;
subplot(1,3,1)
hist(rst_hex,xbins2);
ylabel('1st readout','FontSize', 18);
subplot(1,3,2)
hist(px_hex,xbins2);
ylabel('2nd readout','FontSize', 18);
subplot(1,3,3);
hist(cds,xbins);
ylabel('cds result','FontSize', 18);
ratio_cds = hist_0/(hist_n1+hist_1)*2
ratio_rst = hist_rst_0/(hist_rst_n1+hist_rst_1)*2