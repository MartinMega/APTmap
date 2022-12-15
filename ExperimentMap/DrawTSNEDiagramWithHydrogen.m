function [] = DrawTSNEDiagramWithHydrogen(TsneTab, HydrogenTab, MinHinBin)


if nargin<3
    MinHinBin = 0;
end



% Combine TsneTab and HydrogenTab. 
% Check if result is as long as TsneTab and HydrogenTab. If not, complain!
FullTab = innerjoin(TsneTab, HydrogenTab, 'Keys', {'Experiment', 'Experiment'});
if ((height(FullTab) ~= height(TsneTab)) || (height(FullTab) ~= height(HydrogenTab)))
    warning('Experiment Names in TsneTab and HydrogenTab dont fully match. Are you sure you have loaded the correct TsneTab and HydrogenTab?')
end




%add column to table for the fit coefficients
FullTab = addvars(FullTab, -1.*ones(height(FullTab),1), -1.*ones(height(FullTab),1), 'NewVariableNames', ["Hfit_m", "Hfit_t"]);
FullTab = addvars(FullTab, -1.*ones(height(FullTab),1), -1.*ones(height(FullTab),1), 'NewVariableNames', ["totalH", "totalH2"]);



for k = 1:height(FullTab)
    
   
    h2inbins = cell2mat(FullTab.H2absolute(k));
    hinbins = cell2mat(FullTab.Habsolute(k));    
    enoughH = h2inbins>MinHinBin & hinbins>MinHinBin; 
    
    h2inbins(~enoughH) = [];
    hinbins(~enoughH) = [];    
    hratio = h2inbins./hinbins;
    
    voltages = mean(cell2mat(FullTab.voltagebins(k)),1); % we use the mean voltage for each voltage bin
    voltages(~enoughH) = [];
   
    
    if length(hratio) > 1
        fitopt = fitoptions('Robust', 'Bisquare', 'Method', 'LinearLeastSquares'); 
        fitobj = fit(hratio(:), voltages(:), 'poly1', fitopt);  
        FullTab.Hfit_m(k) = fitobj.p1;
        FullTab.Hfit_t(k) = fitobj.p2;
    else
        FullTab.Hfit_m(k) = NaN; % cannot fit if we don't have enough data points.
        FullTab.Hfit_t(k) = NaN;
    end
    
    FullTab.totalH(k) = sum(hinbins);
    FullTab.totalH2(k) = sum(h2inbins);
    
end
    






%prepare figure
fig = figure;
%fig.Position(3:4) = fig.Position(3:4) .* 1.5;
hold on
grid on


% we want the size of the markers to be somewhat related to slope of the linear fit.
% This does the following: the 10 percent lowest (absolute) slopes get 
% assigned the smallest marker,  the 90 [ercent highest value get the
% largest marker, all other dots get linearly interpolated values in
% between.
dotsize = FullTab.Hfit_m;
dotsize = FullTab.totalH2 ./ FullTab.totalH;
dotsize = abs(dotsize);
dotsize = interp1(prctile(dotsize,[25,75]), [3 40], abs(dotsize), 'linear', 'extrap');
dotsize = min(max(dotsize,10),40);


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
leg = legend({sprintf('H2/H increases \nwith Voltage'), sprintf('H2/H decreases \nwith Voltage'), 'Insufficient Data'}, 'Location', 'southeast');
ax = gca;
ax.XTick = ax.XTick; % I believe this works around a matlab bug which causes axis ticks
ax.YTick = ax.YTick; % to get messes up when saving a figure using print()
ax.XTickLabel = {};
ax.YTickLabel = {};
%ax.FontSize = 14;
xlabel('t-SNE Dimension 1')
ylabel('t-SNE Dimension 2')






























