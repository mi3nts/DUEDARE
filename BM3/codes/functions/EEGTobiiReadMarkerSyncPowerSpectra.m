% FUNCTION TO READ IN COGNIONICS EEG AND TOBII PRO GLASSES 2 DATA.
% SYNCHRONIZE THE DATA. THEN COMPUTE POWER SPECTRA OF EEG.

% INPUTS
%     YEAR = STRING. EX: '2019'
%     MONTH = STRING. EX: '12'
%     DAY = STRING. EX: '5'
%     TRIAL = STRING. EX: 'T03'
%     USER = STRING. EX: 'U010'
%     EEG =  STRING. EX: 'EEG01'
%     Tobii = STRING. EX: 'Tobii01'
%     NumberOfWorkers = INTEGER. NUMBER OF CORES TO USE. USE [] IF NOT 
%                       USING PARALLEL PROCESSING 

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = EEGTobiiReadMarkerSyncPowerSpectra(YEAR, MONTH, DAY, ...
    TRIAL, USER, EEG, Tobii, NumberOfWorkers)

    % read eeg
    EEGRead(YEAR, MONTH, DAY, TRIAL, USER, EEG)

    % read tobii
    TobiiRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii)

    % sync eeg and tobii
    EEGTobiiMarkerSync(YEAR, MONTH, DAY, TRIAL, USER, EEG, Tobii)

    % compute power spectra of eeg
    EEGPowerSpectra(YEAR, MONTH, DAY, TRIAL, USER, EEG, NumberOfWorkers)
end