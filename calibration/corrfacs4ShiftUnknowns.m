function [CorrValsTab_newFactors] = corrfacs4ShiftUnknowns(CorrValsTab_FingerprintKnown, KnownShiftsTab, FileTab)



scalefac_4test = linspace(0.9929, 1.0057, 80);

%0. have a list of all corrected APT spectra the ones which are corrected at this point) ready
%    This can be done via
    
    
    ExpAlreadyCorrected = table(KnownShiftsTab.Experiment(sum(~isnan(table2array(KnownShiftsTab(:,2:end))),2, 'omitnan')~=1), 'VariableNames', {'Experiment'});
    ExpNotYetCorrected = table(KnownShiftsTab.Experiment(sum(~isnan(table2array(KnownShiftsTab(:,2:end))),2, 'omitnan')==1), 'VariableNames', {'Experiment'});
    
    FileTab_alreadycorrected = innerjoin(FileTab, ExpAlreadyCorrected);
    FileTab_notyetcorrected = innerjoin(FileTab, ExpNotYetCorrected);
    
    CorrValsTab_newFactors =innerjoin(CorrValsTab_FingerprintKnown, ExpNotYetCorrected);  
    
    
    binedges = 1:1e-3:120;
    doItParallel = false;    
    SpecTab_alreadycorrected = BuildSpecTable(FileTab_alreadycorrected, binedges, doItParallel, CorrValsTab_FingerprintKnown);
    SpecMat_alreadycorrected = SpecTab_alreadycorrected.Spectrum ./ sum(SpecTab_alreadycorrected.Spectrum ,2);
    

%1. Loop through all datasets where Knownshiftstab contains exactly one nan

for k = 1:height(FileTab_notyetcorrected)    
    
    shift = CorrValsTab_FingerprintKnown.corr_shift(CorrValsTab_FingerprintKnown.Experiment == FileTab_notyetcorrected.Experiment(k));

    epos = qreadpos(FileTab_notyetcorrected.path(k));
    mnval = epos(:,4);
    epos = -inf;
    
    mindists = -1.* ones(length(scalefac_4test),1);
    
    for k2 = 1:length(scalefac_4test)
        
        mnval_scaled = (mnval .* scalefac_4test(k2)) + shift;
        spec_scaled = histcounts(mnval_scaled, binedges);
        spec_scaled = spec_scaled ./ sum (spec_scaled);
        
        dists = pdist2(spec_scaled, SpecMat_alreadycorrected, 'cityblock');
        
        mindists(k2) = min(dists);
    end
    
    [~, minind] = min(mindists);
    scalefac = scalefac_4test(minind);
    
    CorrValsTab_newFactors.corr_fac(CorrValsTab_newFactors.Experiment == FileTab_notyetcorrected.Experiment(k)) = scalefac;
    
    if (CorrValsTab_newFactors.corr_shift(CorrValsTab_newFactors.Experiment == FileTab_notyetcorrected.Experiment(k)) ~= shift)
        error('something is wrong!!')
    end
    
    % this plot should ususally have a nice minimum
    % plot(scalefac_4test, mindists, 'o-');
    % title(FileTab_notyetcorrected.Experiment(k));
    % drawnow;
    
    fprintf('Processed: %u out of %u \n', k, height(CorrValsTab_newFactors));
    
end
    

%Sanity check: Does the distribution of scale facsdetermined by thes mothod
%look similar to the ones determined using known fingerprints?
% figure
% histogram(CorrValsTab_newFactors.corr_fac,40)
% yyaxis right
% histogram(CorrValsTab.corr_fac(ismember(CorrValsTab.Experiment,table2array(ExpAlreadyCorrected))),40)
% 


