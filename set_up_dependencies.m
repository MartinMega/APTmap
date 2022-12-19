
%% Set up Dependencies
% This script will help you to obtain GIXSGUI and a matlab script for optics cluster search,
% which are needed for APTmap.




%% GIXSGUI

% We need GIXSGUI by Z Jiang, but with one small patch applied.
% This patch has been applied in a fork that is available at https://github.com/MartinMega/GIXSGUI

% The original version of GIXSGUI  by Z Jiang is available at https://github.com/ennogra/GIXSGUI
% For more information, see:
%       Z. Jiang, GIXSGUI: a MATLAB toolbox for grazing-incidence X-ray scattering data visualization and reduction, 
%       and indexing of buried three-dimensional periodic nanostructured films, J. Appl. Crystallogr. 48, 917-926 (2015).
%       https://doi.org/10.1107/S1600576715004434

% You can either manually navigate to https://github.com/MartinMega/GIXSGUI
% and download files into the Jcurvefit folder (a sub-folder of the folder 
% where this det_up_dependencies.m script was found in, or run the
% matlab code below which will do all of this for you.

downloaded = webread("https://github.com/MartinMega/GIXSGUI/archive/refs/heads/master.zip"); %download the zip compressed files

temp_filename = tempname(); % this creates a temporary file
fid = fopen(temp_filename,'w'); 
fwrite(fid, downloaded); %write the just downloaded data into the temp file
fclose(fid);

unzip(temp_filename,"Jcurvefit") % unzip into Jcurvefit folder



%% OPTICS

% We also need optics code from Michal Daszykowski, availabe at 
% 10.13140/RG.2.1.3998.3843 but with some modifications in order to make it
% support non-euclidean distance metrics.

% To this end,  you need to obtain the original code file, and
% subsequently change some bits. I have not found a way to automate
% downloading of the file, but I do have a matlab script that modifies the
% file for you once downloaded,  which is get_optics.

% So, first you need to go to doi.org/10.13140/RG.2.1.3998.3843,  and download the
% file optics.m. You will get text file called Matlab_code_for_OPTICS.txt.
% Enter a path to this file below,  and run get_optics. This will save a
% modified version of this code into a new file optics_modified.m onto your 
% matlab path

pathToOriginalOpticsM = "path/to/Matlab_code_for_OPTICS.txt";
get_optics(pathToOriginalOpticsM);


