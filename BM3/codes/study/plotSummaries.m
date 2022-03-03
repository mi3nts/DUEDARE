clear; close all; clc

% CODE TO CREATE PLOTS TO EVALUATE ML MODELS OF PARTICULATE MATTER

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

%% OVERHEAD

% grab current directory
curDir = pwd;

% add functions and change to homeDir
homeDir

%%

% specify subdirectory models
modelIDs = ["BM-9_PM-6_Trials-7_TP-90" "BM-9_PM-6_Trials-7_TP-90_withEEG" ...
    "BM-9_PM-54_Trials-7_TP-90"];

for modelID = modelIDs
    splitModelID = split(modelID, "_");
    numVars = str2num(strrep(splitModelID(1), "BM-", ""));
    corePath = strcat(curDir,"/Models/", modelID, "/");
    
    %% ITERATE THROUGH ALL MODELS
    
    % get list of subdirs in core path
    filelist = dir(corePath);
    
    % initialize array to store summary statistics
    classificationSummary = [];
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
    
    %% WEIGHTED TOP PREDICTOR PLOT
    
    % create figure
    figure(1)
    fig = gcf;
    fig.Units = 'normalized';
    fig.Position = [0 0 1 1];
    
    tempTable = array2table(zeros(1,length(Model.XNames)), 'VariableNames', Model.XNames);
    prettyVarNames = getPrettyNames(tempTable);
    for band=["delta" "theta" "alpha" "beta" "gamma"]
        nameContainsBand = contains(prettyVarNames, band);
        prettyVarNames(nameContainsBand) = strrep(prettyVarNames(nameContainsBand), ...
            "_", "-");
        prettyVarNames(nameContainsBand) = ...
            strcat(prettyVarNames(nameContainsBand), " ", "(V^2/Hz)");
        
    end
    
    % plot most important variables
    [sorted_imp,isorted_imp] = sort(varImportancesWeighted,'descend');
    sortedXNames = prettyVarNames(isorted_imp);
    topSortedXNames = sortedXNames(sorted_imp>0);
    topSortedCounts = sorted_imp(sorted_imp>0);
    topN = 10;
    if topN>length(sortedXNames)
        topN = length(sortedXNames);
    end
    
    bar(topSortedCounts(1:topN))
    grid()
    ax = gca;
    ax.XAxis.TickValues = 1:topN;
    ax.XAxis.TickLabels = topSortedXNames;
    ax.XAxis.TickLabelRotation = 40;
    ax.XAxis.Label.String = "\bf{Top Predictor Names}";
    ax.YAxis.Label.String = "Top Predictor Weights";
    
    set(gca, 'FontSize', 30)
    title("Top Predictor Ranking", 'FontSize', 55)
    
    % save plot
    directory = strcat(corePath, "/_summaryPlots/");
    createDir(directory)
    print(strcat(directory, modelID,"_TopPredictors"),'-dpng')
    
    %% REGRESSION PERFORMANCE SUMMARIES
    if length(regressionSummary) <= 10

        % create figure
        figure(2)
        fig = gcf;
        fig.Units = 'normalized';
        fig.Position = [0 0 1 1];
        
        % get regression accuracy for testing data
        regressionAccuracyTest = cell2table(regressionSummary(:,4));
        
        % sort performance by accuracy
        [~,isorted] ...
            = sort(regressionAccuracyTest.Variables,'descend');
        % sort names by accuracy
        sortedYNames = regressionSummary(isorted,2);
        % clean up PM names
        sortedYNames = strrep(sortedYNames, "PM", "PM_{");
        sortedYNames = strrep(sortedYNames, "{25", "{2.5");
        sortedYNames = strcat(sortedYNames, "}");
        sortedYNames = strrep(sortedYNames, "n}", "n");
        
        % NAMES FOR BINS
        % import bin size ranges
        binSizesTable = readtable(strcat(curDir, '/backend/palas_data-channels_sizes.csv'));
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
        for i = 1:length(sortedYNames)
            
            varname  = strip(sortedYNames(i), "}");
        
            if contains(varname, "bin")
                eval(strcat("sortedYNames(", string(i), ...
                    ") = binNameTable.", varname,";"));
            end
        end
        
        % create table with sorted training and testing dataset accuracies
        regressionAccuracy = cell2table(regressionSummary(isorted,3:4));
        regressionAccuracy.Properties.VariableNames = ["Training Data", "Validation Data"];
        
        % create plot
        notNan = ~isnan(regressionAccuracy(:,2).Variables);
        bar(regressionAccuracy(notNan,:).Variables)
        grid()
        ax = gca;
        ax.XAxis.TickValues = 1:length(sortedYNames(notNan));
        ax.XAxis.TickLabels = sortedYNames(notNan);
        ax.XAxis.FontSize = 24;
        ax.XAxis.Label.String = "\bf{Target Names}";
        
        ax.YAxis.Label.String = "Model Accuracy";
        ax.YAxis.Label.FontSize = 24;
        
        legend(regressionAccuracy.Properties.VariableNames, ...
            'FontSize', 24)%, 'Location','bestoutside')
        
        
        set(gca, 'FontSize', 30)
        title("Model Performances", 'FontSize', 55)
        
        % save figure
        print(strcat(directory, modelID, "_regressionAccuracies"),'-dpng')
        
        %%
        load(strcat(corePath,"_data/DUEDARE_", ...
            strrep(modelID,"_withEEG",""), ".mat"))
        Predictors.Properties.VariableNames = prettyVarNames;
        
        TargetNames = strrep(Targets.Properties.VariableNames, "PM", "PM_{");
        TargetNames = strrep(TargetNames, "{25", "{2.5");
        TargetNames = strcat(TargetNames, "}");
        TargetNames = strrep(TargetNames, "n}", "n");
        % replace bin variables names one by one
        for i = 1:length(TargetNames)
            
            varname  = strip(TargetNames(i), "}");
        
            if contains(varname, "bin")
                eval(strcat("sortedYNames(", string(i), ...
                    ") = binNameTable.", varname,";"));
            end
        end
        TargetNames = strcat(TargetNames, " (\mug/m^3)");
        Targets.Properties.VariableNames = strrep(TargetNames, "dCn (\mug/m^3)", ...
             "dCn (P/cm^3)");
        
        % save figure
        plotHistos(Predictors)
        print(strcat(directory, modelID, "_Histograms-Predictors"),'-dpng')
        
        plotHistos(Targets)
        print(strcat(directory, modelID, "_Histograms-Targets"),'-dpng')
        
        %% PLOT CORRELATION MATRIX PREDICTORS AND TARGETS
        
        close all
        
        TT = [Predictors Targets];
        
        % create figure
        figure(3)
        fig = gcf;
        fig.Units = 'normalized';
        fig.Position = [0 0 1 1];
        
        n = width(TT);
        imagesc(corr(TT.Variables, 'rows','complete')-1000*eye(n))
        
        cmap = colormap('turbo');
        % cmap(128,:) = [0 0 0];
        
        ax = gca;
        ax.XTick =  1:n; % center x-axis ticks on bins
        ax.YTick =  1:n; % center y-axis ticks on bins
        ax.XTickLabel  = TT.Properties.VariableNames;
        ax.YTickLabel  = TT.Properties.VariableNames;
        ax.XTickLabelRotation = 45;
        ax.FontSize = 20;
        title('Correlation Plot', 'FontSize', 55); % set title
        % colormap('turbo'); % Choose jet or any other color scheme
        c = colorbar();
        c.Label.String = 'Correlation Coefficent';
        c.Label.FontSize = 26;
        caxis([-1 1])
        print(strcat(directory, modelID, "_CorrelationPlot"),'-dpng')
    
    end
    close all
end