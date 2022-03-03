% FUNCTION TO GET CURRENT FOLDER NAME

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function foldername = getCurrentFoldername()

    % get current path folders as a cell array
    path = split(pwd,'/');

    % get current foldername as a string
    foldername = string(path(end));
end