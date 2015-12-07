clear all;
%close all;

nMon = 20000;  % number of Monte Carlo trials for each point
sigma_list = [0.5:0.003:3];
P0 = zeros(1, length(sigma_list));
P1 = P0;
P2 = P0;
P00=P0;
P11=P0;
P50 = P0;
P51 = P0;
for i = 1 : length(sigma_list)
    sigma = sigma_list(i);
    for mon = 1: nMon
        v1 = rand() - 0.5;  % generate Unif(-0.5, 0.5)
        v2 = v1+(2.2862e-1)/1.7046;
        z1 = sigma* randn();  % generate i.i.d. Gaussian noise w/ variance sigma^2
        z2 = sigma* randn();

        Q1 = round(v1+z1)-v1;  % Quantize
        Q2 = round(v2+z2)-v2;
        
        Q3 = round(v1+z1);
        Q4 = round (v1+z2);
        
        Q5 = z1*5-z2*5;
        
        if round (Q5) == 0;
            P50(i) = P50(i) + 1;
        elseif round (Q5) == 1;
            P51(i) = P51(i) + 1;
        end
            
        if round(Q3-Q4) ==0
            P00(i) = P00(i) + 1;
        elseif round(Q3-Q4)==1
            P11(i)=P11(i) +1;
        end
        
        if round(Q2 - Q1) == 0
            P0(i) = P0(i) + 1;  % empirical probability that Q1 - Q2 = 0
        elseif round(Q2 - Q1) == 1
            P1(i) = P1(i) + 1;  % empirical probability that Q1 - Q2 = 1
        elseif round(Q2 - Q1) == -1;
            P2(i) = P2(i) + 1;
        end
    end
end
%figure;
%subplot(1,2,1);
% plot(sigma_list, 2*P0./(P1+P2)) %
% hold on;
% figure;
% exp3='a*exp(b*x)+c*exp(d*x)+e';
% f = fit( 2*(P0./(P1+P2))',sigma_list',exp3,'StartPoint',[0.8 -0.45 78, -4.6,0])
% plot(f, 2*(P0./(P1+P2))',sigma_list')
% grid on;
figure;
plot(sigma_list, P00./P11,'r'); %CDS
exp3='a/x^2+b/x+c';;
f = fit(sigma_list',(P00./P11)',exp3)
plot(f, sigma_list',(P00./P11)')
% figure;
% plot(sigma_list, P50./P51,'g');
% ylabel('P0/P1','FontSize', 18);
% xlabel('sigma_{noise}','FontSize', 18);
% grid on;
% figure;
% exp3='a/x^2+b/x+c';
% f = fit((P50./P51)',sigma_list',exp3)
% plot(f, (P50./P51)',sigma_list');
% ylim([0 0.14])
