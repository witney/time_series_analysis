% generates random values to offset event_indices by
% used for bootstrapping


function skip=make_skip_list(number_of_sample_points_in_signal,number_of_surrogate_runs,sample_rate)

skip=ceil(...                               %makes a random vector that is twice length of number
    rand(1,2*number_of_surrogate_runs)*...  % of surrogate runs, and randomly corresponds to points in 
    number_of_sample_points_in_signal);     %doesn't include the begining or end of signal
skip(find(skip<sample_rate))=[];
skip(find(...
    skip>number_of_sample_points_in_signal-sample_rate))=[];
skip=skip(1:number_of_surrogate_runs);  %takes what is left and picks surrogate runs to be random sampling points
