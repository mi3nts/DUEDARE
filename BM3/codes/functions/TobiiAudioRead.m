% FUNCTION TO READ AUDIO FROM TOBII PRO GLASSES VIDEO

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

% INPUTS
%     YEAR = STRING. ex:'2019';
%     MONTH = STRING. ex:'12';
%     DAY = STRING. ex:'5';
%     TRIAL = STRING. ex:'T01';
%     USER = STRING. ex:'U010';
%     Tobii = STRING. ex:'Tobii01';

function [] = TobiiAudioRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii, ffmpegPath)

% navigate to home directory and add function path if not already done
homeDir

% create ID and pathID for data 
[ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, Tobii);

% change directory to one with video
eval(strcat("cd ", strcat('raw/', pathID, '/', ID,...
    '/segments/1/')))

% convert fullstream video to wav file using ffmpeg library from terminal
% NOTE: matlab was unable to understand .mp4 audio codec that why
% conversion is necessary
cmd = strcat(ffmpegPath, " -i fullstream.mp4 tobiiaudio.wav");
system(cmd)

% read audio file
[y,Fs] = audioread('tobiiaudio.wav');

% get recording start time 
fileText = fileread('segment.json');
decodedText = jsondecode(fileText);
startDate = datetime(decodedText.seg_t_start(1:10), 'InputFormat', 'yyyy-MM-dd');
startTime = duration(strrep(decodedText.seg_t_start(12:end), '+', '.'),...
    'format','hh:mm:ss.SSSS');

% create array with times for signal points
t = (1:length(y))'./Fs;
% convert numeric values to duration
time = seconds(t);
% include date and time
Datetime = startDate + startTime + time;
% create timetable with timestamped audio signal
Timetable = table2timetable(table(Datetime, y));

% create a structure called TobiiAudio to store audio data
TobiiAudio.signal = y;
TobiiAudio.sampleRate = Fs;
TobiiAudio.startTime = startTime;
TobiiAudio.Timetable = Timetable;

% go back to homeDir
homeDir

%% SAVE STRUCTURE TO FILE

% check if proper folder in tables exists, if not create it
if ~exist(strcat('objects/', pathID), 'dir')
    mkdir(strcat('objects/', pathID))
end

% save timetables
save(strcat('objects/', pathID,'/', ID,'_TobiiAudio'),...
    'TobiiAudio');
