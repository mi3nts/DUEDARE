% FUNCTION TO DETECT BLINKS USING EAR VALUES. ROUTINE TAKES EYESTREAM VIDEO
% AND CONVERTS IT INTO A CSV. NOTE: EYESTREAM VIDEO MUST BE SAVED IN RAW
% SUBDIRECTORY FOR INPUT DATASET INFORMATION.

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

%% FUNCTION

function [] = eyesstreamBlinkDetection(YEAR, MONTH, DAY, TRIAL, USER, ...
    DEVICE, pythonPath)

% get ID and pathID
[ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, DEVICE);

% define path to eyestream video
vidFilename = strcat(pwd,"/raw/",pathID,"/", ID,"/segments/1/eyesstream.mp4");
outputFilename = strcat(pwd,"/raw/",pathID,"/", ID, ...
    "/segments/1/eyesstream_blink_data.csv");

% cd to dir with script
cd backend/Blink_Detection

% add current directory to python path if not already added
if count(py.sys.path,'') == 0
    insert(py.sys.path,int32(0),'');
end

% create system command
cmd = strcat(pythonPath, " eye_blink_dataset_generator.py -v ", vidFilename , ...
    " -o ", outputFilename);

% execute system command
system(cmd)

% change to home directory
homeDir()