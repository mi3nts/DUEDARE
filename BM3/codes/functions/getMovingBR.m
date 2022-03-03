% FUNCTION TO COMPUTE AND ADD BREATH RATE TO INPUT TIMETABLE.
% NOTE: FUNCTION IS DESIGNED FOR CGX TIMETABLE.

% INPUTS:
%     inTimetable = TIMETABLE WITH RESP DATA

% OUTPUT:
%     outTimetable = TIMETABLE WITH ORIGINAL DATA PLUS BREATH RATE

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function outTimetable = getMovingBR(inTimetable)

    % compute moving breath rate
    movingBR = computeMovingBR(inTimetable.Resp,...
        inTimetable.Datetime,...
        inTimetable.Properties.SampleRate);

    % add breath rate to timetable
    outTimetable = addvars(inTimetable, movingBR, ...
        'After', 'Resp', ...
        'NewVariableNames', 'BR');