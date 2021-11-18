
% This script contains some examples for searching spectra in a collection
% of many spectra by similarity.
% Searching is done by one single function:
% [neighbourIndices] = findSimilarRunsInSpecTab(candidatespec, SpecTab, numNeighbours);
% however it needs some setting up, therefore it provided in this Example
% File.
% It also comes with four example datasets that we can search similar
% spectra for: A Supoeralloy,  a Bioglass and two tungsten datasets.
% Unfortunately, I don't have permission to publish all of the data that I
% used for testing. It may therefore be possible that some of the example
% pos files mentioned in this code are missing in the version of this
% matlab library that you have received.





% First, we need a spectrum to search for. This means, we need to define
% binedges of this spectrum (in search_binedges), load a pos file, and make
% a spectrum. Then,% we normalise the spectrum to sum up to one. Below are
% some examples. just pick one and uncomment it,  or define your own
% binedges and load a pos file.
% We typically don't search for a full spectrum but only for a section of a
% certain spectrum that contains e.g. a certain fingerprint. Therefore,
% search_binedges does not cover the full range from 0 to [high value].
% However,  this is not a requirement,  and search_binedges can also be an
% entire m/n range of an experiment e.g. search_binedges = 0:0.01:180.
% it is advisable a bin size in search_binedges that is the same or an
% integer multiple of the bin size that was used for creating SpecTab.

% Ti-Cr fingerprint in Inc718
% pos = qreadpos("data/R56_00545-v01_inc718_by_MM.pos");
% search_binedges = 22.7:0.01:25.3;

% SiO2+, Na4P++, PO2+, Po2H+ overlap in Bioglass.
% Dataset by Yanru Ren et al,
% Published in Microscopy & Micfroanalysis: https://doi.org/10.1017/S1431927621012976
% pos = qreadpos("data/R5083_10591-v01_BioGlass_by_Yanru.pos");
% search_binedges = 59.5:0.01:65.5;

% Plain W, liftout
 pos = qreadpos("data/R5083_12410_LiftoutW_by_MM.pos");
 search_binedges = 89.5:0.01:93.5;

% W Wire, but a fingerprint with few counts an a spec that does not have
% well shaped peaks and that is poorly calibrated (and XS instead of XR)
% pos = qreadpos("data/R5111_10114_WWire_by_MM.pos");
% search_binedges = 89.5:0.01:94;


% The the script how many similar spectra to search for:
numNeighbours = 4;





% Create search spectrum, normalise to sum up to 1
search_spec = histcounts(pos(:,4), search_binedges);
search_spec = search_spec ./ sum(search_spec);


% get a matrix of all Spectra in SpecTab with the correct binning for
% searching, normalise to sum up to 1
SpecTab_search = scaleDownSpecMat(SpecTab, binedges, search_binedges);
specmat = SpecTab_search.Spectrum;
specmat = specmat ./ repmat(sum(specmat,2),[1,size(specmat,2)]);


% do the next neigbour search.
[neighbourIndices] = findSimilarRunsFromSpecMat(search_spec, specmat, numNeighbours);




%get figure ready
fig = figure;
tl = tiledlayout(length(neighbourIndices)+1,1,'TileSpacing','none','Padding','none');


%plot the neighbours
col = lines(numNeighbours);
for k = length(neighbourIndices):-1:1
    
    nexttile
    stairs(search_binedges(1:end-1)-diff(search_binedges), specmat(neighbourIndices(k),:), 'Color', col(k,:),'LineWidth', 1.4);
    
    xlim([search_binedges(1), search_binedges(end)]);
    grid on
    
    dataname = SpecTab_search.Experiment(k);
    legtxt = string(iptnum2ordinal(k)) + " Neighbour: " + dataname;    
    legend(legtxt, 'Location', 'best')
    ax = gca; ax.XTickLabel = {}; ax.YTickLabel = {};
    
end


%finally, plot original spectrum!
nexttile
stairs(search_binedges(1:end-1), search_spec, 'LineWidth', 1.4, 'Color', 'k')
xlim([search_binedges(1), search_binedges(end)]);
legend('Original Dataset', 'Location', 'best')

ax = gca; ax.YTickLabel = {};

xlabel(tl, 'm/n')
ylabel(tl, 'Counts')



