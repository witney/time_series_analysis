% calculates coherence between all channel combinations in ecog and lfp
% uses matlab function mscohere (magnitude squared coherence)
% INPUTS: 
% ecog - data in matrix format, ch x time
% lfp - data in matrix format, ch x time
% bad - noisy ch
% Fs - sampling rate
% filename
% OUTPUTS: 
% Mcoher_* - coherence in theta, delta, alpha, beta, gamma bands

function [Mcoher_theta, Mcoher_delta, Mcoher_alpha, Mcoher_beta, Mcoher_gamma] = calculate_and_plot_coherence_matrixInput(ecog,lfp,bad,Fs,filename)

filename = strrep(filename,'.mat','');

% merge ecog and lfp into one matrix
data=[];
if ~isempty(lfp)
    data=[ecog; lfp];
else
    data=ecog;
end

% calculate coherence across all channel pairs
for i = 1:size(data,1)
    for j = i:size(data,1)
        if ~isempty(data(i,:)) && ~isempty(data(j,:))
            signal1 = data(i,:);
            signal2 = data(j,:);
            [Cxy,F] = mscohere(signal1,signal2,2^(nextpow2(Fs)),2^(nextpow2(Fs/2)),2^(nextpow2(Fs)),Fs);
        else
            Cxy = nan;
            F=nan;
        end
        
        Coh_all(:,i) =Cxy;
        t = find(F>=1 & F<=4);
        Mcoher_delta(i,j) = nanmean(Cxy(t));
        Mcoher_delta(j,i) = nanmean(Cxy(t));
        t = find(F>=5 & F<=7);
        Mcoher_theta(i,j) = nanmean(Cxy(t));
        Mcoher_theta(j,i) = nanmean(Cxy(t));
        t = find(F>=8 & F<=12);
        Mcoher_alpha(i,j) = nanmean(Cxy(t));
        Mcoher_alpha(j,i) = nanmean(Cxy(t));
        t = find(F>=13 & F<=30);
        Mcoher_beta(i,j) = nanmean(Cxy(t));
        Mcoher_beta(j,i) = nanmean(Cxy(t));
        t = find(F>=13 & F<=20);
        Mcoher_Lbeta(i,j) = nanmean(Cxy(t));
        Mcoher_Lbeta(j,i) = nanmean(Cxy(t));
        t = find(F>=20 & F<=30);
        Mcoher_Hbeta(i,j) = nanmean(Cxy(t));
        Mcoher_Hbeta(j,i) = nanmean(Cxy(t));
        t = find(F>=30 & F<=50);
        Mcoher_gamma(i,j) = nanmean(Cxy(t));
        Mcoher_gamma(j,i) = nanmean(Cxy(t));
        
    end 
end

% plot coherence matrices
figure;
subplot(2,4,1)
imagesc(Mcoher_delta)
caxis([0 .7])
title('delta')
subplot(2,4,2)
imagesc(Mcoher_theta)
caxis([0 .7])
title('theta')
subplot(2,4,3)
imagesc(Mcoher_alpha)
caxis([0 .7])
title('alpha')
subplot(2,4,4)
imagesc(Mcoher_beta)
caxis([0 .7])
title('beta')
subplot(2,4,5)
imagesc(Mcoher_Lbeta)
caxis([0 .7])
title('Lbeta')
subplot(2,4,6)
imagesc(Mcoher_Hbeta)
caxis([0 .7])
title('Hbeta')
subplot(2,4,7)
imagesc(Mcoher_gamma)
caxis([0 .7])
title('gamma')
colorbar;
saveas(gcf,[filename '_MCoher'],'fig');

set(gcf,'units','normalized','outerposition',[0 0 1 1])
saveas(gcf,[filename '_MCoher'],'fig');
save([filename '_MCoher'],'Mcoher_theta', 'Mcoher_delta','Mcoher_alpha','Mcoher_beta','Mcoher_Lbeta','Mcoher_Hbeta','Mcoher_gamma','Coh_all','F','bad');

end