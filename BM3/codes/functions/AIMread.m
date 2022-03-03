% FUNCTION TO READ AIM2 DATA IN EEGLAB. DATA IS SAVED IN 3 FORMS: 1. EEGLAB
% STRUCTURE 2. TABLE 3. TIMETABLE. 

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

% -------------------------------------------------------------------------
function[] = AIMread(YEAR, MONTH, DAY, TRIAL, USER, AIM)

    % define ID number and pathID
    ID = strcat(YEAR, '_', MONTH, '_',DAY, '_',TRIAL, '_',USER, '_', AIM);
    pathID = strrep(ID,'_','/');

    % change directory to proper parent
    homeDir

    % add paths to eeglab folders
    addEEGLabFunctions

    % use long format
    format long

    % -------------------------------------------------------------------------
    % GET START DATE AND TIME
    % -------------------------------------------------------------------------
    % define header filename
    header = strcat('raw/',pathID,'/',ID,'/',ID,'.vhdr');

    % open file for reading
    file = fopen(header);
    flag = 0;
    while feof(file)==0

        line = fgetl(file);
        if strcmp(line, 'Recording Start Time')
            flag = 1;
            continue
        end
        if flag == 1
            break
        end
    end

    start_date = datetime(line(1:10), 'InputFormat', 'yyyy-MM-dd');
    start_time = duration(line(12:end),'format','hh:mm:ss.SSSS');

    % -------------------------------------------------------------------------
    % CREATE DATA objects FROM EEG DATA
    % -------------------------------------------------------------------------
    % define filename
    filename = strcat('raw/',pathID,'/',ID,'/',ID,'.eeg');

    % import AIM data for the accelerometer and full data
    AIM = pop_fileio(filename);
    AIM.setname = 'FullAIM';

    % define channel names
    electrodeNames = {'ExG1' 'ExG2' 'ExG3' 'ExG4' 'ECG' 'Resp' 'PPG' 'SPO2' ...
        'HR' 'GSR' 'Temp' 'AUX1' 'AUX2' 'PacketCounter' 'Trigger'};

    % -------------------------------------------------------------------------
    % TIMESTAMPS
    % -------------------------------------------------------------------------
    % create vector with timestamps in milliseconds since start of collection
    mstime = milliseconds(AIM.times);

    % create table with actual time stamp
    datetimes = array2table((start_date + start_time + mstime)',...
        'VariableNames', "Datetime");

    % -------------------------------------------------------------------------
    % TABLES
    % -------------------------------------------------------------------------
    % create table with electrodes as variables
    AIMTable = [datetimes ...
        array2table(AIM.data', 'VariableNames', electrodeNames)];

    % -------------------------------------------------------------------------
    % TIMETABLES
    % -------------------------------------------------------------------------
    % create timetable of EEG data
    AIMTimetable = table2timetable(AIMTable);
    
    % add gsr in microsiemens
    AIMTimetable = getGSR(AIMTimetable);

    % -------------------------------------------------------------------------
    % SAVE objects
    % -------------------------------------------------------------------------
    % check if proper folder for storing timetables exists, if not create it
    if ~exist(strcat('objects/', pathID), 'dir')
        mkdir(strcat('objects/', pathID))
    end

    % save timetable
    save(strcat('objects/', pathID, '/', ID, '_AIMTimetable'), 'AIMTimetable');