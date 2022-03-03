% FUNCTION TO CREATE TIMETABLE OF BLINK DETECTION DATA

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

%% FUNCTION

function [] = TobiiEARRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii)

    % get pathID
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, Tobii);

    % read data
    try
        TobiiEARTimetable = readtimetable(...
            strcat('raw/',pathID, '/',ID,'/segments/1/eyesstream_blink_data.csv'));
    catch
        disp(strcat("Unable to read 'raw/",pathID, '/',ID, ...
            "/segments/1/eyesstream_blink_data.csv'")) 
    end
      

    % load data
    TobiiTimetable = LoadTimetable(YEAR, MONTH, DAY, TRIAL, USER, Tobii);
    %% UPDATE EAR TIMETABLE TIMES

    newTimes = TobiiTimetable.Properties.StartTime + ...
        (TobiiEARTimetable.TimeStamp - TobiiEARTimetable.TimeStamp(1));

    TobiiEARTimetable.TimeStamp = newTimes;

    %% SAVE TIMETABLE

    % create string with Timetable name
    objectName = 'TobiiEARTimetable';

    % get path string for file
    objectPath = getFilePath('objects', ID, objectName);

    % save timetable
    save(objectPath, objectName)
end