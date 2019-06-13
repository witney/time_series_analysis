% generates spectrogram for 1 time series using Gabor wavelets

function [pwr,zpwr,ang,center_frequencies] = make_spectrogram_with_Gabor_wavelets(signal1,Fs)

minimum_frequency               = 2.5; % lowest freq to examine
maximum_frequency               = 200; % highest freq to examine (remember Nyquist! <samplingrate/2 at least!), 250
number_of_frequencies           = 100; % total number of frequencies to look at, 128
minimum_frequency_step_size     = .5;
fractional_bandwidth            = .35; % this sets the width of the gaussian for filtering; recommend between .2-.35

% generates center frequencies, a 128 point vector from min to max freq
% with step size that increases in spacing for higher freq
center_frequencies = make_center_frequencies(minimum_frequency,...
    maximum_frequency,number_of_frequencies,minimum_frequency_step_size)';

% get analytic signals per freq and calculate amplitude and phase angle
for frequency_index=1:number_of_frequencies
     analytic_signal1=gaussian_filter_signal('output_type',...
         'analytic_signal','raw_signal',signal1,'sampling_rate',Fs,...
         'center_frequency',center_frequencies(frequency_index),...
         'fractional_bandwidth',fractional_bandwidth);
            
     pwr(frequency_index,:)=abs(analytic_signal1);%.*conj(analytic_signal1);
     zpwr(frequency_index,:)=pwr(frequency_index,:)./center_frequencies(frequency_index);
     ang(frequency_index,:)=angle(analytic_signal1);   
end

% epoch_time=[1:1/Fs:size(pwr,2)/Fs];
% 
% figure; % plot spectrogram
% 
% h=subplot(1,1,1);
% clear tempcolor;
% tempmat=double(squeeze(zpwr(:,:)));
% pcolor(epoch_time,center_frequencies,tempmat);
% shading interp;
% tempcolor=zpwr(:,Fs*5:Fs*10);
% cmax=max(squeeze(tempcolor(:)));
% cmin=min(squeeze(tempcolor(:)));
% caxis([cmin cmax]);
% colorbar;
% title('Power', 'FontWeight', 'bold','FontSize',20);
% xlabel('Time (s)');
% ylabel('Frequency (Hz)');
% hold on;
% set(h,'YScale','log');
% set(h,'YTick',[2.5 4 8 16 32 64 128 250]); 

end
