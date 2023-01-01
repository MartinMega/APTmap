function [TsneTab_nD] = BuildTsneTable_nD(SpecTab, NumDimensions)
% Same as BuildTsneTable, but for N-dimensional tSNE embedding


if nargin < 2
    NumDimensions = 2;
end


% Get all the spectra as matrix. Normalise the such that each of the
% spectra sums up to 1
specmat = SpecTab.Spectrum;
specmat = specmat ./ repmat(sum(specmat,2),[1,size(specmat,2)]); 


% run t-SNE with cityblock distance
tsmat = tsne(specmat, 'Distance', 'cityblock', 'NumDimensions', NumDimensions);


% stick all the coordinates and files into a table
% TsneTab = table('Size', [0,1], 'VariableNames', {'Experiment'}, 'VariableTypes', {'string'});
% for k = 1:length(APTdb)
%     TsneTab.Experiment(k) = APTdb{k}.name;
% end
% TsneTab.tsne_x = tsmat(:,1);
% TsneTab.tsne_y = tsmat(:,2);

if NumDimensions == 2
    TsneTab_nD = table(SpecTab.Experiment, tsmat(:,1), tsmat(:,2), 'VariableNames', {'Experiment', 'tsne_x', 'tsne_y'});
elseif NumDimensions == 3
    TsneTab_nD = table(SpecTab.Experiment, tsmat(:,1), tsmat(:,2), tsmat(:,3), 'VariableNames', {'Experiment', 'tsne_x', 'tsne_y', 'tsne_z'});
else %more than 3 dimensions
    ts_tmp = array2table(tsmat, 'VariableNames', "tsne_" + string(1:NumDimensions));
    TsneTab_nD = table(SpecTab.Experiment, 'VariableNames', {'Experiment'});
    TsneTab_nD = [TsneTab_nD ts_tmp];
end


