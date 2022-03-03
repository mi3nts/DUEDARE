% FUNCTION TO COMPUTE ALPHA BAND POWER VALUES FROM EEG SPECTRA DATA

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function alphaBand = getAlphaBand(EEGps)

    % get alpha band frequencies indicies
    iwantAlpha = find(EEGps.frequencyValues >= 8 &...
        EEGps.frequencyValues <= 12);

    % convert timetable of power spectra data to array
    EEGpsArray = timetable2table(EEGPowerSpectraReorderVars(...
        EEGps.Timetable_groupedByElectrodes));
    EEGpsArray = EEGpsArray(:,2:end);
    EEGpsArray = table2array(EEGpsArray);

    numRecords = height(EEGps.Timetable_groupedByElectrodes);

    % intialize an array to store alpha band PS
    alphaBand = zeros(numRecords, 64);

    % create array of PS data for each constituent freq value in alpha band
    for i=iwantAlpha'

        % get column range of electrodes for ith freq value
        rangeAlphaiStart = i*64 - 63;
        rangeAlphaiEnd = i*64;

        % create array for PS of ith freq value
        eval(strcat('alphaBand', string(i),...
            " = EEGpsArray(:,rangeAlphaiStart:rangeAlphaiEnd);"));

        % add ith PS array to alphaBand array
        eval(strcat('alphaBand = alphaBand + alphaBand', string(i),';'));

        eval(strcat("clear alphaBand", string(i)));

    end

    % normalize alphaBand array
    alphaBand = normalize(alphaBand);
