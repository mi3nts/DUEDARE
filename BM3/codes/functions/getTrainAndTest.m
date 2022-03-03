% FUNCTION TO SETUP DATA TRAINING AND TESTING DATA TABLES FOR MACHINE 
% LEARNING SUPERVISED REGRESSION

% INPUTS:
%     inTimetable = INPUT TIMETABLE OF BIOMETRIC DATA WHERE TARGET VARIABLE
%     IS THE LAST COLUMN OF TABLE
%     testSize = NUMBER BETWEEN 0 AND 1. PROPORTION OF DATA THAT WILL BE 
%     USED IN TESTING

% OUTPUTS:
%     Train = TABLE OF TRAINING DATASET
%     InTrain = TABLE OF PREDICTOR VALUES IN TRANING DATASET
%     OutTrain = TABLE OF TARGET VALUES IN TRAINING DATASET
%     Test = TABLE OF TESTING DATASET
%     InTest = TABLE OF PREDICTOR VALUES IN TESTING DATASET
%     OutTest = TABLE OF TARGET VALUES IN TESTING

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [Train, InTrain, OutTrain,Test, InTest, OutTest] = ...
    getTrainAndTest(inTimetable, testSize)

%% SETUP DATA TABLE

% convert timetable to table
Data = timetable2table(inTimetable);
% convert table to array with datetime column
Data = table2array(Data(:,2:end));
% find NaN elements
nansData = isnan(Data);
% replace NaNs with 0 (just for classification purposes)
Data(nansData) = 0;

% caste array as a table
Table = array2table(Data);
% relabel the variable names in table
Table.Properties.VariableNames = ...
    inTimetable.Properties.VariableNames;

%% SETUP TRAINING AND TESTING DATA SETS

% create a partition of training and testing data
c = cvpartition(height(Table),'HoldOut', testSize);

% set up training data set
Train = Table(c.training,:);
InTrain = Train(:,1:end-1);
OutTrain = Train(:,end);

% set up testing data set
Test = Table(c.test,:);
InTest = Test(:,1:end-1);
OutTest = Test(:,end);