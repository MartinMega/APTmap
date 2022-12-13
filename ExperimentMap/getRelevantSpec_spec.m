function [relevantspec, noisefit, noisecurve_a] = getRelevantSpec_spec(bincenters, spectrum, confidence)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


if length(bincenters) ~=length(spectrum)
    error("Bincenters and spectrum need to have same length");
end


%Find the histogram bins in which it is guaranteed that ions are contained
ionfreeareas = [0.9, 0.92; 1.1 1.45; 1.56 1.93; 2.1 2.27; 2.73 2.93]; % These are the areas in an APT spectrum which have no ions
                                                                      % as described in https://doi.org/10.1017/S1431927620024290, however they
                                                                      % are a bit adapted (more narrow, especially the first range). This is so
                                                                      % we don't run into troubles with the veto signal.

isguaranteedionfree = zeros([1,length(bincenters)]);
for k = 1:size(ionfreeareas,1)
    isguaranteedionfree((bincenters>ionfreeareas(k,1)) & (bincenters<ionfreeareas(k,2))) = 1;
end


%Fit background to ion-free areas
xforfit = double(bincenters(isguaranteedionfree == 1));
yforfit = double(spectrum(isguaranteedionfree == 1));
ft = fittype( 'a/(sqrt(x)*2)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% Fit model to data.
warning('off','curvefit:fit:noStartPoint')
[fitresult, ~] = fit(xforfit', yforfit', ft, opts );
warning('on','curvefit:fit:noStartPoint')

noisecurve_a = fitresult.a;

%calculate peak line and the spec of relevant peaks
res = fitresult(bincenters);
res(isinf(res)) = NaN;
confipkminline = poissinv(confidence, res);
relevantspec = spectrum(:) - confipkminline(:);
relevantspec(relevantspec < 0) = 0;

if any(isnan(relevantspec))
    warning([' nan encountered when fitting noise bg. Replacing by 0 counts in bin. ' ...
            ' This could happen when, after noise correction, one or more bins should ' ...
            ' contain less than 0 counts. We dont allow for less than 0 counts here so we just set it to 0.']);
    relevantspec(isnan(relevantspec)) = 0;
end



relevantspec(1) = 0; % to suppress an aritfact. This region of the spectrum is never relevant

noisefit = confipkminline(:);

end

