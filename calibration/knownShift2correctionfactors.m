function [CorrValsTab] = knownShift2correctionfactors(KnownShiftsTab)

tab_Varnames = {'H+', 'Ti++', 'Mo++', 'Cr++', 'Zr++', 'U+++', 'Ga+'};
locations = {1.0078 47.9479/2 97.90540/2 51.94050/2, 91.224/2, 238.02891/3. 69.723}; 
targetPositions = cell2table(locations, 'VariableNames', tab_Varnames);
clear tab_Varnames locations

tab_Varnames = {'Experiment', 'corr_fac', 'corr_shift'};
tab_Vartypes = {'string', 'double', 'double'};
correction_vals = table('Size', [0,length(tab_Varnames)], 'VariableNames', tab_Varnames, 'VariableTypes', tab_Vartypes);

for k = 1:height(KnownShiftsTab)
    
    offset = table2array(KnownShiftsTab(k,2:end));
    target = table2array(targetPositions);
    actual = target + offset;
    target(isnan(offset)) = [];
    actual(isnan(offset)) = [];
    
    if (length(target) == 1) % we only have one fingeprint? We can;t calulate scale factor,  but a shift factor./
        correctionscalefac = 1;
        correctionshift = offset(~isnan(offset));
    end
    if (length(target) > 1)        
        fitted = polyfit(actual,target,1); % Two or more fingerints? Nice, we can calulate shift and scale factor 
        correctionscalefac = fitted(1);
        correctionshift = fitted(2);
    end
    if (isempty(target)) % No fingerprints? Nothing to do here... 
        correctionscalefac = 1;
        correctionshift = 0;
    end
    
    
    newline = {KnownShiftsTab.Experiment(k), correctionscalefac, correctionshift};
    correction_vals(k,:) = newline;
    
    
end


CorrValsTab = correction_vals;



