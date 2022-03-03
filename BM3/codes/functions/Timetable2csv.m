% FUNCTION TO CONVERT TIMETABLE TO .CSV FILE. FUNCTION WILL SAVE .CSV IN
% THE SAME DIRECTORY AS THE RESPECTIVE TIMETABLE.

% INPUTS
%     YEAR = STRING. EX: '2019'
%     MONTH = STRING. EX: '12'
%     DAY = STRING. EX: '5'
%     TRIAL = STRING. EX: 'T01'
%     USER = STRING. EX: 'U010'
%     DEVICE =  STRING. 
%         SUPPORTED INPUTS: 'EEGXX', 'TobiiXX', 'Synchronized'

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = Timetable2csv(YEAR, MONTH, DAY, TRIAL, USER, DEVICE)

[Timetable, ID, pathID, TT] = LoadTimetable(YEAR, MONTH, DAY,...
    TRIAL, USER, DEVICE);

eval(strcat(TT, " = Timetable;"));

writetable(timetable2table(Timetable),...
    strcat('objects/', pathID,'/',ID,'.csv'))