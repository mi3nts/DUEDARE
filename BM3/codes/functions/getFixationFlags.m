% FUNCTION TO CLASSIFY SACCADES AND FIXATIONS IN TOBII DATA

% VARIABLES ADDED:

%     1. FIXATION FLAG: 0 = SACCADE, 1 = FIXATION, NaN = indeterminante

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function newTobiiTimetable = getFixationFlags(oldTobiiTimetable)

    %% COVERT GAZE DATA TO POLAR COORDINATES

    theta = cart2pol(1920*oldTobiiTimetable.GazePositionX, ...
        1080*oldTobiiTimetable.GazePositionY);

    %% CALCULATE ANGULAR SPEED

    % define step size (10 ms)
    h = 0.01;

    % define fixation threshold
    fixationThreshold = 2;

    % compute angular speed 
    angularSpeed = (gradient(theta)/h);
    
    %% DEFINE FIXATION FLAG

    FixationFlag = NaN(height(oldTobiiTimetable),1);

    for i = 1:height(oldTobiiTimetable)

        % if angular speed is nan set flag to nan
        if isnan(angularSpeed(i))

            continue

        % if angular speed is greater than or equal to 30 set flag to 0
        elseif abs(angularSpeed(i)) >= fixationThreshold

            FixationFlag(i) = 0;  

        % if angular speed is less than 30 set flag to 1
        else

            FixationFlag(i) = 1;

        end
    end
    %% CREATE NEW TIMETABLE WITH FIXATION FLAG
    
    newTobiiTimetable = addvars(oldTobiiTimetable, FixationFlag);
end