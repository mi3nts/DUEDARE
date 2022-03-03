% CODE TO VISUALIZE BIOMETRIC DATA RECORDED WITH TOBII PRO GLASSES AND
% COGNIONICS SYSTEM. THE FOLLOWING VISUALIZATIONS ARE GENERATED WITH THIS
% FUNCTION:

%     1. TOBII PRO GLASSES POV VIDEO
%     2. BAR PLOT OF HR
%     3. HEAT MAP OF POWER OVER TIME OF ALPHA BAND

% INPUTS:

%     YEAR = STRING. YEAR OF DATA COLLECTION. EX: '2019'
%     MONTH = STRING. MONTH OF DATA COLLECTION. EX: '12'
%     DAY = STRING. DAY OF DATA COLLECTION. EX: '5'
%     TRIAL = STRING. TRIAL NUMBER OF DATA. EX: 'T03'
%     USER = STRING. USER ID OF DATA. EX: 'U010'
%     EEG = STRING. EEG ID OF DATA. EX: 'EEG01'
%     Tobii = STRING. Tobii ID OF DATA. EX: 'Tobii01'

% OUTPUTS:
% 
%     NO OUTPUTS BUT AVI FILE IS SAVED TO VISUALS FOLDER IN DIRECTORY 
%     CORRESPONDING TO THE DATA SET ID.


% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = visualizationVideo_EEG_HR(YEAR, MONTH, DAY, TRIAL, USER, ...
    EEG, Tobii)
    %% LOAD DATA

    % add eeglab functions
    addEEGLabFunctions

    % get dataset ID and pathID
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);
    
    disp(strcat("starting ", ID, "..."));

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
    %% GET SAMPLE RATE

    % get sample rate of biometric data
    dataSampleRate = EEGAccelTobiiTimetable.Properties.SampleRate;

    %% SET UP FIGURE

    fig1 = figure;
    fig1.Units = 'inches';
    fig1.Position = [0 0 25 14.0625];
    fig1.Visible = 'off';

    %% DEFINE SUBPLOT RANGES FOR EACH VISUALIZATION

    videoPosition = [1:5 8:12 15:19];
    alphaPosition = [22:26 29:33];
    hrPosition = [6 7 13 14 20 21 34 35];
    %% RUN VISUALIZATION

    % define number of records
    numRecords = max(size(alphaBand));

    % define directory to save video
    directory = strcat('visuals/', pathID,'/videos/');

    % create directory if it does not alreay exist
    createDir(directory)

    % set up writer object to record plot 
    % NOTE: input must be char array!
    writerObj = VideoWriter(char(...
        strcat(directory, ID,'_video_EEGps_HR.avi')));

    % set frame rate of Tobii POV video
    writerObj.FrameRate = v.FrameRate;

    open(writerObj);

    for i = 1:round(dataSampleRate/v.FrameRate):numRecords

        % update video
        subplot(5, 7, videoPosition)
        videoAxes = gca;
        vidFrame = readFrame(v);
        im = image(vidFrame, 'Parent', videoAxes);
        videoAxes.Visible = 'off';

        % update HR plot
        subplot(5, 7, hrPosition)
        visualizeHR(EEGAccelTobiiTimetable, i, []);

        % update EEG PS
        subplot(5, 7, alphaPosition)
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
    
    disp(strcat("finished ", ID, "."));