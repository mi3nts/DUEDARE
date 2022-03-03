% FUNCTION TO COMPUTE RESPIRATION RATE FROM RESPIRATION ELECTRODE SIGNAL

% INPUTS:
    % v = a vector of the respiraton values for each time
    % t = a vector of the times
    % Fs = sampling rate of signal
    
% OUTPUT:

    % movingRR = respiration rate of signal over time with 5 second
    % precision and values computed over 15 seconds

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function movingBR = computeMovingBR(v,t,Fs)

    % define a window size over which to compute breath rate 
    window = seconds(15);

    % Make the inputs into a timetable so we can use the withtol funtion to 
    % define the moving window.
    Data=timetable(t,v);

    % initialize the output values (initially fill with NaN).
    movingBR=nan(size(t));

    % loop over timesteps with 5 second precision.
    % NOTE: movingRR will have unique values in 5 second intervals, where
    % the RR value is computed over a 15 second window
    for i=1:5*Fs:length(t)

        % select the timesteps within the time window of interest
        % select just the subset of times of interest
        W=Data(withtol(t(i),window),:).v;
        T=Data(withtol(t(i),window),:).t;

        % compute RR centered at ith timestep then set a 5 second segment
        % of movingRR equal to that value
        movingBR(i:i+(5*Fs)-1) = computeBR(W,T,Fs);

    end
    
    % drop extra terms 
    movingBR(length(t)+1:end) = [];

end