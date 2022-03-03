% FUNCTION TO COMPUTE RMS ERROR IN MOVING WINDOW

% INPUTS:

    % t = a vector of the times
    % v = a vector of the variable values for each time
    % window = the size of the window e.g. seconds(1) would be a one second 
    % window
    % UseParallel = 0 or 1. 1 to use parfor and 0 not to use parfor
    
% OUTPUT:

    % MovingRMS = VECTOR OF RMS ERROR VALUES IN MOVING TIME WINDOW

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function MovingRMS = moving_rms(t, v, window, UseParallel)

    % Make the inputs into a timetable so we can use the withtol funtion to 
    % define the moving window.
    Data=timetable(t,v);

    % initialize the output values (initially fill with NaN).
    MovingRMS=nan(size(t));

    if UseParallel

        % loop over timesteps in parallel
        parfor i=1:length(t)

            % select the timesteps within the time window of interest
            % select just the subset of times of interest
            W=Data(withtol(t(i),window),:).v;

            MovingRMS(i) = sqrt(nanmean(W.^2));

        end

    else
        % loop over timesteps
        for i=1:length(t)

            % select the timesteps within the time window of interest
            % select just the subset of times of interest
            W=Data(withtol(t(i),window),:).v;

            MovingRMS(i) = sqrt(nanmean(W.^2));

        end
    end