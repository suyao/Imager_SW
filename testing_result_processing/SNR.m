function SNR_result = SNR(data,fs)
    NN = length(data);
    spectrum = abs(fft(data(1:end)));
    spectrum = 2/NN*spectrum(1:NN/2+1);
    spectrum(1)=0;
    spectrumdb = 20*log10(spectrum+eps);
    %frequency = 1/NN * (0:length(spectrumdb)-1);
    frequency = fs*(0:(NN/2))/NN;
    [fund, fundidx] = max(spectrum);
    funddb=20*log10(fund);
    spec_nodc_nofund = [spectrum(2:fundidx-1), spectrum(fundidx+1:end)];
    [spur, spuridx] = max (spec_nodc_nofund);
    
    sfdrdb = funddb-20*log10(spur);
    sndr = norm(fund)/norm(spec_nodc_nofund);
    sndrdb=20*log10(sndr);
    funddb=20*log10(norm(fund));
    nofunddb=20*log(norm(spec_nodc_nofund));
    norm(fund);
    norm(spec_nodc_nofund);
    HD2=spectrumdb(2*8);
    HD3=spectrumdb(3*8);
    HD4=spectrumdb(4*8);
    SNR_result = sndrdb;
    figure;
    plot(frequency, spectrumdb, '*-', 'linewidth', 2);
    enob = (sndrdb-1.76)/6.02;
     string = sprintf('Fundamental=%0.3gdBV, SNDR=%0.3gdB, SFDR=%0.3gdB, ENOB=%0.3gb\n', funddb, sndrdb, sfdrdb,enob)
     title(string);
    xlabel('Frequency [f/fs]');
    ylabel('Amplitude [dBV]');
   % axis([0 0.5 -120 0]);
    grid;
end