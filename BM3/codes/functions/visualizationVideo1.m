% CODE TO VISUALIZE BIOMETRIC DATA RECORDED WITH TOBII PRO GLASSES AND
% COGNIONICS SYSTEM. THE FOLLOWING VISUALIZATIONS ARE GENERATED WITH THIS
% FUNCTION:

%     1. TOBII PRO GLASSES POV VIDEO
%     2. BAR PLOT OF REPRESENTATIVENESS OF THE DISTANCE BETWEEN PUPILS 
%     (VERGENCE VARIATION)
%     3. BAR PLOT OF DISTANCE BETWEEN PUPIL CENTERS
%     4. BAR PLOT OF DIFFERENCE PUPIL DIAMETER SIZE
%     5. BAR PLOT OF HR
%     6. HEAT MAP OF POWER OVER TIME OF ALPHA BAND
%     7. MOVING PUPIL VISUALIZATION
%     8. SOM CLASSES PLOTTED OVER TIME
%     9. VARIATION IN SOM CLASS

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

% OUTPUTS:
% 
%     NO OUTPUTS BUT AVI FILE IS SAVED TO VISUALS FOLDER IN DIRECTORY 
%     CORRESPONDING TO THE DATA SET ID.


% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = visualizationVideo1(YEAR, MONTH, DAY, TRIAL, USER, ...
    EEG, Tobii, iSOM, jSOM)

    %% LOAD DATA

    % add eeglab functions
    addEEGLabFunctions

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
    % load EEG power spectra data
    load(strcat('objects/',pathID, '/', EEG, '/', ...
        ID, '_', EEG,'_EEGps.mat'));

    % load channel locations
    load(strcat('backend/channelLocations/', EEG, '_chanlocs.mat'));
    %% GET ALPHA BAND POWER

    alphaBand = getAlphaBand(EEGps);

    % clear unnecessary variables from workspace
    clear EEGps
    %% SETUP TOBII PRO GLASSES VIDEO 

    % define path to tobii pov video
    inputPath = strcat('raw/',pathID, '/', Tobii, '/', ...
            ID, '_', Tobii, '/segments/1/');

    % if running on Linux system use .avi format
    if strcmp(computer, 'GLNXA64')

        % check if .avi video exists
        if ~exist(strcat(inputPath,'fullstream.avi'), 'file')

            % if it does not, convert mp4 to avi
            TobiiMp4ToAvi(inputPath);

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
    %% INTERPOLATE PUPIL METRICS

    % perform interpolation over NaN values for tobii variables
    EEGAccelTobiiTimetable = interpolTobiiNaNs(EEGAccelTobiiTimetable);

    %% SET UP FIGURE

    fig1 = figure;
    fig1.Units = 'inches';
    fig1.Position = [0 0 25 14.0625];
    fig1.Visible = 'off';

    %% DEFINE SUBPLOT RANGES FOR EACH VISUALIZATION

    % for 6 by 7
    videoPos = [1 2 3 8 9 10];
    pdPos = [18:20 25:27];
    pddPos = [6 13];
    pcdPos = [5 12];
    pcd_sdPos = [4 11];
    alphaPos = [15:17 22:24];
    hrPos = [7 14 21 28];
    somPos = [29:34 36:41];
    somVarPos = [35 42];

    %% PLOT SOM CLASSES OVER TIME

    % define maximum class value
    y = max(EEGAccelTobiiTimetable.Class) + round(0.1*max(EEGAccelTobiiTimetable.Class));

    % plot class time series
    subplot(6, 7, somPos)
    plot(EEGAccelTobiiTimetable.Datetime, EEGAccelTobiiTimetable.Class)
    title('SOM Classes Over Time', 'FontSize', 20)
    hold on
    % initilize time mark time
    plot(EEGAccelTobiiTimetable.Datetime([1 1]),[0 y])

    %% RUN VISUALIZATION

    % define number of records
    numRecords = max(size(alphaBand));

    % define colormap for HR plot
    cmap = colormap(hot);

    % define directory to save video
    directory = strcat('visuals/', pathID,'/videos/');

    % create directory if it does not alreay exist
    createDir(directory)

    % set up writer object to record plot 
    % NOTE: input must be char array!
    writerObj = VideoWriter(char(...
        strcat(directory, ID,'_video_vergence_movingPD_EEGps_HR_SOM', ...
        string(iSOM), 'by', string(jSOM),'.avi')));

    % set frame rate of Tobii POV video
    writerObj.FrameRate = v.FrameRate;

    open(writerObj);

    for i = 1:round(dataSampleRate/v.FrameRate):numRecords

        % update video
        subplot(6, 7, videoPos)
        videoAxes = gca;
        vidFrame = readFrame(v);
        im = image(vidFrame, 'Parent', videoAxes);
        videoAxes.Visible = 'off';

        % update SOM time series
        subplot(6, 7, somPos)
        % get current axis
        ax = gca;    
        % delete old time mark line
        delete(ax.Children(1))
        % plot new time mark line
        plot(EEGAccelTobiiTimetable.Datetime([i i]),[0 y], ...
            'r--', 'LineWidth', 1);

        % update SOM variability plot
        subplot(6,7,somVarPos)
        visualizeBar(somMovingRepresentativeness, i, colormap(jet), ...
            'SOM Class Variability');

        % update HR plot
        subplot(6, 7, hrPos)
        visualizeHR(EEGAccelTobiiTimetable, i, []);

        % update PD visualization
        subplot(6, 7, pdPos)
        visualizePD(EEGAccelTobiiTimetable, i);

        % update PDD visualization
        subplot(6, 7, pddPos)
        visualizePDD(EEGAccelTobiiTimetable, i, colormap(jet));

        % update PCD visualization
        subplot(6, 7, pcdPos)
        visualizePCD(EEGAccelTobiiTimetable, i, colormap(jet));

         % update PCD_SD visualization
        subplot(6, 7, pcd_sdPos)
        visualizePCD_SD(EEGAccelTobiiTimetable, i, colormap(jet));

        % update EEG PS
        subplot(6, 7, alphaPos)
        % clear old topoplot
        cla('reset')
        if ~isnan(alphaBand(i,1))
            % plot new topoplot
            topoplot(alphaBand(i,:), EEG01_chanlocs, 'conv', 'on');
            % update all plots now
            drawnow
        else
            % update all plots now
            drawnow
        end

        % get frame and add to video object (uncomment this for recording)
        frame = getframe(fig1);
        writeVideo(writerObj,frame);

    end

    % close video
    close(writerObj)
