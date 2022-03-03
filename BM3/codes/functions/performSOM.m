% FUNCTION TO PERFROM SELF-ORGANIZING MAP ON DATA IN INPUT TIMETABLE FOR
% STANDARD TIMETABLES IN BM3. NOTE: THIS DIFFERS FROM THE getClassesSOM
% FUNCTION IN 3 WAYS: 
% 1. DATA IS INPUT AS A TIMETABLE AS OPPOSED TO AN ARRAY 
% 2. META VARAIBLES ARE AUTOMATICALLY REMOVED 
% 3. CLASSES ARE RETURNED IN A 1 VARIABLE TIMETABLE
 
% INPUTS:
%     Timetable - INPUT DATA WITH VARIABLES AS COLUMNS AND TIMESTEPS AS ROWS
%     i - NUMBER OF ROWS IN SOM
%     j - NUMBER OF COLUMNS IN SOM
% 
% OUTPUTS:
% SOMTimetable = TIMETABLE WITH CLASS VALUE AT EACH TIMESTEP


% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function SOMTimetable = performSOM(Timetable, iSOM, jSOM)

    % remove meta variables from timetable
    Timetable = rmMetaVars(Timetable);
    % convert timetable to table
    Table = timetable2table(Timetable);
    % convert table to timetable
    Data = table2array(Table(:,2:end));
    % get SOM classes
    classes = getClassesSOM(real(Data), iSOM, jSOM);
    % create timetable of SOM classes
    SOMTimetable = table2timetable([Table(:,1) array2table(classes', ...
        'VariableNames', "Class")]);
    
end