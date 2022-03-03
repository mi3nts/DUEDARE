% FUNCTION TO CONTRUCTION A TIME SERIES OF TARGET PREDICTIONS FROM A
% REGRESSION MODEL

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = timeSeriesRegPlots(modelPath, Mdl, t, X, Y, modelName, YName)

%% TIME SERIES RECONSTRUCTION

% create figure
figure(1)
fig = gcf;
fig.Units = 'normalized';
fig.Position = [0 0 1 1];

% plot time series
plot(t, Y, 'k', 'LineWidth', 1.5)
hold on
plot(t, predict(Mdl, X), 'r--', 'LineWidth', 1.5)
xlabel("Time Index")
ylabel(YName, 'Interpreter', 'none')
title(strcat(YName, " Time Series"), 'Interpreter', 'none')
legend("True Values", "Estimated Values", 'Location','best')
set(gca, 'FontSize', 20)


% save plot to file
directory = strcat(modelPath, modelName, "/Plots/targetTS_Plot/");
createDir(directory)
print(strcat(directory, modelName, "_targetTS"),'-dpng')

%% QUANTILE-QUANTILE PLOT

% create figure
figure(2)
fig = gcf;
fig.Units = 'normalized';
fig.Position = [0 0 1 1];

% plot Q-Q plot (training)
qqplot(predict(Mdl, X),Y);
title(strcat(modelName, " Quantile-Quantile Plot"), ...
    'FontSize', 28, ...
    'Interpreter', 'none')
xlabel(strcat("Estimated ", TargetName), 'FontSize', 20)
ylabel(strcat("True ", TargetName), 'FontSize', 20)
ax = gca;
set(ax,'FontSize',20)
ax.Children(1).MarkerSize = 10;
ax.Children(1).LineWidth = 1.5;
ax.Children(2).MarkerSize = 10;
ax.Children(2).LineWidth = 1.5;
ax.Children(3).MarkerSize = 10;
ax.Children(3).LineWidth = 1.5;
ax.XLabel.String = "Predicted Target Quantiles";
ax.XLabel.FontSize = 20;
ax.YLabel.String = "True Target Quantiles";
ax.YLabel.FontSize = 20;

% save plot to file
directory = strcat(modelPath, modelName, "/Plots/QQ_Plots/");
createDir(directory)
print(strcat(directory, modelName, "_QQ"),'-dpng')
