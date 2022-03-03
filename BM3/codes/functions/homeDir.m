% FUNCTION TO CHANGE PATH TO HOME DIRECTORY FOR BM3 FILE STRUCTURE

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = homeDir()

%% change directory to BM3 home folder
str = pwd;  % get current path

% get folder names in current path
% windows case
if contains(computer, 'WIN')

    folderNames = split(str,'\'); 

% mac and linux case
else
    
    folderNames = split(str,'/'); 
end
    

% find place of BM3 in path
idx = length(folderNames) - find(folderNames=="BM3") - 1;

% find commas in string of current path
idcs = strfind(pwd,filesep);

if idx ~= -1
    % change directory to BM3
    eval(strcat("cd ", "'",(str(1:idcs(end-idx))), "'"))
end

% get folder names in current path
% windows case
if contains(computer, 'WIN')

    % add functions folder to path
    addpath('codes\functions\')
    % add functions folder to path
    addpath('backend\prettyVariableNames\')

% mac and linux case
else
    
    % add functions folder to path
    addpath('codes/functions/')
    % add functions folder to path
    addpath('backend/prettyVariableNames/') 
end
