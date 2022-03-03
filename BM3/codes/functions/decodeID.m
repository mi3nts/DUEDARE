% FUNCTION TO CONVERT ID TO YEAR, MONTH, DAY, TRIAL, USER, DEVICE

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

% ID = '2019_12_5_T01_U010_Tobii01';

function [YEAR, MONTH, DAY, TRIAL, USER, DEVICE] = decodeID(ID)

% split string into cellarray
temp = split(ID,'_');

% assign output values
YEAR = temp{1};
MONTH = temp{2};
DAY = temp{3};
TRIAL = temp{4};
USER = temp{5};
try
    DEVICE = temp{6};
catch
    DEVICE = [];
end
