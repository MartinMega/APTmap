function [FileTab] = BuildFileTable(eposfiles_dirstruct)


% Make a Table for all the Files
tab_Varnames = {'Experiment', 'path'};
tab_Vartypes = {'string',     'string'};
FileTab = table('Size', [length(eposfiles_dirstruct),length(tab_Varnames)], 'VariableNames', tab_Varnames, 'VariableTypes', tab_Vartypes);


%loop through all epos files and crate a list
for k =1:length(eposfiles_dirstruct)
    
    %Get the epos file path
    eposfileinfo = eposfiles_dirstruct(k);
    eposfilepath = [eposfileinfo.folder, filesep, eposfileinfo.name];
    
    %get the name of the experiment. We use the filename without the 'epos'.
    [~, expname, ~] = fileparts(eposfilepath);
    
    % If an experiment with this name is already in the list (ie we have
    % duplicate file names), just add a number to the experiment name
    if any(contains(FileTab.Experiment, expname))
        kf = 1;
        expname_new = string(expname) + kf;
        while any(contains(FileTab.Experiment, expname))
            kf = kf + 1;
            expname_new = string(expname) + kf;
        end
        expname = expname_new;
    end
    
    % that that's it! just add this to the Spec Table.
    newrow = cell2table({expname, eposfilepath}, 'VariableNames', tab_Varnames);
    FileTab(k,:) = newrow;
    
end


















