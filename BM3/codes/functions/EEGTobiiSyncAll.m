% FUNCTION TO SYNCHRONIZE EEG AND TOBII TIMETABLES. FUNCTION CREATES AND
% SAVES SYNCHRONIZED TIMETABLE TO APPROPRIATE DIRECTORY

% INPUTS
%     EEG =  STRING. EX: 'EEG01'
%     Tobii = STRING. EX: 'Tobii01'
%     NumberOfWorkers = INTEGER. EX: 2. 
%                       NOTE: USE [] IF PARALLEL IS NOT DESIRED
%     overwrite = 0 OR 1. WHERE, 1 = OVERWRITE EXISTING TIMETABLE

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = EEGTobiiSyncAll(EEG, Tobii, NumberOfWorkers, overwrite)

    %% GET FILE IDS OF TIMETABLES TO SYNCHRONIZE

    % get all files IDs corresponding to input EEG and Tobii devices
    EEGfileIDs = findAllFiles('objects', strcat(EEG,'_EEGAccelTimetable'));
    TobiifileIDs = findAllFiles('objects', strcat(Tobii,'_TobiiTimetable'));

    % consider only fileIDs in both EEGfileIDs and EEGfileIDs
    fileIDs = intersect(EEGfileIDs,TobiifileIDs);

    %% SYNCHRONIZE TIMETABLES IF NOT ALREADY DONE

    if ~isempty(NumberOfWorkers)    % if NumberOfWorkers is given use parfor

        % create parallel pool
        poolobj = parpool(NumberOfWorkers);

        parfor i = 1:length(fileIDs)

            % get input strings for ith raw EEG file for EEGRead
            [YEAR, MONTH, DAY, TRIAL, USER, ~] = decodeID(fileIDs(i));

            % get ID and pathID
            [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);

            % create directory for synchronized timetable
            file = strcat('objects/',pathID, '/_Synchronized/',...
                ID, '_Synchronized_EEGAccelTobiiTimetable.mat'); 

            % if synchronized timetable does not exist or overwrite is on 
            % make it
            if ~exist(file, 'file') || overwrite == 1
                
                try
                % synchronize timetables
                EEGTobiiSync(YEAR, MONTH, DAY, TRIAL, USER, EEG, Tobii)
                catch
                    disp('----error syncing----')
                end

                % print trial is complete
                disp(strcat(fileIDs(i), " is complete"));
                
                continue
            end

            % timetable already exists
            disp(strcat(fileIDs(i), " already exists"));
            
            

        end

        % delete parallel pool
        delete(poolobj)

    else    % if NumberOfWorkers is not given use for loop

        % iteratively read data files
        for i = 1:length(fileIDs)

            % get input strings for ith raw EEG file for EEGRead
            [YEAR, MONTH, DAY, TRIAL, USER, ~] = decodeID(fileIDs(i));

            % get ID and pathID
            [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, []);

            % create directory for synchronized timetable
            file = strcat('objects/',pathID, '/_Synchronized/',...
                ID, '_Synchronized_EEGAccelTobiiTimetable.mat'); 

            % if synchronized timetable does not exist or overwrite is on 
            % make timetable            
            if ~exist(file, 'file') || overwrite == 1
                % synchronize timetables
                EEGTobiiSync(YEAR, MONTH, DAY, TRIAL, USER, EEG, Tobii)

                % print trial is complete
                disp(strcat(fileIDs(i), " is complete"));
                
                continue
            end

            % timetable already exists
            disp(strcat(fileIDs(i), " already exists"));

        end

    end