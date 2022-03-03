% FUNCTION TO PLOT COGNITIVE LOAD VARIABLES

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = plotCLVars(YEAR, MONTH, DAY, TRIAL, USER, visibility)

    %% LOAD DATA
    
    % get data ID and pathID
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);

    % load data
    try
        Timetable = LoadTimetable(YEAR, MONTH, DAY, TRIAL, USER, 'Synchronized');
    catch
        error(strcat("Synchronized timetable does not exist for ", ID))
    end

    %% PREPARE DATA

    % define moving window size
    movWindow = 5000;
    
    % take care of error measures
    Timetable.HR(Timetable.HR > 250) = NaN;
    Timetable.SpO2(Timetable.HR > 100) = NaN;

    % perform moving average to all variables
    HR = (movmean(interpolNaNs(Timetable.HR),movWindow));
    HRV = (movmean(interpolNaNs(Timetable.HRV_rMSSD),movWindow));
    SpO2 = (movmean(interpolNaNs(Timetable.SpO2),movWindow));
    BR = (movmean(interpolNaNs(Timetable.BR),movWindow));
    GSR = (movmean(interpolNaNs(Timetable.GSR_uS),movWindow));

    % interpolate over NaNs
    APD = interpolNaNs(Timetable.AveragePupilDiameter);
    % perform moving average
    APD = (movmean(APD,movWindow));

    % create single array with all data
    Data = [HR HRV SpO2 BR GSR APD];
    %% PLOT DATA

    % create figure
    fig = figure();
    fig.Units = 'normalized';
    fig.Position = [0 0 1 1];
    fig.Visible = visibility;

    % define plot line colors
    colors = ["#A2142F" "#D95319" "#0072BD" "#4DBEEE" "#77AC30" "#EDB120"];
    % define variable names
    varNames = {'HR (bpm)' 'HRV (ms)' ...
        'SpO2 (%)' 'BR (brpm)' 'GSR (\muS)' 'APD (mm)'};

    % create subplot for each variable
    for i = 1:length(varNames)

        % create plot
        subplot(length(varNames),1,i)
        plot(Timetable.Datetime, Data(:,i), ...
            'Color',colors(i), ...
            'LineWidth', 2)
        ylabel(varNames(i), 'FontSize',16)
        ax = gca;
        ax.XAxis.FontSize = 12;

        % add title
        if i == 1
            title('Cognitive Load Indicators', 'FontSize',18)
        end

        % add xlabel
        if i == length(varNames)
            xlabel('Time (UTC)', 'FontSize', 16)
        end

    end

    %% SAVE PLOT

    % create directory to save png of plot
    directory = strcat("visuals/",pathID, "/CL_plots/");
    createDir(directory)

    % create filename of png
    filename = strcat(directory, ID,"_HR_HRV_SpO2_BR_GSR_APD_plots");

    % save png
    print(filename, '-dpng')