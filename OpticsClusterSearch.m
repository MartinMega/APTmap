function [] = OpticsClusterSearch(SpecTab, EstTab, ElementsAmountsMarkers, optics_minpts)


% Combine SpecTab and EstTab. 
% Check if result is as long as tsneTab and EstTab. If not, complain!
FullTab = innerjoin(EstTab, SpecTab, 'Keys', {'Experiment', 'Experiment'});
if ((height(FullTab) ~= height(EstTab)) || (height(FullTab) ~= height(SpecTab)))
    warning('Experiment Names in TsneTab and SpecTab dont fully match. Are you sure you have loaded the correct TsneTab and EstTab?')
end


%creata a spectra matrix, normalise such that all specs sum up to 1
specmat = FullTab.Spectrum;
specmat = specmat ./ repmat(sum(specmat,2),[1,size(specmat,2)]); 


%apply the optics algorithm
[rd, cd, order] = optics_modified(specmat, optics_minpts, 'cityblock');



%get figure ready
figure
hold on
col = lines(7);

%plot all data as black line
plot_order = 1:length(order);
plot(plot_order, rd(order), 'k-')

%sort the FullTab table so we stick the coloured dots onto he right
%datasets!
FullTab_sorted = FullTab(order, :);


for k = 1:height(ElementsAmountsMarkers)
    Element = ElementsAmountsMarkers.Highlight_Element(k);
    column = contains(FullTab_sorted.Properties.VariableNames, Element +"est");
    
    if ~ any(column)
        error("Did not find a column for element" + Element + " in table.");
        continue
    end
    
    highamount = (table2array(FullTab_sorted(:,column)) >= ElementsAmountsMarkers.Highlight_MinAmount(k));
    
    scatter(plot_order(highamount), rd(order(highamount)), ...
                char(ElementsAmountsMarkers.MarkerType(k)),    ...
                'MarkerFaceColor', char(ElementsAmountsMarkers.MarkerFaceColour(k)), ...
                'MarkerEdgeColor', char(ElementsAmountsMarkers.MarkerEdgeColour(k)) );
end
    



% add legend
legendentries = "all data";
for k = 1:1:height(ElementsAmountsMarkers)
    legendline = ElementsAmountsMarkers.Highlight_Element(k) + " > " + ElementsAmountsMarkers.Highlight_MinAmount(k);
    legendentries(k+1) = legendline;
end
leg = legend(legendentries, 'Location', 'best');


% make it look good
grid on; grid minor;
xlabel('Order')
ylabel('Reachability Distance')
ax = gca;
ax.YTickLabel = {};














