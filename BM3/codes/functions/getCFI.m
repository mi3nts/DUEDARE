% FUNCTION TO COMPUTE COMPOSITE FOCUS INDEX BASED ON DISTANCE BETWEEN PUPIL
% CENTERS, AVERAGE PUPIL DIAMETER, AND FIXATION FLAG.

% INPUTS:
%     YEAR = string. year of data collection.
%     MONTH = string. month of data collection.
%     DAY = string. day of data collection.
%     TRIAL = string. trial number of data.
%     USER = string. user id.
%     iSOM = integer. Granularity of index
%     savePlotFlag = boolean. True inidcates time series will be saved to
%     file

% OUTPUTS:
%     CLI = composite cognitive load index for each record in Timetable

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function CFI = getCFI(YEAR, MONTH, DAY, TRIAL, USER, iSOM, savePlotFlag)

%% LOAD DATA

Timetable = LoadTimetable(YEAR, MONTH, DAY, TRIAL, USER, 'Synchronized');

%% PREPARE FOCUSEDNESS SPACE

% interpolate eye tracking variables
Timetable = interpolTobiiNaNs(Timetable);

windowSize = 5000;

invPCD = movmean(1./Timetable.PupilCenter_Distance,windowSize);
APD = movmean(Timetable.AveragePupilDiameter,windowSize);
mvFF = movvar(Timetable.FixationFlag,windowSize);
%% PREPARE DATASET

Table = table(invPCD, APD, mvFF);
Timetable = table2timetable(Table,'RowTimes',Timetable.Datetime);
Data = Timetable.Variables;

%% SOM 

jSOM = 1;
% get composite focus index
[CFI, ~] = getClassesSOM(Data, iSOM, jSOM);

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
    plot(Timetable.Time, CFI, ...
        'Color', cmap(1,:), ...
        'LineWidth', 2)
    ylim([-1 iSOM+1])
    title('Composite Focus Index', 'FontSize', 18)
    ylabel('Index Value', 'FontSize', 12)
    
    % plot time series of input space
    for i = 1:n-1
        subplot(n,1,i+jSOM)
        plot(Timetable.Time, Data(:,i), ...
            'Color', cmap(i+1,:), ...
            'LineWidth', 2)
        title(Timetable.Properties.VariableNames(i), 'FontSize', 18)
    end
    
    xlabel('Timestamp (UTC)', 'FontSize', 14)

    %% SAVE PLOT
    
    % make ID and pathID
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);

    % create directory to save png of plot
    directory = strcat("visuals/",pathID, "/CFI_som/");
    createDir(directory)

    % create filename of png
    filename = strcat(directory, ID,"_CFI_som_",string(iSOM));

    % save png
    print(filename, '-dpng')
end