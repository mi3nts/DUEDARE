% FUNCTION TO SYNCHRONIZE MULTIPLE TRIALS OF EEG AND TOBII TIMETABLES USING
% MARKER DATA. FUNCTION CREATES AND SAVES SYNCHRONIZED TIMETABLE TO 
% APPROPRIATE DIRECTORY.

% INPUTS
%     YEAR = STRING. EX: '2019'
%     MONTH = STRING. EX: '12'
%     DAY = STRING. EX: '5'
%     USER = STRING. EX: 'U010'
%     EEG =  STRING. EX: 'EEG01'
%     Tobii = STRING. EX: 'Tobii01'
%     TrialNumbers = ROW VECTOR OF INTEGERS IN ASCENDING ORDER
%     NumberOfWorkers = INTEGER. NUMBER OF CORES TO USE. USE [] IF NOT 
%                       USING PARALLEL PROCESSING 

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = EEGTobiiMarkerSyncMulti(YEAR, MONTH, DAY, USER, EEG, Tobii,...
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
            TRIAL = strcat('T0', string(i));
        else
            TRIAL = strcat('T', string(i));
        end
        
        % synchronize respective trial data
        EEGTobiiMarkerSync(YEAR, MONTH, DAY, TRIAL, USER, EEG, Tobii)
        
        % display which trial was read
        disp(strcat("Trial ", string(i), " complete"))
        fprintf('\n')

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
        
        % synchronize respective trial data
        EEGTobiiMarkerSync(YEAR, MONTH, DAY, TRIAL, USER, EEG, Tobii)

        % display which trial was read
        disp(strcat("Trial ", string(i), " complete"))
        fprintf('\n')

    end
  
end