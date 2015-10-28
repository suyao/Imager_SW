%image capture
%Time[s], Channel 0, Channel 1, Channel 2, Channel 3, Channel 4, Channel 5, Channel 6, Channel 7, Channel 8, Channel 9, Channel 10, 
%New Row, New Frame, clk_smp
clear all;
close all;
%c = partial_settling_fitting(3,1);
c = partial_settling_fitting(5,2);
%%
if (0 ==1)
row_num = 320;
col_num = 240/2;
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1019_1711_vert.csv';
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1020_1115_1f4fslow_vert.csv'; % tightly screwed upside
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1020_1145_1f4fslow_vert.csv'; % loosely screwed downside
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1020_1149_1f4fslow_vert.csv'; % 2 turn screwed upside
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1020_1155_1f4fslow_vert.csv'; % 1 turn screwed upside
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1020_1155_1f4fslow_vert.csv'; % 2/3 turn screwed upside
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1020_1211_1f4fslow_vert.csv'; % 5/6 turn screwed upside
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1020_1218_1f4fslow_vert.csv'; % 1/2 turn screwed upside
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1020_1227_1f4fslow_vert.csv'; % 1/2 turn out
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1021_1517_vert.csv'; % 0 turn
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1021_1556_vert.csv'; % 1/8 turn out best
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1021_1556_cup.csv'; % 1/8 turn out best
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1021_1630_grid.csv'; % 1/8 turn out best
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1021_1651_vert.csv'; % 1/16 turn out
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1021_1702_vert.csv'; % 3/32 turn out
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1021_1800_bird.csv'; % 1/8 turn out best
filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1021_1800_grid.csv'; % 1/8 turn out best
%filename = '/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/FullFrame/image_capture_1026_1108_vert2.csv'; % 3/32 turn out

fid = fopen(filename,'r');
c = fgetl(fid); 
f = fscanf(fid, '%f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d, %d, %d', [15 inf] );
time = f(1,:);
new_frame = f(14,:);
new_row = f(13,:);
clk_smp = f(15,:);
data= [ f(2,:);f(3,:);f(4,:);f(5,:);f(6,:);f(7,:);f(8,:);f(9,:);f(10,:);f(11,:); f(12,:)]';

%close all;
fit_order = 5;
vmin = 0.0;
weights{1} = adc_calibration(0);
weights{2} = adc_calibration(1);
wbi = [1 2 4 8 16 32 64 128 256 512 1024];
%%
idx_at_frame = 0;
rst_raw = zeros(row_num,col_num);
px_raw = zeros(row_num,col_num);

idx_row = 0;
wait_col = 28;
idx_start = 2;
frame_num_start(1)=7;
frame_num_start(2)=7;
for lr = 1:1:2
    rst_hex{lr} = zeros(row_num,col_num);
    px_hex{lr} = zeros(row_num,col_num);
    rst_calib{lr} = zeros(row_num,col_num);
    px_calib{lr} = zeros(row_num,col_num);
    fit_coeff{lr} = partial_settling_fitting(fit_order,lr);
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
                    rst_raw(idx_row,idx_col) = data(i,:)*weights{lr}'/sum(weights{lr})+vmin; 
                    rst_calib{lr}(idx_row,idx_col) = partial_settling_calib(rst_raw(idx_row,idx_col),fit_coeff{lr}); 
                end

                if (idx_col > col_num + wait_col && idx_col <=col_num*2+wait_col)
                    px_hex{lr}(idx_row,idx_col-col_num - wait_col) = (data(i,:)*wbi');
                    px_raw(idx_row,idx_col-col_num - wait_col) = data(i,:)*weights{lr}'/sum(weights{lr})+vmin;
                    px_calib{lr}(idx_row,idx_col-col_num - wait_col) = partial_settling_calib(px_raw(idx_row,idx_col-col_num - wait_col),fit_coeff{lr});

                end 
                idx_col = idx_col + 1;
            end
        end
         
    end

    image_half{lr} = (rst_raw - px_raw);
    image_half_calib{lr} = (rst_calib{lr} - px_calib{lr});
end

image_raw = [image_half{1} image_half{2}(:,2:end)];
figure;
imshow(flipud(image_raw));

image_calib = [image_half_calib{1} image_half_calib{2}(:,2:end)];
figure;
imshow(flipud(image_calib));

%imshow(fliplr(image_raw'));

%imshow(fliplr(image_calib'));
end   