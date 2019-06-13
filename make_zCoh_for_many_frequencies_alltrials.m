function ...
    [S11,...
    S22,...
    S12,...
    Coh,...
    C12_trial,...
    C11_trial,...
    C22_trial,...
    angleCoh,...
    zCoh,...
    mean_of_prestimulus_segment_of_Coh,...
    surrogate_Coh_fit]=...
    wc_make_zCoh_for_many_frequencies_alltrials(...
    analytic_signal1,...
    analytic_signal2,...
    event_indices,...
    start_epoch_at_this_sample_point,...
    stop_epoch_at_this_sample_point,...
    start_baseline_indices,...
    stop_baseline_indices,...
    skip)

% function ...
%     [Coh,...
%     zCoh,...
%     mean_of_prestimulus_segment_of_Coh,...
%     surrogate_Coh_fit]=...
%     make_zCoh_for_many_frequencies_for_one_condition(...
%     analytic_signal_1,...
%     analytic_signal_2,...
%     event_indices,...
%     start_epoch_at_this_sample_point,...
%     stop_epoch_at_this_sample_point,...
%     baseline_info,...
%     skip)



number_of_frequencies=size(analytic_signal1,1);                 %initilize variables
number_of_sample_points_in_signal=size(analytic_signal1,2);
number_of_surrogate_runs=size(skip,2);

event_indices(find(event_indices<...                        %take out ones too close to the end or the begining
    abs(start_epoch_at_this_sample_point)))=[];
event_indices(find(event_indices>...
    number_of_sample_points_in_signal-...
    abs(stop_epoch_at_this_sample_point)))=[];
number_of_epochs=length(event_indices);
number_of_sample_points_in_epoch=...
    length(...
    start_epoch_at_this_sample_point:...
    stop_epoch_at_this_sample_point);
number_of_sample_points_in_baseline=length(start_baseline_indices(1):...
    stop_baseline_indices(1));

% Coherence (absolute values)
Coh=zeros(...
    number_of_frequencies,...
    number_of_sample_points_in_epoch,'single');
% Coherence per trial
Coh_trial=zeros(...
    number_of_frequencies,...
    number_of_sample_points_in_epoch,...
    number_of_epochs,'single');
% Autospectra - channel 1
S11=zeros(...
    number_of_frequencies,...
    number_of_sample_points_in_epoch,'single');
% Autospectra - channel 2
S22=zeros(...
    number_of_frequencies,...
    number_of_sample_points_in_epoch,'single');
% Crosspectra
S12=zeros(...
    number_of_frequencies,...
    number_of_sample_points_in_epoch,'single');
% Phase Lag
angleCoh=zeros(...
    number_of_frequencies,...
    number_of_sample_points_in_epoch,'single');
% Phase Lag per trial
angleCoh_trial=zeros(...
    number_of_frequencies,...
    number_of_sample_points_in_epoch,...
    number_of_epochs,'single');
% Baseline values of Coh
baseline_Coh=zeros(...
    number_of_frequencies,...
    number_of_sample_points_in_baseline,'single');
% Baseline values of Coh per trial
baseline_Coh_trial=zeros(...
    number_of_frequencies,...
    number_of_sample_points_in_baseline,...
    number_of_epochs,'single');
% z score Coherence
zCoh=zeros(size(Coh),'single');
surrogate_Cohs=zeros(...
    number_of_frequencies,...
    number_of_surrogate_runs,'single');
surrogate_Coh_fit=zeros(...
    number_of_frequencies,2,'single');

% Temporary variables
Coh_sum_seg12=zeros(1,number_of_sample_points_in_epoch);
Coh_sum_seg11=zeros(1,number_of_sample_points_in_epoch);
Coh_sum_seg22=zeros(1,number_of_sample_points_in_epoch);

Coh_sum_baseline_seg12=zeros(1,number_of_sample_points_in_baseline);
Coh_sum_baseline_seg11=zeros(1,number_of_sample_points_in_baseline);
Coh_sum_baseline_seg22=zeros(1,number_of_sample_points_in_baseline);

for e=1:number_of_epochs
%    disp(['epochs remaining = ' int2str(e)]);
    segment_1=analytic_signal1(:,...     
        event_indices(e)+...
        (start_epoch_at_this_sample_point:...
        stop_epoch_at_this_sample_point));
    
    segment_2=analytic_signal2(:,...    
        event_indices(e)+...
        (start_epoch_at_this_sample_point:...
        stop_epoch_at_this_sample_point));
       
    baseline_segment_1= analytic_signal1(:,...    
        event_indices(e)+...
        (round(start_baseline_indices(e)):...
        round(stop_baseline_indices(e))));
    
    baseline_segment_2= analytic_signal2(:,...     
        event_indices(e)+...
        (round(start_baseline_indices(e)):...
        round(stop_baseline_indices(e))));

%     C_seg=segment_1.*conj(segment_2);
%     Coh_sum_seg=Coh_sum_seg+C_seg./(abs(segment_1).*abs(segment_2));;
%     
%     C_baseline_seg=baseline_segment_1.*conj(baseline_segment_2);
%     Coh_sum_baseline_seg=Coh_sum_baseline_seg+C_baseline_seg./(abs(baseline_segment_1).*abs(baseline_segment_2));
%     

    C_seg12=segment_1.*conj(segment_2);
    C_seg11=segment_1.*conj(segment_1);
    C_seg22=segment_2.*conj(segment_2);
    
%     Coh_trial(:,:,e)=squeeze(abs(C_seg12).^2 ./ (C_seg11.*C_seg22));
    C12_trial(:,:,e)=C_seg12;
    C11_trial(:,:,e)=C_seg11;
    C22_trial(:,:,e)=C_seg22;
%     [Coh_trial(:,:,e),~,Coh_trial_F]=wcoherence;
    angleCoh_trial(:,:,e)=squeeze(angle(C_seg12).^2 ./ (abs(segment_1).*abs(segment_2)));

    Coh_sum_seg12=Coh_sum_seg12+C_seg12;
    Coh_sum_seg11=Coh_sum_seg11+C_seg11;
    Coh_sum_seg22=Coh_sum_seg22+C_seg22;  
    
    C_baseline_seg12=baseline_segment_1.*conj(baseline_segment_2);
    C_baseline_seg11=baseline_segment_1.*conj(baseline_segment_1);
    C_baseline_seg22=baseline_segment_2.*conj(baseline_segment_2);   

    baseline_Coh_trial(:,:,e) = squeeze(abs(C_baseline_seg12 ./ sqrt(C_baseline_seg11.*C_baseline_seg22)));
   
    Coh_sum_baseline_seg12=Coh_sum_baseline_seg12+C_baseline_seg12;
    Coh_sum_baseline_seg11=Coh_sum_baseline_seg11+C_baseline_seg11;
    Coh_sum_baseline_seg22=Coh_sum_baseline_seg22+C_baseline_seg22;    

end

normalizer=1/number_of_epochs;
Coh_sum_seg12=Coh_sum_seg12*normalizer;
Coh_sum_seg11=Coh_sum_seg11*normalizer;
Coh_sum_seg22=Coh_sum_seg22*normalizer;

S11=( Coh_sum_seg11 );
S22=( Coh_sum_seg22 );
S12=( Coh_sum_seg12 );

Coh=abs( Coh_sum_seg12./ sqrt(Coh_sum_seg11.*Coh_sum_seg22));
%itc=itc*normalizer;
angleCoh=angle( Coh_sum_seg12./ sqrt(Coh_sum_seg11.*Coh_sum_seg22) );


Coh_sum_baseline_seg12=Coh_sum_baseline_seg12*normalizer;
Coh_sum_baseline_seg11=Coh_sum_baseline_seg11*normalizer;
Coh_sum_baseline_seg22=Coh_sum_baseline_seg22*normalizer;

baseline_Coh = abs( Coh_sum_baseline_seg12 ./ sqrt(Coh_sum_baseline_seg11 .* Coh_sum_baseline_seg22 ));

 mean_of_prestimulus_segment_of_Coh=...      %finds baseline values, (before stimulus)
     mean(...
     baseline_Coh,2);

for s=1:number_of_surrogate_runs
%     if mod(s,1000)==0
%         disp(['surrogate runs remaining = ' int2str(number_of_surrogate_runs-s)]);
%     end
    surrogate_event_indices=mod(...   %[picks surrogate runs
        event_indices+skip(s),...
        number_of_sample_points_in_signal);
    
    surrogate_event_indices(...   %if an event indice = 0, then just assing it to the end of the data (why?)
        find(surrogate_event_indices==0))=...
        number_of_sample_points_in_signal;
    
    surr_seg_1=analytic_signal1(:,surrogate_event_indices);
    surr_seg_2=analytic_signal2(:,surrogate_event_indices);
    surr_Coh12=surr_seg_1 .* conj(surr_seg_2);
    surr_Coh11=surr_seg_1 .* conj(surr_seg_1);
    surr_Coh22=surr_seg_2 .* conj(surr_seg_2);
    surr_Coh12=sum(surr_Coh12)/number_of_epochs;
    surr_Coh11=sum(surr_Coh11)/number_of_epochs;
    surr_Coh22=sum(surr_Coh22)/number_of_epochs;
    
    surrogate_Cohs(:,s)=...   %calc for surrogates
        abs(surr_Coh12/sqrt(surr_Coh11*surr_Coh22 ) )   ;
    
    
  %  surrogate_itcs(:,s)=...
  %      mean(...
  %      exp(i*angle(...
  %      analytic_signals(:,surrogate_event_indices))),2);
end

% clf;
% hist(surrogate_Cohs);
% pause(0.25);

for f=1:number_of_frequencies

    [surrogate_Coh_fit(f,1),surrogate_Coh_fit(f,2)]=...  %come up with firts for surrogates
        normfit(double(surrogate_Cohs(f,:)));
    
    zCoh(f,:)=(Coh(f,:)-repmat(...
        surrogate_Coh_fit(f,1),size(Coh(f,:))))./...                               %subtract surrogates from real data
        repmat(surrogate_Coh_fit(f,2),size(Coh(f,:)));
    
    %surrogate_itc_fit(f)=...
    %    raylfit(double(abs(surrogate_itcs(f,:))))';         %same for itc, new kind of fit
    %zitc(f,:)=norminv(...
    %    raylcdf(abs(itc(f,:)),surrogate_itc_fit(f)),...
    %    0,1);
    
end
