% 1. reorganizes raw NO variables into ecog, lfp, emg, aux in matrix format
% 2. preprocesses data
% 3. rereferences data

%% Data Conversion

clear all;

files = dir('*.mat');

fileformat.ecog_module      = [1;2]; % modules with ecog data
fileformat.ecog_chan        = [14;14]; % last channel in each ecog module
fileformat.emg_module       = [3]; % modules with emg data
fileformat.emg_chan         = [2]; % last emg channel
fileformat.lfp_module       = [4]; % module with lfp data
fileformat.lfp_chan         = [4]; % last lfp channel
fileformat.aux_chan         = [1]; % aux channels
fileformat.M1needle_module  = [1];
fileformat.M1needle_chan    = [15];

reorganize_raw_NO_data(files,fileformat);



%% Preprocess

clear all;

files = dir('*matrix*');

for i = 1:length(files)
    EcogFileName=files(i).name;
    ecogPreprocess_matrixInput(EcogFileName); 
    clearvars -except files i
    close all
end


%% Rereference

clear all;

files = dir('*matrix.mat');

for i = 1:length(files)
    EcogFileName=files(i).name;
    load(EcogFileName)
    [ecog_preprocessReref0,lfp_preprocessReref2] = wc_ReReferenceData_matrixInput(ecog_preprocess,lfp_preprocess,0,bad,EcogFileName);
    save(EcogFileName,'-append','ecog_preprocessReref0','lfp_preprocessReref2');
    clearvars -except files i;
    close all
end

for i =1:length(files)
    EcogFileName=files(i).name;
    load(EcogFileName)
    [ecog_preprocessReref2,~] = wc_ReReferenceData_matrixInput(ecog_preprocess,lfp_preprocess,2,bad,EcogFileName);
    save(EcogFileName,'-append','ecog_preprocessReref2');
    clearvars -except files i;
    close all
end
