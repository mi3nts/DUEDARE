% FUNCTION TO GET CLASSES FROM A SOM FOR AN INPUT DATASET
 
% INPUTS:
%     Data - INPUT DATA WITH VARIABLES AS COLUMNS AND TIMESTEPS AS ROWS
%     i - NUMBER OF ROWS IN SOM
%     j - NUMBER OF COLUMNS IN SOM
% 
% OUTPUTS:
%     classes - ARRAY OF CLASS VALUES FOR EACH TIMESTEP
%     numClasses - TOTAL NUMBER OF UNIQUE CLASSES


% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [classes, numClasses] = getClassesSOM(Data, i, j)

% check Data for nans
nansData = isnan(Data);

% set nans to 0
Data(nansData) = 0;

% compute number of classes for SOM
numClasses = i*j;

% initialize SOM
net = selforgmap([i j]);
% train SOM  
net = train(net,Data');

% apply SOM to input data to get class labels
y = net(Data');
classes = vec2ind(y);