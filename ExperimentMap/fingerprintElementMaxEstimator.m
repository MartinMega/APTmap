function [UpperLimit] = fingerprintElementMaxEstimator(spec, spec_binedges, Element, allowedChargeStates, minAbundance)
% fit the fingerprint of a given Element into a spectrum, and estimate for
% which fraction of all counts in the spectrum it could possibly account
% for.
% Spec -> spectrum as histogram
% spec_binedges -> histogram binning
% Element -> Element to fit as string, e.g. "Fe"
% allowedChargeStates -> charge states to consider, e.g. [1 2]
% minAbundance -> min Abundance for isotopes in percent



%load isotope list. iI am using the isotope list by AJ London, from
%atomprobelab: https://sourceforge.net/projects/atomprobelab/
isotopes = load ("isotopes_original.mat", "isotopes");
isotopes = isotopes.isotopes;




%input can either be a char array for an
%find weights of the element
element_regex = [ Element '\([0-9]+\)' ]; %element name, followed by any number in braces ()
element_searchindex = regexp({isotopes{:,1}}, element_regex);
indices_namematch = ~cellfun('isempty', element_searchindex); %seach for isotopes with a matching name
indices_abundancymatch = cellfun((@(x) x>=minAbundance), {isotopes{:,3}}); % seach for isotopes with sufficient abundancy
element_weights = cell2mat({isotopes{indices_namematch & indices_abundancymatch,2}}); % get weights of isotopes which fulfil both conditions
abundancies  = cell2mat({isotopes{indices_namematch & indices_abundancymatch,3}});  % get abundancies of isotopes which fulfil both conditions


%find mn ranges to search for
UpperLimit = 0;
if (isempty(abundancies))
    return; % return 0 content if isotope does not exist
    % - this may eg happen if we search for a Element where no stable isotope exists, or
    % if searching for a Element name that does nto exist
end

% the fitting uses bincenters instead of binedges.
bincenters = spec_binedges(1:end-1) + (diff(spec_binedges) ./ 2);

%loop through charge states
for k_cs = 1:length(allowedChargeStates)
    
    % position where we expect out peaks
    ExpectedPeakPositions =  element_weights(:) ./ allowedChargeStates(k_cs);
    
    maxcontent_extrapolated = -1 .* ones(length(abundancies),1);
    
    % loop through all of the peaks in the fingerpint at give charge state
    for k_ab = 1:length(abundancies)
        %use a voigt fit to determine peak position. If no peak exists
        %at give position, this will return nonsense, but this is ok bc
        % we are doing just a very primitive and rough estimation here.
        [pk_start, pk_end] = Voigt_fit_edMM(spec,bincenters,ExpectedPeakPositions(k_ab),5); %may return 0 if expected pk position is ouside of spctreum rang but this is ok
        binsInInterval = (bincenters >= pk_start) & (bincenters <= pk_end);
        maxcontent_extrapolated(k_ab) = sum(spec(binsInInterval))./sum(spec) ./ ((abundancies(k_ab) ./ 100)); %/100 bc abundancy is in %
    end
    
    
    UpperLimit = UpperLimit + min(maxcontent_extrapolated);
    
end





end

