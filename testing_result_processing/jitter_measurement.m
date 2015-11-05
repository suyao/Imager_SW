clear all;
close all;
fid = fopen('/Users/suyaoji/Dropbox/research/board_design/JTAG_JAVA/Imager_SW/outputs/jitter_measurement/jitter_p100n_p21_b1_80deg_1104_1254.csv','r');

c = fgetl(fid); 
f = fscanf(fid, '%f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d, %d', [13 inf] );
t = f(1,:)';
dout= [ f(2,:);f(3,:);f(4,:);f(5,:);f(6,:);f(7,:);f(8,:);f(9,:);f(10,:);f(11,:);f(12,:)]';
clk_smp = [f(13,:)]';
[r,nbits] = size(dout);
fclose(fid);

weights = adc_calibration(0);
%%
%close all;

N=100000;
fs = 1/100e-9;
lsb = 1/(1+sum(weights));
idx = 1;
data=zeros(1,N);
weights_bi = [1 2 4 8 16 32 64 128 256 512 1024];
for i = 2:r
    if (clk_smp(i-1) == 1 && clk_smp(i)==0)
        data_raw(idx) = dout(i,:)*weights_bi';
        data(idx)=dout(i,:)*weights';  
        idx= idx +1;
    end
    if idx > N
        break;
    end
end
sig = mean(data)

figure;
subplot(2,1,1);
plot(data);
subplot(2,1,2);
plot(data_raw);

figure;
xbins = [min(data):1:max(data)];
hist(data,xbins);
[count,value]=hist(data,xbins);
for i = 2:length(value)
    if count(i)>count(i-1)
        center_idx = i;
    end
end
p_center = count(center_idx);
p_left = count(center_idx-1);
p_right = count(center_idx+1);
ratio = p_center/(p_left+p_right)*2;
%%
nMon = 20000;  % number of Monte Carlo trials for each point
sigma_list = [0.1:0.001:1.5];
P0 = zeros(1, length(sigma_list));
P1 = P0;
P2 = P0;

for i = 1 : length(sigma_list)
    sigma = sigma_list(i);
    for mon = 1: nMon
        v1 = rand() - 0.5;  % generate Unif(-0.5, 0.5)
        v2 = rand() - 0.5;  % generate Unif(-0.5, 0.5)
        z1 = sigma* randn();  % generate i.i.d. Gaussian noise w/ variance sigma^2
        z2 = sigma* randn();

        Q1 = round(v1+z1);  % Quantize
        Q2 = round(v1+z2);
        
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
plot(sigma_list, ratio*ones(1,length(sigma_list)),'r');
ylabel('P0/P1','FontSize', 18);
xlabel('sigma_{noise}','FontSize', 18);
grid on;



