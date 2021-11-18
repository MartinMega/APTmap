function [relevantspec, noisefit, noisecurve_a] = getRelevantSpec_spec(bincenters, spectrum, confidence)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


if length(bincenters) ~=length(spectrum)
    error("Bincenters and spectrum need to have same length");
end


%Find the histogram bins in which it is guaranteed that ions are contained
ionfreeareas = [0 0.94; 1.05 1.45; 1.56 1.93; 2.02 2.27; 2.73 2.93]; %From Dan's paper
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
    warning(' nan encountered when fitting noise bg. Replacing by 0 counts in bin');
    relevantspec(isnan(relevantspec)) = 0;
end



relevantspec(1) = 0; % to suppress an aritfact. This region of the spectrum is never relevant

noisefit = confipkminline(:);

end

