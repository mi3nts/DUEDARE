% FUNCTION TO CLASSIFY BLINKS IN TOBII DATA

% VARIABLES ADDED:

%     1. BLINK FLAG: 0 = NO BLINK, 1 = BLINK, NaN = indeterminante

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function newTobiiTimetable = getBlinkFlags(oldTobiiTimetable)

    %% LABEL BLINKS BASED ON NANS

    % define threshold for blink detection (that is number of consecutive nan
    % values are needed to classify sequence of records as a blink).
    % Default value corresponds to 0.2 sec (200 ms) of nans.
    blinkNumSamples = 0.2/seconds(oldTobiiTimetable.Properties.TimeStep);

    % get nan elements in tobii timetable
    nans = isnan(oldTobiiTimetable.GazeIndex_GazePosition_Timetable);
    nans(1) = 0;

    % compute difference between elements in nans
    diffNans=[diff(nans); 0];

    % initialize loop variables 
    BlinkFlag = zeros(size(nans));
    nanFlag = 0;
    nanCounter = 0;

    % start loop iterate over length of nans
    for i = 1:length(nans)

        % take ith element in diffNans
        ele = diffNans(i);

        % case 1: do nothing
        if ele==0 && nanFlag==0
            continue
        end

        % case 2: set nanFlag
        if ele==1 && nanFlag==0
            nanFlag = 1;
            continue
        end

        % case 3: return error this shouldn't happen
        if ele==-1 && nanFlag==0
            disp('error in getBlinkFlags: ele=-1 & nanFlag=0')
            break
        end

        % case 4: update nanCounter
        if ele==0 && nanFlag==1
            nanCounter = nanCounter+1;
            continue
        end

        % case 5: return error this shouldn't happen
        if ele==1 && nanFlag==1
            disp('error in getBlinkFlags: ele=1 & nanFlag=1')
            break
        end

        % case 6: determine if sequence of records are "blinks". reset nanFlag.
        % reset nanCounter
        if ele==-1 && nanFlag==1
            % determine if sequence of records are "blinks"
            if nanCounter >= blinkNumSamples
                BlinkFlag(i-nanCounter:i-1) = 1;
            end
            % reset nanFlag
            nanFlag = 0;
            % reset nanCounter
            nanCounter = 0;
            continue
        end

    end
    %% ADD BLINK FLAG TO TIMETABLE

    newTobiiTimetable = addvars(oldTobiiTimetable, BlinkFlag);