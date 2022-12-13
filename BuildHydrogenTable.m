function [HydrogenTab] = BuildHydrogenTable(FileTab, voltagebins, Hrange, H2range, ...
    MinCounts_voltagebin, MinHinBin, doItParallel, CorrValsTab)


if (nargin < 8)
    %if the user provides us with no correction table for the mass spectrum
    % calibration, we just set all corection factors to 1.
    CorrValsTab = table(FileTab.Experiment, ones(height(FileTab),1), ones(height(FileTab),1), 'VariableNames', {'Experiment', 'corr_fac', 'corr_shift'});
end


% Combine FileTab and CorrValsTab.
% Check if result is as long as FileTab and CorrValsTab. If not, complain!
FullTab = innerjoin(FileTab, CorrValsTab, 'Keys', {'Experiment', 'Experiment'});
if ((height(FullTab) ~= height(FileTab)) || (height(FullTab) ~= height(CorrValsTab)))
    warning('Experiment Names in FileTab and CorrValsTab dont fully match. Are you sure you have loaded the correct FileTab and CorrValsTab')
end



% Noise correction parameters - just ignore!
binw_noisecorr = 1e-2;
conf_noisecorr = 0.5;


% Teh column names for the table that will hold the results
tab_Varnames = {'Experiment', 'Habsolute', 'H2absolute', 'noise_a', 'totalCounts', 'voltagebins'};

% now make a cell array for the results.  I have tried really hard to use a
% more easy to read table instead,  but just couldn't get matlab to
% initialise an empty table with multi-dimensional columns as would be
% needed for parfor. therefore,  we work with a cell array for now and
% covert to table later.
results = cell(cell(height(FullTab),length(tab_Varnames)));


ti = tic;


%loop through FullTab
if doItParallel
    parfor k = 1:height(FullTab)
        newrow_cell = readFilePrepareTableRow_BulidHydrogenTable(FullTab(k,:), voltagebins, MinCounts_voltagebin, MinHinBin, Hrange, H2range, binw_noisecorr, conf_noisecorr);
        results(k,:) = newrow_cell;
        elapsed = toc(ti);
        fprintf("Processed: %u | Remaining: %u | Elapsed: %.1f s  (may be out of order when working parallel) \n", k, height(FullTab)-k, elapsed);
    end
else
    for k = 1:height(FullTab)
        newrow_cell = readFilePrepareTableRow_BulidHydrogenTable(FullTab(k,:), voltagebins, MinCounts_voltagebin, MinHinBin, Hrange, H2range, binw_noisecorr, conf_noisecorr);
        results(k,:) = newrow_cell;
        elapsed = toc(ti);
        fprintf("Processed: %u | Remaining: %u | Elapsed: %.1f s \n", k, height(FullTab)-k, elapsed);
    end
end



HydrogenTab = cell2table(results, 'VariableNames', tab_Varnames);







end











