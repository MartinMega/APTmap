

% Situation: You have a Table with estimated amounts EstTab. You want to
% know which elements to use for highlighting in a tsnediagram, or which
% minimum amounts to use for highlighting.

% Solution: Draw a scatter plot from you EstTable, where you plot the
% estimated amount for each dataset on the y-Axis,  and the element on the
% x-Axis:

estmat = table2array(EstTab(:,2:end)); % EstTab as matrix,  without the Experiment name
elementnum = 1:1:size(estmat,2);
elementmat = repmat(elementnum, [size(estmat,1),1]);
elementmat = elementmat + ((rand(size(elementmat))-0.5)./2); %use this to add some random "dither" if your dataset is big.
                                                             %this makes the diagram easiyer to read.
                                                             % just comment line out if you don't need it.

figure
scatter(elementmat(:), estmat(:), 'k.');
ax = gca;
ax.XTick = elementnum;
ax.XTickLabel = strrep(EstTab.Properties.VariableNames(2:end),"est", "");
xlabel('Element');
ylabel('Estimated concentration');

% In this diagram, you will see the estimated amounts for all datasets and
% elements. You might find that there are some elements where the
% distribution is bimodal, or at least wider than for other elements.
%
% These are the elements that could be useful for highlighting in the tsne
% diagram, as it seems as if there is a group of datasets which is
% distinct from the other datasets in that a certainfingerprint fits well.
% From the estimated concentration, you can infer from which minimum
% concentration value you might want to highlight these experiments in the
% tsne diagram.
%
% If you screen resolution is not high enough,  you might need to zoom
% in on the diagram, using matlabs standard zoom function for diagrams.





