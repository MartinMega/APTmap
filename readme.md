# APTdb tools


## What is this?

This is a collection of matlab files that can be used for automated analyses of many APT experiments. Specifically, it can
 - read many epos files and build a table of APT spectra
 - search spectra by similarity, using nearest-neighbour search
 - perform a (very) naive estimation of which elements may be present in your datasets
 - Visualise your spectra point cloud using a tsne diagram
 - Apply the optics algorithm to investigate clusters in your spectra point cloud
 - Extract the evolution of H2+/H+ ion concentrations as function of the voltage
 - Visualise the H2+/H+ behaviour on the tsne diagram. 



## Requirements

In order to use these sripts, you need

 - Matlab,  ideally release 2020b, with the following toolboxes:
   - Curve Fitting Toolbox
   - Statistics Toolbox
   - Distributed Computing Toolbox (optional - this is the Parallel Toolbox)
 - Lots of epos files - 100 is good, 1000 is better. However,  it works from al little as 2. The m/n and voltage columns in all epos files most be populated (ie they must not contain all-zeros)
 - A fast computer, and ideally a fast hard drive if your collection of epos files is large
 - A copy of https://github.com/ennogra/GIXSGUI on your computer, with a small patch. See the "Get Started" section for more info. 



## Get started

1. Download this repository into a folder on your computer
2. Go to https://github.com/ennogra/GIXSGUI, download the repository and copy it into the Jcurvefit folder
3. Apply a small patch to GIXSgui:
    1. Find the file Jcurvefit/linefit/linefit.m, open it in matlab or another editor
    2. Go to line 43, and change "properties (SetAccess = private)" to "properties (SetAccess = public)"
    3. Save the modified file, replacing the original.
4. Open matlab, navigate to this folder
5. Open the file "StepByStep.m" in matlab.

The stepbystep file walks you through all of the data analyses. The file contains some adjustable parameters. Except from the path to the folder with your epos files, all of them can be left as is, however you may wish to tweaksome of them in order to achieve better analysis results. On large collections of epos files, this script will have a long runtime, possibly of several hours.

I therfore recommend to start with an epos folder with only few files, e.g. 10, just to explore what the script does. On this small collection, do not run the script in one go, but section-by-section, using matlabs "run selection" feature (don't expect any meaningful cluster analysis or similar on such a low number of datasets). Once this works, run the script overnight on your full collection of epos files.




