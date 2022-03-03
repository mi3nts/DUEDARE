% FUNCTION TO READ DATA FROM EQUIVITAL EQ02 COMBINED CSV FILE INCLUDING THE
% FOLLOWING DATA EXPORT OPTIONS:

%     1. SUMMARY [SAMPLE RATE: 15 s] 
%     Variables: Date, Time, SensorID, SEMFileDesignation, 
%               HR_EQV, BR_EQV, SkinTemperature_IRThermometer, 
%               BodyPosition, AmbulationStatus, Alert, PWI,
%               DeviceIndications, SubjectIndications

%     2. EVENT COMMENTS [SAMPLE RATE: varies] 
%     Variables: Date, Time, Comments

%     3. ECG (mV) [SAMPLE RATE: 4 ms]
%     Variables: Date, Time, ECGLead1, ECGLead2

%     4. ACCELEROMETER (mG) [SAMPLE RATE: ~40 ms]
%     Variables: Date, Time, LateralAcc, LongitudinalAcc, VerticalAcc

%     5. BREATHING WAVEFORM [SAMPLE RATE: ~40 ms]
%     Variables: Date, Time, BreathingWave

%     6. PHOTO PLETHYSMOGRAPHY [SAMPLE RATE: ]
%     Variables: Date, Time, PLETHYSMOGRAPHY

%     7. HEART RATE [SAMPLE RATE: 15 s] 
%     Variable: HR_EQV (in summary)

%     8. BREATHING RATE [SAMPLE RATE: 15 s] 
%     Variable: BR_EQV (in summary)

%     9. ECG DERIVED BREATHING RATE [SAMPLE RATE: 15 s] 
%     Variables: Date, Time, ECG_BR_EQV, ECG_BR_EQV_Quality

%     10. INTER BEAT INTERVAL (ms) [SAMPLE RATE: r peaks] 
%     Variables: Date, Time, InterBeatInterval

%     11. OXYGEN SATURATION [SAMPLE RATE: ]
%     Variables: Date, Time, Source, Percentage

%     12. SKIN TEMPERATURE (IR THERMOMETER) [SAMPLE RATE: 15 s]
%     Variable: SkinTemperature_IRThermometer (in summary)

% INPUTS:
%     YEAR = STRING. 
%     MONTH = STRING
%     DAY = STRING
%     TRIAL = STRING
%     USER = STRING
%     DEVICE = STRING. DEVICE ID

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function[] = EQVRead(YEAR, MONTH, DAY, TRIAL, USER, DEVICE)
    %% READ RAW DATA

    % get ID and pathID from input strings
    [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, DEVICE);

    % detect import options
    opts = detectImportOptions(strcat('raw/', pathID, '/', ID, '/', ID, '_Combined.csv'));

    % define variable names
    opts.VariableNames = {'Date', 'Time', 'SensorID', 'SEMFileDesignation', ...
        'HR_EQV', 'BR_EQV', 'SkinTemperature_IRThermometer', ...
        'BodyPosition', 'AmbulationStatus', 'Alert', 'PWI', ...
        'DeviceIndications', 'SubjectIndications', ...
        'LeadOffAlert', 'BeltOffAlert', 'LowHRConfidence', ...
        'HRConfidence', ...
        'LowBRConfidence', ...
        'BRConfidence', ...
        'LowBatteryInternal', 'FullBatteryInternal', 'LowBatteryExternal', ...
        'ButtonPressEvent', 'ECGSaturation', 'FallAlarm', 'Apnea', ...
        'IrregularRhythmHR', 'BroadPulseTachycardia', ...
        'HeartRateHigh_low', 'BreathingRateHigh_low', 'ECGBreathingRateHigh_low', ...
        'ECG_BR_EQV', 'ECG_BR_EQV_Quality', ...
        'ECGLead1', 'ECGLead2', ...
        'LateralAcc', 'LongitudinalAcc', 'VerticalAcc', ...
        'BreathingWave', 'Plethysmography', 'InterBeatInterval', ...
        'Source', 'Percentage', ...
        'Comments'};


    % define variable types
    opts.VariableTypes = {'datetime', 'duration', 'int32', 'categorical', ...
        'double', 'double', 'double', ...
        'categorical', 'categorical', 'categorical', 'categorical', ...
        'logical', 'logical', ...
        'logical', 'logical', 'logical', ...
        'double', ...
        'logical', ...
        'double', ...
        'logical', 'logical', 'logical', ...
        'logical', 'logical', 'logical', 'logical', ...
        'logical', 'logical', ...
        'logical', 'logical', 'logical', ...
        'double', 'double', ...
        'double', 'double', ...
        'double', 'double', 'double', ...
        'double', 'double', 'double', ...
        'categorical', 'double', ...
        'string'};

    % set date format option
    opts = setvaropts(opts,'Date','InputFormat','MM/dd/uuuu');

    % read raw data as table
    EQVTable = readtable(strcat('raw/', pathID, '/', ID, '/', ID, '_Combined.csv'), opts);

    %% CLEAN DATA (LIGHTLY)

    numRecords = height(EQVTable);

    % make sensor ID uniform across records
    iwantID = find(EQVTable.SensorID ~= 0);
    EQVTable.SensorID = EQVTable.SensorID(iwantID(1))*...
        ones(numRecords, 1, 'int32');

    % make SEMFileDesignation uniform
    EQVTable.SEMFileDesignation(isundefined(EQVTable.SEMFileDesignation)) = ...
        categories(EQVTable.SEMFileDesignation);

    %% MERGE DATE AND TIME 

    Datetime = datetime(EQVTable.Date + EQVTable.Time, ...
        'Format', 'dd-MMM-y HH:mm:ss.SSSS');

    %% CREATE TIMETABLE

    % remove Date and Time variables
    EQVTable = removevars(EQVTable, 1:2);

    % add Datetime variable
    EQVTable = addvars(EQVTable, Datetime, 'Before', 'SensorID');

    % convert table to timetable
    EQVTimetable = table2timetable(EQVTable);
    
    %% ADD CORE TEMPERATURE, HRV, AND R PEAKS
    
    EQVTimetable = getCoreTemp(EQVTimetable, 'HR_EQV');
    EQVTimetable = getHRV(EQVTimetable, 'InterBeatInterval', 1);
    EQVTimetable = getRpeaks(EQVTimetable, 'EQV');

    %% SAVE TIMETABLE

    directory = strcat('objects/', pathID, '/');

    % create directory if it doesn't exist
    createDir(directory)

    % save timetable to proper path
    save(strcat(directory, ID, '_EQVTimetable'), 'EQVTimetable');