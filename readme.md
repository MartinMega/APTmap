# APTmap

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
 - Lots of epos files - 100 is good, 1000 is better. However,  it works from as little as 2. The m/n and voltage columns in all epos files most be populated (ie they must not contain all-zeros).
 - A fast computer, and ideally a fast hard drive if your collection of epos files is large
 - A copy of https://github.com/MartinMega/GIXSGUI onyour computer. This is a fork of https://github.com/ennogra/GIXSGUI with a small patch.
 - A script for optics cluster search by M. Daszykowsky, available from doi.org/10.13140/RG.2.1.3998.3843 ,with some modifications. Have a look at the Get Started section for how to set this up. 


## Get started

1. Download this repository into a folder on your computer
2. Open matlab and navigate into the this folder (it the folder where this readme.md file is found)
3. Upen the file set_up_dependencies.m in the matlab editor. This file will help you to set up GIXSGUI and the optics script.
3. Open the StepByStep.mlx live script. This will guide you through all the data analyses.  

Runnig the entire StepbyStep script on a large collection of files (more than 100, dpeending on computer speed) could take a long time, possibly several hours. I'd therefore recommend to start with a low number of files (maybe 20) to check if everything is working, and then repeat with the full number of datasets.

<br/><br/>
<br/><br/>


## Licenses etc.

<b> The files in this repository are licensed under a GPLv3 license. See license.md for more Information. </b>

<br/><br/>

The list of isotopes and their masses (in isotopes_original.mat) has been obtained from AtomProbeLab by A. London,  which is available under the GNU General Public License v3.
see https://sourceforge.net/projects/atomprobelab/files/ 

<br/><br/>

The isotopic abundance data itself has the following copyright notice:
MX Cheminformatics Tools for Java

Copyright (c) 2007, 2008 Metamolecular, LLC
http://metamolecular.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

This system of atomic masses is quoted from:

de Laeter, J.R.; Boehlke, J.K.; de Bievre, P.; Hidaka, H.; Peiser, H.S.; Rosman, K.J.R.;
Taylor, P.D.P. Atomic Weights of the Elements: Review 2000 (IUPAC Technical Report)
Pure Appl. Chem. 2003, 75, 683-800.

http://www.iupac.org/publications/pac/2003/7506/7506x0683.html

<br/><br/>

The function for peak fitting (voigt_fit_edMM) has been adopted from work by Jaspreet Singh:
Singh, J. (2021). Atom probe tomography characterization of engineering ceramics [PhD thesis]. University of Oxford. Available at: https://ora.ox.ac.uk/objects/uuid:60ef298f-bd52-47d4-984d-23982f2a6963

<br/><br/>

The scripts here use MatlabProgressBar by JAAdrian. MatlabProgressBar is available under a BSD 3-Clause License.
Available at: https://github.com/JAAdrian/MatlabProgressBar

MatlabProgressBar has the following Copyright notice:
BSD 3-Clause

Copyright (c) 2020, Jens-Alrik Adrian
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in
       the documentation and/or other materials provided with the
       distribution.

    3. Neither the name of the copyright holder nor the names of its
       contributors may be used to endorse or promote products derived
       from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

