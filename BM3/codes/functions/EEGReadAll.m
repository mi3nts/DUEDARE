% FUNCTION TO READ ALL RAW EEG DATA FILES IN BM3 FOR A PARTICULAR EEG
% DEVICE

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function [] = EEGReadAll(EEG, NumberOfWorkers)

    %% GET FILE IDs

    fileIDs = findAllRawEEGFiles(EEG);

    %% READ EEG FILES IN PARALLEL


    if ~isempty(NumberOfWorkers)

        % create parallel pool
        poolobj = parpool(NumberOfWorkers);

        parfor i = 1:length(fileIDs)

            % get input strings for ith raw EEG file for EEGRead
            [YEAR, MONTH, DAY, TRIAL, USER, EEG] = decodeID(fileIDs(i));

            % read raw EEG data
            EEGRead(YEAR, MONTH, DAY, TRIAL, USER, EEG);

            % print trial is complete
            disp(strcat(fileIDs(i), " is complete"));

        end

        % delete parallel pool
        delete(poolobj)

    else

        % iteratively read data files
        for i = 1:length(fileIDs)

            % get input strings for ith raw EEG file for EEGRead
            [YEAR, MONTH, DAY, TRIAL, USER, EEG] = decodeID(fileIDs(i));
            
%             if strcmp(MONTH, '07')
%                 continue
%             end

            % read raw EEG data
            EEGRead(YEAR, MONTH, DAY, TRIAL, USER, EEG);

            % print trial is complete
            disp(strcat(fileIDs(i), " is complete"));

        end

    end