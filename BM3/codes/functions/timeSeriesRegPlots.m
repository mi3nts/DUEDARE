% FUNCTION TO CONTRUCTION A TIME SERIES OF TARGET PREDICTIONS FROM A
% REGRESSION MODEL

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = timeSeriesRegPlots(modelPath, Mdl, t, X, Y, modelName, YName)

%% VARIABLE NAME

if contains(YName, 'bin')
     % NAMES FOR BINS
    % import bin size ranges
    temp = split(modelPath, 'Models');
    curDir = temp{1};
    binSizesTable = readtable(strcat(curDir, '/data/palas_data-channels_sizes.csv'));
    % create bin names
    newBinNames = strcat(string(round(binSizesTable.XLower_um_,2)), "-", ...
        string(round(binSizesTable.XUpper_um_,2)), " \mum");
    % get raw names of bins
    rawNames = string((1:length(newBinNames)));
    for name = rawNames
        if length(char(name))==1
            rawNames(strcmp(rawNames,name)) = strcat("0", name);
        end
    end
    rawNames = strcat("bin", rawNames);
    % creat table that maps raw names to bin ranges
    binNameTable = rows2vars(array2table(newBinNames));
    binNameTable = binNameTable(:,2:end);
    binNameTable.Properties.VariableNames = rawNames;
    
    % find index corresponding to target name
    ibool = YName==rawNames;

    % grab pretty target name
    YName = binNameTable(1,ibool).Variables;
    YName = strcat(YName, " (\mug/m^3)");

elseif contains(YName, 'PM')
    % clean up PM names
    YName = strrep(YName, "PM", "PM_{");
    YName = strrep(YName, "{25", "{2.5");
    YName = strcat(YName, "}");
    YName = strrep(YName, "n}", "n");

    YName = strcat(YName, " (\mug/m^3)");

elseif contains(YName, 'dCn')

    YName = "dCn (P/cm^3)";
end

%% TIME SERIES RECONSTRUCTION

% create figure
figure(10)
fig = gcf;
fig.Units = 'normalized';
fig.Position = [0 0 1 0.5];

% patches
if isdatetime(t)
    trialEdgesBool = diff(t);
    trialEdgesBool = trialEdgesBool - trialEdgesBool(1);
    trialEdgesBool = seconds(trialEdgesBool) > 0;
    trialEdges = ((1:length(trialEdgesBool))'.*trialEdgesBool)';

    trialEdges(trialEdges==0) = [];
    trialEdges = [0 trialEdges length(t)];

    cmap = colormap(hsv(length(trialEdges)-1));
    for i = 1:length(trialEdges)-1
        patch([trialEdges(i) trialEdges(i+1) trialEdges(i+1) trialEdges(i)], ...
            [0 0 ceil(max(Y)) ceil(max(Y))], cmap(i,:))
        alpha(0.05)
        hold on
        text(trialEdges(i) + ((trialEdges(i+1) - trialEdges(i))/2), ...
            ceil(max(Y))*0.95, ...
            strcat("Trial ", string(i)), ...
            'FontSize', 26, 'HorizontalAlignment','center', ...
            'FontWeight', 'bold')
    end
end

% plot time series
plot(1:length(t), Y, 'k', 'LineWidth', 1.5)
hold on
plot(1:length(t), predict(Mdl, X), 'r--', 'LineWidth', 1.5)
xlabel("Time Index")
ylabel(YName, 'Interpreter', 'tex')
xlim([0 trialEdges(end)]);
ylim([0 ceil(max(Y))]);
title(strcat(YName, " Time Series"), 'Interpreter', 'tex')

labels = [repelem("", 1, length(trialEdges)-1), ...
    "True Values", "Estimated Values"];

legend(labels, 'Location','best')
set(gca, 'FontSize', 36)
grid on

% save plot to file
directory = strcat(modelPath, modelName, "/Plots/targetTS_Plot/");
createDir(directory)
print(strcat(directory, modelName, "_targetTS"),'-dpng')

%% QUANTILE-QUANTILE PLOT

% create figure
figure(11)
fig = gcf;
fig.Units = 'normalized';
fig.Position = [0 0 0.5 0.5];

% plot Q-Q plot (training)
qqplot(predict(Mdl, X),Y);
xlabel(strcat("Estimated ", YName))
ylabel(strcat("True ", YName))
ax = gca;
ax.Children(1).MarkerSize = 10;
ax.Children(1).LineWidth = 1.5;
ax.Children(2).MarkerSize = 10;
ax.Children(2).LineWidth = 1.5;
ax.Children(3).MarkerSize = 10;
ax.Children(3).LineWidth = 1.5;
ax.XLabel.String = strcat("Estimated ", YName);
% ax.XLabel.FontSize = 20;
ax.YLabel.String = strcat("True ", YName);
% ax.YLabel.FontSize = 20;
set(ax,'FontSize',28)

title(strcat(YName, " Quantile-Quantile Plot"), ...
    'FontSize', 28, ...
    'Interpreter', 'tex')

grid on

% save plot to file
directory = strcat(modelPath, modelName, "/Plots/QQ_Plots/");
createDir(directory)
print(strcat(directory, modelName, "_QQ"),'-dpng')
