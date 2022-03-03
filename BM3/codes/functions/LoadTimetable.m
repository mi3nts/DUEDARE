% FUNCTION TO LOAD A TIMETABLE

% INPUTS
%     YEAR = STRING. EX: '2019'
%     MONTH = STRING. EX: '12'
%     DAY = STRING. EX: '5'
%     TRIAL = STRING. EX: 'T01'
%     USER = STRING. EX: 'U010'
%     DEVICE =  STRING. 
%         SUPPORTED INPUTS: 'EEGXX', 'TobiiXX', 'Synchronized'

% OUTPUTS
%     Timetable = TIMETABLE DATA STRUCTURE. TIMETABLE CORRESEPONDING TO
%     INPUT STRINGS
%     ID = STRING. ID OF TIMETABLE DATA STRUCTURE
%     pathID = STRING. RELATIVE PATH OF TIMETABLE DATA STRUCTURE
%     TTname = STRING. NAME OF TIMETABLE TO SPECIFIES THE KIND OF DATA IN 
%       TIMETABLE.

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [Timetable, ID, pathID, TTname] = LoadTimetable(YEAR, MONTH, DAY,...
    TRIAL, USER, DEVICE)

% define ID and pathID
[ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, DEVICE);

% adjust ID and pathID based on DEVICE
if strcmp(DEVICE, 'Synchronized')
    
    TTname = 'EEGAccelTobiiTimetable';
    ID = strcat(ID, '_', TTname);
%     pathID = insertBefore(pathID,'Synchronized','_');
    
elseif strcmp(DEVICE(1:3), 'EEG')

    TTname = 'EEGAccelTimetable';
    ID = strcat(ID, '_', TTname);
    
elseif strcmp(DEVICE(1:3), 'EQV')

    TTname = 'EQVTimetable';
    ID = strcat(ID, '_', TTname);
    
elseif strcmp(DEVICE(1:5), 'Tobii')
    
    TTname = 'TobiiTimetable';
    ID = strcat(ID, '_', TTname);
end

% load desired timetable
load(strcat('objects/', pathID,'/',ID,'.mat'));

% relabel timetable as output
eval(strcat("Timetable = ", TTname, ';'));
