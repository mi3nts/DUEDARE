% FUNCTION TO COMPUTE AND APPEND AVERAGE PUPIL DIAMETER TO TIMETABLE OF 
% TOBII PRO GLASSES 2 DATA

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function newTobiiTimetable = getPDAverage(oldTobiiTimetable)

    % compute average
    AveragePupilDiameter =...
        (oldTobiiTimetable.PupilDiameter_LeftPupilDiameter_Timetable...
        + oldTobiiTimetable.PupilDiameter_RightPupilDiameter_Timetable)/2;

    % create new timetable with average pupil diameter included as variable
    newTobiiTimetable =...
        addvars(oldTobiiTimetable,AveragePupilDiameter);


