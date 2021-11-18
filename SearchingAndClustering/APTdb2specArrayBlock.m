function [specmat] = APTdb2specArrayBlock(APTdb,binedges)
%creates a m by n array of all spectra from a given APTdb array with m
%entries. binedges is an array with ((n+1) entries for the binedges of
%output histograms. The histogram counts in APTdb combined and cropped to
%fit into the povided binedges, so binedges have to be the same binwith as the
%spectra in APTdb or a binwith that is a integer multiple of the binwiths
%in APTdb (currently APTdb uses binwith 0.001, so something like
%binedges=(0:0.001) or (0:0.01:100) should work fine.
%does not perform any scaling (eg such that they sum up to 1), this needs 
%to be sorted by the user if needed


specmat = -1 .* ones(length(APTdb), length(binedges)-1);
for k = 1:length(APTdb)
    
    APspec_bincenters = APTdb{k}.spec.binwidth .* (0.5+(0:(length(APTdb{k}.spec.corrspec)-1)));
    APspec_spec = APTdb{k}.spec.corrspec;
    
    specassoc = discretize(APspec_bincenters, binedges);
    nanassoc = isnan(specassoc);
    specassoc(nanassoc) = 1; % Trick: some bins of the histogram in APdb will not map to bins in the output (eg simply bc we don;t consider bins above eg 100 Da).
    APspec_spec(nanassoc) = 0; % This means discretice will give us nans of these "unassociated bins". We cannot easily remove these BUT we can just set all of the 
                               % nans to 1 (means all of these unassociated bins will accumulate in the
                               % first bin of the output) and set the spectrum that will be transformed to
                               % the output specrum for these bins to . Accumulating all the zeros in one
                               % bin -> bins geteffectively thrown away, which is exactly what we want.    
    scaledSpec = accumarray(specassoc', APspec_spec);
    clear APspec_spec % clear the APspec_spec to avoid accitentially re-using it after we set some bins to zero in the "Trick" above.


    specmat(k,:) = padarray(scaledSpec, size(specmat,2)-length(scaledSpec), 0, 'post');

end


end

