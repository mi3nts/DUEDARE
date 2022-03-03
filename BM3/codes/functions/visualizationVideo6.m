% FUNCTION TO VISUALIZE BIOMETRIC DATA RECORDED WITH TOBII PRO GLASSES AND
% COGNIONICS SYSTEM. THE FOLLOWING VISUALIZATIONS ARE GENERATED WITH THIS
% FUNCTION:

%     1. TOBII PRO GLASSES POV VIDEO WITH TIMESTAMP AND GAZE POSITIONS
%     2. BAR PLOT OF HR
%     3. BAR PLOT OF GSR
%     4. BAR PLOT OF DISTANCE BETWEEN PUPIL CENTERS MINUS AVERAGE DISTANCE
%     IN MILLIMETERS

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

function [] = visualizationVideo6(YEAR, MONTH, DAY, TRIAL, USER, EEG, Tobii)

%%
tic

% add eeglab functions
addEEGLabFunctions

% get dataset ID and pathID
[ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);

disp(strcat("Starting visualization for ", ID, " ..."));

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

% load channel locations
load(strcat('backend/channelLocations/', EEG, '_chanlocs.mat'));
%% SETUP TOBII PRO GLASSES VIDEO 

% define path to tobii pov video
inputPath = strcat('raw/',pathID, '/', Tobii, '/', ...
        ID, '_', Tobii, '/segments/1/');

% if running on Linux system use .avi format
if strcmp(computer, 'GLNXA64')
    
    % check if .avi video exists
    if ~exist(strcat(inputPath,'fullstream.avi'), 'file')
    
        % if it does not, convert mp4 to avi
        TobiiMp4ToAvi(inputPath, 'fullstream');
        
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

%% INTERPOLATE TOBII GAZE VALUES

EEGAccelTobiiTimetable = interpolTobiiNaNs(EEGAccelTobiiTimetable);

%% GET SAMPLE RATE

% get sample rate of biometric data
dataSampleRate = EEGAccelTobiiTimetable.Properties.SampleRate;

%% SET UP FIGURE

fig1 = figure;
fig1.Units = 'inches';
fig1.Position = [0 0 25 14.0625];
fig1.Visible = 'off';

% define colormap
colormap jet;
cmap = colormap('jet');
%% DEFINE SUBPLOT RANGES FOR EACH VISUALIZATION

videoPosition = [1:2 4:5];
hrPosition = 3:3:9;
gsrPosition = 7;
vergencePosition = 8;
%% RUN VISUALIZATION

% define number of records
numRecords = height(EEGAccelTobiiTimetable);

% define directory to save video
directory = strcat('visuals/', pathID,'/videos/');

% create directory if it does not alreay exist
createDir(directory)

% set up writer object to record plot 
% NOTE: input must be char array!
writerObj = VideoWriter(char(...
    strcat(directory, ID,'_videoWithGazeTimestamp_HR_GSR_vergence.avi')));

% set frame rate of Tobii POV video
writerObj.FrameRate = v.FrameRate;

open(writerObj);

for i = 1:round(dataSampleRate/v.FrameRate):numRecords
    
    % update video with Gaze
    %  ------------------------------------------------------------------
    subplot(3, 3, videoPosition)
    videoAxes = gca;
    
    % try to read frame from video reader object
    try
        % read frame
        vidFrame = readFrame(v);
    catch
        % if frame can't be read break out of loop
        break
    end
    im = image(vidFrame, 'Parent', videoAxes);
    videoAxes.Visible = 'off';

    % turn hold on
    hold on

    % plot fixation
    scatter(v.Width*EEGAccelTobiiTimetable.GazePositionX(i), ...
        v.Height*EEGAccelTobiiTimetable.GazePositionY(i),...
        500, 'r', 'LineWidth', 3)

      ax = gca;
      ax.XLim = [0 v.Width];
      ax.YLim = [0 v.Height];

    % plot past 10 records
    if i > 10
        interval = i-10:i;
        plot(v.Width*EEGAccelTobiiTimetable.GazePositionX(interval), ...
        v.Height*EEGAccelTobiiTimetable.GazePositionY(interval), ...
        'g--', 'LineWidth', 3);
    end

    hold off

    % plot timestamp
    text(2,30, string(EEGAccelTobiiTimetable.Datetime(i)), ...
        'FontSize', 21, 'Color', 'white')
    %  ------------------------------------------------------------------

    %  ------------------------------------------------------------------
    % update HR plot
    subplot(3, 3, hrPosition)
    visualizeHR(EEGAccelTobiiTimetable, i, []);
    %  ------------------------------------------------------------------
    % update GSR plot
    subplot(3, 3, gsrPosition)
    visualizeBar(double(EEGAccelTobiiTimetable.GSR_uS), i, cmap, 'GSR (\muS)');
    %  ------------------------------------------------------------------
    % update vergence plot
    subplot(3, 3, vergencePosition)
    visualizePCD(EEGAccelTobiiTimetable, i, cmap);
    %  ------------------------------------------------------------------

    
    % get frame and add to video object (uncomment this for recording)
    frame = getframe(fig1);
    writeVideo(writerObj,frame);
    
end

% close video
close(writerObj)
disp(strcat("Finished visualization for ", ID, " in ", string(toc), " seconds."));