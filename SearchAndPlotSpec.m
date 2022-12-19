
% This script contains some examples for searching spectra in a collection
% of many spectra by similarity.
% Searching is done by one single function:
% [neighbourIndices] = findSimilarRunsInSpecTab(candidatespec, SpecTab, numNeighbours);
% however it needs some setting up, therefore it provided in this Example File.
% It also comes with four example datasets that we can search similar
% spectra for: A Superalloy,  a Bioglass and two tungsten datasets.
% Unfortunately, I don't have permission to publish all of the data that I
% used for testing. At the time, only the two tungsten datasets are publicly available,
% in code below.

% This script assumes that the variables SpecTab and binedges as produced in the StepbyStep
% script exist in your matlab workspace.


%% Select your candidate
% First, we need a spectrum to search for. This means, we need to define
% binedges of this spectrum (in search_binedges), load a pos file, and make
% a spectrum. Then,% we normalise the spectrum to sum up to one. Below are
% some examples. just pick one and uncomment it,  or define your own
% binedges and load a pos file.
% We typically don't search for a full spectrum but only for a section of a
% certain spectrum that contains e.g. a certain fingerprint. Therefore,
% search_binedges does not cover the full range from 0 to [some high value].
% However,  this is not a requirement,  and search_binedges can also be an
% entire m/n range of an experiment e.g. search_binedges = 0:0.01:180.
% it is advisable to use a bin size in search_binedges that is the same or an
% integer multiple of the bin size that was used for creating SpecTab.


%{
% Ti-Cr fingerprint in Inc718
% SHA-256 value of corresponding raw Experiment file is 5BC338DA8E0958A846227F4ABCF9B1AD4F3C6182342FE0147F650E9B18C96F77
% This pos file has been archived to ORA (not publicly available): !!! Link here !!!
pos = qreadpos("data/R56_00545-v01_inc718_by_MM.pos");
search_binedges = 22.7:0.01:25.3; % this is the location fo the Ti-Cr fingerprint in the spectrum
%}

%{
% SiO2+, Na4P++, PO2+, Po2H+ overlap in Bioglass.
% Dataset by Yanru Ren et al,
% Published in Microscopy & Microanalysis: https://doi.org/10.1017/S1431927621012976
% SHA-256 value of experiment is c5a44a2e8c65c8d7241b6b63be340ec35b11979789fbcd5c292970db9c50529e, listed in https://raw.githubusercontent.com/oxfordAPT/hashlist/master/cameca_5000XR.txt
% This pos file has been archived to ORA (not publicly available): !!! Link here !!!

pos = qreadpos("data/R5083_10591-v01_BioGlass_by_Yanru.pos");
search_binedges = 59.5:0.01:65.5;
%}


% Plain W, liftout
% SHA-256 value of experiment is 87364561c49ef57c9759296eb904593ea32f09006b9b78eb7a8f4b8acbbec929, listed in https://raw.githubusercontent.com/oxfordAPT/hashlist/master/cameca_5000XR.txt
% This pos file is available in !!! ORA link here !!! 
 pos = qreadpos("data/R5083_12410_LiftoutW_by_MM.pos");
 search_binedges = 89.5:0.01:93.5;

     
 
%{
% W Wire, but a fingerprint with few counts an a spec that does not have
% Well shaped peaks and that is poorly calibrated (and XS instead of XR)
% SHA-256 value of experiment is 9a14401b87374a3ac47621eedd46a7da239dc158f51d76e3780e5aa2a4bffc60, listed in https://github.com/oxfordAPT/hashlist/blob/master/cameca_5000XS.txt
% This pos file is available in !!! ORA link here !!! 
pos = qreadpos("data/R5111_10114_WWire_by_MM.pos");
search_binedges = 89.5:0.01:94;
%}


%% How many neighbours to search for?
% The the script how many similar spectra to search for:
numNeighbours = 4;





%% Now actually search for the spectrum and plot results
% just run this part of the script to search neighbours and plot the results


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
fig.Position(4) = fig.Position(4) .* 1.7;
fig.Color = [1 1 1];
if isMATLABReleaseOlderThan("R2021a") % they changed the option "none" to "tight" in 2021a
    tl = tiledlayout(length(neighbourIndices)+1,1,'TileSpacing', 'none');
else    
    tl = tiledlayout(length(neighbourIndices)+1,1,'TileSpacing', 'tight');
end


% plot original spectrum
nexttile
stairs(search_binedges(1:end-1), search_spec, 'LineWidth', 1.4, 'Color', 'k')
xlim([search_binedges(1), search_binedges(end)]);
legtxt = "Original Dataset";
ti = title(legtxt, 'Color', 'k', 'VerticalAlignment', 'baseline');
ylim([0, max(search_spec)]);
ax = gca; ax.XTickLabel = {}; ax.YTickLabel = {};

ax = gca; ax.YTickLabel = {};
ax.FontSize = 11.5;
ax.TitleHorizontalAlignment = 'left';
ax.FontName = 'Bahnschrift';

xlabel(tl, 'm/n (Da)', 'FontName', 'Bahnschrift', 'FontWeight', 'bold')
ylabel(tl, 'Counts (normalised)', 'FontName', 'Bahnschrift', 'FontWeight', 'bold')






%now plot all the neighbours
col = jet(length(neighbourIndices));
col = col(randperm(size(col,1)),:);
for k = 1:1:length(neighbourIndices)
    
    nexttile
    stairs(search_binedges(1:end-1)-diff(search_binedges), specmat(neighbourIndices(k),:), 'Color', col(k,:),'LineWidth', 1.4);
    
    xlim([search_binedges(1), search_binedges(end)]);
    ylim([0, max(specmat(neighbourIndices(k),:))]);
    grid on
    
    dataname = SpecTab_search.Experiment(neighbourIndices(k));
    legtxt = string(iptnum2ordinal(k)) + " Neighbour: " + dataname; % if iptnum2ordinal(k) doesn't work bc of missing toolbox license, just replace it by string(k) . Works fine,  just not as cool.
    legtxt = char(legtxt);
    legtxt(1) = upper(legtxt(1));% this convert to char , change 1st char and back is afaik the easiyest way of making first lelter uppercase
    legtxt = string(legtxt);    
    
    title(legtxt, 'Color', col(k,:), 'VerticalAlignment', 'baseline', 'FontWeight', 'bold');
    ax = gca;
    if k < length(neighbourIndices) % the last diagram will keep its axis label
        ax.XTickLabel = {};
    end
    ax.YTickLabel = {};
    ax.FontSize = 11.5;
    ax.TitleHorizontalAlignment = 'left';
    ax.FontName = 'Bahnschrift';
    
end




