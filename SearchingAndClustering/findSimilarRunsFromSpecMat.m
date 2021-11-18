function [neighbourIndices] = findSimilarRunsFromSpecMat(spectrum, SpecScan_Array, numNeighbours)
% Takes a Specscan array and a spctrum (num bins and binswidh must be the
% same), and returns the indices of the numNeighbour nearest neighbour spectra.


[nbs, dist] = knnsearch(SpecScan_Array, spectrum, 'K', numNeighbours+1);
nbs(1) = []; dist(1) = [];
neighbourIndices = nbs;



end

