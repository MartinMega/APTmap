function [] = DrawTSNEDiagram3(TsneTab3, EstTab, ElementsAmountsMarkers)
% same as DrawTSNEDiagram, but 3D (requires a 3D TsneTab as input)



% Combine tsne and EstTab. 
% Check if result is as long as tsneTab and EstTab. If not, complain!
FullTab = innerjoin(TsneTab3, EstTab, 'Keys', {'Experiment', 'Experiment'});
if ((height(FullTab) ~= height(TsneTab3)) || (height(FullTab) ~= height(EstTab)))
    warning('Experiment Names in TsneTab and EstTab dont fully match. Are you sure you have loaded the correct TsneTab and EstTab?')
end



%get figure ready
figureposition = get(0, 'defaultFigurePosition');
fig = figure('Name', "tsne Diagram", 'Position', figureposition);
hold on


%Plot the t-SNE embedding using black dots
scatter3(FullTab.tsne_x, FullTab.tsne_y, FullTab.tsne_z, 50, '.k');


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
    
    scatter3(FullTab.tsne_x(highamount), FullTab.tsne_y(highamount), FullTab.tsne_z(highamount), 60, ...
                char(ElementsAmountsMarkers.MarkerType(k)),    ...
                'MarkerFaceColor', char(ElementsAmountsMarkers.MarkerFaceColour(k)), ...
                'MarkerEdgeColor', char(ElementsAmountsMarkers.MarkerEdgeColour(k)), ...
                'MarkerFaceAlpha', 0.4);
end
    


% add legend
legendentries = "all data";
for k = 1:1:height(ElementsAmountsMarkers)
    legendline = ElementsAmountsMarkers.Highlight_Element(k) + " > " + ElementsAmountsMarkers.Highlight_MinAmount(k);
    legendentries(k+1) = legendline;
end
leg = legend(legendentries, 'Location', 'southeast');


% some beautification
grid on; 
xlabel('t-SNE Dimension 1')
ylabel('t-SNE Dimension 2')
zlabel('t-SNE Dimension 3')
ax = gca;
ax.XTickLabel = {};
ax.YTickLabel = {};
ax.ZTickLabel = {};


return








