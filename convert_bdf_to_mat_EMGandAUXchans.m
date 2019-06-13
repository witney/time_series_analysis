% converts Biosemi bdf files into mat files, using biosig toolbox to read
% only saves ch used for emg and aux channels
% inputs: file directory with BDF files
% outputs: new file in .mat format, with EMG and AUX channels saved

function convert_bdf_to_mat_EMGandAUXchans(input_dir)

cd(input_dir);
files=dir('*.bdf*');

emg_channels = 8;
aux_channels = 2;

for q = 1:length(files)
    
    emg_raw = [];
    emg_raw_Fs = [];
    aux_raw = [];
    aux_raw_Fs = [];
    
    %read in EEG file
    EEG = pop_biosig([input_dir files(q).name]);
%     EEG = pop_biosig();

    % save emg channels
    for k = 1:emg_channels
        emg_raw(k,:) = double(EEG.data(64+k,:));
        emg_raw_Fs(k) = EEG.srate; 
    end
    
    % save aux channels
    for k = 1:aux_channels
        aux_raw(k,:) = double(EEG.data(74+k,:));
        aux_raw_Fs(k) = EEG.srate; 
    end
    
    clear k
    save([files(q).name(1:end-4) '.mat'],'emg_raw','emg_raw_Fs','aux_raw','aux_raw_Fs');
end
