


% load the table with the Tsne Coordinates
% load tsnetab

% load the table with the Hydrogen Values
% load HydrogenTable


    
% Combine tsne and Hydrogen table. 
% Check if result is as long as tsneTab and HydrogenTab. If not, complain!
FullTab = innerjoin(TsneTab, HydrogenTab, 'Keys', {'Experiment', 'Experiment'});
if ((FullTab.height ~= TsneTab.height) || (FullTab.height ~= HydrogenTab.height))
    warning('Experiment Names in TsneTab and HydrogenTab don;t fully match. Are you sure you have loaded the correct TsneTab and HydrogenTab?')
    pause(10);
end


% Add a column 'Hfit' to our table so we can add the results of fitting
% the H evolution. Pre-populate with negative Inf for now.
FullTab.Hfits = -1 .* inf(height(FullTab), 2);


%Now loop through the table and apply a linear fit, stick results into table.
for k = 1:height(FullTab)
    
    tab_Varnames = {'Experiment', 'Habsolute', 'H2absolute', 'noise_a', 'totalCounts', 'voltagebins',};
    
    fitY = FullTab.H2absolute(k) ./ FullTab.Habsolute(k);
    fitX = mean(FullTab.voltagebins, 2); % Table contains voltage bins, we fit using the mean voltage in each bin

    % skip if not having enough data points for fit, else apply robust fit
    if length(fitY) > 1
        fitopt = fitoptions('Robust', 'Bisquare', 'Method', 'LinearLeastSquares'); 
        fitobj = fit(fitX(:), fitY(:), 'poly1', fitopt);        
        FullTab.Hfits(k,:) = [fitobj.p1, fitobj.p2];  
    else
        FullTab.Hfits(k,:) = [NaN, NaN];  
    end
end




% get figure ready
figure
hold on
grid on
grid minor

%First, draw all data using black dots
scatter(FullTab.tsne_x, FullTab.tsne_y, '.k');

% We can use something fancy for the dot size. However, this might nead
% some manual twaking, depending on the data. Therefore I'll just leave a
% default value in here.
dotsize = 10;
%dotsize = ((abs(fits(:,1))./ 5e-4) .* 70 + 20);
%dotsize(dotsize > 100) = 100;


% Draw an downward facing trangle if H is going down, ie if the first fit
% parameter is negative
hdecreasing = FullTab.Hfits(:,1) < 0;
scatter(FullTab.tsne_x(hdecreasing), FullTab.tsne_y(hdecreasing), dotsize, 'v', 'filled', 'MarkerFaceColor', hexcol2mat('#483DB8'), 'MarkerEdgeColor','k');


% same for experiments with increasing H amount, upward facing triangle
increasing = FullTab.Hfits(:,1) > 0;
scatter(FullTab.tsne_x(hincreasing), FullTab.tsne_y(hincreasing), dotsize, '^', 'filled', 'MarkerFaceColor', hexcol2mat('#FFD700'), 'MarkerEdgeColor','k');


% some diagram beautification
ax = gca;
ax.XTickLabel = {};
ax.YTickLabel = {};
xlabel('tsne dimension 1', 'FontSize', 10);
ylabel('tsne dimension 2', 'FontSize', 10);
leg = legend({'all data', 'H2/H decreasing', 'H2/H increasing'}, 'Location', 'best');






