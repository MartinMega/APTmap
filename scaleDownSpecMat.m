function [SpecTab_new] = scaleDownSpecMat(SpecTab_old, binedges_old, binedges_new)



%make a table for the results
SpecTab_new = table('Size',[height(SpecTab_old),1],'VariableNames', {'Experiment'}, 'VariableTypes', {'string'});
SpecTab_new = addvars(SpecTab_new, -1.*ones(height(SpecTab_old),length(binedges_new)-1), 'NewVariableNames', 'Spectrum');


bincenters_old = binedges_old(1:end-1) + (diff(binedges_old) ./ 2);

for k = 1:height(SpecTab_old)
    
    oldspec = SpecTab_old.Spectrum(k,:);    
    
    specassoc = discretize(bincenters_old, binedges_new);
    nanassoc = isnan(specassoc);
    specassoc(nanassoc) = 1;     % Trick: some bins of the histogram in APdb will not map to bins in the output (eg simply bs we don;t consider bins above eg 100 Da).
    oldspec(nanassoc) = 0;   % This means discretice will give us nans of these "unassociated bins". We cannot easily remove these BUT we can just set all of the
                                 % nans to 1 (means all of these unassociated bins will accumulate in the
                                 % first bin of the output) and set the spectrum that will be transformed to
                                 % the output specrum for these bins to 0. Accumulating all the zeros in one
                                 % bin -> bins geteffectively thrown away, which is what we want.
    scaledSpec = accumarray(specassoc', oldspec);
    
    % add zeros if the new binedges are longer
    % than the old ones
    if length(binedges_new)-1-length(scaledSpec) > 0 
        scaledSpec = [scaledSpec, zeros(1,length(binedges_new)-1-length(scaledSpec))];
    end
    
    %scaledSpec = padarray(scaledSpec, length(binedges_new)-1-length(scaledSpec), 0, 'post');
    
    scaledSpec = scaledSpec';
    
    
    % Add result to table.
    expname = SpecTab_old.Experiment(k);
    newrow = cell2table({expname, scaledSpec}, 'VariableNames', {'Experiment', 'Spectrum'});
    SpecTab_new(k,:) = newrow;
    

end