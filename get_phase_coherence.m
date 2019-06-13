function coh_data = get_phase_coherence(data, s_rate, frequency_range)
% Data is continuous data [n_channels x n_samples]
% s_rate is sample rate of data (Hz)
% frequency_range is a 2-element vector. First element is the frequency to start at, second element is the frequency to end at.



if(size(data,1) > size(data,2))
  fprintf('\n\nWarning: transposing data matrix to channels x samples\n\n');
  data = data';
end

n_channels = size(data,1);
n_samples = size(data,2);

% Bandpass filter data
fprintf('\tBandpass filtering from %d Hz to %d Hz\t', frequency_range(1), frequency_range(end));
%bandpass_data = X_bandpassfft(data, s_rate, frequency_range(1), frequency_range(end));
bandpass_data = eegfilt(data,s_rate,frequency_range(1),frequency_range(end));
clear data;
fprintf('\n');

% Hilbert transform
fprintf('\tHilbert transforming\t');
hilbert_data = zeros(n_channels,n_samples);
for channel_n = 1:n_channels
    hilbert_data(channel_n,:) = hilbert(squeeze(bandpass_data(channel_n,:)));
end
clear bandpass_data;
phase_data = angle(hilbert_data);
clear hilbert_data;
fprintf('\n');

% Calculate phase coherence
fprintf('\tComputing phase coherence\n');
coh_data = zeros(n_channels,n_channels);
for channel_n1 = 1:n_channels
  data1 = squeeze(phase_data(channel_n1,:));
  for channel_n2 = (channel_n1+1):n_channels
    data2 = squeeze(phase_data(channel_n2,:));
    coh_data(channel_n1,channel_n2) = abs(sum(exp(1i * (data1 - data2)), 'double')) / length(data1);
  end
end
% Copy values to opposite half of matrix to make it symmetric
for chan1 = 1:size(coh_data,1)
  coh_data(chan1,chan1,:) = 1;
  for chan2 = (chan1+1):size(coh_data,1)
    coh_data(chan2,chan1,:) = coh_data(chan1,chan2,:);
  end
end







%% Bandpass function
% Usage:
%  >> [smoothdata] = eegfiltfft(data,srate,locutoff,hicutoff);
%
% Inputs:
%   data        = (n_channels,n_samples) data to filter
%   srate       = data sampling rate (Hz)
%   locutoff    = low-edge frequency in pass band (Hz)  {0 -> lowpass}
%   hicutoff    = high-edge frequency in pass band (Hz) {0 -> highpass}
%
%
% Outputs:
%    smoothdata = smoothed data
%
% % Example: 
% s_rate = 500;
% n_samples = 1000;
% sig_freq = 20;
% lowcut = 18;
% highcut = 22;
% noise_level = 3;
% rand_phase = rand*pi;
% data = sin(linspace(0-rand_phase,sig_freq*2*pi*(n_samples/s_rate)-rand_phase,n_samples))*1.0 + rand(1,n_samples)*noise_level-(noise_level/2);
% X_bandpassfft(data, s_rate, lowcut, highcut);
%

function smoothdata = X_bandpassfft(data, s_rate, lowcut, highcut)

if nargin < 4
  help eegfiltfft;
end;

plot_it = 0;
plot_freqs = [0 80];

% Get size of data
[n_channels, n_samples] = size(data);
if(n_samples <= n_channels)
  error('\n\nERROR IN X_bandpassft. Input data might be transposed because it has more channels than data points.\n\n');
end

% Frequency vector for plotting
nfft = 2^nextpow2(n_samples);
freq_vector = s_rate/2*linspace(0,1,1+nfft/2);
freq_vector = [freq_vector(1:end) freq_vector((end-1):-1:2)];

if( (highcut-lowcut) < (freq_vector(9)-freq_vector(7)) )
  fprintf('\n\nERROR IN X_bandpassfft().  Difference between lowcut and highcut is too small.\n');
  fprintf('\tlowcut: %3.3f\n', lowcut);
  fprintf('\thighcut: %3.3f\n', highcut);
  fprintf('\tdifference: %1.3f\n', highcut-lowcut);
  fprintf('\tNFFT (%4.0f) makes frequency resolution %1.3f,\n', nfft, (freq_vector(9)-freq_vector(8)));
  fprintf('\tso difference between highcut and lowcut should be at least %1.3f\n\n', (freq_vector(9)-freq_vector(7)));
end

% find closest freq in fft decomposition to low and high cutoffs
[temp, idxl_1] = min(abs(freq_vector(1:floor(length(freq_vector)/2))-lowcut));
[temp, idxh_1] = min(abs(freq_vector(1:floor(length(freq_vector)/2))-highcut));
[temp, idxl_2] = min(abs(freq_vector(ceil(length(freq_vector)/2):end)-lowcut));  idxl_2 = idxl_2+ceil(length(freq_vector)/2)-1;
[temp, idxh_2] = min(abs(freq_vector(ceil(length(freq_vector)/2):end)-highcut)); idxh_2 = idxh_2+ceil(length(freq_vector)/2)-1;

if(plot_it == 1)
  figure('Position', [40 80 1000 800]);
end

% filter the data
% ---------------
smoothdata = zeros(n_channels,n_samples);
for channel_n=1:n_channels
  
  if(plot_it == 1)
    % Plot original signal
    subplot(5,1,[1 2]); hold on;
    plot(linspace(0,n_samples/s_rate,n_samples),data(channel_n,:),'b');
    xlim([0 n_samples/s_rate]);
  end
  
  fft_signal = fft(data(channel_n,:), nfft);
  
  if(plot_it == 1)
    % Plot FFT signal and filter limits
    subplot(5,1,[4 5]);
    plot(freq_vector, abs(fft_signal), 'b');
    %set(gca, 'YScale', 'log');
    xlabel('Frequency [Hz]');
    ylabel('Signal power [dB]');
    hold on;
    ymin = min(abs(fft_signal));
    ymax = max(abs(fft_signal));
    plot([freq_vector(idxl_1) freq_vector(idxl_1)], [ymin ymin+(ymax-ymin)/2], 'k', 'LineWidth', 2);
    plot([freq_vector(idxh_1) freq_vector(idxh_1)], [ymin ymin+(ymax-ymin)/2], 'k', 'LineWidth', 2);
    plot([freq_vector(idxl_2) freq_vector(idxl_2)], [ymin+(ymax-ymin)/2 ymax], 'g', 'LineWidth', 2);
    plot([freq_vector(idxh_2) freq_vector(idxh_2)], [ymin+(ymax-ymin)/2 ymax], 'g', 'LineWidth', 2);
    xlim([plot_freqs(1) plot_freqs(2)]);
  end
  
  % Generate gaussian mask
  mask_gaussianity = 1.0;
  %freq_indices = 1:length(freq_vector);
  center_index = round((idxh_1+idxl_1)/2);
  width = idxh_1-center_index;
  g_1 = ngaussian(1:length(freq_vector),center_index,width,mask_gaussianity); 
  center_index = round((idxh_2+idxl_2)/2);
  width = idxh_2-center_index;
  g_2 = ngaussian(1:length(freq_vector),center_index,width,mask_gaussianity);
  gaussian_mask = g_1 + g_2;
  
  if(plot_it == 1)
    % Plot FFT mask
    subplot(5,1,3);
    plot(freq_vector, gaussian_mask);
    xlim([plot_freqs(1) plot_freqs(2)]);
  end
  
  % Mask the signal
  masked_fft_signal = fft_signal .* gaussian_mask;
  
  if(plot_it == 1)
    % Plot masked FFT signal
    y_min = min(abs(fft_signal));
    y_max = max(abs(fft_signal));
    subplot(5,1,[4 5]);
    plot(freq_vector, abs(masked_fft_signal), 'r');
    xlim([plot_freqs(1) plot_freqs(2)]);
    ylim([y_min y_max]);
    set(gca, 'YScale', 'log');
  end
  
  padded_smoothdata = 2*real(ifft(masked_fft_signal));
  smoothdata(channel_n,:) = padded_smoothdata(1:n_samples);
  
  if(plot_it == 1)
    % Plot filtered signal
    subplot(5,1,[1 2]); hold on;
    plot(linspace(0,n_samples/s_rate,n_samples),smoothdata(channel_n,:),'r');
    xlim([0 n_samples/s_rate]);
    pause;
    close all;
  end
  
end

function g = ngaussian(x,pos,wid,n)
%  ngaussian(x,pos,wid) = peak centered on x=pos, half-width=wid
%  x may be scalar, vector, or matrix, pos and wid both scalar
%  Shape is Gaussian when n=1, becomes more rectangular as n increases.
% Example: ngaussian([1 2 3],1,2,1) gives result [1.0000    0.5000    0.0625]
g = exp(-((x-pos)./(0.6006.*wid)) .^(2*round(n)));






