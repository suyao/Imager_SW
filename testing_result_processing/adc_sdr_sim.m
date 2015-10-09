clear all;
close all;

% load sim output
fid=importdata('H:/data/cmp_ideal_sw_0221.csv');
fin=importdata('H:/data/in_ideal_sw_0221.csv');
fs=400e6; fsig=7/64*fs/20;   %slow case when fs=250k fsig=2.5M

%dot=61;
dot=64+1;
data_cmp=fid(:,2);
data_in=fin(:,2);
% vod=vod(154:floor(length(vod)/dot)+1:end);
tr=fid(:,1);
plot(tr,data_cmp);
bit=10;
range=1;
lsb=range/2^bit;
t_start=3.7e-9+20/fs*3;
vdd=1;
v_l=0.3;
%plot(tr,data_cmp);

for i=1:length(tr)
    if data_cmp(i)>0.8
        data_cmp(i)=1;
    elseif data_cmp(i)<0.2
        data_cmp(i)=0;
    else
        data_cmp(i)=1000; 
    end
end
j=1;
k=1;
for i=1:length(tr);
    if tr(i)-t_start-20/fs*(k-1)>0
        if abs(tr(i)-t_start-3/4/fs-20/fs*(k-1)-(j-1)/fs)<=0.1/fs
            tt(j)=tr(i);
            dig(j)=data_cmp(i);
            j=j+1;
            if j==bit+1;
                dout(k)=0;
                t(k)=tt(1);
                for j=1:bit
                    dout(k)=dout(k)+2^(bit-j)*dig(j);
                end
                j=1;
                k=k+1;
            end

        end
    end
end
j=1;
vrefp=0.5;
vrefn=0;
vcm=0.25;
v0=1.7;
for i=1:length(tr);
    if abs(tr(i)-t_start-2/4/fs-(j-1)/fs*20)<=0.08/fs      
        vin(j)=data_in(i);
        
        dout_ideal(j)=0;
        vx(1)=vin(j);
        vy(1)=v0;
        for k=1:bit;
            if vx(k)>vy(k)
                vx(k+1)=vx(k)+(vrefn-vcm)/2^k;
                vy(k+1)=vy(k)+(vrefp-vcm)/2^k;
                dcmp_ideal(k)=1;
            else
                vx(k+1)=vx(k)+(vrefp-vcm)/2^k;
                vy(k+1)=vy(k)+(vrefn-vcm)/2^k;
                dcmp_ideal(k)=0;
            end
            dout_ideal(j)=dcmp_ideal(k)*(2^(bit-k))+dout_ideal(j);
        end
        j=j+1;
    end
    
end
figure(4);
dout_diff=dout-dout_ideal;
plot(1:length(dout_diff),dout_diff);
vin_in=vin;
t=(t(1:dot))';
vod=(dout(1:dot))'/1024;
% t=t(154:floor(length(t)/dot)+1:end);
figure(2);
% vic=1.2;
% %t1=t_start+1/fs/2:1/fs:t_start+0.5/fs+(dot-1)/fs;
% t1=t_start:1/fs:t_start+(dot-1)/fs;
% ideal=0.5*sin(2*pi*fsig*t1)+vic;
% % vod=ideal';
% plot(t,ideal,'s','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',3);
plot(t,vod,'s','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',3);
% figure(2);
% plot(t,ideal'-vod,'s','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',3)
% figure(2);
% hold on;
% M=length(t)-1;
% s=abs(fft(ideal(1:end-1)));
% s=s(1:end/2);
% s(1)=0;
% s=20*log10(2*s/M);
% f=[0:M/2-1]/M;
% plot(f,s,'r')
% 
% read into matlab variables
% t    = vod_.time;
% vod  = vod_.V;
N    = length(t)-1;

% if first and last point don't match within good precison, the fft data is garbage...
delta = vod(1)-vod(end)
if abs(delta)>1e-6
    disp('This looks like inaccurate fft data...');
    beep
end

spectrum = abs(fft(vod(2:end)));
spectrum = 2/N*spectrum(1:N/2+1);
spectrum(1)=0;
spectrumdb = 20*log10(spectrum+eps);
frequency = 1/N * (0:length(spectrumdb)-1);

[fund, fundidx] = max(spectrum);
funddb=20*log10(fund);
spec_nodc_nofund = [spectrum(2:fundidx-1); spectrum(fundidx+1:end)];
[spur, spuridx] = max (spec_nodc_nofund);

sfdrdb = funddb-20*log10(spur);
sndr = norm(fund)/norm(spec_nodc_nofund)
sndrdb=20*log10(sndr);
funddb=20*log10(norm(fund))
nofunddb=20*log(norm(spec_nodc_nofund))
norm(fund)
norm(spec_nodc_nofund)
HD2=spectrumdb(2*8);
HD3=spectrumdb(3*8);
HD4=spectrumdb(4*8);
figure(3);
plot(frequency, spectrumdb, '*-', 'linewidth', 2);
string = sprintf('Fundamental=%0.3gdBV, SNDR=%0.3gdB, SFDR=%0.3gdB \n HD2=%0.3gdBV, HD3=%0.3gdBV, HD4=%0.3gdBV', funddb, sndrdb, sfdrdb, HD2, HD3, HD4)
title(string);
xlabel('Frequency [f/fs]');
ylabel('Amplitude [dBV]');
axis([0 0.5 -120 0]);
% grid;
