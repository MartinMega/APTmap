
function [] = checkIfMatlabReady()



%Check matlab version. 2020b is ideal.
v= ver('matlab'); 
if (v.Release ~= "(R2020b)")
   fprintf(" \nYour matlab version is " + string(v.Release) ...
           + ". \n -> All of the scripts & functions in this collections were written on v2020b \n" ...
           + " You can have a go and run the script anyway, it will probabably run just fine. \n \n " ) ;
else
    fprintf(' \n You use matlab2020b -> good \n'); 
end
    



% Check if all toolboxes are there
toolboxesneeded = [ "curve_fitting_toolbox";
                    "distrib_computing_toolbox";
                    "statistics_toolbox"];
allgood = true;
for k = 1:length(toolboxesneeded)
    if (license('test',toolboxesneeded(k)))
        fprintf("You have a license for " + toolboxesneeded(k) + " -> good \n"); 
    else
        fprintf("You don;t seem to have a license for " + toolboxesneeded(k) + ". -> This might cause problems.\n"); 
        allgood = false;
    end
end

if allgood
    fprintf("Seems like you have all of the toolboxes. This is skript is probably likely to run on your matlab installation.\n"); 
end
        
    