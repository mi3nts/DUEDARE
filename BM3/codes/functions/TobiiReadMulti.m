% FUNCTION TO READ MULTIPLE DATASETS FROM LIVEDATA.JSON FILES FOR TOBII PRO
% GLASSES 2

% INPUTS:
%     YEAR = STRING
%     MONTH = STRING
%     DAY = STRING
%     USER = STRING
%     Tobii = STRING. NUMBER OF THE TOBII SYSTEM USED
%     TrialNumbers = ROW VECTOR OF INTEGERS IN ASCENDING ORDER
%     NumberOfWorkers = INTEGER. NUMBER OF CORES TO USE. USE [] IF NOT 
%                       USING PARALLEL PROCESSING 

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function[] = TobiiReadMulti(YEAR, MONTH, DAY, USER, Tobii,...
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
        
        % read respective tobii data file
        TobiiRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii)
        
        % display which trial was read
        disp(strcat("---Trial ", string(i), " complete---"))

    end
  
    % delete parallel pool
    delete(poolobj)
    
else

    % iteratively read data files
    for i=TrialNumbers

        % define trial name
        if i<9
            TRIAL = strcat('T0', string(i));
        else
            TRIAL = strcat('T', string(i));
        end

        % read respective tobii data file
        TobiiRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii)

        % display which trial was read
        disp(strcat("Trial ", string(i), " complete"))

    end

end