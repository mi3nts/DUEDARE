% CODE TO VISUALIZE BIOMETRIC DATA RECORDED WITH TOBII PRO GLASSES AND
% COGNIONICS SYSTEM. THE FOLLOWING VISUALIZATIONS ARE GENERATED WITH THIS
% FUNCTION:

%     1. TOBII PRO GLASSES POV VIDEO
%     5. BAR PLOT OF HR
%     8. SOM CLASSES PLOTTED OVER TIME
%     8. COMPOSITE PHYSICAL LOAD INDEX PLOTTED OVER TIME
%     8. COMPOSITE FOCUS INDEX PLOTTED OVER TIME

% INPUTS:

%     YEAR = STRING. YEAR OF DATA COLLECTION. EX: '2019'
%     MONTH = STRING. MONTH OF DATA COLLECTION. EX: '12'
%     DAY = STRING. DAY OF DATA COLLECTION. EX: '5'
%     TRIAL = STRING. TRIAL NUMBER OF DATA. EX: 'T03'
%     USER = STRING. USER ID OF DATA. EX: 'U010'
%     EEG = STRING. EEG ID OF DATA. EX: 'EEG01'
%     Tobii = STRING. Tobii ID OF DATA. EX: 'Tobii01'
%     iSOM = INTEGER. NUMBER OF ROWS IN SOM GEOMETRY
%     jSOM = INTEGER. NUMBER OF COLUMNS IN SOM GEOMETRY
%     iSOM_cli = INTEGER. GRANULARITY OF CLI
%     iSOM_cfi = INTEGER. GRANULARITY OF CFI

% OUTPUTS:
% 
%     NO OUTPUTS BUT AVI FILE IS SAVED TO VISUALS FOLDER IN DIRECTORY 
%     CORRESPONDING TO THE DATA SET ID.


% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = visualizationVideo_compositeIndicies(YEAR, MONTH, DAY, TRIAL, USER, ...
    Tobii, iSOM, jSOM, iSOM_cli, iSOM_cfi)

    %% LOAD DATA

    % get dataset ID and pathID
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);

    % load synchronized EEGAccelTobiiTimetable
    load(strcat('objects/',pathID, '/_Synchronized/', ID, ...
        '_Synchronized_EEGAccelTobiiTimetable.mat'));
    
    % if synchronized timetable is empty exit function
    if height(EEGAccelTobiiTimetable) == 0
        disp('CGX and Tobii Timetables not aligned')
        return
    end
    
    % load Tobii Timetable
    load(strcat('objects/',pathID, '/', Tobii, '/', ...
        ID, '_', Tobii,'_TobiiTimetable.mat'));

    %% SETUP TOBII PRO GLASSES VIDEO 

    % define path to tobii pov video
    inputPath = strcat('raw/',pathID, '/', Tobii, '/', ...
            ID, '_', Tobii, '/segments/1/');

    % if running on Linux system use .avi format
    if strcmp(computer, 'GLNXA64')

        % check if .avi video exists
        if ~exist(strcat(inputPath,'fullstream.avi'), 'file')

            % if it does not, convert mp4 to avi
            TobiiMp4ToAvi(inputPath, "fullstream");

        end

        % read video
        v = VideoReader(strcat(inputPath,'fullstream.avi'));

    % if running on MAC or Windows system use .mp4 format
    else
        % read video
        v = VideoReader(strcat('raw/',pathID, '/', Tobii, '/', ...
            ID, '_', Tobii, '/segments/1/fullstream.mp4'));
    end


    % get start time of entire dataset
    tobiiStartTime = seconds(EEGAccelTobiiTimetable.Properties.StartTime - ...
        TobiiTimetable.Properties.StartTime);
    v.CurrentTime = tobiiStartTime;

    % clear unnecessary variables from workspace
    clear TobiiTimetable
    
    %% INTERPOLATE PUPIL METRICS

    % perform interpolation over NaN values for tobii variables
    EEGAccelTobiiTimetable = interpolTobiiNaNs(EEGAccelTobiiTimetable);
    %% GET SOM CLASSES

    % create variable to check whether SOM Classes are provided in Table
    hasSOMClasses = ...
        sum(strcmp(EEGAccelTobiiTimetable.Properties.VariableNames, 'Class'));

    if ~hasSOMClasses
        % create timetable with SOM classes at each timestep
        SOMTimetable = performSOM(EEGAccelTobiiTimetable, iSOM, jSOM); 
        EEGAccelTobiiTimetable.Class = SOMTimetable.Class;
    end

    % get sample rate of biometric data
    dataSampleRate = EEGAccelTobiiTimetable.Properties.SampleRate;

    % get SOM class variability
    [~,~,somMovingRepresentativeness] = ...
        timeseries_moving_average(EEGAccelTobiiTimetable.Datetime, ...
        EEGAccelTobiiTimetable.Class, ...
        seconds(1), 0);

    clear SOMTimetable
    
    %% COMPUTE COMPOSITE INDICIES

    
    CLI = getCLI(YEAR, MONTH, DAY, TRIAL, USER, iSOM_cli, true);
    CFI = getCFI(YEAR, MONTH, DAY, TRIAL, USER, iSOM_cfi, true);
    %% SET UP FIGURE

    fig1 = figure;
    fig1.Units = 'inches';
    fig1.Position = [0 0 25 14.0625];
    fig1.Visible = 'off';

    %% DEFINE SUBPLOT RANGES FOR EACH VISUALIZATION

    % for 6 by 5
    videoPos = [1:3 6:8 11:13];
    hrPos = 5:5:30;
    somPos = 16:19;
    cliPos = 21:24;
    cfiPos = 26:29;

    %% PLOT SOM CLASSES AND COMPOSITE INDICIES

    % define maximum class value
    y = max(EEGAccelTobiiTimetable.Class) + round(0.1*max(EEGAccelTobiiTimetable.Class));

    % plot class time series
    subplot(6, 5, somPos)
    plot(EEGAccelTobiiTimetable.Datetime, EEGAccelTobiiTimetable.Class)
    title('SOM Classes', 'FontSize', 20)
    hold on
    % initilize time mark time
    plot(EEGAccelTobiiTimetable.Datetime([1 1]),[0 y])
    
    % plot cli time series
    subplot(6, 5, cliPos)
    plot(EEGAccelTobiiTimetable.Datetime, CLI)
    title('Composite Load Index', 'FontSize', 20)
    hold on
    % initilize time mark time
    plot(EEGAccelTobiiTimetable.Datetime([1 1]),[0 iSOM_cli+1])
    
    % plot cfi time series
    subplot(6, 5, cfiPos)
    plot(EEGAccelTobiiTimetable.Datetime, CFI)
    title('Composite Focus Index', 'FontSize', 20)
    hold on
    % initilize time mark time
    plot(EEGAccelTobiiTimetable.Datetime([1 1]),[0 iSOM_cli+1])

    %% RUN VISUALIZATION

    % define number of records
    numRecords = height(EEGAccelTobiiTimetable);

    % define colormap for HR plot
    cmap = colormap(hot);

    % define directory to save video
    directory = strcat('visuals/', pathID,'/videos/');

    % create directory if it does not alreay exist
    createDir(directory)

    % set up writer object to record plot 
    % NOTE: input must be char array!
    writerObj = VideoWriter(char(...
        strcat(directory, ID,'_video_SOM', ...
        string(iSOM), 'by', string(jSOM), ...
        '_CLI_', string(iSOM_cli), ...
        '_CFI_', string(iSOM_cfi), ...
        '.avi')));

    % set frame rate of Tobii POV video
    writerObj.FrameRate = v.FrameRate;

    open(writerObj);

    for i = 1:round(dataSampleRate/v.FrameRate):numRecords

        % update video
        subplot(6, 5, videoPos)
        videoAxes = gca;
        try
            vidFrame = readFrame(v);
        catch
        end
        im = image(vidFrame, 'Parent', videoAxes);
        videoAxes.Visible = 'off';

        % update SOM time series
        subplot(6, 5, somPos)
        % get current axis
        ax = gca;    
        % delete old time mark line
        delete(ax.Children(1))
        % plot new time mark line
        plot(EEGAccelTobiiTimetable.Datetime([i i]),[0 y], ...
            'r--', 'LineWidth', 1);
        
        % update cli time series
        subplot(6, 5, cliPos)
        % get current axis
        ax = gca;    
        % delete old time mark line
        delete(ax.Children(1))
        % plot new time mark line
        plot(EEGAccelTobiiTimetable.Datetime([i i]),[0 iSOM_cli+1], ...
            'r--', 'LineWidth', 1);
        
        % update cfi time series
        subplot(6, 5, cfiPos)
        % get current axis
        ax = gca;    
        % delete old time mark line
        delete(ax.Children(1))
        % plot new time mark line
        plot(EEGAccelTobiiTimetable.Datetime([i i]),[0 iSOM_cfi+1], ...
            'r--', 'LineWidth', 1);

        % update HR plot
        subplot(6, 5, hrPos)
        visualizeHR(EEGAccelTobiiTimetable, i, []);

        % get frame and add to video object (uncomment this for recording)
        frame = getframe(fig1);
        writeVideo(writerObj,frame);
        
%         pause

    end

    % close video
    close(writerObj)
