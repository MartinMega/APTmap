

%% Preparation
% Before starting, run this function to see if you have licenses for all the
% toolboxes that this code uses.

checkIfMatlabReady();

% Add folders with sub-functions and extra data to matlab search path

addpath(genpath('Jcurvefit'))
addpath(genpath('data'))
addpath(genpath('ExperimentMap'))
addpath(genpath('SearchingAndClustering'))
addpath(genpath('utilities'))


%% location of all the epos files
% Modify the line below such that it points to the folders with your epos files.
% All epos files should be valid (ie no corrupt files), and columns for m/n
% and the voltage should be populated (APsuite file converter produces epos
% files with all-zero columns is some data is not available. This script is
% not ready for epos files with all-zero columns).

eposfiles_dirstruct = dir('E:\Martin\APTdb_copy_loadbalancing\**\*.epos');


%% make table of Files
% This makes a list of all epos files available, and assigns an experiment
% name to each of them. The experiment name is the Filename unless there are
% duplicate names,  in which case numbers are added to the name.
FileTab = BuildFileTable(eposfiles_dirstruct);


%% Make Table of Spectra
% Next, we read all the epos files and create a table with all m/n spectra.
% Depending on the number of datsets and the data rate of your hard drive,
% this might take a while.
% If you have a table with correction factors ("CorrValsTab") to apply
% some m/n spectrum calibration, you can load and use it here. This is not
% needed if your epos files are already well calibrated.

% Define the binning for our spectra
binedges = (0:0.01:180);

% Decide if you'd like to process your files in parallel. Don't use
% parallel if your files come from a magnetic harddrive, as parallel reading
% such such drives is significantly slower than serial. Also don't use it if
% you fear you don't have enough RAM to hold several epos at the same time.
% Do use parallel on a SSD to achieve a speedup.
doItParallel = false;

SpecTab = BuildSpecTable(FileTab, binedges, doItParallel);

% One problem with the spectra in the paper !!! ref goes here !!! is that the
% spectra have been exported automatically and therefore are not calibrated.
% It therefore possible to call BuildSpecTable with a table of correction
% values as additional parameter. The Script "StepByStep_Spectracorrection"
% shows how these values have been obtained for the spectra in above paper.
% To load a table of correction values,  use the following:
%
% ld = load('CorrValsTab.mat', 'CorrValsTab');
% CorrValsTab= ld.CorrValsTab;
% clear ld;
% SpecTab = BuildSpecTable(FileTab, binedges, doItParallel, CorrValsTab);

% Depending on the speed of your computer and the number of experiments you have,
% reading all of these files could take a while. It therefore makes sense to store
% the SpecTab, so you can just load them again at a later point. We also want to add
% the binedges to this file so it is clear what the binning in these spectra is.
% save("Spectab.mat", "SpecTab", "binedges"  "-v7.3)
% load("Spectab.mat")


%% Search for Spectra
% Now that we have spectra of all our datasets,  we can use
% nearest-neighbour search so search for spectra that are similar to a
% given search spectrum.
% The script files SearchAndPlotSpec.m outlines the process for spectrum
% searching. You can open and try this file now or continue with this
% script.



%% Build Table of Estimated Amounts of Elements
% We now make a table with the estimated amounts of all Elements.

% Charge states to be checked.
allowedChargeStates = [1,2];

% Minimum abundance. Less common isotopes will be ignored.
minAbundance = 1; %in percent

% Array of names of Elements to be checked. We want to check all elements,
% so we load a list of all element names. However, you can also specify
% only a few elements to be checked,  this will be signifianctly faster
% than checking the entire periodic table. In particular, going for the
% entire periodic table means we also check against odd Elements where no
% isotopes with meaningful half-life time exist (and the result is always
% 0, bc these Elements can't be in an APT tip, of course.)
ElementNames = load("ElementNames.mat", "ElementNames");
ElementNames = ElementNames.ElementNames;
%ElementNames = {'Li', 'Fe'};

EstTab = BuildEstimationTable(SpecTab, binedges, allowedChargeStates, minAbundance, ElementNames);


%% Make table with tsne coordinates, then plot
% Now we want to use tsne to draw a map of the spectra in our table.
% Problem: We currently use spectra with a bin size of 0.01, or 18001 bins
% (unless you changed this bit of the code above).
% tsne on so many dimensions will take very long,  therefore we "downscale"
% all the spectra such that they only use binsizes of 0.1.
binedges_tsne = (0:0.1:180);
SpecTab_tsne = scaleDownSpecMat(SpecTab, binedges, binedges_tsne);

% optional: initialise matlab's random generator with a known seed such that
% we can reproduce the tsne map
randseed_tsne = 6511;
rng(randseed_tsne, 'twister')

% get a table with the tsne-coordinates
% If you only have a low number of experiments, this may not converge well
TsneTab = BuildTsneTable(SpecTab_tsne);

% Now, we draw a tsne diagram. To make it more easy to interpret, we also
% want to highlight datasets where a certain fingerprint fits well. For this,
% we can use the estimated amounts in the EstTab Estimation table: If a
% certain Element is estimated to make up more than a certain amount of all
% the counts in a spectrum, we draw it with a certain marker and colour
% in the tsne diagram.
% Therefore,  we first create the ElementsAmountsMarkers table, which
% contains all the Elements and minimum amounts from which we want to
% highlight our data. The example table below works well for the Oxford-848
% collection of datasets. If just contains sample base materials that are
% (or: were) commonly run at the oxford APT group.
% If the samples in you database have other common base materials,  you might
% want to use other Elements for highlighting.
% If you have no idea which elements and thresholds to use for highlighting,
% have a look at the skript OhNoWhatShouldIUseForHighlighting.m

Highlight_Element =   ["Fe";      "Zr";      "Si";      "W";       "Ni";      "Ti";      "Ga";     "U"       ];
Highlight_MinAmount = [0.5;       0.5;       0.5;       0.1;       0.2;       0.2;       0.3;      0.1       ];
MarkerType =          ["d";       "^";       "s";       "p";       "v";       "h";       "x";      "+"       ];
MarkerFaceColour =    ["#0072bd"; "#d95319"; "#edb120"; "#7e2f8e"; "#77ac30"; "#4dbeee"; "none";   "none"    ];
MarkerEdgeColour =    ["none";    "none";    "none";    "none";    "none";    "none";    "#a214f0"; "#ff0081" ];
ElementsAmountsMarkers = table(Highlight_Element, Highlight_MinAmount, MarkerType, MarkerFaceColour, MarkerEdgeColour);

DrawTSNEDiagram(TsneTab, EstTab, ElementsAmountsMarkers);


%% Apply OPTICS
% At this point, you might want to consult some "real" cluster algorithm
% to check of the clusters int the t-sne diagram are legit,  or just an
% aretfact (provided there are any). The function opticsClusterSearchSpecTab
% does this cluster analysis for you, and plots the reachability diagram.
% more info about optics on wikipdia: https://en.wikipedia.org/wiki/OPTICS_algorithm

% optics has one parameter MinPts. 10 works well for the oxford-848 dataset.
% You might need to tweak it if your collection of spectra is significantly
% larger or smaller, or has strongly deviating cluster sructure.
% this number must be lower than the number of datasets in you collection.
optics_minpts = 10;

%Run the OPTICS Algorithm. This draws a diagram.
OpticsClusterSearch(SpecTab, EstTab, ElementsAmountsMarkers, optics_minpts)



%% Check how the relative amounts of H2 and H change with voltage
% We want to know if there are discinct behaviours of the hydrogen
% behaviour on the tsne diagram. To this end, we check for all experiments
% how the ratio of these ions changes with voltage,  and then draw the tsne
% diagram again, with different markers depending on whether the ratio
% increases or decreases.

% There are a couple of parameters to this:

% the voltage bins to be used
%voltagebins = 1000:1000:15000;
voltagebins = 1000:500:15000;

% If a voltage bin has less than MinCounts_voltagebin counts (before noise correction), we ignore it.
% If there are less H or H2 than MinHinBin in a voltage bin (after noise corr), we can ignore it.
% MinCounts_voltagebin = 100000;
MinCounts_voltagebin = 50000;
MinHinBin_Table = 1;

% where in the mass-charge spectrum should we look for the Hydrogen peaks?
Hrange = [0.9, 1.1];
H2range = [1.9, 2.1];

% like above - better no parallel on magnetic drives, otherwise go for it
doItParallel = false;

% First, we need to go back to our epos files, and get some
% Hydrogen-Voltage curves. These curves we save into the HydrogenTab table.
% If you'd like to include a m/n spectrum calibration, use the alternative
% form with the CorrValsTab (See above section about BuildSpecTab)
%[HydrogenTab] = BuildHydrogenTable(FileTab, voltagebins, Hrange, H2range, MinCounts_voltagebin, MinHinBin, doItParallel);
[HydrogenTab] = BuildHydrogenTable(FileTab, voltagebins, Hrange, H2range, MinCounts_voltagebin, MinHinBin_Table, doItParallel, CorrValsTab);



% Then we can fit lines to the H2/H-ratio vs voltage curves to check if it is increasing or decreasing.
% The results go into a tsne diagram that is re-drawn with the new markers.
% At this point, we might want to irnogre some voltage bins where the count
% is very low. For my data, 500 minimum count sof H2 or H per bin works
% well. Drop this value if you are getting excessive "insufficient data"
% points.
MinHinBin_Diagram = 500;
DrawTSNEDiagramWithHydrogen(TsneTab, HydrogenTab, MinHinBin_Diagram);
















