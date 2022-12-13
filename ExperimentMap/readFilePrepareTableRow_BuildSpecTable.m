   function newrow = readFilePrepareTableRow_BuildSpecTable(FileTabJOINEDcorrFacTab_row, spec_binedges)
        % read epos file.
        [epos] = qreadpos(FileTabJOINEDcorrFacTab_row.path);
        %apply mass-charge spectrum calibration
        epos(:,4) = ( epos(:,4) .* FileTabJOINEDcorrFacTab_row.corr_fac ) + FileTabJOINEDcorrFacTab_row.corr_shift;
        % make a histogram
        spec = histcounts(epos(:,4),spec_binedges);        
        %get the name of the experiment.
        expname = FileTabJOINEDcorrFacTab_row.Experiment; 
        % that that's it! just add this to the Spec Table.
        newrow = cell2table({expname, spec}, 'VariableNames', {'Experiment', 'Spectrum'});
   end 