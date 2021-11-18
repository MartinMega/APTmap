function [relevantspec,binedges,bincenters, noisecurve_a] = getNoiseCorrSpecFromMassCharge(mnvalues, binwidth, confidence)
% This function takes an array of mass-charge values and returns a noise
% corrected mass-charge spectrum.
% Uses methods suggested by Haley et al in https://doi.org/10.1017/S1431927620024290 
% mnvalues - an array of m/n values, typically the 4th column in a pos array
% binwidth - bin width of the spctrum. 1e-1 or 1e-2 work well.
% confidence for noise fit. Should be 0.5, else the bg correction could be biased




% create histogram spectrum and binedges
binedges = linspace(0,max(mnvalues),ceil(max(mnvalues)/binwidth));
spectrum = histcounts(mnvalues, binedges);
bincenters = binedges(1:end-1) + ((binedges(2) - binedges(1))/2); 


[relevantspec, ~, noisecurve_a] = getRelevantSpec_spec(bincenters, spectrum, confidence);



end

