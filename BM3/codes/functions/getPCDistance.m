% FUNCTION TO COMPUTE AND APPEND DISTANCE BETWEEN PUPIL CENTERS TO 
% TIMETABLE OF TOBII PRO GLASSES 2 DATA AS WELL AS THE MOVING AVERAGE,
% MOVING VARIANCE, AND MOVING STANDARD DEVIATION IN 1 SECOND WINDOWS.

% VARIABLES THAT ARE COMPUTED AND APPENDED:
%     1. PUPIL CENTER DISTANCE IN X DIRECTION (TOWARD LEFT EAR)
%     2. PUPIL CENTER DISTANCE IN Y DIRECTION (POINTING UP)
%     3. PUPIL CENTER DISTANCE IN Z DIRECTION (POINTING FORWARD)
%     4. PUPIL CENTER DISTANCE IN 3D
%     5. MOVING AVERAGE OF PUPIL CENTER DISTANCE IN 3D IN 1 SECOND WINDOW
%     6. MOVING VARIANCE OF PUPIL CENTER DISTANCE IN 3D IN 1 SECOND WINDOW
%     7. MOVING REPRESENTATIVENESS OF PUPIL CENTER DISTANCE IN 3D IN 1 
%        SECOND WINDOW

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function newTobiiTimetable = getPCDistance(oldTobiiTimetable)

    % compute difference between X, Y, and Z elements
    % NOTE: origin is centered between eyes with X direction pointing out left
    % ear, Y direction pointing up, and Z pointing forward
    
    % pupil center difference in X direction
    PupilCenterX_Distance = oldTobiiTimetable.PupilCenterX_LeftPupilCenter_Timetable - ...
        oldTobiiTimetable.PupilCenterX_RightPupilCenter_Timetable;

    % pupil center difference in Y direction
    PupilCenterY_Distance = oldTobiiTimetable.PupilCenterY_LeftPupilCenter_Timetable - ...
        oldTobiiTimetable.PupilCenterY_RightPupilCenter_Timetable;

    % pupil center difference in Z direction
    PupilCenterZ_Distance = oldTobiiTimetable.PupilCenterZ_LeftPupilCenter_Timetable - ...
        oldTobiiTimetable.PupilCenterZ_RightPupilCenter_Timetable;

    % pupil center difference in 3D
    PupilCenter_Distance = sqrt(PupilCenterX_Distance.^2 + ...
        PupilCenterY_Distance.^2 + ...
        PupilCenterZ_Distance.^2);

    % compute moving average, variance, and standard deviation of the
    % distance between pupil centers in 1 second window, and without using
    % parfor
    [PupilCenter_Distance_MovingAverage, ...
        PupilCenter_Distance_MovingVariance, ...
        PupilCenter_Distance_MovingRepresentativeness] = ...
        timeseries_moving_average(...
        oldTobiiTimetable.Datetime,...
        PupilCenter_Distance,...
        seconds(1),...
        0);

    % add variables to input timetable
    newTobiiTimetable =...
        addvars(oldTobiiTimetable, ...
        PupilCenterX_Distance, PupilCenterY_Distance, PupilCenterZ_Distance, ...
        PupilCenter_Distance, ...
        PupilCenter_Distance_MovingAverage, ...
        PupilCenter_Distance_MovingVariance, ...
        PupilCenter_Distance_MovingRepresentativeness);
    
    end