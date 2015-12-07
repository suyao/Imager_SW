%image capture
%Time[s], Channel 0, Channel 1, Channel 2, Channel 3, Channel 4, Channel 5, Channel 6, Channel 7, Channel 8, Channel 9, Channel 10, 
%New Row, New Frame, clk_smp
if (1 ==1)
clear all;
close all;
row_num = 320;
col_num = 240/2;
iii = 20;
filename = strcat('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/Conv_Gain/strong_test_1204/light_strong_',int2str(iii),'.csv');
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/uniform_dimlight_1119_2154_slow_1pF4pF.csv';

fid = fopen(filename,'r');
c = fgetl(fid); 
f = fscanf(fid, '%f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d, %d, %d', [15 inf] );
time = f(1,:);
new_frame = f(14,:);
new_row = f(13,:);
clk_smp = f(15,:);
data= [ f(2,:);f(3,:);f(4,:);f(5,:);f(6,:);f(7,:);f(8,:);f(9,:);f(10,:);f(11,:); f(12,:)]';
fclose(fid);
%close all;
fit_order = 3;
vmin = 0.0;
%weights{1} = adc_calibration(0);
weights{1} =[ 0.9688    1.9375    3.7812    7.6250   14.8438 16.0625   32.0312   64.1875  128.0938  256.0000 481.6875];
wbi = [1 2 4 8 16 32 64 128 256 512 1024];
lsb = 1/(sum(weights{1})+weights{1}(1));
%fit_coeff{1} = partial_settling_fitting(fit_order,1);
fit_coeff{1} = [    1.0648;1.7800;-0.5080;0.5241];
end
%%

close all;
idx_at_frame = 0;
%rst_raw = zeros(row_num,col_num);
%px_raw = zeros(row_num,col_num);

idx_row = 0;
wait_col = 28;
idx_start = 2;
frame_num_start(1)=35;
frame_num_start(2)=4;
for lr = 1
    rst_hex{lr} = zeros(row_num,col_num);
    px_hex{lr} = zeros(row_num,col_num);
    rst_calib{lr} = zeros(row_num,col_num);
    px_calib{lr} = zeros(row_num,col_num);
    
    frame_time = 0;
    for i = idx_start:length(new_frame)
        if ((new_frame(i-1) == 1) && (new_frame(i) == 0))
            idx_at_frame = i;
            idx_row = 1;
            break;
        end   
    end

    flag = 0;
    for i = idx_at_frame:length(new_frame)
        if frame_time > frame_num_start(lr)
            idx_start = i;
            break;
        end
        if (new_row(i-1) == 1 && new_row(i) == 0)
            idx_row = idx_row + 1;
            idx_col = 0;
            if (idx_row == row_num +1)
                flag = 1;
                frame_time = frame_time +1;
                %p11 = i;
                idx_row =1;
            end
        end
        if (flag ==1)
            if (clk_smp(i-1) == 1 && clk_smp(i) == 0)
                
                if (idx_col <=col_num && idx_col >0)
                    
                    rst_hex{lr}(idx_row,idx_col) = (data(i,:)*wbi');
                    rst_raw{frame_time}(idx_row,idx_col) = data(i,:)*weights{lr}'/(sum(weights{lr})+weights{lr}(1))+vmin; 
                    rst_calib{lr,frame_time}(idx_row,idx_col) = partial_settling_calib(rst_raw{frame_time}(idx_row,idx_col),fit_coeff{lr}); 
                end

                if (idx_col > col_num + wait_col && idx_col <=col_num*2+wait_col)
                    px_hex{lr}(idx_row,idx_col-col_num - wait_col) = (data(i,:)*wbi');
                    px_raw{frame_time}(idx_row,idx_col-col_num - wait_col) = data(i,:)*weights{lr}'/(sum(weights{lr})+weights{lr}(1))+vmin;
                    px_calib{lr,frame_time}(idx_row,idx_col-col_num - wait_col) = partial_settling_calib(px_raw{frame_time}(idx_row,idx_col-col_num - wait_col),fit_coeff{lr});

                end 
                idx_col = idx_col + 1;
            end
        end
         
    end

   
    
end

for i = 1:frame_num_start(1)
    image_half_calib{lr,i} = (rst_calib{lr,i} - px_calib{lr,i});
     image_raw{i} = (rst_raw{i} - px_raw{i});
    for j=1:row_num
        for k = 1: col_num
            if (image_half_calib{lr,i}(j,k)<0)
                image_half_calib{lr,i}(j,k)=0;
            end
        end
    end
end

image_calib = image_half_calib{1,15};
figure;
imshow(flipud(image_calib));

iii
for i = frame_num_start(1)-30:frame_num_start(1)-1
   filename=strcat('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/Conv_Gain/suyao_1204_strong/light_1_0_',int2str(iii),'/frame_',int2str(i-frame_num_start(1)+30),'.bin');
   fod = fopen(filename,'w');
   fwrite(fod, round(image_half_calib{1,i+1}*2^10)','uint16');
   fclose(fod);
    pixel_raw_mean_perfram(i-frame_num_start(1)+31) = mean2(image_raw{i+1}(135:185,35:85));
     pixel_val_mean_perfram(i-frame_num_start(1)+31) = mean2(image_half_calib{1,i+1}(135:185,35:85));
end

light_mean = mean(pixel_val_mean_perfram)
raw_mean = mean(pixel_raw_mean_perfram);
k=1;
for i = frame_num_start(1)-30:frame_num_start(1)-1
    for row = 135:185
        for col = 35:85
            px_var(k)=image_raw{i+1}(row,col)-raw_mean;
            k=k+1;
        end
    end
end
figure;
xbins = [floor(min(px_var)/lsb):1:ceil(max(px_var)/lsb)];
[hist_counts, value]=hist(px_var/lsb,xbins);
hist(px_var/lsb,xbins);
hist_0 = hist_counts(-floor(min(px_var)/lsb)+1);
hist_n1 = hist_counts(-floor(min(px_var)/lsb));
hist_1 = hist_counts(-floor(min(px_var)/lsb)+2);
ratio_p0_p1 = 2*hist_0/(hist_n1+hist_1);
% for x=0.5:0.01:3;
%     fit1=0.298./x.^2-0.06026./x+1.02;
%     if ratio_p0_p1>=fit1
%         noise=x
%         break;
%     end
% end
figure;
imshow(image_half_calib{1,15}(135:185,35:85)/5)
%plot(x,fit1,x,ratio_p0_p1*ones(1,length(x)));


if (0==1)

nMon = 20000;  % number of Monte Carlo trials for each point
sigma_list = [0.1:0.001:1];
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
plot(sigma_list, P0./P1)
hold on;
plot(sigma_list, ratio_p0_p1*ones(1,length(sigma_list)),'r');
ylabel('P0/P1','FontSize', 18);
xlabel('sigma_{noise}','FontSize', 18);
grid on;

end