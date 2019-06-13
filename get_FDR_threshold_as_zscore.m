function ...
    threshold_zscore=...
    get_FDR_threshold_as_zscore...
    (array_of_zscores,...
    FDR_alpha)
% function threshold_zscore=get_FDR_threshold_as_zscore(array_of_zscores,FDR_alpha,number_of_comparisons);
% array_of_zscores: array of z-score values
% FDR_alpha: e.g. 0.01
% number_of_comparisons: true number of tests, may be larger than array_of_zscores if array_of_zscores has
% already been cleared of values greater than FDR_alpha
%returns FDR corrected z-threshold

number_of_comparisons=numel(array_of_zscores);
array_size=size(array_of_zscores);
[largest_dim_length,largest_dim]=max(array_size);
zcell=squeeze(num2cell(array_of_zscores,largest_dim));
%clear array_of_zscores
lengthall=0;
FDR_z=abs(norminv(.5*FDR_alpha,0,1));

for n=1:prod(size(zcell))
    temp=abs(zcell{n}(:));
    temp(find(temp<FDR_z))=[];
    zcell{n}=temp;
    lengthall=lengthall+length(temp);
end
array_of_zscores2=zeros(lengthall,1);
array_of_zscores2(1:length(zcell{1}))=zcell{1};
counterind=length(zcell{1});
for n=2:prod(size(zcell))
    array_of_zscores2(counterind+(1:length(zcell{n})))=zcell{n};
    counterind=counterind+length(zcell{n});
end
%clear zcell

p=sort(2*normcdf(-array_of_zscores2,0,1),'ascend');
numtest=length(p);
testagainst=(FDR_alpha*(1:numtest)/number_of_comparisons)';
p_logical=(p<=testagainst);
threshold=squeeze(testagainst(max(find(p_logical==1))));
if isempty(threshold)
    threshold=0;
end
threshold_zscore=abs(norminv(.5*threshold,0,1));
% 
% 
% testaginstz=abs(norminv(.5*testagainst,0,1));
% z2=eegfilt(array_of_zscores,2003,0,10);
% z22=sort(abs(z2(:)));
% z=sort(abs(array_of_zscores(:)));
% plot(flipud(z),'k');
% hold on;
% plot(flipud(z2));
% plot(testaginstz,'r');
% hold off;
% axis([0 1000 3.5 5]);
% 
% plot(p,'k');
% hold on;
% plot(testagainst,'r');
% hold off;
