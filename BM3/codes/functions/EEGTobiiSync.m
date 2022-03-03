% FUNCTION TO SYNCHRONIZE EEG AND TOBII TIMETABLES. FUNCTION CREATES AND
% SAVES SYNCHRONIZED TIMETABLE TO APPROPRIATE DIRECTORY

% INPUTS
%     YEAR = STRING. EX: '2019'
%     MONTH = STRING. EX: '12'
%     DAY = STRING. EX: '5'
%     TRIAL = STRING. EX: 'T01'
%     USER = STRING. EX: 'U010'
%     EEG =  STRING. EX: 'EEG01'
%     Tobii = STRING. EX: 'Tobii01'

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = EEGTobiiSync(YEAR, MONTH, DAY, TRIAL, USER, EEG, Tobii)

    % get ID and pathID
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);

    % load timetables
    EEGAccelTimetable = LoadTimetable(YEAR, MONTH, DAY, TRIAL, USER, EEG);
    TobiiTimetable = LoadTimetable(YEAR, MONTH, DAY, TRIAL, USER, Tobii);
    %% TIME OFFSET FROM CROSS CORRELATION

    try
        % compute time offset
        offset = computeTimeOffset(TobiiTimetable, EEGAccelTimetable);
        
        % add offset to tobii timetable 
        TobiiTimetable.Datetime = TobiiTimetable.Datetime + offset;
    catch
        disp("warning: Could not compute time offset")
    end
        
    %% RESAMPLE TIMETABLES

    % define timestep of 0.5 millisecond
    dt = milliseconds(0.5);  

    % reconfigure timesteps to have 0.5 ms intervals
    EEGAccelTimetable = retime(EEGAccelTimetable, ...
        'regular', ...
        'fillwithmissing', ...
        'TimeStep', dt);

    TobiiTimetable = retime(TobiiTimetable, ...
        'regular', ...
        'fillwithmissing', ...
        'TimeStep', dt);
    %% SYNCHRONIZE TIMETABLES

    % synchronize timetables by there intersection 
    EEGAccelTobiiTimetable = synchronize(EEGAccelTimetable, TobiiTimetable, ...
        'intersection');

    try 
        % change timesteps in synchronized timetable to 2 milliseconds
        EEGAccelTobiiTimetable = retime(EEGAccelTobiiTimetable, 'regular',  ...
            'mean', 'TimeStep', 4*dt);
    catch
        disp('----Timetables do not overlap----')
    end

    %% SAVE SYNCHRONIZED TIMETABLE
    
    % check if proper folder for storing timetables exists, if not create it
    if ~exist(strcat('objects/', pathID, '/_Synchronized/'), 'dir')
        mkdir(strcat('objects/', pathID, '/_Synchronized/'))
    end
    
    % save timetables
    save(strcat('objects/', pathID, '/_Synchronized/', ID,...
        '_Synchronized_EEGAccelTobiiTimetable'), 'EEGAccelTobiiTimetable');
    
end