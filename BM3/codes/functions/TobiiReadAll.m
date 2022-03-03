% FUNCTION TO READ ALL RAW TOBII DATA FILES IN BM3 FOR A PARTICULAR TOBII
% DEVICE

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function [] = TobiiReadAll(Tobii, NumberOfWorkers)

    %% GET FILE IDs

    fileIDs = findAllRawTobiiFiles(Tobii);

    %% READ EEG FILES IN PARALLEL


    if ~isempty(NumberOfWorkers)

        % create parallel pool
        poolobj = parpool(NumberOfWorkers);

        parfor i = 1:length(fileIDs)

            % get input strings for ith raw EEG file for EEGRead
            [YEAR, MONTH, DAY, TRIAL, USER, Tobii] = decodeID(fileIDs(i));

            % read raw EEG data
            TobiiRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii);

            % print trial is complete
            disp(strcat(fileIDs(i), " is complete"));

        end

        % delete parallel pool
        delete(poolobj)

    else

        % iteratively read data files
        for i = 1:length(fileIDs)

            % get input strings for ith raw EEG file for EEGRead
            [YEAR, MONTH, DAY, TRIAL, USER, Tobii] = decodeID(fileIDs(i));

            % read raw EEG data
            TobiiRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii);

            % print trial is complete
            disp(strcat(fileIDs(i), " is complete"));

        end

    end