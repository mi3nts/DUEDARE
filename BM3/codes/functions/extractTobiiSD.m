% FUNCTION TO EXTRACT RAW TOBII DATA FROM SD CARD AND COPY IT TO NEW DATA
% FOLDER

% INPUTS:
%     cardPath = STRING. PATH FOR SD CARD
%     newDataPath = STRING. PATH FOR _newData FOLDER
%     USER = STRING. USER ID
%     Tobii = STRING. TOBII DEVICE ID

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = extractTobiiSD(cardPath, newDataPath, USER, Tobii)

    %% DEFINE FILE SEPERATOR BASED ON OS
    % windows case
    if contains(computer, 'WIN')
        seperator = '\';

    % mac and linux case
    else
        seperator = '/';
    end
    
    %% GET FOLDER INFORMATION IN PROJECT FOLDER
    % change to projects directory
    eval(strcat("cd ", cardPath, 'projects'))

    % create structure containing directory information
    dirStruct = dir;

    % throw error is mulitple projects are saved on SD card
    if length(dirStruct) > 3
        error('Multiple projects saved on SD card. Please delete irrelevant projects.')
    end

    % change to project directory
    eval(strcat("cd ", dirStruct(3).name,seperator, 'recordings'))

    % create structure containing recording folder information
    projectDirStruct = dir;
    %% GET AND SORT TRIAL START TIMES
    % initialize array to store start times
    recStartTimes = [];

    % iterate through recording folders and get recording start times
    for i = 3:length(projectDirStruct)
        eval(strcat("cd ", projectDirStruct(i).name))
        recInfo = fileread('recording.json');
        recInfoStruct = jsondecode(recInfo);
        startTime = datetime(recInfoStruct.rec_created, ...
            'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss+SSSS');
        recStartTimes = [recStartTimes; startTime];
        cd ..
    end

    % sort recordings by start times
    [times, isorted] = sort(recStartTimes);
    %% COPY FILES TO NEW DATA FOLDER

    for i = 1:length(isorted)
        % define index to use for projectDirStruct
        j = isorted(i) + 2;

        % define trial name
        if i>9
            TRIAL = strcat('T',string(i));
        else
            TRIAL = strcat('T0',string(i));
        end

        % define month string
        if month(times(i))>9
            MONTH = string(month(times(i)));
        else
            MONTH = strcat('0', string(month(times(i))));
        end

        % define day string
        if day(times(i))>9
            DAY = string(day(times(i)));
        else
            DAY = strcat('0', string(day(times(i))));
        end

        % define name of new data folder
        newFolderName = strcat(string(year(times(i))), '_', ...
            MONTH, '_', ...
            DAY, '_', ...
            TRIAL, '_', ...
            USER, '_', ...
            Tobii);

        % define old destination for data
        oldDestination = strcat(projectDirStruct(j).folder, seperator, ...
            projectDirStruct(j).name);

        % define new destination for data
        newDestination = strcat(newDataPath, newFolderName);

        % copy files to new data folder
        eval(strcat("copyfile ", oldDestination, " ", newDestination))
    end