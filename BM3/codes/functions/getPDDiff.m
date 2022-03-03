% FUNCTION TO COMPUTE AND APPEND PUPIL DIAMETER DIFFERENCE TO TIMETABLE OF 
% TOBII PRO GLASSES 2 DATA

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function newTobiiTimetable = getPDDiff(oldTobiiTimetable)

    % compute average
    PupilDiameterDifference =...
        (oldTobiiTimetable.PupilDiameter_LeftPupilDiameter_Timetable...
        - oldTobiiTimetable.PupilDiameter_RightPupilDiameter_Timetable);

    % create new timetable with average pupil diameter included as variable
    newTobiiTimetable =...
        addvars(oldTobiiTimetable,PupilDiameterDifference);