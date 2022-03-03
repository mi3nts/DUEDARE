clear; close all; clc

% CODE TO CREATE PLOTS TO EVALUATE ML MODELS OF PARTICULATE MATTER

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

%% OVERHEAD

% grab current directory
curDir = pwd;

% specify subdirectory models
modelID = "BM-9_PM-54_Trials-7_TP-90";
splitModelID = split(modelID, "_");
numVars = str2num(strrep(splitModelID(1), "BM-", ""));
corePath = strcat(curDir,"/Models/", modelID, "/");

% add functions and change to homeDir
homeDir

%% ITERATE THROUGH ALL MODELS

% get list of subdirs in core path
filelist = dir(corePath);

% initialize array to store summary statistics
regressionSummary = [];
varImportances = zeros(1,numVars); % change size according to model
varImportancesWeighted = zeros(1,numVars); % change size according to model

for i=1:length(filelist)

    foldername = filelist(i).name;
    if foldername(1) == '.'
        continue
    end
    if foldername(1) == '_'
        continue
    end

    % define path to model folder
    modelPath = strcat(filelist(i).folder, '/');

    % load model
    load(strcat(modelPath,filelist(i).name,"/Model.mat"))
            
    % model evaluation plots
    % calculate correlation coefficent for training set
    cc_train = corrcoef(Model.YTrain_predicted,Model.YTrain);
    r_train = cc_train(1,2);
    r2_train = r_train^2;
    if isnan(r2_train)
        r2_train = 1;
    end

    % calculate correlation coefficent for testing set
    cc_test = corrcoef(Model.YTest_predicted,Model.YTest);
    r_test = cc_test(1,2);
    r2_test = r_test^2;

    regressionSummary = [regressionSummary; ...
        {Model.modelName} Model.YName ...
        {r2_train} {r2_test}];
    
    varImportances = varImportances + single(predictorImportance(Model.Mdl)>0);
    varImportancesWeighted = varImportancesWeighted + predictorImportance(Model.Mdl);
end

%% PLOT ACCURACY VS BIN SIZE

% create figure
figure(1)
fig = gcf;
fig.Units = 'normalized';
fig.Position = [0 0 1 1];

line_width = 2;

modelNames = string(regressionSummary(:,1));
binSummary = regressionSummary(contains(modelNames, "bin"),:);

[~,sortedBinIndex] = sort(binSummary(:,2));
binSummarySorted = cell2table(binSummary(sortedBinIndex,:));

binNames = split(binSummarySorted.Var1, '-');
binNames = binNames(:,end);

% NAMES FOR BINS
% import bin size ranges
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

% replace bin variables names one by one
for i = 1:length(binNames)
    
    varname  = strip(binNames(i), "}");

    if contains(varname, "bin")
        eval(strcat("newBinNames(", string(i), ...
            ") = binNameTable.", varname,";"));
    end
end

% patches
% trialEdgesBool = diff(t);
% trialEdgesBool = trialEdgesBool - trialEdgesBool(1);
% trialEdgesBool = seconds(trialEdgesBool) > 0;
% trialEdges = ((1:length(trialEdgesBool))'.*trialEdgesBool)';
% 
% trialEdges(trialEdges==0) = [];
patchEdgePoints = ["1-1.07 \mum" "2.37-2.55 \mum"]';
respiratory_regions = ["Respirable" "Thoracic" "Inhalable"];

patchEdges = (1:length(newBinNames))'.*contains(newBinNames,patchEdgePoints);
patchEdges(patchEdges==0) = [];
patchEdges = [0 patchEdges' 45];

% newBinNames

cmap = colormap(autumn(length(patchEdges)-1));
for i = 1:length(patchEdges)-1
    patch([patchEdges(i) patchEdges(i+1) patchEdges(i+1) patchEdges(i)], ...
        [0 0 1.2 1.2], cmap(i,:))
    alpha(0.05)
    hold on
    text(patchEdges(i) + ((patchEdges(i+1) - patchEdges(i))/2), 1.1, ...
        respiratory_regions(i), ...
        'FontSize', 26, 'HorizontalAlignment','center', ...
        'FontWeight', 'bold')
end

plot(binSummarySorted(:,3).Variables, 'LineWidth', line_width)
hold on
plot(binSummarySorted(:,4).Variables, 'LineWidth', line_width)

ax = gca;
set(gca, 'FontSize', 26)
ax.XAxis.TickValues = 1:height(binSummarySorted);
ax.XAxis.TickLabels = newBinNames;
ax.XAxis.TickLabelRotation = 80;
ax.XAxis.FontSize = 20;
ax.XAxis.Label.String = "\bf{Bin Sizes (\mug/m^3)}";

ax.YAxis.Label.String = "Model Accuracy";
xlim([0 patchEdges(end)]);
ylim([0 1.2]);

labels = [repelem("", 1, length(respiratory_regions)), ...
    "Training Data", "Validation Data"];

legend(labels, ...
    'FontSize', 26)%, 'Location','bestoutside')
title("Model Performances", 'FontSize', 28)
grid("on")

directory = strcat(corePath, "_summaryPlots/");
createDir(directory)
print(strcat(directory, modelID, "_Accuracy_BinSize"),'-dpng')
