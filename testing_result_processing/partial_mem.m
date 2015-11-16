%image capture
%Time[s], Channel 0, Channel 1, Channel 2, Channel 3, Channel 4, Channel 5, Channel 6, Channel 7, Channel 8, Channel 9, Channel 10, 
%New Row, New Frame, clk_smp
clear all;
close all;
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/partial_mem/right_2pF_fast_1111_1603_rst16n.csv'; 
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
lr = 1;
fit_order = 3;
weights{lr} = adc_calibration(lr-1);
%weights{2} = adc_calibration(1);
wbi = [1 2 4 8 16 32 64 128 256 512 1024];
row_num = 3;
col_num = 240/2;
%fit_coeff{lr} = partial_settling_fitting(fit_order,lr);
%% close all;
close all;
lsb = 1/(sum(weights{lr})+weights{lr}(1));
row = 1;
for col = 1:120;
    col 
    idx_row = 0;
    wait_col = 28;
    count = 0;
    flag = 0;
    for i = 2:length(new_frame)
        if (new_row(i-1) == 1 && new_row(i) == 0 )
            idx_row = idx_row + 1;
            if (idx_row == row)      
                count = count +1;
                idx_col = 0; 
                flag = 1;
            end

        end
        if ( flag == 1 && clk_smp(i-1) == 1 && clk_smp(i) == 0)             
            if (idx_col ==col)                  
                rst_hex(col,count) = (data(i,:)*wbi');
                rst_raw(col,count) = data(i,:)*weights{lr}'/(sum(weights{lr})+1)+vmin;  
                rst_time(col,count) = time(i);
            end

            if (idx_col == col_num + wait_col + col )
                px_hex(col,count) = (data(i,:)*wbi');
                px_raw(col,count) = data(i,:)*weights{lr}'/(sum(weights{lr})+1)+vmin;
                px_time(col,count) = time(i);
                flag = 0;
            end 
            idx_col = idx_col + 1;
        end
    end
    
end

figure;
plot(rst_raw(:,1));
hold on;
%rst_calib =partial_settling_calib(rst_raw(:,1),fit_coeff{lr}); 
%plot(rst_calib,'r');