% FUNCTION TO COMPUTE DIFFERENT HEART RATE VARIABILITY VARIABLES FROM INPUT
% TIMETABLE WITH PEAK TO PEAK TIME INTERVAL. VALUES ARE COMPUTED IN 15
% SECONDS SLIDING TIME WINDOW.

% INPUTS:
%     inTimetable = TIMETABLE WITH HR DATA
%     nnVarName = STRING OR CHAR. VARIABLE NAME FOR PEAK TO PEAK TIME
%     DIFFERENCE IN MILLISECONDS
%     useParallel = BOOLEAN. 0 = NO PARALLEL PROCESSING. 1 = USE PARALLEL
%     PROCESSING

% OUTPUT:
%     outTimetable = TIMETABLE WITH ORIGINAL DATA PLUS HRV VARIABLES

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function outTimetable = getHRV(inTimetable, nnVarName, useParallel)

    %% GET NN VAR INDEX
    
    nnIndex = strcmp(string(inTimetable.Properties.VariableNames), nnVarName);

    %% COMPUTE MOVING AVERAGE, VARIANCE, AND STANDARD DEVIATION OF NN INTERVALS

    % compute moving statistics in 15 second window
    [HRV_meanNN, HRV_VNN, HRV_SDNN] = ...
        timeseries_moving_average(inTimetable.Datetime, ...
        inTimetable(:,nnIndex).Variables, ...
        seconds(15), ...
        useParallel);

    %% COMPUTE MOVING RMS ERROR OF NN INTERVALS

    % compute moving rms error in 15 second window
    HRV_rMSSD = moving_rms(inTimetable.Datetime, ...
        inTimetable(:,nnIndex).Variables, ...
        seconds(15), ...
        useParallel);

    %% DEFINE CORE TEMPERATURE VARIABLE NAME BASED HR VARIABLE NAME
    
    hrvVarNames = ["HRV_meanNN" "HRV_VNN" "HRV_SDNN" "HRV_rMSSD"];
    
    % if timetable is of EQV data append "_EQV" to variable names
    if strcmp(nnVarName, 'InterBeatInterval')
        hrvVarNames = append(hrvVarNames, '_EQV');
    end
    %% ADD CORE TEMPERTATURE TO EQVTIMETABLE

    outTimetable = addvars(inTimetable, ...
        HRV_meanNN, HRV_VNN, HRV_SDNN, HRV_rMSSD, ...
        'After', nnVarName, ...
        'NewVariableNames', hrvVarNames);