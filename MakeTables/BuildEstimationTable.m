function [EstTab] = BuildEstimationTable(SpecTab, spec_binedges, allowedChargeStates, minAbundance, ElementNames)


% Make a Table for the results. We just start with one column for the
% Experiment names (and copy this from SpecTab),  then add estimated 
% amounts of all the elements as new columns as we go.
EstTab = table(SpecTab.Experiment, 'VariableNames', {'Experiment'});

%Loop through all elements in the periodic table, check if fingerprints
%fit to the spectra an add a possible fraction to SpecTab as new column!
ti = tic;
for k_e =1:length(ElementNames) 
    
    
    elementToSearch = ElementNames{k_e};
    
    % for each dataset in the spectab,  we will fit the fingerprint and put a potential maximum in the estimatexmax array
    estimatedmax = -1 .* ones(height(SpecTab),1);   
    
    % loop through all spectra
    parfor k_s = 1:height(SpecTab)
        estimatedmax(k_s) = fingerprintElementMaxEstimator(SpecTab.Spectrum(k_s,:), spec_binedges, elementToSearch, allowedChargeStates, minAbundance);
    end
    
    % add results as new column to table. Column name = elemen name + "est"
    colname = string(elementToSearch) + "est";
    EstTab = addvars(EstTab, estimatedmax, 'NewVariableNames', colname);
    
    fprintf("Processed: %dth out of %d elements, Elapsed: %f \n", k_e, length(ElementNames), toc(ti));

    
end
    
    
    
    
    
    
    
 




















