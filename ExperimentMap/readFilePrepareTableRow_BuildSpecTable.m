   function newrow = readFilePrepareTableRow_BuildSpecTable(FileTab_row, spec_binedges)
        % read epos file.
        [epos] = qreadpos(FileTab_row.path);        
        % make a histogram
        spec = histcounts(epos(:,4),spec_binedges);        
        %get the name of the experiment.
        expname = FileTab_row.Experiment; 
        % that that's it! just add this to the Spec Table.
        newrow = cell2table({expname, spec}, 'VariableNames', {'Experiment', 'Spectrum'});
   end 