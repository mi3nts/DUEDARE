% FUNCTION TO AGGREGATE BASELINE MEASRUEMENTS OF SPECIFIED VARAIBLE NAMES IN
% ADDITION TO EEG POWER SPECTRAL DATA

% INPUTS:
%     YEAR = STRING. EX: "2020"
%     MONTH = STRING. EX: "12" 
%     DAY = STRING. EX: "01"
%     TRIAL = STRING. EX: "T01"
%     USER = STRING. USER ID EX: "U00T"
%     DEVICE = STRING. EX: 'EEG01', 'Synchronized'
%     varNames = STRING ARRAY. DESIRED COGNITIVE LOAD VARIABLES

% OUTPUT:
%     baseline_averages = ARRAY. IN THE SAME ORDER AS varNames FOLLOWED BY
%     EEG POWER SPECTRA DATA ORDER VIA: Data is organized such that the 
%     first 257 columns correspond to the power spectrum of electrode 1 
%     (Fp1), the next 257 columns correspond to the power spectrum of 
%     electrode 2 (Fp2), and so on.

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function baseline_averages = aggregateBaseline(YEAR, MONTH, DAY, TRIAL, ...
    USER, DEVICE, varNames, useTrigger)

    %% LOAD DATA

    % Load EEGTobiiTimetable
    EEGTobiiTimetable = LoadTimetable(YEAR, MONTH, DAY, TRIAL, USER, DEVICE);

    %% DEFINE TEMPORARY TIMETABLE WITH DESIRED DATA
    
    % define array of desired variable names
    varNames = [varNames "TRIGGER"];

    % get indicies of desired variable names in EEGTobiiTimetable
    [~,i,~] = intersect(EEGTobiiTimetable.Properties.VariableNames, varNames);

    % create timetable with cognitive load variables
    CLTimetable = EEGTobiiTimetable(:,sort(i));
    % create timetable with eeg variables
    EEGTimetable = EEGTobiiTimetable(:,1:64);

    %% INTERPOLATE OVER NANS FOR TOBII DATA

    CLTimetable = interpolTobiiNaNs(CLTimetable);

    %% ONLY KEEP RECORDS DURING BASELINE

    if useTrigger
        % return trigger point indicies
        triggerPoints = getTriggerPoints(EEGTobiiTimetable);

        % keep records during baseline
        CLTimetable = CLTimetable(triggerPoints(1):triggerPoints(2),:);
        EEGTimetable = EEGTimetable(triggerPoints(1):triggerPoints(2),:);
    end

    % remove trigger variable
    CLTimetable = removevars(CLTimetable, "TRIGGER");
    %% AGGREGATE 

    % compute cognitive load averages
    cl_averages = nanmean(CLTimetable.Variables);

    % average EEG power spectra
    pxx = pwelch(rmmissing(EEGTimetable.Variables), [], [], 512, EEGTimetable.Properties.SampleRate);
    ps_averages = reshape(pxx, [1, 16448]);

    % concatenate averages
    baseline_averages = [cl_averages ps_averages];
