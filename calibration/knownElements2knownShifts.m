function [knownShiftsTab] = knownElements2knownShifts(SpecTab, KnownElementsTab)
%needed: spectab, binedges (for spectab), binwidth must be 1e-3!


% Combine SpecTab and knownElementsTab.
% Check if result is as long as SpecTab and knownElementsTab. If not, complain!
FullTab = innerjoin(SpecTab, KnownElementsTab, 'Keys', {'Experiment', 'Experiment'});
if ((height(FullTab) ~= height(SpecTab)) || (height(FullTab) ~= height(KnownElementsTab)))
    warning('Experiment Names in SpecTab and KnownElementsTab dont fully match. Are you sure you have loaded the correct SpecTab and KnownElementsTab?')
end



tab_Varnames = {'Experiment', 'H+', 'Ti++', 'Mo++', 'Cr++', 'Zr++', 'U+++', 'Ga+'};
tab_Vartypes = {'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};
knownShiftsTab = table('Size', [height(FullTab),length(tab_Varnames)], 'VariableNames', tab_Varnames, 'VariableTypes', tab_Vartypes);
clear tab_Varnames tab_Vartypes
knownShiftsTab.Experiment = FullTab.Experiment;



% 1. Populate the H shift column
% Other than for every other element, there is no autocorr here.
% instead, we just search for maximum between 0.6 and 1.4 Da.
% if the max is less than 0.2 off from the 1.0078 where the H should be, we
% use this for the spectrum shift. If not, the H spectrum probably looks
% weird and we skip.
binwidth = 1e-3; %important: this script just assumes thay binwith is 1e-3 everywhere in APTdb.
aios = round((0.6:binwidth:1.4) ./ binwidth);
for k = 1:height(FullTab)
    spec = spec_chop_and_norm(FullTab.Spectrum(k,:), aios);
    spec = smoothdata(spec, 'gaussian', 3); %some gaussian smoothing - some spectra have very few counts
    [~,maxind] =  max(spec);
    lag = (aios(1) + maxind) - (1.0078./binwidth);
    lag = lag .* binwidth;  %positive lag -> spec is off to the right
                            %negative lag -> spec is off to the left
    if (abs(lag)<0.2)
        knownShiftsTab.("H+")(k) = lag;
    else
        knownShiftsTab.("H+")(k) = nan;
    end
end



% 3.1. Populate the Ti shift column
% prepare Ref dataset
binwidth = 1e-3;
refpos = qreadpos("R56_00545-v01.pos"); % This is a datasets which contains a nicely calibrated fingerprint of Ti. Also see footnote [A]
histedges = 0:binwidth:(max(refpos(:,4))+1);
refspec = histcounts(refpos(:,4), histedges);
aios = round((22.7:binwidth:24.7) ./ binwidth);
refspec = spec_chop_and_norm(refspec, aios);
% 3.2. Loop through APTdb, correct
maxlag = 500; %generous maximum lag here - we know the Ti traces are in there, so don;t need to care for accidential fits with other signatures
% loop, autocorrelate, write factor into table
for k = 1:height(FullTab)
    if (FullTab.("Ti++")(k) == true)
        spec = FullTab.Spectrum(k,:);
        lag = autocorr_getlag(refspec, spec, aios, maxlag, binwidth);
        knownShiftsTab.("Ti++")(k) = lag;
    else
        knownShiftsTab.("Ti++")(k) = nan;
    end
end




% 4.1. Populate the Mo shift column
% prepare Ref dataset
binwidth = 1e-3;
refpos = qreadpos("R56_00545-v01.pos"); % This is a datasets which contains a nicely calibrated fingerprint of Mo. Also see footnote [A]
histedges = 0:binwidth:(max(refpos(:,4))+1);
refspec = histcounts(refpos(:,4), histedges);
aios = round((46.7:binwidth:49.3) ./ binwidth);
refspec = spec_chop_and_norm(refspec, aios);
% 4.2. Loop through APTdb, correct
maxlag = 400; %generous maximum lag here - we know the Ti traces are in there, so don;t need to care for accidential fits with other signatures
% loop, autocorrelate, write factor into table
for k = 1:height(FullTab)
    if (FullTab.("Mo++")(k) == true)
        spec = FullTab.Spectrum(k,:);
        lag = autocorr_getlag(refspec, spec, aios, maxlag, binwidth);
        knownShiftsTab.("Mo++")(k) = lag;
    else
        knownShiftsTab.("Mo++")(k) = nan;
    end
end




% 5.1. Populate the Cr shift column
% prepare Ref dataset
binwidth = 1e-3;
refpos = qreadpos("R56_00545-v01.pos"); % This is a datasets which contains a nicely calibrated fingerprint of Cr. Also see footnote [A]
histedges = 0:binwidth:(max(refpos(:,4))+1);
refspec = histcounts(refpos(:,4), histedges);
aios = round((25.8:binwidth:26.8) ./ binwidth);
refspec = spec_chop_and_norm(refspec, aios);
% 5.2. Loop through APTdb, correct
maxlag = 400;
for k = 1:height(FullTab)
    if (FullTab.("Cr++")(k) == true)
        spec = FullTab.Spectrum(k,:);
        lag = autocorr_getlag(refspec, spec, aios, maxlag, binwidth);
        knownShiftsTab.("Cr++")(k) = lag;
    else
        knownShiftsTab.("Cr++")(k) = nan;
    end
end




%Do sth like
scatter(knownShiftsTab.("Ti++"), knownShiftsTab.("Mo++"))
%there are outliers, some cleanup may be necessary!



% 6.1. Populate the Zr shift column
% use MUZIC 2 data - these are relatively uniform datasets
binwidth = 1e-3;
refpos = qreadpos("R14_23293-v01_ref_Zr.epos"); % This is a datasets which contains a nicely calibrated fingerprint of Zr. Also see footnote [A]
histedges = 0:binwidth:(max(refpos(:,4))+1);
refspec = histcounts(refpos(:,4), histedges);
aios = round((51:binwidth:57) ./ binwidth);
refspec = spec_chop_and_norm(refspec, aios);
% 6.2. Loop through APTdb, correct
maxlag = 400;
for k = 1:height(FullTab)
    if (FullTab.("Zr++")(k) == true)
        spec = FullTab.Spectrum(k,:);
        lag = autocorr_getlag(refspec, spec, aios, maxlag, binwidth);
        knownShiftsTab.("Zr++")(k) = lag;
    else
        knownShiftsTab.("Zr++")(k) = nan;
    end
end





% 7.1. Populate the U shift column
binwidth = 1e-3;
refpos = qreadpos("R14_18809-v01_ref_U.epos"); % This is a datasets which contains a nicely calibrated fingerprint of U. Also see footnote [A]
histedges = 0:binwidth:(max(refpos(:,4))+1);
refspec = histcounts(refpos(:,4), histedges);
aios = round((78:binwidth:81) ./ binwidth);
refspec = spec_chop_and_norm(refspec, aios);
% 7.2. Loop through APTdb, correct
maxlag = 400;
for k = 1:height(FullTab)
    if (FullTab.("U+++")(k) == true)
        spec = FullTab.Spectrum(k,:);
        lag = autocorr_getlag(refspec, spec, aios, maxlag, binwidth);
        knownShiftsTab.("U+++")(k) = lag;
    else
        knownShiftsTab.("U+++")(k) = nan;
    end
end





% 8.1. Populate the Ga shift column
binwidth = 1e-3;
refpos = qreadpos("R14_18084-v01_ref_Ga.epos"); % This is a datasets which contains a nicely calibrated fingerprint of Ga. Also see footnote [A]
histedges = 0:binwidth:(max(refpos(:,4))+1);
refspec = histcounts(refpos(:,4), histedges);
aios = round((68.3:binwidth:71.7) ./ binwidth);
refspec = spec_chop_and_norm(refspec, aios);
% 8.2. Loop through APTdb, correct
maxlag = 400;
for k = 1:height(FullTab)
    if (FullTab.("Ga+")(k) == true)
        spec = FullTab.Spectrum(k,:);
        lag = autocorr_getlag(refspec, spec, aios, maxlag, binwidth);
        knownShiftsTab.("Ga+")(k) = lag;
    else
        knownShiftsTab.("Ga+")(k) = nan;
    end
end




end





function spec = spec_chop_and_norm(spec_in, aios)
spec = spec_in(aios);
spec = spec ./ sum(spec); %spec sums up to 1
end


function lag = autocorr_getlag(ref_spec, cand_spec, aios, maxlag, binwidth)
%ref_spec is normed to sum um to 1, cand_spec is not.
spec = spec_chop_and_norm(cand_spec, aios);

%         plot(spec);
%         title(num2str(k));
%         drawnow;
%         pause(1);

[xc, lags] = xcorr(ref_spec, spec, maxlag);
[~, mai] = max(xc);
lag = -lags(mai);

lag = lag .* binwidth; %positive lag -> spec is off to the right
                       %negative lag -> spec is off to the left


end




% [A] These reference datasets are simply .epos files of experiments which have well calibrated
% spectra (by a human operator), ie the fingerprints are precisely where we expect them to be.
% The reference files are archived to the Oxford Research archive !!! link !!! and are not publicly
% available. However, it should be relatively easy to replace them by re-using publicly
% available APT datasets which contain the corresponding ionic fingerprints.







