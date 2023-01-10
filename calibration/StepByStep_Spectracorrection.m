


%% Preparation
% check if all Toolboxes are available

checkIfMatlabReady();
addpath(genpath('ExperimentMap'))
addpath(genpath('SearchingAndClustering'))
addpath(genpath('utilities'))
addpath(genpath('calibration'))



%% Load files
% This is the same process as in the beginning of the StepbyStep script: Locate the epos files, 
% load them and generate spectra.
eposfiles_dirstruct = dir('path_to_manyeposfiles\**\*.epos');
FileTab = BuildFileTable(eposfiles_dirstruct);
binedges = (0:0.001:180);
doItParallel = false;

% The function BuildSpecTable would allow us to provide a list of calibration factors so the
% spectra can be corrected, by providing an additional parameter when calling the function (ie
% BuildSpecTable(FileTab, binedges, doItParallel) ). However, we don't have this list of factors yet 
% beause this is just what we want to produce here. Therefore, we call the BuildSpecTab without this
% additional parameter in order to load the spectra without calibration.
SpecTab = BuildSpecTable(FileTab, binedges, doItParallel);


%% Calculate shift of known fingerprints
% Firstly, there are some experiments where we definitely know that they containt a fingerprint
% of some specific element, because someone (I) manually had a look at them - namely,  we know
% of some datasets that they have fingerprints for Ti++, Mo++, Cr++, Zr++, U+++, Ga+.
% This information is stored in a table,  which we will load now:
ld = load('path\to\KnownElementsTab.mat', 'KnownElementsTab');
KnownElementsTab = ld.KnownElementsTab;
clear ld;
% For more info about this file,  see the footnote [A] at the bottom of this document.


% For each of these fingerprints, we have a reference dataset that is well-calibrated and that
% contains the corresponding fingerprint (see footnote [B]).
% We can then go though all the experiments in our collection where a fingerprint is known, and
% check how well the fingerprint in the uncalibrated experiment overlaps with the fingerprint
% from the calibrated reference spectrum. We can also shift the uncalibrated fingerprint to the 
% left or right by one or more bins, and see if this improves the overlap. The overlap between 
% the two spectra is expected to be best when we have shifted the uncalibrated fingerprint such
% that is is just at the position where it should be,  which is the position this fingerprint
% is at in the calibrated spectrum.
% From this number of bins that we need to shift the uncalibrated spectrum in order to maximise
% the overlap, we know by how much (in Da) the fingerprint in the uncalibrated spectrum is off
% from its expected position.
% This information about how far a fingerprint is away from its expected position is what we
% need to calibrate the spectrum, therefore we store this information in a table.

% For the "goodness of overlap", we use the dot product of both spectra. 
% This means that seaching for a shift by which a fingerprint in an uncalibrated spectrum is off
% from its expected position corresponds to searching for a maximum in the cross-correlation 
% between fingerprint from reference spectrum and uncalibrated spectrum.

% In addition to all of this, almost all experiments also contain a H+ peak. We can also
% check how much this peak is shifted away from its expected position by looking for a maximum
% in the spectrum near the m/n=1 position. This will tell us by how much the H+ peak is away
% from its expected position.

% The function knownElements2knownShifts does all of this: It iterates through all know 
% fingerprints in the experiments and calulates the shift which maximises overlap between 
% uncalibrated experiment and reference spectrum.
% Currently, this function is hardcoded for a bin size of 1e-3 for the spectra in SpecTab, and
% specifically works with the fingerprints H+, Ti++, Mo++, Cr++, Zr++, U+++, Ga+.
knownShiftsTab = knownElements2knownShifts(SpecTab, KnownElementsTab);




%% Correction factor,  known Fingerprints
% Now that we know for all known fingerprints by how much they are shifted relative to their
% expected position,  we can calulate the calibration factors that will calibrate the spectra
% such the fingerprints in these spectra will end up at their expected positions.
% We use two calibration factors here: one for shifting the spectrum, and one for scaling. This
% means, in order to calculate both of these,  we need at leat two data points, ie we need to
% know by how much the spectrum is off at least two fingerprints. For those spectra where we know
% the shift of at least two fingerprints, we can do this.
% In cases where we know by how much the spectrum is off at only one position (This is usually 
% the H+ peak, because a H signal is in almost every APT dataset),  we cannot calulate both values,
% so we only the calibration factor for shifting the spectrum.
% We can't do anything with the datasets where we have no known fingerprint and not even know
% where the H+ peak is, so we set the correction factor for scaling to 1 and for shift to 0. 

% This is what the function knownShift2correctionfactors does. It once more is hardcoded to
% assume we are working with the elements H+, Ti++, Mo++, Cr++, Zr++, U+++, Ga+. For all
% spectra with no known fingerprints, this outputs scale factors of 1 (which coorresponds to no
% scaling at all),  because we don't know how (or if) these spectra need to be calibrated.
[CorrValsTab_FingerprintKnown] = knownShift2correctionfactors(knownShiftsTab);


%% Correction factor,  only one known fingerprint

% In the last step, we try to calibrate those spectra where only one fingerprint is known,  ie 
% where we have assigned a shift factor so far (from the known fingerprint,  which usually turns
% out to be H+)
% To this end, we take each of these spectra (shift correctionknown) and iterate through a
% range of scaling factors (from 0.9929 to 1.0057 in 80 steps,  footnote [C]). We scale the 
% spectrum according to the correction factors and calculate the distance from the nearest of all 
% fully calibrated spectra (=spectra where both factors are known). Then,  we search for the 
% scaling factor where the distance to the neares neighbour is smallest. This is the sale factor 
% that we accept.
[CorrValsTab_newFactors] = corrfacs4ShiftUnknowns(CorrValsTab_FingerprintKnown, knownShiftsTab, FileTab);


%% Combine results in one Table
%Now we only need to put all experiments into one table,  CorValsTab. To this end,  we simply
%take the CorrValsTab_FingerprintKnown, and overwrite the lines for which CorrValsTab_newFactors
% has given us a new result.
CorrValsTab = CorrValsTab_FingerprintKnown;
CorrValsTab(contains(CorrValsTab.Experiment, CorrValsTab_newFactors.Experiment),:) = [];
CorrValsTab = [CorrValsTab; CorrValsTab_newFactors];



%% Save the result
% so we dont need to compute it again when we need it
save("CorrValsTab.mat", "CorrValsTab")






%% Footnotes
% [A] The list of known Elements that is used in the paper !!! Ref goes here !!! has been archived
% to Oxford ORA as item no !!!.
% Unfortunately, this list cannot be published as the APT data in this paper contains confidential
% information. However, an example file has been included in this gihub repository: !!!
% Filename here !!!
% [B] The reference datasets are simply .epos files of experiments which have well calibrated
% spectra (by a human operator), ie the fingerprints are precisely where we expect them to be.
% The reference files are archived to the Oxford Research archive !!! link !!! and are not publicly
% available. However, it should be relatively easy to replace them by re-using publicly
% available APT datasets which contain these signatures.
% [C] in the Oxford APT database it turns out that the scaling factor for those spectra where
% two or more fingerprints are known always lies between 0.9929 to 1.0057. We therefore assume
% that this also applies to the experimentsd where only one fingerprint is known,  and
% therefore chose this range of values here.











