% given 2 input signals, plots spectrograms for each individual signal
% and coherogram between the signals

function [pwr1,pwr2,pwrF,coh,cohF,crossspec]=plot_spectroandcoherogram_two_signals(signal1,signal2,Fs)

figure; 
[pwr1,pwrF] = cwt(signal1,Fs);
plottime = [0:1/Fs:(size(pwr1,2)-1)/Fs];
h = subplot(3,1,1); 
pcolor(plottime,pwrF,log10(abs(pwr1))); 
shading interp; 
colorbar;
Fthresh = find(pwrF<=150,1); % set frequency threshold to set coloraxis values
temp = log10(abs(pwr1(1:Fthresh,10*Fs:length(pwr1)-10*Fs))); % select middle chunk of data
caxis([.55*min(temp(:)) max(temp(:))]); % set coloraxis based on highest and lowest values in data chunk
box off;
title('Pwr Signal 1');
xlabel('Time (s)');
ylabel('Freq (Hz)');

[pwr2,pwrF] = cwt(signal2,Fs);
plottime = [0:1/Fs:(size(pwr1,2)-1)/Fs];
h = subplot(3,1,2); 
pcolor(plottime,pwrF,log10(abs(pwr2))); 
shading interp; 
colorbar; 
Fthresh = find(pwrF<=150,1);
temp = log10(abs(pwr2(1:Fthresh,10*Fs:length(pwr2)-10*Fs)));
caxis([.5*min(temp(:)) max(temp(:))]);
box off;
title('Pwr Signal 2');
xlabel('Time (s)');
ylabel('Freq (Hz)');

[coh,crossspec,cohF]=wcoherence(signal1,signal2,Fs);
plottime = [0:1/Fs:(size(coh,2)-1)/Fs];
h = subplot(3,1,3); 
pcolor(plottime,cohF,coh); 
shading interp; 
colorbar; 
ylim([2.5 max(cohF)]);
box off;
caxis([0 1]);
linkaxes;
title('Coherence');
xlabel('Time (s)');
ylabel('Freq (Hz)');

% colormap jet;
set(gcf,'units','normalized','outerposition',[0 0 .25 .25]);
