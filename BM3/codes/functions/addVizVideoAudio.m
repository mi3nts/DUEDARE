% FUNCTION TO ADD AUDIO TO VISUALIZATION VIDEO
% NOTE: TESTED ON ffmpeg version 4.0

% INPUTS:
%   YEAR = STRING. YEAR OF DATA COLLECTION. EX: '2019'
%   MONTH = STRING. MONTH OF DATA COLLECTION. EX: '12'
%   DAY = STRING. DAY OF DATA COLLECTION. EX: '5'
%   TRIAL = STRING. TRIAL NUMBER OF DATA. EX: 'T03'
%   USER = STRING. USER ID OF DATA. EX: 'U010'
%   Tobii = STRING. Tobii ID OF DATA. EX: 'Tobii01'
%   videoID = STRING. Identifier appended to end of video file name 
%   e.g. 'videoWithTimestamp'
%   ffmpegPath = STRING. System path of desired ffmpeg installation to
%   use. To use system default navigate to terminal and type "which ffmpeg"

% OUTPUTS:
%     NO OUTPUTS BUT MP4 FILE IS SAVED TO VISUALS FOLDER IN DIRECTORY 
%     CORRESPONDING TO THE DATASET ID.

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)


function [] = addVizVideoAudio(YEAR, MONTH, DAY, TRIAL, USER, Tobii, ...
    videoID, ffmpegPath)

    %% READ AUDIO

    % read audio
    TobiiAudioRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii, ffmpegPath)

    % define ID and pathID with Tobii
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, Tobii);
    audioPath = strcat(pwd,'/raw/', pathID, '/', ID,'/segments/1/');
    %% CHECK IF MP4 VERSION OF VIDEO EXISTS

    % define ID and pathID without Tobii
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);

    % change directory to one with video
    eval(strcat("cd ", strcat('visuals/', pathID, '/videos/')))

    % define filename for mp4 and avi formats
    fileRoot = strcat( ID,'_', videoID);
    filenameMP4 = strcat(fileRoot, '.mp4');
    filenameAVI = strcat(fileRoot, '.avi');

    % check if visualization exists in mp4 format
    if ~isfile(filenameMP4) && ~isfile(filenameAVI)

        disp("---- Visualization does not exist ----")

        
    % if file is not mp4 convert it
    elseif ~isfile(filenameMP4)

        disp("Converting file from AVI to MP4...")

        % create command
        cmd = strcat("!",ffmpegPath," -i ", filenameAVI, ...
            " -acodec libmp3lame -ab 192 ",filenameMP4);

        % evaluate command
        eval(cmd)    
    end
    
    %% ADD AUDIO

    % create command
    cmd = strcat("!",ffmpegPath," -i ",filenameMP4, ...
        " -i ", audioPath, ...
        "tobiiaudio.wav -c:v copy -map 0:v:0 -map 1:a:0 -c:a aac -b:a 192k ", ...
        fileRoot,"_audio.mp4");

    % evaluate command
    eval(cmd)