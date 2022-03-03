% FUNCTION TO SYNCHRONIZE EEG AND TOBII TIMETABLES USING MARKER DATA. 
% FUNCTION CREATES AND SAVES SYNCHRONIZED TIMETABLE TO APPROPRIATE
% DIRECTORY.

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
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = EEGTobiiMarkerSync(YEAR, MONTH, DAY, TRIAL, USER, EEG, Tobii)

    % get ID and pathID
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);

    % load timetables
    load(strcat("raw/", pathID,'/',Tobii,'/', ID,'_',Tobii,...
        '_rawTobiiTimetable.mat'));
    EEGAccelTimetable = LoadTimetable(YEAR, MONTH, DAY, TRIAL, USER, EEG);
    %% ALIGN TIMES

    % get array of marker data for each system
    tobiiSig = rawTobiiTimetable.Signal;
    cgxSig = EEGAccelTimetable.TRIGGER-2;

    % find where cgx signal is 1
    iwant1cgx = find(cgxSig==1);
    first1Cgx = iwant1cgx(1);

    % find where tobii signal is 1
    iwant1tobii = find(tobiiSig==1);
    first1Tobii = iwant1tobii(1);

    % get initial sync times
    cgxStart = EEGAccelTimetable.Datetime(first1Cgx);
    tobiiStart = rawTobiiTimetable.Datetime(first1Tobii);

    % compute offset
    offset = cgxStart - tobiiStart;

    % add offset to tobii timetable
    rawTobiiTimetable.Datetime = rawTobiiTimetable.Datetime + offset;

    %% CLEAN UP TOBII TIMETABLE

    % Remove values with errors
    TobiiTimetable = TobiiRemoveErrors(rawTobiiTimetable);

    % Compute and append additional pupil and gaze variables
    TobiiTimetable = getAllTobiiVars(TobiiTimetable);

    %% SYNCHRONIZE TIMETABLES

    % get timerange of TobiiTimetable
    S = timerange(TobiiTimetable.Datetime(1),TobiiTimetable.Datetime(end));

    % retime timetables to have regular time intervals
    EEGAccelTimetable = retime(EEGAccelTimetable,...
        'regular','linear','TimeStep', milliseconds(2));
    TobiiTimetable = retime(TobiiTimetable,...
        'regular','nearest','TimeStep', milliseconds(10));

    % synchronize timetables
    EEGAccelTobiiTimetable = synchronize(EEGAccelTimetable,TobiiTimetable);

    % only keep common timerange
    EEGAccelTobiiTimetable = EEGAccelTobiiTimetable(S,:);
    
    % set sample rate
    EEGAccelTobiiTimetable.Properties.SampleRate = ...
        EEGAccelTimetable.Properties.SampleRate;
    whos
    %% SAVE SYNCHRONIZED TIMETABLE
    
    % check if proper folder for storing timetables exists, if not create it
    if ~exist(strcat('objects/', pathID, '/_Synchronized/'), 'dir')
        mkdir(strcat('objects/', pathID, '/_Synchronized/'))
    end
    
    % save timetables
    save(strcat('objects/', pathID, '/_Synchronized/', ID,...
        '_Synchronized_EEGAccelTobiiTimetable'), 'EEGAccelTobiiTimetable');
    
end
