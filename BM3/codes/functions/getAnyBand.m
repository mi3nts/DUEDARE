% FUNCTION TO COMPUTE ARBRITARY EEG BANDWIDTH POWER VALUES FROM EEG SPECTRA

% INPUTS:
%     EEGps = EEGps sturcture
%     lowerbound = number. lower freq bound of desired eeg band
%     upperbound = number. upper freq bound of desired eeg band

% some common bands:
%     delta: 1-3 Hz
%     theta: 4 - 7 Hz
%     alpha: 8 - 12 Hz
%     beta: 13 - 25 Hz
%     low gamma: 25 - 75 Hz
%     high gamma: > 70 Hz

% Louis, E.K., Frey, L.C., et al. (2016). 
% Electroencephalography (EEG): An Introductory Text and Atlas of Normal 
% and Abnormal Findings in Adults, Children, and Infants.

% OUTPUT:
%     eegBand = array of normalized power values for desired eeg band

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function eegBand = getAnyBand(EEGps, lowerbound, upperbound)

    % get band frequency indicies
    iwantBand = find(EEGps.frequencyValues >= lowerbound &...
        EEGps.frequencyValues <= upperbound);

    % convert timetable of power spectra data to array
    EEGpsArray = timetable2table(EEGPowerSpectraReorderVars(...
        EEGps.Timetable_groupedByElectrodes));
    EEGpsArray = EEGpsArray(:,2:end);
    EEGpsArray = table2array(EEGpsArray);

    numRecords = height(EEGps.Timetable_groupedByElectrodes);

    % intialize an array to store band PS
    eegBand = zeros(numRecords, 64);

    % create array of PS data for each constituent freq value in band
    for i=iwantBand'

        % get column range of electrodes for ith freq value
        rangeiStart = i*64 - 63;
        rangeiEnd = i*64;

        % create array for PS of ith freq value
        eval(strcat('eegBand', string(i),...
            " = EEGpsArray(:,rangeiStart:rangeiEnd);"));

        % add ith PS array to eegBand array
        eval(strcat('eegBand = eegBand + eegBand', string(i),';'));

        eval(strcat("clear eegBand", string(i)));

    end

    % normalize eegBand array
    eegBand = normalize(eegBand);