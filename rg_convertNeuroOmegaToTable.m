% converts a raw Neuro Omega .mat to a MATLAB table 
% input: Neuro Omega file name (full path) 
% output: 2 tables, 1 with brain dta (dataTbl) the other with analog (anaTbl)
%         These tabels will be saved to .mat file of same name 
%         In same location, with ending '_table'.           

function [dataTbl,anaTbl] = rg_convertNeuroOmegaToTable(filename)

load(filename); 

%% convert brain data 
% find only variables that start wtih CECOG 
temp = whos('CECOG*');
rawnames = {temp.name}';
ecogVars = rawnames(~strncmp('CECOG_LF_',rawnames,9));
logexc = cellfun(@any, regexp(ecogVars,'BitResolution$')) | ...
         cellfun(@any, regexp(ecogVars,'Gain$')) | ... 
         cellfun(@any, regexp(ecogVars,'KHz$')) | ... 
         cellfun(@any, regexp(ecogVars,'KHz_Orig$')) | ... 
         cellfun(@any, regexp(ecogVars,'TimeBegin$')) | ... 
         cellfun(@any, regexp(ecogVars,'TimeEnd$'));
ecogNames = rawnames(~logexc);
for e = 1:size(ecogNames,1) 
    dat(e).varname  = ecogNames{e};
    % get channel / array/ module numbes
    strnums = regexp(ecogNames{e},'[0-9]+','match'); 
    chnident = cellfun(@str2num,strnums); % channel / array / module number 
    dat(e).module_num  = chnident(1);% first number is module number
    dat(e).module_chan  = chnident(2);% second number is internal module channel count.
%     dat(e).array_numb  = chnident(3);% third number is array number (this is grouping of modules)
%     dat(e).array_chan  = chnident(4);% fourth number is array channel number (running count within array)
    % get other variables 
    dat(e).bit_res  = eval([ecogNames{e} '_BitResolution']);
    dat(e).gain     = eval([ecogNames{e} '_Gain']);
    dat(e).khz      = eval([ecogNames{e} '_KHz']);
    dat(e).khz_orig = eval([ecogNames{e} '_KHz_Orig']);
    dat(e).time_beg = eval([ecogNames{e} '_TimeBegin']);
    dat(e).time_end = eval([ecogNames{e} '_TimeEnd']);
    dat(e).data = double(eval(ecogNames{e}));
end
dataTbl = struct2table(dat); 

%% convert analog data 
temp = whos('CANALOG*');
anaVars = {temp.name}';
logexc = cellfun(@any, regexp(anaVars,'BitResolution$')) | ...
         cellfun(@any, regexp(anaVars,'Gain$')) | ... 
         cellfun(@any, regexp(anaVars,'KHz$')) | ... 
         cellfun(@any, regexp(anaVars,'KHz_Orig$')) | ... 
         cellfun(@any, regexp(anaVars,'TimeBegin$')) | ... 
         cellfun(@any, regexp(anaVars,'TimeEnd$'));
anaNames = anaVars(~logexc);
for e = 1:size(anaNames,1) 
    datan(e).varname  = anaNames{e};
    datan(e).ana_num  = e; 
    % get other variables 
    datan(e).bit_res  = eval([anaNames{e} '_BitResolution']);
    datan(e).gain     = eval([anaNames{e} '_Gain']);
    datan(e).khz      = eval([anaNames{e} '_KHz']);
    datan(e).khz_orig = eval([anaNames{e} '_KHz_Orig']);
    datan(e).time_beg = eval([anaNames{e} '_TimeBegin']);
    datan(e).time_end = eval([anaNames{e} '_TimeEnd']);
    datan(e).data = double(eval(anaNames{e}));
end
anaTbl = struct2table(datan); 
[pn,fn,ext] = fileparts(filename); 
% save(fullfile(pn,[fn '_table' ext]),'dataTbl','anaTbl'); 
end