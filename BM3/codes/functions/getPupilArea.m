% FUNCTION TO COMPUTE AND APPEND PUPIL AREA VARIABLES TO TIMETABLE OF 
% TOBII PRO GLASSES 2 DATA

% VARIABLES ADDED:

%     1. LEFT PUPIL AREA
%     2. RIGHT PUPIL AREA
%     3. PUPIL AREA DIFFERENCE

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function newTobiiTimetable = getPupilArea(oldTobiiTimetable)

    % compute left pupil area
    LeftPupilArea =...
        (pi/4)*...
        (oldTobiiTimetable.PupilDiameter_LeftPupilDiameter_Timetable.^2);
    
    % compute right pupil area
    RightPupilArea =...
        (pi/4)*...
        (oldTobiiTimetable.PupilDiameter_RightPupilDiameter_Timetable.^2);
    
    % compute pupil area difference 
    PupilAreaDifference = abs(LeftPupilArea - RightPupilArea);
    
    % create new timetable with average pupil diameter included as variable
    newTobiiTimetable =...
        addvars(oldTobiiTimetable, LeftPupilArea, RightPupilArea, ...
        PupilAreaDifference);