% converts raw TDT files (.htk) to mat files
% reorganizes data into vars for ecog, lfp, emg, aux

function convert_htk_to_mat(directory,filename,ecog_ch,lfp_ch,aux_ch,emg_ch)

% load the data and store data as matrices

cd(directory);
files = dir('*.htk');
    
ecog_raw       = [];
ecog_raw_Fs    = [];
aux_raw        = [];
aux_raw_Fs     = [];
emg_raw        = [];
emg_raw_Fs     = [];
lfp_raw        = [];
lfp_raw_Fs     = [];
anin_raw       = []; 
anin_raw_Fs    = [];
signals_raw    = [];
signals_raw_Fs = [];
    
gain=1e6; % constant to convert ecog/lfp channel voltage level from V->microV to match GL4k system
Glfp = 25000;   % LFP channel gain  

% sort through htk files and reorganize
for abc=1:length(files)
    if ~isempty(strfind(files(abc).name,'htk'));
        % load the data and convert in mat.file
        file_name=files(abc).name;
        [d,fs,dt,tc,t]=readhtk(file_name);

        if ~isempty(strfind(file_name,'accel'))
            anin_raw=[anin_raw; d];
            anin_raw_Fs=[anin_raw_Fs fs];
        elseif ~isempty(strfind(file_name,'ANIN'))
            anin_raw=[anin_raw; d];
            anin_raw_Fs=[anin_raw_Fs fs];
        elseif ~isempty(strfind(file_name,'emg'))
            emg_raw=[emg_raw; d];
            emg_raw_Fs=[emg_raw_Fs fs];
        elseif ~isempty(strfind(file_name,'sound'))
            anin_raw=[anin_raw; d];
            anin_raw_Fs=[anin_raw_Fs fs];
        elseif ~isempty(strfind(file_name,'diode'))
            anin_raw=[anin_raw; d];
            anin_raw_Fs=[anin_raw_Fs fs];
        else            
            signals_raw(tc,:)=d.*gain;
            signals_raw_Fs(tc)=fs;
        end
    end
end
    
ecog_raw    = signals_raw(ecog_ch,:);
ecog_raw_Fs = signals_raw_Fs(ecog_ch);
lfp_raw     = signals_raw(lfp_ch,:);
lfp_raw_Fs  = signals_raw_Fs(lfp_ch);
aux_raw     = anin_raw(aux_ch,:);
aux_raw_Fs  = anin_raw_Fs(aux_ch);
emg_raw     = anin_raw(emg_ch,:);
emg_raw_Fs  = anin_raw_Fs(emg_ch);
    
clear d dt fs Fs t tc files anin* signals*
    
filename=[filename '_matrix'];
save(filename,'ecog_raw','ecog_raw_Fs','aux_raw','aux_raw_Fs',...
	'lfp_raw','lfp_raw_Fs','emg_raw','emg_raw_Fs','gain','filename');
end
