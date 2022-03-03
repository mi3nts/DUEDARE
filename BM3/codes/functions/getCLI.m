% FUNCTION TO COMPUTE COMPOSITE PHYSICAL LOAD INDEX BASED ON HR AND GSR

% INPUTS:
%     YEAR = string. year of data collection.
%     MONTH = string. month of data collection.
%     DAY = string. day of data collection.
%     TRIAL = string. trial number of data.
%     USER = string. user id.%     iSOM = integer. Granularity of index
%     savePlotFlag = boolean. True inidcates time series will be saved to
%     file

% OUTPUTS:
%     CLI = composite cognitive load index for each record in Timetable

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function CLI = getCLI(YEAR, MONTH, DAY, TRIAL, USER, iSOM, savePlotFlag)

%% LOAD DATA

Timetable = LoadTimetable(YEAR, MONTH, DAY, TRIAL, USER, 'Synchronized');

%% PREPARE AUTONOMIC AROUSAL SPACE

% define moving window size
movWindow = 5000;

% perform moving average to all variables
HR = (movmean(Timetable.HR,movWindow,'omitnan'));
GSR = (movmean(Timetable.GSR_uS,movWindow, 'omitnan'));
% HRV = (movmean(Timetable.HRV_rMSSD,movWindow));

% get derivatives of 
dHR = gradient(HR);
mvdGSR = movvar(gradient(GSR), movWindow, 'omitnan');
%% PREPARE DATASET

Table = table(HR, GSR, dHR, mvdGSR);
Timetable = table2timetable(Table,'RowTimes',Timetable.Datetime);
Data = Timetable.Variables;

%% SOM 

% get composite load index
[CLI, ~] = getClassesSOM(Data, iSOM, 1);

%% TIME SERIES PLOTS

if savePlotFlag
    fig1 = figure;
    fig1.Units = 'normalized';
    fig1.Position = [0 0 1 1];
    fig1.Visible = 'off';
    
    % define number of plots
    n = length(Timetable.Properties.VariableNames)+1;
    % define color map
    cmap = colormap(jet(n));

    % plot SOM
    subplot(n,1,1)
    plot(Timetable.Time, CLI, ...
        'Color', cmap(1,:), ...
        'LineWidth', 2)
    ylim([-1 iSOM+1])
    title('Composite Load Index', 'FontSize', 18)
    ylabel('Index Value', 'FontSize', 12)

    % plot time series of input space
    for i = 2:n
        subplot(n,1,i)
        plot(Timetable.Time, Data(:,i-1), ...
            'Color', cmap(i,:), ...
            'LineWidth', 2)
        title(Timetable.Properties.VariableNames(i-1), 'FontSize', 18)
    end
    
    xlabel('Timestamp (UTC)', 'FontSize', 14)

    %% SAVE PLOT

    % make ID and pathID
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);

    % create directory to save png of plot
    directory = strcat("visuals/",pathID, "/CLI_som/");
    createDir(directory)

    % create filename of png
    filename = strcat(directory, ID,"_CLI_som_",string(iSOM));

    % save png
    print(filename, '-dpng')
end