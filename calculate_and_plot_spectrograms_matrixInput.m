% plots spectrograms of data (using chronux function mtspecgramc)
% INPUTS: 
% ecog - data in matrix format, ch vs. time
% lfp - data in matrix format, ch vs. time
% bad - vector of noisy ch
% Fs - sampling rate
% filename

function calculate_and_plot_spectrograms_matrixInput(ecog,lfp,bad,Fs,filename)

filename = strrep(filename,'.mat','');

% merge ecog and lfp into one matrix
data=[];
if ~isempty(lfp)
    data=[ecog; lfp];
else
    data=ecog;
end

% generate spectrogram for each channel
params.tapers   = [3 5];
params.pad      = 1;
params.err      = [2 0.05];
params.trialave = 0;
params.Fs       = 1000;
movingwin       = [1 0.1];
signal          = [];

figure;
for i = 1:size(data,1)
    signal = data(i,:);
    if ~isempty(signal)
        [S,t,f,Serr] = mtspecgramc(signal,movingwin,params);
        SS(:,:,i)=S;
        subplot(3,14,i)
        imagesc(t,f,10*log10(S'));
        axis xy;
        ylim([0 150])
        caxis([-30 30])
        if i<=28
            title(['C' num2str(i)]);
%         elseif ~isempty(strfind(name,'lfp')) && i<=32 
%             title(['LFP C' num2str(i-29)]);
        end
%         if i ~= 1
%             axis off
%         end
    end
end

save([filename '_spect'],'SS', 't','f','Serr','bad');
set(gcf,'units','normalized','outerposition',[0 0 1 1])
saveas(gcf,[filename '_spect'],'fig');
