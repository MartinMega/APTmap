function [TsneTab] = BuildTsneTable(SpecTab)



% Get all the spectra as matrix. Normalise the such that each of the
% spectra sums up to 1
specmat = SpecTab.Spectrum;
specmat = specmat ./ repmat(sum(specmat,2),[1,size(specmat,2)]); 


% run t-SNE with cityblock distance
tsmat = tsne(specmat, 'Distance', 'cityblock');


% stick all the coordinates and files into a table
% TsneTab = table('Size', [0,1], 'VariableNames', {'Experiment'}, 'VariableTypes', {'string'});
% for k = 1:length(APTdb)
%     TsneTab.Experiment(k) = APTdb{k}.name;
% end
% TsneTab.tsne_x = tsmat(:,1);
% TsneTab.tsne_y = tsmat(:,2);

TsneTab = table(SpecTab.Experiment, tsmat(:,1), tsmat(:,2), 'VariableNames', {'Experiment', 'tsne_x', 'tsne_y'});


