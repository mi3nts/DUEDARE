% FUNCTION TO READ EEG DATASETS USING EEGLAB FROM MUTLIPLE TRIALS. DATA IS 
% SAVED AS A TIMETABLE. THE TIMETABLE INCLUDES DATA FROM THE EEG ELECTRODES
% IN ADDITION TO DIFFERENCES IN SYMMETRIC NODES, AIM DATA, ACCELEROMETER 
% DATA, AND AUXILIARY DATA INCLUDING PACKET COUNT AND TRIGGER INFORMATION.

% INPUTS:
%     YEAR = STRING
%     MONTH = STRING
%     DAY = STRING
%     USER = STRING
%     EEG = STRING. NUMBER OF THE EEG SYSTEM USED
%     TrialNumbers = ROW VECTOR OF INTEGERS IN ASCENDING ORDER
%     NumberOfWorkers = INTEGER. NUMBER OF CORES TO USE. USE [] IF NOT 
%                       USING PARALLEL PROCESSING 

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function[] = EEGReadMulti(YEAR, MONTH, DAY, USER, EEG, ...
    TrialNumbers, NumberOfWorkers)

% NOTE: to use parfor, parallel processing toolbox must be installed and
% TrialNumbers must be a row vector with integer elements that are in
% ascending order
if sum(diff(TrialNumbers)==ones(1, length(TrialNumbers)-1))...
        == length(TrialNumbers)-1 ...
        && ~isempty(NumberOfWorkers)

    % create parallel pool
    poolobj = parpool(NumberOfWorkers);

    % read tobii data files using parfor
    parfor i=TrialNumbers
        
        % define trial name
        if i<=9
            TRIAL = char(strcat('T0', string(i)));
        else
            TRIAL = char(strcat('T', string(i)));
        end
        
        % read respective EEG data file
        EEGRead(YEAR, MONTH, DAY, TRIAL, USER, EEG)
        
        % display which trial was read
        disp(strcat("---Trial ", string(i), " complete---"))

    end
  
    % delete parallel pool
    delete(poolobj)
    
else

    % iteratively read data files
    for i=TrialNumbers

        % define trial name
        if i<=9
            TRIAL = strcat('T0', string(i));
        else
            TRIAL = strcat('T', string(i));
        end

        % read respective EEG data file
        EEGRead(YEAR, MONTH, DAY, TRIAL, USER, EEG)

        % display which trial was read
        disp(strcat("---Trial ", string(i), " complete---"))

    end

end