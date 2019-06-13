%makes log spaced frequencies

function center_frequencies=make_center_frequencies(minimum_frequency,...
    maximum_frequency,number_of_frequencies,minimum_frequency_step_size)


center_frequencies=zeros(1,number_of_frequencies);
temp1=(0:minimum_frequency_step_size:number_of_frequencies*minimum_frequency_step_size-minimum_frequency_step_size);
temp2=logspace(log10(minimum_frequency),log10(maximum_frequency),number_of_frequencies);
temp2=(temp2-temp2(1))*.((temp2(end)-temp1(end))/temp2(end))+temp2(1);
center_frequencies=temp1+temp2;
