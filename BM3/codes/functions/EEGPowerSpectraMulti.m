% FUNCTION TO COMPUTE WELCH POWER SPECTRUM WITH OVERLAPPING HAMMING WINDOW 
% OF 64-ELECTRODE EEG DATA AT EACH TIMESTEP AND SAVE TO FILE FOR MULTIPLE
% TRIALS

% INPUTS:
%     YEAR = STRING
%     MONTH = STRING
%     DAY = STRING
%     USER = STRING
%     EEG = STRING. NUMBER OF THE EEG SYSTEM USED
%     TrialNumbers = ROW VECTOR OF INTEGERS IN ASCENDING ORDER
%     NumberOfWorkers = INTEGER. NUMBER OF CORES TO USE FOR MULTIPLE TRIAL.
%                       USE [] IF NOT USING PARALLEL PROCESSING FOR.
%                       
%     NumberOfWorkersForPS = INTEGER. NUMBER OF CORES TO USE POWER SPECTR.
%                            CALCULATIONS. USE [] IF NOT USING PARALLEL 
%                            PROCESSING 
%     NOTE: ENSURE AT LEAST ONE OF THE WORKER NUMBER INPUTS IS EMPTY!!

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function[] = EEGPowerSpectraMulti(YEAR, MONTH, DAY, USER, EEG, ...
    TrialNumbers, NumberOfWorkers, NumberOfWorkersForPS)

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
        if i<9
            TRIAL = char(strcat('T0', string(i)));
        else
            TRIAL = char(strcat('T', string(i)));
        end
        
        % compute and save power spectra for respective trial
        EEGPowerSpectra(YEAR, MONTH, DAY, TRIAL, USER, EEG,...
            NumberOfWorkersForPS)
        
        % display which trial was read
        disp(strcat("Trial ", string(i), " complete"))

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

        % compute and save power spectra for respective trial
        EEGPowerSpectra(YEAR, MONTH, DAY, TRIAL, USER, EEG,...
            NumberOfWorkersForPS)

        % display which trial was read
        disp(strcat("Trial ", string(i), " complete"))

    end

end