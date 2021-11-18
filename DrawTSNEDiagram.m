function [] = DrawTSNEDiagram(TsneTab, EstTab, ElementsAmountsMarkers)



% Combine tsne and EstTab. 
% Check if result is as long as tsneTab and EstTab. If not, complain!
FullTab = innerjoin(TsneTab, EstTab, 'Keys', {'Experiment', 'Experiment'});
if ((height(FullTab) ~= height(TsneTab)) || (height(FullTab) ~= height(EstTab)))
    warning('Experiment Names in TsneTab and EstTab dont fully match. Are you sure you have loaded the correct TsneTab and EstTab?')
end



%get figure ready
figure;
hold on


%Plot the t-SNE embedding using black dots
scatter(FullTab.tsne_x, FullTab.tsne_y, '.k');


% Now loop through the colours and markers and re-draw some dots with
% colours:
for k = 1:height(ElementsAmountsMarkers)
    Element = ElementsAmountsMarkers.Highlight_Element(k);
    column = contains(FullTab.Properties.VariableNames, Element +"est");
    
    if ~ any(column)
        error("Did not find a column for element" + Element + " in table.");
        continue
    end
    
    highamount = (table2array(FullTab(:,column)) >= ElementsAmountsMarkers.Highlight_MinAmount(k));
    
    scatter(FullTab.tsne_x(highamount), FullTab.tsne_y(highamount), ...
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


% some beautification
grid on; grid minor;
xlabel('t-SNE Dimension 1')
ylabel('t-SNE Dimension 2')
ax = gca;
ax.XTickLabel = {};
ax.YTickLabel = {};



return








