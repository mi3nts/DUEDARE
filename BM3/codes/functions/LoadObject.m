% FUNCTION TO LOAD ANY OBJECT IN BM3/OBJECTS FOLDER

% INPUTS
%     YEAR = STRING. EX: '2019'
%     MONTH = STRING. EX: '12'
%     DAY = STRING. EX: '5'
%     TRIAL = STRING. EX: 'T01'
%     USER = STRING. EX: 'U010'
%     DEVICE =  STRING. 
%         SUPPORTED INPUTS: 'EEGXX', 'TobiiXX', 'Synchronized'
%         NOTE: DEVICE MUST COINCIDE WITH THE SENSOR USED TO COLLECT DATA
%         IN DESIRED OBJECT.
%     ObjectName = STRING. NAME THAT CORRESPONDS TO THE DATA INCLUDED IN 
%         OBJCET
%         EXAMPLES: 'EEGAccelTimetable', 'EEGps',
%         'TobiiTimetable'


% OUTPUTS
%     Object = OBJECT CORRESEPONDING TO INPUT STRINGS
%     ID = STRING. ID CORRESPONDING TO Object
%     pathID = STRING. RELATIVE PATH OF Object FILE LOCATION

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [Object, ID, pathID] = LoadObject(YEAR, MONTH, DAY,...
    TRIAL, USER, DEVICE, ObjectName)

    % define ID and pathID
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, DEVICE);

    % load desired object
    load(strcat('objects/', pathID,'/',ID,'_',ObjectName,'.mat'));
    
    eval(strcat('Object =',ObjectName,';'))