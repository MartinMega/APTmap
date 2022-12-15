function [] = get_optics(pathToOriginalOpticsM)
% pathToOriginalOpticsM needs to point to a file which can be downloaded
% from doi.org/10.13140/RG.2.1.3998.3843 


original_code = readlines(pathToOriginalOpticsM);



% 2. Edit some lines
edited_code = original_code;

%first line is empty,  remove
edited_code(1) = [];

%change line 3
edited_code(3) = "% [RD,CD,order]=optics(x,k, distancemetric)";

%add two lines after line 11
add_lines = [ "% distmetric - optional, distance metric, eg 'euclidean' or 'cityblock."; ...
              "% defaults to euclidean." ];
edited_code = [edited_code(1:11); add_lines;  edited_code(12:end) ];


% remove lines 33 and 34,  insert other lines instead
edited_code(34) = [];
edited_code(33) = [];
add_lines = [ "% Modified to allow for cityblock distance and other metrics";  ...
              "" ; ...
              "" ; ...
              ""; ...
              "function [RD,CD,order]=optics_modified(x,k, distmetric)" ; ...
              "%input distmetric can by any distance metric that pdist2 allows" ; ...
              "" ; ...
              ""; ...
              "if nargin < 3" ; ...
              "    distmetric = 'euclidean';" ; ...
              "end" ];
edited_code = [edited_code(1:32); add_lines;  edited_code(33:end) ];

% change a few more lines
edited_code(50) = "parfor i=1:m   ";
edited_code(51) =  "    D=sort(dist(x(i,:),x, distmetric));";
edited_code(64) =  "    mm=max([ones(1,length(seeds))*CD(ob);dist(x(ob,:),x(seeds,:), distmetric)]);";
edited_code(67) =  "    [i1, ind]=min(RD(seeds));";
edited_code(73) =  "function [D]=dist(i,x, distmetric)";
edited_code(78) =  "% Calculates the distances between the i-th object and all objects in x	 ";
edited_code(84) =  "% D - distance (m,1)" ;
edited_code(87) =  "D=pdist2(i,x,distmetric); " ;

%and remove empty lines at the end:
edited_code(92:end) = [];


% save the resulting file
if exist("optics_modified.m", "file")
    warning(" There is already a file called optics_modified.m somewhere on your matlab path, and " + ...
            " we don't want to overwrite or a save a duplicate. Therefore this function doesn't do anything." );
end

fid = fopen("optics_modified.m",'wt');
for k = 1:length(edited_code)
    fprintf(fid, "%s" + string(newline), edited_code(k));
end
fclose(fid);



