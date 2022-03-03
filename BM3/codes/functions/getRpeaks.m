% FUNCTION TO DETECT R PEAKS IN ECG DATA

% INPUTS:

% OUTPUT:

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function outTimetable = getRpeaks(inTimetable, DEVICE)

    %% DEFINE 2 CASES
    if strcmp(DEVICE(1:3), 'EEG')
        ecgVarName = 'ECG';
        rpeakVarNames = ["rpeaks" "rrInterval"];
        ECG = inTimetable.ECG;
        mutilatedMinPeakProminence = 7.5;
        mutilatedMinPeakDistance = 167;
        sampleRate = inTimetable.Properties.SampleRate;
        TimeStep = inTimetable.Properties.TimeStep;
        
    elseif strcmp(DEVICE(1:3), 'EQV')
        ecgVarName = 'ECGLead2';
        rpeakVarNames = ["rpeaks_EQV" "rrInterval_EQV"];
        ECG = inTimetable.ECGLead1;
        mutilatedMinPeakProminence = 2;
        mutilatedMinPeakDistance = 75;
        sampleRate = 250;
        TimeStep = seconds(1/sampleRate);
    end
    %% GET MUTILATED ECG SIGNAL
    mutilatedECG = mutilateECG(ECG, DEVICE);

    %% FIND PEAKS IN MUTILATED SIGNAL
    [~,locs] = findpeaks(mutilatedECG,...
        'MinPeakProminence', mutilatedMinPeakProminence, ...
        'MinPeakDistance', mutilatedMinPeakDistance);

    %% FOR COGNIONICS DATA, FIND PEAKS IN ORIGINAL SIGNAL
    if strcmp(DEVICE(1:3), 'EEG')
        % get total signal time
        time = inTimetable.Datetime(end) - inTimetable.Properties.StartTime;

        % compute average HR
        avgHR = mean(inTimetable.HR);

        % define min peak distance from average HR
        alpha = 1.5;
        thresholdHR = alpha*avgHR;

        minPeakDistance = sampleRate*60/thresholdHR;

        % find peaks
        [~,locs] = findpeaks(ECG,...
            'MinPeakProminence',2, ...
            'MinPeakDistance',minPeakDistance);
    end
    
    %% COMPUTE R PEAK RELATED VARIABLES
    % define bool vector indicating r peaks
    rpeaks = zeros(length(ECG),1);
    rpeaks(locs) = 1;

    % peak to peak intervals
    rrInterval = NaN(length(ECG),1);
    rrInterval(locs(2:end)) = diff(locs)*milliseconds(TimeStep);

    %% ADD VARS TO TIMETABLE
    outTimetable = addvars(inTimetable, rpeaks, rrInterval, ...
        'After', ecgVarName, ...
        'NewVariableNames', rpeakVarNames);
    
end