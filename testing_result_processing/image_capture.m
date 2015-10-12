%image capture
%Time[s], Channel 0, Channel 1, Channel 2, Channel 3, Channel 4, Channel 5, Channel 6, Channel 7, Channel 8, Channel 9, Channel 10, New Row, New Frame, clk_smp
clear all;
%close all;
row_num = 320;
col_num = 240/2;
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_white.csv';
fid = fopen(filename,'r');
f = fscanf(fid, '%f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d, %d, %d', [15 inf] );
new_frame = f(14,:);
new_row = f(13,:);
clk_smp = f(15,:);
data= [f(1,:); f(2,:);f(3,:);f(4,:);f(5,:);f(6,:);f(7,:);f(8,:);f(9,:);f(10,:);f(11,:)]';
weights = [509.3693  272.4805  136.4577   68.4769   34.2635   17.2742 15.5958    7.9048    3.9518    1.9835    1.0000];
weights = fliplr( weights);
idx_at_frame = 0;
for i = 2:1:length(new_frame)
    if ((new_frame(i-1) == 1) && (new_frame(i) == 0))
        idx_at_frame = i;
        break;
    end   
end


rst_raw = zeros(row_num,col_num);
px_raw = zeros(row_num,col_num);
idx_row = 0;
wait_col = 28;
flag = 0;
for i = idx_at_frame:length(new_frame)
    if idx_row > 2*row_num 
        break;
    end
    if (new_row(i-1) == 1 && new_row(i) == 0)
        idx_row = idx_row + 1;
        idx_col = 1;
        if (idx_row == row_num +1)
            flag = 1;
            idx_row =1;
        end
    end
    if (flag ==1)
        if (clk_smp(i-1) == 1 && clk_smp(i) == 0)
            if idx_col <=col_num
                rst_raw(idx_row,idx_col) = data(i,:)*weights';      
            end
           
            if (idx_col > col_num + wait_col && idx_col <=col_num*2+wait_col)
                px_raw(idx_row,idx_col-col_num - wait_col) = data(i,:)*weights';
                
            end 
            idx_col = idx_col + 1;
        end
    end
end
image_raw = (rst_raw - px_raw)/sum(weights);
figure;
imshow(image_raw);
    