% FUNCTION TO PROCESS ALL DATA GIVEN A LIST OF IDS

% INPUTS:
%     IDs = array of strings. each element is an dataset ID with 4 trials
% OUTPUTS:
%     n/a - all processing is done and files are saved to proper
%     directories

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = processIDs(IDs)

    % save current directory name
    curDir = pwd;

    % start timer
    tStart = tic;
    diary on
    disp(strcat("~~~~~~~~~~~~~~~ ", ...
        string(datetime(now,'ConvertFrom','datenum')), " ~~~~~~~~~~~~~~~"));

    for i = 1:length(IDs)

        % disp current ID
        tStartID = tic;
        disp(strcat("--- Starting processing for ", IDs(i), " ---"))

        % decode ID
        [YEAR, MONTH, DAY, ~, USER, EEG] = decodeID(IDs(i));
        % define Tobii ID
        Tobii = strcat('Tobii', EEG(end-1:end));

        % read eeg
        parfor t = 1:4
            % define trial and file name
            TRIAL = strcat('T0', string(t));
            fileName = 'EEGAccelTimetable.mat';

            % define path name
            [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, EEG); 
            pathName = strcat(curDir, "/objects/", pathID, "/", ID, "_", fileName);

            % if file does not exist make it
            if ~exist(pathName, 'file')
                try
                    EEGRead(YEAR, MONTH, DAY, TRIAL, USER, EEG)
                catch
                    warning(strcat("unable to read eeg for ", ID))
                end
            else
                disp(strcat(fileName, " already exists for ", ID))
            end
        end

        % read tobii
        parfor t = 1:4
            % define trial and file name
            TRIAL = strcat('T0', string(t));
            fileName = 'TobiiTimetable.mat';

            % define path name
            [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, Tobii); 
            pathName = strcat(curDir, "/objects/", pathID, "/", ID, "_", fileName);

            % if file does not exist make it
            if ~exist(pathName, 'file')
                try
                    TobiiRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii)
                catch
                    warning(strcat("unable to read tobii for ", ID))
                end
            else
                disp(strcat(fileName, " already exists for ", ID))
            end
        end

        % sync eeg and tobii
        parfor t = 1:4
            % define trial and file name
            TRIAL = strcat('T0', string(t));
            fileName = 'EEGAccelTobiiTimetable.mat';

            % define path name
            [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, 'Synchronized'); 
            pathName = strcat(curDir, "/objects/", pathID, "/", ID, "_", fileName);

            % if file does not exist make it
            if ~exist(pathName, 'file')

                try
                    EEGTobiiMarkerSync(YEAR, MONTH, DAY, TRIAL, USER, EEG, Tobii)
                catch
                    warning(strcat("unable to synchronize data for ", ID))
                end
            else
                disp(strcat(fileName, " already exists for ", ID))
            end
        end


        % compute power spectra of eeg
        for t = 1:4
            % define trial and file name
            TRIAL = strcat('T0', string(t));
            fileName = 'EEGps.mat';

            % define path name
            [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, EEG); 
            pathName = strcat(curDir, "/objects/", pathID, "/", ID, "_", fileName);

            % if file does not exist make it
            if ~exist(pathName, 'file')
                try
                    EEGPowerSpectra(YEAR, MONTH, DAY, TRIAL, USER, EEG, 20)
                catch
                    warning(strcat("unable to get power spectra for ", ID))
                end
            else
                disp(strcat(fileName, " already exists for ", ID))
            end
        end

        % print elapsed time for current ID
        disp(strcat("--- Elapsed time to process ", IDs(i), ": ", ...
            string(toc(tStartID)), " seconds ---"));

    end

    % end timer and print time
    disp(strcat("Total elapsed time: ", string(toc(tStart)), ...
        " seconds to process ", string(4*length(IDs)), " datasets"));

    diary off