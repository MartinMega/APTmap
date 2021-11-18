function [] = DrawTSNEDiagramWithHydrogen(TsneTab, HydrogenTab)


% Combine TsneTab and HydrogenTab. 
% Check if result is as long as TsneTab and HydrogenTab. If not, complain!
FullTab = innerjoin(TsneTab, HydrogenTab, 'Keys', {'Experiment', 'Experiment'});
if ((height(FullTab) ~= height(TsneTab)) || (height(FullTab) ~= height(HydrogenTab)))
    warning('Experiment Names in TsneTab and HydrogenTab dont fully match. Are you sure you have loaded the correct TsneTab and HydrogenTab?')
end




%add column to table for the fit coefficients
FullTab = addvars(FullTab, -1.*ones(height(FullTab),1), -1.*ones(height(FullTab),1), 'NewVariableNames', ["Hfit_m", "Hfit_t"]);



for k = 1:height(FullTab)
    hratio = cell2mat(FullTab.H2absolute(k)) ./ cell2mat(FullTab.Habsolute(k));
    voltages = mean(cell2mat(FullTab.voltagebins(k)),1); % we use the mean voltage for each voltage bin
   
    
    if length(hratio) > 1
        fitopt = fitoptions('Robust', 'Bisquare', 'Method', 'LinearLeastSquares'); 
        fitobj = fit(hratio(:), voltages(:), 'poly1', fitopt);  
        FullTab.Hfit_m(k) = fitobj.p1;
        FullTab.Hfit_t(k) = fitobj.p2;
    else
        FullTab.Hfit_m(k) = NaN; % cannot fit if we don't have enough data points.
        FullTab.Hfit_t(k) = NaN;
    end
    
end
    






%prepare figure
figure
hold on
grid on
grid minor


% we want the size of the markers to be somewhat related to slope of the linear fit.
% This does the following: the 10 percent lowest (absolute) slopes get 
% assigned the smallest marker,  the 90 [ercent highest value get the
% largest marker, all other dots get linearly interpolated values in
% between.
dotsize = FullTab.Hfit_m;
dotsize = abs(dotsize);
dotsize = interp1(prctile(dotsize,[10,90]), [10 100], abs(dotsize), 'linear', 'extrap');
dotsize = min(max(dotsize,10),100);


% draw all data with increasing H ratio
goesup = FullTab.Hfit_m > 0;
scatter(FullTab.tsne_x(goesup), FullTab.tsne_y(goesup), dotsize(goesup), '^', 'filled', 'MarkerFaceColor', '#FFD700', 'MarkerEdgeColor','k');

% draw all data with decreasing ratio
goesdown = FullTab.Hfit_m < 0;
scatter(FullTab.tsne_x(goesdown), FullTab.tsne_y(goesdown), dotsize(goesdown), 'v', 'filled', 'MarkerFaceColor', '#483DB8', 'MarkerEdgeColor','k');


% optional: add crosses for datapoints where no fit was possible
unclear = isnan(FullTab.Hfit_m);
scatter(FullTab.tsne_x(unclear), FullTab.tsne_y(unclear), 'x', 'MarkerEdgeColor',"#eb3474");



%add legend, remove axis labels
leg = legend({'H2/H ratio increases w Voltage', 'H2/H ratio decreases w Voltage'}, 'Location', 'best');
ax = gca;
ax.XTickLabel = {};
ax.YTickLabel = {};
xlabel('tsne dimension 1');
ylabel('tsne dimension 2');






























