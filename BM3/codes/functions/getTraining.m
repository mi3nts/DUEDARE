% FUNCTION TO CREATE TRAINING AND TESTING SETS 

% INPUTS:
%     X = ARRAY OF PREDICTORS SUCH THAT EACH VARIABLE CORRESPONDS TO A
%     COLUMN
%     Y = SINGLE COLUMN ARRAY OF TARGET VARIABLE.
%     trainPercent = PERCENTAGE OF RECORDS TO INCLUDE IN TRAINING. NUMBER 
%     BETWEEN 0 AND 1.

% OUTPUTS:
%     XTrain = ARRAY OF TRAINING PREDICTORS
%     YTrain = ARRAY OF TRAINING TARGETS
%     XTest = ARRAY OF TESTING PREDICTORS
%     YTest = ARRAY OF TESTING TARGETS

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [XTrain, YTrain, XTest, YTest] = getTraining(X, Y, trainPercent)

    % get testing percent
    testPercent = 1-trainPercent;

    % define training and testing indicies
    [trainInd, ~, testInd] = ...
        dividerand(length(Y),trainPercent,0,testPercent);

    % define training set
    XTrain = X(trainInd, :);
    YTrain = Y(trainInd);

    % define testing set
    XTest = X(testInd, :);
    YTest = Y(testInd);