
function [] = checkIfMatlabReady()



%Check matlab version. 2020b is ideal.
v= ver('matlab'); 
if (v.Release ~= "(R2020b)")
   fprintf(" \nYour matlab version is " + string(v.Release) ...
           + ". \n -> All of the scripts & functions in this collections were written on v2020b \n" ...
           + " You can have a go and use them anyway, though problems could possibly occur \n \n " ) ;
else
    fprintf(' \n You use matlab2020b -> good \n'); 
end
    



% Check if all toolboxes are there
toolboxesneeded = [ "curve_fitting_toolbox";
                    "distrib_computing_toolbox";
                    "statistics_toolbox"];
for k = 1:length(toolboxesneeded)
    if (license('test',toolboxesneeded(k)))
        fprintf("You have a license for " + toolboxesneeded(k) + " -> good \n"); 
    else
        fprintf("You don;t seem to have a license for " + toolboxesneeded(k) + ". -> This might cause problems.\n"); 
    end
end

        
    