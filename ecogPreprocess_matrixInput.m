% 1. removes DC offset, highpasses above 1 Hz (3rd order butterworth instead of eegfilt)
% 2. downsamples to 1000 Hz
% 3. manual identification of bad electrodes
% 4. notch filters at 60 Hz and harmonics
% inputs: data in matrix format, ch x time
% outputs: preprocessed data in matrix format, ch x time

function EcogPreprocess_matrixInput(EcogFileName)

load(EcogFileName);


%% remove DC offset and low freq

ecog_preprocess = [];
ecog_preprocess_Fs = [];

% preprocess ecog
for k = 1:size(ecog_raw,1)
    if ~isempty(ecog_raw(k,:)) 
        [b,a] = butter(3,1/((ecog_raw_Fs(1)/2)),'high');
        ecog_preprocess(k,:) = filtfilt(b,a,ecog_raw(k,:)); %filter all signal<1hz using butterworth
        ecog_preprocess(k,:) = ecog_preprocess(k,:)-mean(ecog_preprocess(k,:)); %remove d/c offset
    end
end

% preprocess lfp
lfp_preprocess = [];
lfp_preprocess_Fs = [];
if ~isempty(lfp_raw)
    for k = 1:size(lfp_raw)
         [b,a] = butter(3,1/(lfp_raw_Fs(1)/2),'high');
         lfp_preprocess(k,:) = filtfilt(b,a,lfp_raw(k,:));
         lfp_preprocess(k,:) = lfp_preprocess(k,:)-mean(lfp_preprocess(k,:));
    end
end    

% preprocess aux
aux_preprocess = [];
aux_preprocess_Fs = [];
if ~isempty(aux_raw)
    for k = 1:size(aux_raw,1)
        aux_preprocess(k,:) = aux_raw(k,:)-mean(aux_raw(k,:));
    end
end

% preprocess emg
emg_preprocess = [];
emg_preprocess_Fs = [];
if ~isempty(emg_raw)
    for k = 1:size(emg_raw,1)
        emg_preprocess(k,:) = emg_raw(k,:)-mean(emg_raw(k,:));
    end
end

%% resample data

% resample ecog
for i = 1:size(ecog_preprocess,1)
    if ~isempty(ecog_preprocess(i,:))
        if round(ecog_raw_Fs(i))== 2750
            f1 = 2^10;
            f2 = (4^4)*11;
        elseif round(ecog_raw_Fs(i))== 11000
            f1 = 2^10;
            f2 = (2^10)*11;
        else
            f1 = 1000;
            f2 = round(ecog_raw_Fs(i));
%             f2=22000;
        end
        ecog_resamp(i,:) = resample(ecog_preprocess(i,:),f1,f2);
        ecog_preprocess_Fs(i) = 1000;
    end
end
ecog_preprocess = [];
ecog_preprocess = ecog_resamp; 
clear ecog_resamp;

% resample lfp
if ~isempty(lfp_raw)
    for i = 1:size(lfp_preprocess,1)
        if round(lfp_raw_Fs(i))== 2750
            f1 = 2^10;
            f2 = (4^4)*11;
        elseif round(ecog_raw_Fs(i))== 11000
            f1 = 2^10;
            f2 = (2^10)*11;
        else
            f1 = 1000;
            f2 = round(lfp_raw_Fs(i));
        end
            lfp_resamp(i,:) = resample(lfp_preprocess(i,:),f1,f2);
            lfp_preprocess_Fs(i) = 1000;
    end
    lfp_preprocess = []; 
    lfp_preprocess = lfp_resamp; 
    clear lfp_resamp;
end

% resample aux
if ~isempty(aux_raw)
    for i = 1:size(aux_preprocess,1)
        if round(aux_raw_Fs(i))== 2750
            f1 = 2^10;
            f2 = (4^4)*11;
        elseif round(aux_raw_Fs(i))== 24414
            f1 = 2^10;
            f2 = (5^5)*8;
        else
            f1 = 1000;
            f2 = round(aux_raw_Fs(i));
        end
        aux_resamp(i,:) = resample(aux_preprocess(i,:),f1,f2);
        aux_preprocess_Fs(i) = 1000;
    end
    aux_preprocess=[]; 
    aux_preprocess = aux_resamp; 
    clear aux_resamp;
end

% resample emg
if ~isempty(emg_raw)
    for i = 1:size(emg_preprocess,1)
        if round(emg_raw_Fs(i))== 2750
            f1 = 2^10;
            f2 = (4^4)*11;
        elseif round(emg_raw_Fs(i))== 24414
            f1 = 2^10;
            f2 = (5^5)*8;
        else
            f1 = 1000;
            f2 = round(emg_raw_Fs(i));
        end
            emg_resamp(i,:) = resample(emg_preprocess(i,:),f1,f2);           
            emg_preprocess_Fs(i) = 1000;
    end
    emg_preprocess=[]; 
    emg_preprocess=emg_resamp; 
    clear emg_resamp;
end

%% detection of bad electrodes

% plot preprocessed ecog to look at amplitudes
 figure; 
 hold on
 time = [1:1/ecog_preprocess_Fs(1):length(ecog_preprocess(1,:))/ecog_preprocess_Fs(1)];
 for i = 1: ceil(size(ecog_raw,1)/2)
     subplot(3,5,i)
     plot(time,ecog_preprocess(i,:))
     title(num2str(i))
%      ylim([-500 500])
 end
 linkaxes
 
 figure;hold on
 for i = ceil(size(ecog_raw,1)/2)+1: size(ecog_raw,1)
     subplot(3,5,i-size(ecog_raw,1)/2)
     plot(time,ecog_preprocess(i,:))
     title(num2str(i))
%     ylim([-500 500])
 end
linkaxes

% inspect channels and manually input noisy channels
bad=input('bad contacts:');

%% notch filter for line noise and harmonics around 60Hz, 120Hz and 180Hz
% butterworth notch filter - model order, [low/(Fs/2) high/(Fs/2)]

% notch filter ecog
for i = 1:size(ecog_preprocess,1)
    if ~isempty(ecog_preprocess(i,:))
        [n1_b, n1_a] = butter(3,2*[58 62]/ecog_preprocess_Fs(i),'stop'); %60hz
        [n2_b, n2_a] = butter(3,2*[118 122]/ecog_preprocess_Fs(i),'stop'); %120hz
        [n3_b, n3_a] = butter(3,2*[178 182]/ecog_preprocess_Fs(i),'stop'); %180hz
        
        ecog_preprocess(i,:) = filtfilt(n1_b, n1_a, ecog_preprocess(i,:)); %notch out at 60
        ecog_preprocess(i,:) = filtfilt(n2_b, n2_a, ecog_preprocess(i,:)); %notch out at 120
        ecog_preprocess(i,:) = filtfilt(n3_b, n3_a, ecog_preprocess(i,:)); %notch out at 180
    end
end

% notch filter lfp
if ~isempty(lfp_preprocess)
    for i = 1:size(lfp_preprocess,1)
        [n1_b, n1_a] = butter(3,2*[58 62]/lfp_preprocess_Fs(i),'stop'); %60hz
        [n2_b, n2_a] = butter(3,2*[118 122]/lfp_preprocess_Fs(i),'stop'); %120hz
        [n3_b, n3_a] = butter(3,2*[178 182]/lfp_preprocess_Fs(i),'stop'); %180hz
        
        lfp_preprocess(i,:) = filtfilt(n1_b, n1_a, lfp_preprocess(i,:)); %notch out at 60
        lfp_preprocess(i,:) = filtfilt(n2_b, n2_a, lfp_preprocess(i,:)); %notch out at 120
        lfp_preprocess(i,:) = filtfilt(n3_b, n3_a, lfp_preprocess(i,:)); %notch out at 180
    end
end

%% save data

save(EcogFileName,'-append','ecog_preprocess','ecog_preprocess_Fs',...
    'lfp_preprocess','lfp_preprocess_Fs','emg_preprocess','emg_preprocess_Fs',...
    'aux_preprocess','aux_preprocess_Fs','bad');

