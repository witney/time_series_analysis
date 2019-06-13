% runs basic analysis (power spectra, spectrograms, comodulograms)

%% to analyze preprocessed data (not re-referenced)

clear;

files = dir('*matrix.mat*');

for i = 1:length(files)
    file_name=files(i).name;
    load(file_name);

    % visualize ecog time series
    figure;
    for plotch=1:28
        subplot(4,7,plotch);
        plot(ecog_preprocess(plotch,:));
    end
    linkaxes;
    

    calculate_and_plot_PSD_matrixInput(ecog_preprocess,[],[],ecog_preprocess_Fs(1),file_name);
    calculate_and_plot_coherence_matrixInput(ecog_preprocess,lfp_preprocess,[],ecog_preprocess_Fs(1),file_name);
    calculate_and_plot_spectrograms_matrixInput(ecog_preprocess,lfp_preprocess,[],ecog_preprocess_Fs(1),file_name)
    
    clearvars -except files i
    close all
end


%% to analyze rereferenced data

clear

filesref = dir('*matrix.mat');

for i = 1:length(filesref)
    file_name=filesref(i).name;
    load(file_name)

    calculate_PSD_matrixInput(ecog_preprocessReref0,[],[],ecog_preprocess_Fs(1),file_name);
    calculate_coherence_matrixInput(ecog_preprocessReref0,lfp_preprocessReref2,[],ecog_preprocess_Fs(1),file_name);
    calculate_spectrograms_matrixInput(ecog_preprocessReref0,lfp_preprocessReref2,[],ecog_preprocess_Fs(1),file_name)
    
    clearvars -except filesref i
    close all
end
