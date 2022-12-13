function newrow_cell = readFilePrepareTableRow_BuildHydrogenTable(FileTabANDCorrValsTab_row, voltagebins, MinCounts_voltagebin, MinHinBin, Hrange, H2range, binw_noisecorr, conf_noisecorr)
        
        % read epos file.
        % To save memory, keep m/n and voltage, immediately delete everything else
        [epos] = qreadpos(FileTabANDCorrValsTab_row.path);
        mnvalues = epos(:,4);
        voltages = epos(:,6);
        epos = -inf; % trick: matlab does not allow deleting this in a parfor loop,
                     % but if we just overwrite a big array with a scalar this is
                     % enough to save some memory.
                     
                     
        %apply mass spec calibration
        mnvalues = (mnvalues .* FileTabANDCorrValsTab_row.corr_fac) + FileTabANDCorrValsTab_row.corr_shift;
                     
        
        
        Habs = [];
        H2abs = [];
        noise_a = [];
        totalInBin = [];
        vbins = zeros([2,0]);
        
        % loop through voltage bins
        for kv = 1:(length(voltagebins)-1)
            
            % check if there are enough counts in the voltage bin pre noise correction. If no, skip to the next bin!
            inVbin = voltages >= voltagebins(kv) & voltages < voltagebins(kv+1);
            totalInVBin = sum(inVbin);
            if totalInVBin < MinCounts_voltagebin
                continue
            end
            
            % Get a noise corrected spec from the counts in the voltage bin
            [inVbin_noisecspec,~,bincenters,noisecurve_a] = getNoiseCorrSpecFromMassCharge(mnvalues(inVbin),binw_noisecorr,conf_noisecorr);
            
            %get the Hydrogen counts. If there are less than MinHinBin, skip to
            %next voltage bin.
            HabsVbin = sum(inVbin_noisecspec(bincenters > Hrange(1) & bincenters < Hrange(2)));
            H2absVbin = sum(inVbin_noisecspec(bincenters > H2range(1) & bincenters < H2range(2)));
            if (min(HabsVbin, H2absVbin) < MinHinBin)
                continue;
            end
            
            % Collect result in these arrays
            % matlab discourages changing array sizes in a loop but this is
            % acceptable as arrays are short and it only happens a few
            % hundred-or thousand times, it won't take too long anyway.
            Habs(end+1) = HabsVbin;
            H2abs(end+1) = H2absVbin;
            noise_a(end+1) = noisecurve_a;
            totalInBin(end+1) = sum(inVbin_noisecspec);
            vbins(:,end+1) = voltagebins([kv, kv+1]);
            
        end
        
        
        % Now we've collected all the Hydrogen information we can make a new row
        % for the hyrogen table an
        newrow_cell = {FileTabANDCorrValsTab_row.Experiment, Habs, H2abs, noise_a, totalInBin,vbins};
        
        
    end