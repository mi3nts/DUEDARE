% FUNCTION TO MAKE NEW DIRECTORY IN INPUT PATH IF IT DOES NOT ALREADY
% EXIST

% INPUT:
%     directory = STRING. PATH FROM SYSTEM HOME DIRECTORY

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = createDir(directory)

% check if proper path exists for saving plots
if ~exist(directory, 'dir')

    % if not make directory
    mkdir(directory)
end 