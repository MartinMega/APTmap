function [pos, varargout] = qreadpos(fileName)
% function [pos, pls]=qreadpos( [optional] fileName)
% Reads data from a .pos file or .epos file. 
% returns the pos info (.pos -> 4 columns, .epos -> 11 columns) in the pos
% variable and the pulse information (.epos -> 2 columns) in the pls
% variable.
% modified by MM for high throughput

% This is based on readpos.m from atom-probe-code (https://github.com/peterfelfer/atom-probe-code), 
% but has been modified quite a lot. (Actually only 7 lines are not changed)
% Matlabs result=fread(arguments) which is usually used to read pos files 
% typicalluy reads and typcasts the data in one go. This is slow, and and
% the data rate is limited by the CPU doing the type conversion not the HD
% (at least if you have a quick SSD but slow CPU). Calling fread with 
% arguments to not do any typecasting and doing the casting manually in 
% is much faster. Cost for this is a higher memory consumption, but human
% time is just a wayyy more valuable ressource than memory.


% the filename is optional. A dialog box will pop up if no file name is
% given
if ~exist('fileName','var')
    [file, path] = uigetfile({'*.pos';'*.epos'},'Select a pos file');
    fileName = [path file];
    disp(['file ' file ' loaded']);
end


[~ , ~, ext] = fileparts(fileName);


fid = fopen(fileName, 'r');

if strcmpi(ext,'.pos') %check if file is a pos file
    
    fullfile = fread(fid, inf,'16*uint8=>uint8');
    numAtoms = length(fullfile) ./ 16;

    fullfile = reshape(fullfile, [16, numAtoms]); %watch out: row-column swapped
    fullfile = fullfile';

    singlecandidates = fullfile(:,:);
    singlecandidates = reshape(singlecandidates',1,[]);
    pos = typecast(singlecandidates, 'single');
    pos = swapbytes(pos);
    pos = reshape(pos,4,[]);
    pos = pos';   

elseif strcmpi(ext,'.epos') %check if file is an epos file
    
    fullfile = fread(fid, inf,'44*uint8=>uint8');
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
    pls = typecast(uintcandidates, 'uint32');
    pls = swapbytes(pls);
    pls = reshape(pls,2,[]);
    pls = pls';

    varargout{1} = pls;    
    
else
    error("Don't know what to do with this file name suffix")
end


fclose(fid);


end
