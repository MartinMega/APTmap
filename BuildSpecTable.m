function [SpecTab] = BuildSpecTable(FileTab, spec_binedges, doItParallel)



if (nargin < 3)
    doItParallel = false;
end


% Make a Table for all the Spectra.
% Type:    Experiment           Spectra
%         ------------    ------------------
%            string        fixed size array
SpecTab = table('Size',[height(FileTab),1],'VariableNames', {'Experiment'}, 'VariableTypes', {'string'});
SpecTab = addvars(SpecTab, -1.*ones(height(FileTab),length(spec_binedges)-1), 'NewVariableNames', 'Spectrum');



% Matlab cannot really do a conditional parfor, so we stash everything into
% a sepeatare function and use a  if-clause to check if we want to run parallel or serial
if (doItParallel)
    parfor k =1:height(FileTab)       
        %Read epos and get line for file
        newrow = readFilePrepareTableRow_BuildSpecTable(FileTab(k,:), spec_binedges);
        SpecTab(k,:) = newrow;        
        fprintf('Processed: %d out of %d (may be out of order when working parallel) \n', k, height(FileTab));
    end
else
    for k =1:height(FileTab)        
        %Read epos and get line for file
        newrow = readFilePrepareTableRow_BuildSpecTable(FileTab(k,:), spec_binedges);
        SpecTab(k,:) = newrow;
        fprintf('Processed: %d out of %d \n', k, height(FileTab));
    end

end
     
    
    
    
    
end









