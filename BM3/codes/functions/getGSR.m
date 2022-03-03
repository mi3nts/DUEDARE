% FUNCTION TO CONVERT GSR IN KOHMS TO MICROSIEMENS

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function newTimetable = getGSR(oldTimetable)

    %% CONVERT GSR VALUES

    % define array for conductance GSR values
    GSR_uS = oldTimetable.GSR;

    % convert kohms to ohms
    GSR_uS = 1000*GSR_uS;

    % covert ohms to siemens by taking reciprocal
    GSR_uS = 1./GSR_uS;

    % covert siemens to microsiemens by taking reciprocal
    GSR_uS = GSR_uS*1000000;

    %% ADD VARIABLE TO TIMETABLE

    % add variable to timetable
    newTimetable = addvars(oldTimetable, GSR_uS, 'After', 'GSR');