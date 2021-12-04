function [pos, varargout] = qreadpos(filepath)
% function [pos, pulse]=qreadpos(fileName)
% Reads data from a .pos file or .epos file. 
% returns the pos info (.pos -> 4 columns, .epos -> 11 columns) in the pos
% variable and the pulse information (.epos -> 2 columns) in the pls
% variable.
% optimised for speed, but consumes a good amount of RAM (there is quite
% some opimisation possible)

% The signature of this function should be compatible with Peter Felfer's 
% readpos (as found in https://github.com/peterfelfer/atom-probe-code).



[~,~,extension] = fileparts(filepath);
if strcmpi('.POS',extension) %check if file is a pos file
    
    fid = fopen(filepath, 'r');
    fullfile = fread(fid, inf,'16*uint8=>uint8');
    fclose(fid);
    
    numAtoms = length(fullfile) ./ 16;

    fullfile = reshape(fullfile, [16, numAtoms]); %watch out: row-column swapped
    fullfile = fullfile';

    singlecandidates = fullfile(:,:);
    singlecandidates = reshape(singlecandidates',1,[]);
    pos = typecast(singlecandidates, 'single');
    pos = swapbytes(pos);
    pos = reshape(pos,4,[]);
    pos = pos';   

elseif strcmpi('.EPOS',extension) %check if file is an epos file
    
    fid = fopen(filepath, 'r');
    fullfile = fread(fid, inf,'44*uint8=>uint8');
    fclose(fid);
    
    numAtoms = size(fullfile,1) ./ 44;    

    fullfile = reshape(fullfile, [44, numAtoms]); %watch out: row-column swapped
    fullfile = fullfile';
    
    %this is not memory efficient at all - the number of large arrays could
    %be readuce easily.

    singlecandidates = fullfile(:,1:36);
    singlecandidates = reshape(singlecandidates',1,[]);
    pos = typecast(singlecandidates, 'single');
    pos = swapbytes(pos);
    pos = reshape(pos,9,[]);
    pos = pos';

    uintcandidates =  fullfile(:,37:44);
    uintcandidates = reshape(uintcandidates',1,[]);
    pulse = typecast(uintcandidates, 'uint32');
    pulse = swapbytes(pulse);
    pulse = reshape(pulse,2,[]);
    pulse = pulse';

    varargout{1} = pulse;    
    
else
    error("Don't know what to do with this file name suffix")
end





end
