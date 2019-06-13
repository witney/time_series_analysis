% re-references time series data with common average or bipolar
% INPUTS:
% ecog - ecog time series in matrix format, ch x time
% lfp - lfp time series in matrix format, ch x time
% ref_method - FOR ECOG ONLY (0=common mean, 1=common median, 2=bipolar with adjacent ch)
% (note: LFP is always bipolar re-referenced)
% bad - noisy channels to ignore for common mean/median


function [ecog_preprocessReref,lfp_preprocessReref] = rereference_matrixInput(ecog,lfp,ref_method,bad)
    
% if re-ref is with common mean/med subtraction
if ref_method <2 
    length_CAR = size(ecog,1);

    % exclude bad chan
    good = setdiff(1:size(ecog,1), bad);
    
    % define common reference
    if ref_method == 0 %  use common  mean
        ref = nanmean(ecog(good,:));
    elseif ref_method == 1 % use common median 
        ref = nanmedian(ecog(good,:));
    end
    
    % subtract common reference
    for i = 1:length_CAR
        if ~isempty(ecog(i,:) & sum(ecog(i,:)~=0))
            ecog_preprocessReref(i,:) = ecog(i,:)-ref;
        end
    end
end

% bipolar re-ref ecog
% note ecog strip is 14x2, so ch 14 does not get reref'd to ch 15
if ref_method == 2
    for i = 1:(ceil(size(ecog,1)/2)-1)
        if ~isempty(ecog(i,:)) & ~isempty(ecog(i+1,:))
            ecog_preprocessReref(i,:) = ecog(i,:)-ecog(i+1,:);
        end
    end
    ecog_preprocessReref(size(ecog,1)/2,:) = ecog(size(ecog,1)/2,:);
    for i = (ceil(size(ecog,1)/2)+1):(size(ecog,1)-1)
        if ~isempty(ecog(i,:)) & ~isempty(ecog(i+1,:))
            ecog_preprocessReref(i,:) = ecog(i,:)-ecog(i+1,:);
        end
    end
    ecog_preprocessReref(size(ecog,1),:) = ecog(size(ecog,1),:);
end

if (ref_method <0 || ref_method>2)
    ecog_preprocessRefef=[];
end

% bipolar re-ref lfp
if ~isempty(lfp)
    for i = 1:size(lfp,1)-1
        lfp_preprocessReref(i,:) = lfp(i,:)-lfp(i+1,:);
    end
else
    lfp_preprocessReref = [];
end

