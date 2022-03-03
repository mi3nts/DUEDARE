% FUNCTION TO COMPUTE WELCH POWER SPECTRUM WITH OVERLAPPING HAMMING WINDOW 
% OF 64-ELECTRODE EEG DATA AT EACH TIMESTEP AND SAVE TO FILE

% INPUTS:
%     YEAR = STRING
%     MONTH = STRING
%     DAY = STRING
%     TRIAL = STRING
%     USER = STRING
%     EEG = STRING. NUMBER OF THE EEG SYSTEM USED
%     NumberOfWorkers = INTEGER. NUMBER OF CORES TO USE. USE [] IF NOT 
%                       USING PARALLEL PROCESSING 


% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function [] = EEGPowerSpectra(YEAR, MONTH, DAY, TRIAL, USER, EEG,...
    NumberOfWorkers)

%% GET DATA

% load timetable
Timetable = LoadTimetable(YEAR, MONTH, DAY, TRIAL, USER, EEG);

% get EEG data from timetable
EEGdata = Timetable(:,1:64);
% convert to table
x = timetable2table(EEGdata);
% grab time values
Datetime = x(:,1);
% covert to array
x = table2array(x(:,2:end));

%% DEFINE QUANTITIES FOR POWER SPECTRUM CALCULATION

fs = 500;                           % define sample frequency
epochSeconds = 10;                  % epoch length in seconds
segmentL = epochSeconds*fs + 1;     % define segment length i.e. length of 
                                    % interval over which power spectrum is 
                                    % computed
segmentHalfL = floor(segmentL/2);   % half of segment length rounded down

% intialize an array in which to store power values. NaN array is used to
% handle time steps for which full power spectrum cannot be computed.
% NOTE: values will be stored such that time steps are indexed vertically 
% and frequency values per electrode are indexed horizontally. In other 
% words, the first 257 columns correspond to the power spectrum electrode 1
% , the next 257 columns correspond to electrode 2, and so on.
% NOTE: 257 freqs * 64 elec = 23387 columns
EEGdataPS_groupedByElectrodes = NaN(length(x), 16448);

%% IF APPLICABLE USE PARFOR TO COMPUTE POWER SPECTRA

if ~isempty(NumberOfWorkers)
    % start parallel pool if none exists
    if isempty(gcp('nocreate'))
        poolobj = parpool(NumberOfWorkers);
    end

    % center refers to the point in the middle of the segment
    parfor center = ceil(segmentL/2):(length(x)-segmentHalfL)

        % compute power spectra of all 64 electrodes of segment centered at
        % center
        pxx = pwelch(x(center-segmentHalfL:center+segmentHalfL, :),...
            round(segmentL/10), 50, [], fs);

        % store data in respective array
        EEGdataPS_groupedByElectrodes(center,:) = reshape(pxx, [1, 16448]);

    end
    
%     % delete parallel pool
%     delete(poolobj)

    % generate array of frequency values if using parfor
    f = linspace(0, 250, 257);
%% OTHERWISE USE REGULAR FOR LOOP
else
    % center refers to the point in the middle of the segment
    for center = ceil(segmentL/2):(length(x)-segmentHalfL)

        % compute power spectra of all 64 electrodes of segment centered at
        % center
        [pxx, f] = pwelch(x(center-segmentHalfL:center+segmentHalfL, :),...
            round(segmentL/10), 50, [], fs);

        % store data in respective array
        EEGdataPS_groupedByElectrodes(center,:) = reshape(pxx, [1, 16448]);

    end
    
end

%% 

%% CREATE TIMETABLE WITH POWER DATA

% create table with power spectrum data grouped by electrodes
Table_groupedByElectrodes = [Datetime...
    array2table(EEGdataPS_groupedByElectrodes)];
% convert table into timetable grouped by electrodes
Timetable_groupedByElectrodes = table2timetable(Table_groupedByElectrodes);

%% RENAME VARIABLE NAMES

% create cell array with EEG electrode names
electrodeNames = {'Fp1' 'Fp2' 'F3' 'F4' 'C3' 'C4' 'P3'...
    'P4' 'O1' 'O2' 'F7' 'F8' 'T7' 'T8' 'P7' 'P8' 'Fz' 'Cz' 'Pz' 'Oz'...
    'FC1' 'FC2' 'CP1' 'CP2' 'FC5' 'FC6' 'CP5' 'CP6' 'FT9' 'FT10' 'FCz'...
    'AFz' 'F1' 'F2' 'C1' 'C2' 'P1' 'P2' 'AF3' 'AF4' 'FC3' 'FC4' 'CP3'...
    'CP4' 'PO3' 'PO4' 'F5' 'F6' 'C5' 'C6' 'P5' 'P6' 'AF7' 'AF8' 'FT7'...
    'FT8' 'TP7' 'TP8' 'PO7' 'PO8' 'Fpz' 'CPz' 'POz' 'TP10'};

% define array indexing electrode and frequency bin combinations
indx = 0:16447;

%%% rename variables inTimetable_groupedByElectrodes
% get frequency value for Timetable_groupedByElectrodes
freqVal = f(mod(indx,257)+1);
% get electrode name for Timetable_groupedByElectrodes
electrodeName = electrodeNames(floor(indx./257)+1);

% rename variable names for Timetable_groupedByElectrodes
Timetable_groupedByElectrodes.Properties.VariableNames = ...
    strrep(strcat(string(electrodeName), '_freq_', string(freqVal), ...
    'Hz'), '.','_');

%% ADD USEFUL DESCRIPTIONS TO TIMETABLES

Timetable_groupedByElectrodes.Properties.Description = ...
    strcat('Timetable including power spectra of 64 electrode EEG. Data',...
    ' is organized such that the first 257 columns correspond to the',...
    ' power spectrum of electrode 1 (Fp1), the next 257 columns',...
    ' correspond to the power spectrum of electrode 2 (Fp2), and so on');

%% STORE USEFUL QUANTITIES INTO A STRUCTURE

EEGps.sampleRate = fs; 
EEGps.epochTimeInSeconds = epochSeconds;
EEGps.psWindowLength = segmentL;
EEGps.frequencyValues = f';
EEGps.Timetable_groupedByElectrodes = ...
    Timetable_groupedByElectrodes;

%% COMPUTE CUMULATIVE POWER SPEC FOR BASELINES AND ADD TO EEGps

% eyes closed baseline
if strcmp(TRIAL, 'T01')
    % compute ps
    pxx = pwelch(x, round(segmentL/10), 50, [], fs);
    % reshape so that 
    eyesClosedCumPS_groupedByElectrodes = reshape(pxx, [1, 16448]);
    % add to EEGps
    EEGps.eyesClosedCumPS_groupedByElectrodes = ...
        eyesClosedCumPS_groupedByElectrodes;
end    

% eyes open baseline
if strcmp(TRIAL, 'T02')
    % compute ps
    pxx = pwelch(x, round(segmentL/10), 50, [], fs);
    eyesOpenCumPS_groupedByElectrodes = reshape(pxx, [1, 16448]);
    % add to EEGps
    EEGps.eyesOpenCumPS_groupedByElectrodes = ...
        eyesOpenCumPS_groupedByElectrodes;
end 
%% SAVE STRUCTURE TO FILE

% get IDs
[ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, EEG);

% check if proper folder for storing timetables exists, if not create it
if ~exist(strcat('objects/', pathID), 'dir')
    mkdir(strcat('objects/', pathID))
end

% save structure
save(strcat('objects/', pathID, '/', ID, '_EEGps'),...
    'EEGps', '-v7.3');