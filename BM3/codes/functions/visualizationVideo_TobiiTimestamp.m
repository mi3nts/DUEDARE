% FUNCTION TO GENERATE TOBII PRO GLASSES 2 POV VIDEO WITH TIMESTAMP

% INPUTS:

%     YEAR = STRING. YEAR OF DATA COLLECTION. EX: '2019'
%     MONTH = STRING. MONTH OF DATA COLLECTION. EX: '12'
%     DAY = STRING. DAY OF DATA COLLECTION. EX: '5'
%     TRIAL = STRING. TRIAL NUMBER OF DATA. EX: 'T03'
%     USER = STRING. USER ID OF DATA. EX: 'U010'
%     Tobii = STRING. Tobii ID OF DATA. EX: 'Tobii01'


% OUTPUTS:
% 
%     NO OUTPUTS BUT AVI FILE IS SAVED TO VISUALS FOLDER IN DIRECTORY 
%     CORRESPONDING TO THE DATA SET ID.


% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = visualizationVideo_TobiiTimestamp(YEAR, MONTH, DAY, TRIAL, ...
    USER, Tobii)
    tic
    %% GET DATA
    
    % get dataset ID and pathID
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, Tobii);

    disp(strcat("Starting visualization for ", ID, " ..."));

    % load TobiiTimetable
    TobiiTimetable = LoadTimetable(YEAR, MONTH, DAY, TRIAL, USER, Tobii);
    %% SETUP TOBII PRO GLASSES VIDEO 

    % define path to tobii pov video
    inputPath = strcat('raw/',pathID, '/', ...
            ID, '/segments/1/');

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
        v = VideoReader(strcat('raw/',pathID, '/', ...
            ID, '/segments/1/fullstream.mp4'));
    end

    %% GET TIMES

    times = TobiiTimetable.Datetime;
    dataSampleRate = TobiiTimetable.Properties.SampleRate;

    clear TobiiTimetable

    %% SET UP FIGURE

    fig1 = figure;
    fig1.Units = 'normalized';
    fig1.Position = [0 0 1 1];
    fig1.Visible = 'off';

    %% RUN VISUALIZATION

    % % define number of records
    % numRecords = height(EEGAccelTobiiTimetable);

    % define directory to save video
    ID = strrep(ID, strcat('_',Tobii), '');
    pathID = strrep(pathID, Tobii, '');
    directory = strcat('visuals/', pathID,'videos/');

    % create directory if it does not alreay exist
    createDir(directory)

    % set up writer object to record plot 
    % NOTE: input must be char array!
    writerObj = VideoWriter(char(...
        strcat(directory, ID,'_TobiiTimestamp')));

    % set frame rate of Tobii POV video
    writerObj.FrameRate = v.FrameRate;

    open(writerObj);

    for i = 1:round(dataSampleRate/v.FrameRate):length(times)

        % update video with Gaze
        %  ------------------------------------------------------------------
        videoAxes = gca;

        % try to read frame
        try
            vidFrame = readFrame(v);
        % if out of frames to read exit loop
        catch
            break
        end
        im = image(vidFrame, 'Parent', videoAxes);
        videoAxes.Visible = 'off';

        % plot timestamp
        text(10,30, string(times(i)), ...
            'FontSize', 21, 'Color', 'white')

        drawnow

        % get frame and add to video object (uncomment this for recording)
        frame = getframe(fig1);
        writeVideo(writerObj,frame);

    end

    % close video
    close(writerObj)
    disp(strcat("Finished visualization for ", ID, " in ", string(toc), " seconds."));
