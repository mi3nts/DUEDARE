% FUNCTION TO COMPUTE ALL COMMON EEG BANDS AND KEY RATIOS FROM EEGPS
% STRUCTURE

% INPUTS:
%     EEGps = STRUCTURE. STRUCTURE WITH POWER SPECTRA OF EEG DATA
%     EEG = STRING. DEVICE ID OF EEG
% OUTPUT:
%     eegBandsTimetable = TIMETABLE WITH EEG BANDS AND RATIOS FOR EACH
%     ELECTRODE AT EACH TIMESTEP

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function eegBandsTimetable = getAllBands(EEGps, EEG)

    %% LOAD EEG ELECTRODE NAMES

    % load channel locations structure
    chanlocs = load(strcat('backend/channelLocations/', EEG,'_chanlocs.mat'));

    % extract structure
    name = fieldnames(chanlocs);
    chanlocs = getfield(chanlocs, name{1});
    %% COMPUTE DELTA, THETA, ALPHA, AND BETA BAND VALUES

    deltaBand = getAnyBand(EEGps, 1, 3);
    thetaBand = getAnyBand(EEGps, 4, 7);
    alphaBand = getAlphaBand(EEGps);
    betaBand = getAnyBand(EEGps, 13, 25);
    lowGammaBand = getAnyBand(EEGps, 25, 70);
    highGammaBand = getAnyBand(EEGps, 70, 251);

    %% COMPUTE RATIOS

    thetaOverAlpha = thetaBand./alphaBand;
    betaOverAlpha = betaBand./alphaBand;

    %% DEFINE VARIABLE NAMES

    % define array of string ending for variables
    suffixString = ["deltaBand" "thetaBand" "alphaBand" "betaBand" ...
        "lowGammaBand" "highGammaBand" "thetaOverAlpha" "betaOverAlpha"];

    % initialize array to store variable names
    variableNames = [];

    % get electrode names
    labels = extractfield(chanlocs, 'labels');

    % generate variable names
    for label = string(labels)

        % generate variables names for current electrode
        currentVariableName = strcat(label, '_', suffixString);
        % append current variable name to array
        variableNames = [variableNames currentVariableName];
    end
    %% DEFINE OUTPUT

    % create array with all band and ratio values
    eegBands = [deltaBand thetaBand alphaBand betaBand ...
        lowGammaBand highGammaBand ...
        thetaOverAlpha betaOverAlpha];

    % convert array to timetable with proper times and variable names
    eegBandsTimetable = array2timetable(eegBands, ...
        'RowTimes', EEGps.Timetable_groupedByElectrodes.Datetime, ...
        'VariableNames', variableNames);