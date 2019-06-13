% calculates PSD for all channels in ecog and lfp
% INPUTS: 
% ecog - data in matrix format (ch x time)
% lfp - data in matrix format (ch x time)
% bad - noisy ch
% Fs - sampling rate
% filename - string with file of name
% OUTPUTS: 
% log and normalized PSD 

function calculate_and_plot_PSD_matrixInput(ecog,lfp,bad,Fs,filename)

filename = strrep(filename,'.mat','');

%% merge ecog and lfp data into one matrix

data=[];
if ~isempty(lfp)
    data=[ecog; lfp];
else
    data=ecog;
end


%% calculate psd for each channel

psd=[];
for i = 1:size(data,1)
    if ~isempty(data(i,:))
        [psd,F] = pwelch(data(i,:),2^(nextpow2(Fs)),2^(nextpow2(Fs/2)),2^(nextpow2(Fs)),Fs);
    end

    if ~isempty(psd)
        psd_all(:,i)=psd;
        t = find(F>=1 & F<=4);
        psd_delta(i) = nanmean(log10(psd(t)));
        t = find(F>=5 & F<=7);
        psd_theta(i) = nanmean(log10(psd(t)));
        t = find(F>=8 & F<=12);
        psd_alpha(i) = nanmean(log10(psd(t)));
        t = find(F>=13 & F<=30);
        psd_beta(i) = nanmean(log10(psd(t)));
        t = find(F>=13 & F<=20);
        psd_Lbeta(i) = nanmean(log10(psd(t)));
        t = find(F>=20 & F<=30);
        psd_Hbeta(i) = nanmean(log10(psd(t)));
        t = find(F>=50 & F<=150);
        psd_gamma(i) = nanmean(log10(psd(t)));

        norm_idx=find(F>=5 & F<=100); % use norm_idx to normalize by max power between 8-100Hz
        psd_norm(:,i)=psd_all(:,i);
        psd_norm(:,i)=psd_all(:,i)/mean(psd_all(norm_idx(1):norm_idx(end),i)); % normalize each column to its max value

        t = find(F>=1 & F<=4);
        psd_norm_delta(i) = nanmean(log10(psd_norm(t)));
        t = find(F>=5 & F<=7);
        psd_norm_theta(i) = nanmean(log10(psd_norm(t)));
        t = find(F>=8 & F<=12);
        psd_norm_alpha(i) = nanmean(log10(psd_norm(t)));
        t = find(F>=13 & F<=30);
        psd_norm_beta(i) = nanmean(log10(psd_norm(t)));
        t = find(F>=13 & F<=20);
        psd_norm_Lbeta(i) = nanmean(log10(psd_norm(t)));
        t = find(F>=20 & F<=30);
        psd_norm_Hbeta(i) = nanmean(log10(psd_norm(t)));
        t = find(F>=30 & F<=50);
        psd_norm_gamma(i) = nanmean(log10(psd_norm(t)));
    end
    clear psd
end

save([filename '_psd'],'psd_theta', 'psd_delta','psd_alpha','psd_beta','psd_Lbeta','psd_Hbeta','psd_gamma','psd_all','F'...
    ,'psd_norm_theta', 'psd_norm_delta','psd_norm_alpha','psd_norm_beta','psd_norm_Lbeta','psd_norm_Hbeta','psd_norm_gamma','psd_norm','bad');


%% generate psd plots

% plot non-normalized psd
logpsdall = log10(psd_all);
figure;
for i = 1:size(psd_all,2)
    subplot(3,14,i)
    ha = gca;
    hold(ha,'on');
    plot(F,logpsdall(:,i),'k','LineWidth',2);
    if i<=28
        title(['C' num2str(i) ]); % allows title to have file name
        xlabel('frequency (Hz)');
        ylabel('log PSD');
%     elseif ~isempty(strfind(name,'lfp')) && i<=32 
%         title(['LFP C' num2str(i-29) ]);
    end
    xlim([0 150]);
    ylim([-3 3]);
    hold on
    fill([12 30 30 12],[-3 -3 3 3],'g','EdgeColor','none','FaceAlpha',0.3);
    fill([70 150 150 70],[-3 -3 3 3],'y','EdgeColor','none','FaceAlpha',0.3)
end
set(gcf,'units','normalized','outerposition',[0 0 1 1])
saveas(gcf,[filename '_logpsd'],'fig');


% plot normalized PSD
x2= max(max(log10(psd_norm)));
x1 = min(min(log10(psd_norm)));
log_psd_norm = log10(psd_norm);

figure;
for i = 1:size(psd_all,2)
    subplot(3,14,i)
    
    ha = gca;
    hold(ha,'on');
    plot(F,log_psd_norm(:,i),'k','LineWidth',2);
    if i<=28
        title(['C' num2str(i) ]);
        xlabel('frequency (Hz)');
        ylabel('log PSD');
%     elseif ~isempty(strfind(name,'lfp')) && i<=32 
%         title(['LFP C' num2str(i-29) ]);
    end
    xlim([0 150]);
    ylim([x1 x2]);
    fill([12 30 30 12],[x1 x1 x2 x2],'g','EdgeColor','none','FaceAlpha',0.3);
    fill([70 150 150 70],[x1 x1 x2 x2],'y','EdgeColor','none','FaceAlpha',0.3)
end
set(gcf,'units','normalized','outerposition',[0 0 1 1])
saveas(gcf,[filename '_normpsd'],'fig');

end
