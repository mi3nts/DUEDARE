% FUNCTION TO CREATE ID AND PATHIDFROM YEAR MONTH DAY TRIAL USER AND DEVICE 
% ID. NOTES, INPUTS MUST BE STRINGS.

% INPUTS:
%     YEAR = STRING. EX: '2019'
%     MONTH = STRING. EX: '12'
%     DAY = STRING. EX: '10'
%     TRIAL = STRING. EX: 'T01'
%     USER = STRING. EX: 'U000'
%     DEVICE = STRING. EX: 'EEG01'. NOTE: IF DEVICE IS NOT DESIRED IN ID
%     OR pathID INPUT [].

% THE UNIVERSITY OF TEXAS AT DALLAS
% CODE AUTHORED BY: SHAWHIN TALEBI
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [ID, pathID] = makeIDs(YEAR, MONTH, DAY, TRIAL, USER, DEVICE)

% windows case
if contains(computer, 'WIN')
    seperator = '\';

% mac and linux case
else
    seperator = '/';
end

% create ID
if ~isempty(DEVICE)
    ID = strcat(YEAR, '_', MONTH, '_',DAY, '_',TRIAL, '_',USER, '_',...
        DEVICE);
    
else
    ID = strcat(YEAR, '_', MONTH, '_',DAY, '_',TRIAL, '_',USER);
   
end

% create pathID
pathID = strrep(ID,'_',seperator);

% synchronized case
if strcmp(DEVICE,'Synchronized')
    pathID = strrep(pathID, strcat(seperator,'S'), strcat(seperator,'_S'));
end
