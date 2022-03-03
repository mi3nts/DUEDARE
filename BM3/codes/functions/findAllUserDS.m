% FUNCTION TO RETURN IDs OF ALL DATA SHEETS IN BM3 OF A PARTICULAR USER

% INPUT:
%     USER = STRING. USER ID E.G. 'U00T'
% OUTPUT:
%     userFileIDs = STRING ARRAY OF FILE IDs

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function userFileIDs = findAllUserDS(USER)

    % get file IDs of all data sheets
    fileIDs = findAllDS();

    % get boolean array corresponding to which elements are for deisred user
    iUser = contains(fileIDs, USER);

    % return fileIDs of desired user
    userFileIDs = fileIDs(iUser);