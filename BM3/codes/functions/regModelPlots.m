% FUNCTION TO CREATE PLOTS TO EVALUATE ML REGRESSION MODELS

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

%% FUNCTION

function [] = regModelPlots(modelPath, Mdl, ...
    YTrain, YTest, ...
    YTrain_predicted, YTest_predicted, ...
    modelName, PredictorNames, TargetName)

    %% VARIABLE NAME

    % target name
    if contains(TargetName, 'bin')
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
        ibool = TargetName==rawNames;

        % grab pretty target name
        TargetName = binNameTable(1,ibool).Variables;
        TargetName = strcat(TargetName, " (\mug/m^3)");

    elseif contains(TargetName, 'PM')
        % clean up PM names
        TargetName = strrep(TargetName, "PM", "PM_{");
        TargetName = strrep(TargetName, "{25", "{2.5");
        TargetName = strcat(TargetName, "}");
        TargetName = strrep(TargetName, "n}", "n");

        TargetName = strcat(TargetName, " (\mug/m^3)");

    elseif contains(TargetName, 'dCn')

        TargetName = "dCn (P/cm^3)";
    end


    %% EVALUATE MODEL

    % calculate mean squared error for training set
    mseTrain = mean((YTrain_predicted-YTrain).^2);

    % calculate mean squared error for testing set
    mseTest = mean((YTest_predicted-YTest).^2);

    % calculate correlation coefficent for training set
    cc_train = corrcoef(YTrain_predicted,YTrain);
    r_train = cc_train(1,2);
    r2_train = r_train^2;
    if isnan(r2_train)
        r2_train = 1;
    end

    % calculate correlation coefficent for testing set
    cc_test = corrcoef(YTest_predicted,YTest);
    r_test = cc_test(1,2);
    r2_test = r_test^2;

    % calulate error for testing set
    e = (YTest_predicted-YTest);

    %% PLOT ERROR HISTOGRAM

    % create figure
    figure(1)
    fig = gcf;
    fig.Units = 'normalized';
    fig.Position = [0 0 1 1];

    % plot error histogram
    ploterrhist(double(e))
    grid on
    title(strcat(TargetName, " Error Histogram"));
    ax = gca;
    ax.OuterPosition = [0 0.1 1 0.9];
    set(ax, 'FontSize', 28)
    hold off

    % save histogram
    directory = strcat(modelPath, modelName, "/Plots/ErrorHistogram/");
    createDir(directory)
    print(strcat(directory, modelName,"_ErrHist"),'-dpng')

    %% PLOT PREDICTOR IMPORTANCE

    % pretty var names
    tempTable = array2table(zeros(1,length(PredictorNames)), ...
        'VariableNames', PredictorNames);
    prettyVarNames = getPrettyNames(tempTable);
    for band=["delta" "theta" "alpha" "beta" "gamma"]
        nameContainsBand = contains(prettyVarNames, band);
        prettyVarNames(nameContainsBand) = strrep(prettyVarNames(nameContainsBand), ...
            "_", "-");
        prettyVarNames(nameContainsBand) = ...
            strcat(prettyVarNames(nameContainsBand), " ", "(V^2/Hz)");
        
    end

    % compute importance rankings 
    imp=predictorImportance(Mdl);

    % sort importance in descending order
    [sorted_imp,isorted_imp] = sort(imp,'descend');

    % create figure
    figure(2)
    fig = gcf;
    fig.Units = 'normalized';
    fig.Position = [0 0 1 1];


    % create bar graph of importance rankings
    n_top_bars = 20;
    try
        barh(imp(isorted_imp(1:n_top_bars)));
    catch
        barh(imp(isorted_imp));
        n_top_bars = length(isorted_imp);
    end
    hold on;grid on;
        if length(isorted_imp)>=5
            barh(imp(isorted_imp(1:5)),'y');
        else
            barh(imp(isorted_imp),'y');
        end
        if length(isorted_imp)>=3
            barh(imp(isorted_imp(1:3)),'r');
        else
            barh(imp(isorted_imp(1:n_top_bars)),'r');
        end
    title(strcat(TargetName, " Predictor Importance Ranking"));
    xlabel('Estimated Importance', 'Fontsize', 16);
    ylabel('Predictors', 'Fontsize', 16);
    set(gca,'FontSize',24); set(gca,'TickDir','out'); set(gca,'LineWidth',2);
    ax = gca;ax.YDir='reverse';ax.XScale = 'log';
    xl=xlim;
    xlim([xl(1) xl(2)*2.75]);
    ylim([.25 n_top_bars+.75])

    % label the variables
    for i=1:n_top_bars
        text(...
            1.05*imp(isorted_imp(i)),i,...
            prettyVarNames{isorted_imp(i)},...
            'FontSize',22, 'Interpreter', 'tex' ...
        )
    end
    hold off
    grid on

    % save graph as png
    directory = strcat(modelPath, modelName, "/Plots/ImportanceRanking/");
    createDir(directory)
    print(strcat(directory, modelName,"_ImpRank_T", string(n_top_bars)),'-dpng')

    %% PLOT SCATTER DIAGRAM OF PERFORMANCE

    % create figure
    figure(3)
    fig = gcf;
    fig.Units = 'normalized';
    fig.Position = [0 0 0.5 0.5];

    % plot training/testing actual vs model estimation and 1 to 1
    scatterhist([YTrain_predicted; YTest_predicted], ...
        [YTrain; YTest], ...
        'Color', 'green', 'Kernel', 'on', 'Location','SouthEast', ...
        'Direction', 'out', ...
        'Marker', 'o+', 'Color', 'br','MarkerSize', [8, 8], 'LineWidth', [3, 3], ...
        'Group', repelem(["Training", "Validation"], [length(YTrain) length(YTest)])')
%         'Marker', '+', ...
%         'MarkerSize', 12, ...
    hold on
%     scatter(YTest_predicted,YTest, 100, 'rs', 'filled')
    plot([min([min(YTest) min(YTrain)]) ...
        max([max(YTest) max(YTrain)])], ...
        [min([min(YTest) min(YTrain)]) ...
        max([max(YTest) max(YTrain)])],'k', 'LineWidth', 2)
    try
    legend(strcat("Training r^2 = ",string(r2_train-rem(r2_train,0.01))), ...
        strcat("Validation r^2 = ",string(r2_test-rem(r2_test,0.01))), ...
        "1:1", ...
        'FontSize', 28,'Location', 'southeast');
    catch
        disp("There was an issue computing r^2 values.")
    end
    xlabel(strcat("Estimated ", TargetName), 'FontSize', 20)
    ylabel(strcat("True ", TargetName), 'FontSize', 20)
    ax = gca;
    set(ax,'FontSize',28)
    title(strcat(TargetName, " Performance Scatter Plot"), ...
        'FontSize', 28)
    % make x and y lims equal
    maxLim = (max(max(max(YTrain), max(YTrain)),max(max(YTest_predicted),max(YTest))));
    minLim = (min(min(min(YTrain), min(YTrain)),min(min(YTest_predicted),min(YTest))));
    ax.XLim = [minLim maxLim];
    ax.YLim = [minLim maxLim];
    hold off
    grid on

    % save plot to file
    directory = strcat(modelPath, modelName, "/Plots/ScatterPlots/");
    createDir(directory)
    print(strcat(directory, modelName, "_Scatter"),'-dpng')
%     %% PLOT QUANTILE-QUANTILE PLOTS
% 
%     % create figure
%     figure(4)
%     fig = gcf;
%     fig.Units = 'normalized';
%     fig.Position = [0 0 1 1];
% 
%     % plot Q-Q plot (training)
%     qqplot(YTrain_predicted,YTrain);
%     title(strcat(modelName, " Quantile-Quantile Plot (Training)"), ...
%         'FontSize', 28, ...
%         'Interpreter', 'none')
%     xlabel(strcat("Estimated ", TargetName), 'FontSize', 20)
%     ylabel(strcat("True ", TargetName), 'FontSize', 20)
%     ax = gca;
%     set(ax,'FontSize',20)
%     ax.Children(1).MarkerSize = 10;
%     ax.Children(1).LineWidth = 1.5;
%     ax.Children(2).MarkerSize = 10;
%     ax.Children(2).LineWidth = 1.5;
%     ax.Children(3).MarkerSize = 10;
%     ax.Children(3).LineWidth = 1.5;
%     ax.XLabel.String = "Predicted Target Quantiles";
%     ax.XLabel.FontSize = 20;
%     ax.YLabel.String = "True Target Quantiles";
%     ax.YLabel.FontSize = 20;
% 
%     % save plot to file
%     directory = strcat(modelPath, modelName, "/Plots/QQ_Plots/");
%     createDir(directory)
%     print(strcat(directory, modelName, "_QQ-Training"),'-dpng')
% 
%     % create figure
%     figure(5)
%     fig = gcf;
%     fig.Units = 'normalized';
%     fig.Position = [0 0 1 1];
% 
%     % plot Q-Q plot (testing)
%     qqplot(YTest_predicted,YTest)
%     title(strcat(modelName, " Quantile-Quantile Plot (Testing)"), ...
%         'FontSize', 28, ...
%         'Interpreter', 'none')
%     xlabel(strcat("Estimated ", TargetName), 'FontSize', 20)
%     ylabel(strcat("True ", TargetName), 'FontSize', 20)
%     ax = gca;
%     set(ax,'FontSize',20)
%     ax.Children(1).MarkerSize = 10;
%     ax.Children(1).LineWidth = 1.5;
%     ax.Children(2).MarkerSize = 10;
%     ax.Children(2).LineWidth = 1.5;
%     ax.Children(3).MarkerSize = 10;
%     ax.Children(3).LineWidth = 1.5;
%     ax.XLabel.String = "Predicted Target Quantiles";
%     ax.XLabel.FontSize = 20;
%     ax.YLabel.String = "True Target Quantiles";
%     ax.YLabel.FontSize = 20;
% 
%     % save plot to file
%     directory = strcat(modelPath, modelName, "/Plots/QQ_Plots/");
%     createDir(directory)
%     print(strcat(directory, modelName, "_QQ-Testing"),'-dpng')
% 
