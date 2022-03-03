% FUNCTION TO READ MULTIPLE DATASETS FOR ANY INPUT READ FUNCTION SUCH AS
% EEGRead, TobiiRead, EQVRead. 

% INPUTS:
%     AnyReadFunctionName = STRING OF ANY READ FUNCTION
%         e.g. "EEGRead", "TobiiRead", "EQVRead"
%     YEAR = STRING
%     MONTH = STRING
%     DAY = STRING
%     USER = STRING
%     EEG = STRING. NUMBER OF THE EEG SYSTEM USED
%     TrialNumbers = ROW VECTOR OF INTEGERS CORRESPONDING TO TRIAL NUMBER


% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function[] = AnyReadMulti(AnyReadFunctionName, YEAR, MONTH, DAY, USER, ...
    DEVICE, TrialNumbers)

    % iteratively read data files
    for i=TrialNumbers

        % define trial name
        if i<=9
            TRIAL = strcat('T0', string(i));
        else
            TRIAL = strcat('T', string(i));
        end

        % read respective data file
        eval(strcat(AnyReadFunctionName, ...
            "('", YEAR, "','", MONTH, "','", DAY, "','", ...
            TRIAL, "','", USER, "','", DEVICE, "')"));
        
        % display which trial was read
        disp(strcat("---Trial ", string(i), " complete---"))

    end

