% findBetaBursts for high res M1 data
% matrix input

function [ecog_beta,ecog_beta_Fs,ecog_betaPwr,ecog_betaMed,ecog_betaThresh,ecog_betaBurst_start,ecog_betaBurst_end,ecog_betaBurst_raster,ecog_betaBurst_meanPwr,ecog_betaBurst_maxPwr,ecog_betaBurst_duration]=wc_findBetaBursts_M1_matrixInput(ecog,Fs,file_name)

%% 0 - make filters for later
% Fs=ecog_raw_Fs(1); % ASSUMING ALL CHANNELS HAVE SAME SAMPLING FREQ
butter100low = designfilt('lowpassiir','FilterOrder',8,'HalfPowerFrequency',100,'SampleRate',round(Fs),'DesignMethod','butter');
butterBeta = designfilt('bandpassiir','FilterOrder',4, ...
    'HalfPowerFrequency1',13,'HalfPowerFrequency2',30, ...
    'SampleRate',220);

%clear Fs
%% 1 - lowpass filter @ 100 Hz

for i=1:size(ecog,1)
    ecog_beta(i,:)=filtfilt(butter100low,ecog(i,:));
end

% for i=1:length(lfp.contact)
%     lfp.contact(i).beta = filtfilt(butter100low,lfp.contact(i).signal);
% end

clear i

%% 2 - downsample to 220Hz

newF = 220; 

for i=1:size(ecog_beta,1)
    temp(i,:)=resample(ecog_beta(i,:),newF,round(Fs));
    ecog_beta_Fs(i)=newF;
end

ecog_beta=[]; ecog_beta=temp;

% for i=1:length(lfp.contact)
%     lfp.contact(i).beta = resample(lfp.contact(i).beta,newF,round(lfp.Fs(i)));
%     lfp.FsB(i) = newF;
% end

clear i newF 

%% 3 - bandpass filter @ 13-30 Hz

for i=1:size(ecog_beta,1)
    ecog_beta(i,:)=filtfilt(butterBeta,ecog_beta(i,:));
end

% for i=1:length(ecog.contact_pair)
%     ecog.contact_pair(i).beta = filtfilt(butterBeta,ecog.contact_pair(i).remontaged_ecog_signal);
% end

% for i=1:length(lfp.contact)
%     lfp.contact(i).beta = filtfilt(butterBeta,lfp.contact(i).beta);
% end

clear i

%% 4 - square the value of each sample

for i=1:size(ecog_beta,1)
    ecog_betaPwr(i,:)=(ecog_beta(i,:)).^2;
end

% for i=1:length(lfp.contact)
%     for j=1:length(lfp.contact(i).beta)
%         lfp.contact(i).betaPwr(j) = lfp.contact(i).beta(j)^2;
%     end
% end

clear i j

%% 5 - smooth with Hanning window 35 samples wide

w = hann(35, 'symmetric');
% w = hann(160, 'symmetric');

for i=1:size(ecog_betaPwr,1)
    ecog_betaPwr(i,:) = conv(ecog_betaPwr(i,:),w,'same');
end

% for i=1:length(lfp.contact)
%     lfp.contact(i).betaPwr = conv(lfp.contact(i).betaPwr,w,'same');
% end

clear w i

%% 6 - calculate median for whole trace
for i=1:size(ecog_betaPwr,1)
    ecog_betaMed(i) = median(ecog_betaPwr(i,:));
    ecog_betaThresh(i) = 3*ecog_betaMed(i);
end

% for i=1:length(lfp.contact)
%     lfp.contact(i).medB = median(lfp.contact(i).betaPwr);
%     lfp.contact(i).thresh = 3*lfp.contact(i).medB;
% end

clear i
%% 6.5 - OR, IF STIM FILE, only calculate median for pre-stim samples
% 
% stimStart = 14520; % estimate sample number in betaPwr file
% 
% for i=1:length(ecog.contact)
%     ecog.contact(i).medB = median(ecog.contact(i).betaPwr(1:stimStart));
%     ecog.contact(i).thresh = 3*ecog.contact(i).medB;
% end
% 
% for i=1:length(lfp.contact)
%     lfp.contact(i).medB = median(lfp.contact(i).betaPwr(1:stimStart));
%     lfp.contact(i).thresh = 3*lfp.contact(i).medB;
% end
% 
% clear i stimStart

%% 7 - mark a burst every time go above 3x median

% for i=1:size(ecog_betaPwr,1)
%     for j=1:size(ecog_betaPwr,2)
%         if ecog_betaPwr(i,j)>ecog_betaThresh(i)
%             ecog_betaBurst_raster(i,j)=1;
%         else
%             ecog_betaBurst_raster(i,j)=0;
%         end
%     end
% end

% identify indices for burst beginning, peak, and end
for i=1:size(ecog_betaPwr,1)
    
    beta_peak=[];
    beta_min=[];
    temp1=[];
    temp2=[];
    start=[];
    finish=[];
    
    beta_peak=find(ecog_betaPwr(i,:)>ecog_betaThresh(i)); % find peaks
    beta_min=find(ecog_betaPwr(i,:)<1.5*ecog_betaMed(i)); % find all values below minimum

    for n=1:length(beta_peak) 
    	temp1=find(beta_min<beta_peak(n)); %find all min values before peak
        temp2=find(beta_min>beta_peak(n)); %find all min values after peak
        if ~isempty(temp1) && ~isempty(temp2)
            start=[start beta_min(temp1(end))]; %burst begins at last min point before peak
            finish=[finish beta_min(temp2(1))];  %burst ends at the first min point after peak
        end
    end
    
    ecog_betaBurst_start{i}=unique(start); % remove repeated bursts
    ecog_betaBurst_end{i}=unique(finish);
end

% generate raster of beta bursts
ecog_betaBurst_raster=0*ones(28,length(ecog_betaPwr));
for i=1:size(ecog_betaPwr,1)
    for j=1:size(ecog_betaBurst_start{i},2)
        ecog_betaBurst_raster(i,ecog_betaBurst_start{i}(j):ecog_betaBurst_end{i}(j))=1;
    end
end

% plot burst detection for sample channel
% figure; plot(ecog_betaPwr(3,:)); hold on; 
% plot([1:length(ecog_betaPwr(3,:))],ecog_betaThresh(3)*ecog_betaBurst_raster(3,:),'*r');


% for i=1:length(lfp.contact)
%     for j=1:length(lfp.contact(i).betaPwr)
%         if lfp.contact(i).betaPwr(j)>lfp.contact(i).thresh
%             lfp.contact(i).burst(j)=1;
%         else
%             lfp.contact(i).burst(j)=0;
%         end
%     end
% end

%% 8 - characterize properties of bursts

% duration, mean power, max power
for i=1:size(ecog_betaPwr,1)
    for j=1:size(ecog_betaBurst_start{i},2)
        ecog_betaBurst_meanPwr{i}(j)=nanmean(ecog_betaPwr(i,ecog_betaBurst_start{i}(j):ecog_betaBurst_end{i}(j)));
        ecog_betaBurst_maxPwr{i}(j)=max(ecog_betaPwr(i,ecog_betaBurst_start{i}(j):ecog_betaBurst_end{i}(j)));
        ecog_betaBurst_duration{i}(j)=(ecog_betaBurst_end{i}(j)-ecog_betaBurst_start{i}(j))/ecog_beta_Fs(i);
    end
end

%% 9 - burst density calculation

% average over trials of the binary burst time series, aligned to specific task event



clearvars butter100low butterBeta i j
file_name=[file_name '_betaBursts'];
save(file_name)
