% FUNCTION TO GENERATE EEG CLASSIFICATION MODEL FOR A GIVEN NUMBER OF
% COGNITIVE/PHYSICAL TASKS. INPUTS ARE OUTLINED BELOW. OUTPUT IS A SINGLE
% CLASSIFICATION MODEL THAT USES A ENSEMBLE APPROACH AND HYPERPARAMETER
% OPTIMIZATION.

% PARALLEL PROCESSING TOOLBOX IS USED IN THIS FUNCTION

% EXAMPLE INPUT VARIABLES:

    % YEAR = '2019';    (STRING)
    % MONTH = '10';     (STRING)
    % DAY = '24';       (STRING)
    % USER = 'U001';    (STRING)
    % EEG = 'EEG01';    (STRING)
    % 
    % firstClassNum = 1;    (INTEGER)
    % lastClassNum = 4;     (INTEGER)
    % 
    % classLabels = {'EyesClosed' 'EyesOpen' 'Reading' 'Arithmetic'}; (CELL ARRAY)
    %
    % numWorkers = 24;  (INTEGER)

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function Mdl = EEGTaskClassification(YEAR, MONTH,DAY, USER, EEG,...
    firstClassNum,lastClassNum,classLabels, numWorkers)
    %% IMPORT DATA OBJECTS
    
    % define number of classes
    numClasses = (lastClassNum-firstClassNum) + 1;

    % change to home directory
    homeDir

    % use long format
    format long

    % use painters image renderer
    set(0, 'DefaultFigureRenderer', 'painters');

    % define ID and pathIDs for 4 trials
    for i = firstClassNum:lastClassNum
        % define ith ID string
        eval(strcat("ID", string(i), " = strcat(YEAR, '_', MONTH, '_',DAY, '_','T0",...
            string(i), "', '_',USER, '_', EEG);"));
        % define ith pathID string
        eval(strcat("pathID", string(i), " = strrep(ID", string(i),...
            ",'_','/');"));
        % load ith timetable
        eval(strcat("load(strcat('objects/', pathID",string(i),...
            ",'/', ID",string(i),",'_EEGAccelTimetable'));"));
        % rename ith timetable
        eval(strcat("EEGAccelTimetable_T0",string(i), " = EEGAccelTimetable;"));
    end

    % clear extraneous timetable
    clear EEGAccelTimetable;
    %% REMOVE RECORDS THAT OCCUR OUTSIDE THE TRIGGER POINTS

    for i = firstClassNum:lastClassNum
        % find nonzero trigger elements
        eval(strcat("iwantTrig = find(EEGAccelTimetable_T0",string(i),...
            ".TRIGGER ~= 0);"));

        % find where difference of nonzero trigger elements is greater than 1
        iwantIntervalStart = find(diff(iwantTrig) > 1);

        % compute the interval of cognitive state
        Interval = iwantTrig(iwantIntervalStart):iwantTrig(iwantIntervalStart+1);

        % remove records outside trigger points
        eval(strcat("EEGAccelTimetable_T0", string(i),...
            " = EEGAccelTimetable_T0", string(i),"(Interval, 1:end-2);"));
    end

    % clear interval object
    clear Interval
    %% RESIZE DATA TABLES TO HAVE SAME NUMBER OF RECORDS

    % initialize array to hold heights of timetables
    hts = zeros(numClasses, 1);

    % define a delta relating the sequences firstClassNum:lastClassNum and 
    % 1:numClasses
    delta = firstClassNum - 1;

    % get heights of each timetable
    for i = firstClassNum:lastClassNum

       eval(strcat("hts(i-delta) = height(EEGAccelTimetable_T0",string(i),");"));

    end

    % define number of records for each class
    numRecords = min(hts);

    % keep only first numRecords of each timetable 
    for i = firstClassNum:lastClassNum

        eval(strcat("EEGAccelTimetable_T0",string(i),...
            " = EEGAccelTimetable_T0", string(i),"(1:numRecords,:);"));

    end
    %% MERGE DATA TABLES

    % intialize data table
    Table = table();
    for i = firstClassNum:lastClassNum

        % convert ith timetable to table
        eval(strcat("Table",string(i),...
            " = timetable2table(EEGAccelTimetable_T0", string(i),");"));
        % remove timestamps from table
        eval(strcat("Table",string(i)," = Table", string(i),"(:,2:end);"));
        % concatenate ith table to end of Table
        eval(strcat("Table = [Table; Table", string(i),"];"));

        % clear ith table and timetable objects
        eval(strcat("clear EEGAccelTimetable_T0", string(i),...
            " Table", string(i)));
    end
    %% LABEL EACH CLASS

    % create categorical array with class labels
    class = discretize((1:numClasses*numRecords)', numClasses,...
        'categorical',classLabels);
    % add class labels to data table
    Table = addvars(Table, class);

    %% SETUP TRAINING AND TESTING DATA SETS

    % create a partition of training and testing data
    c = cvpartition(height(Table),'HoldOut',0.1);

    % set up training data set
    itemp = (1:height(Table))';
    train_rows = itemp.*(c.training);
    train_rows = train_rows(train_rows~=0);

    Train = Table(train_rows,:);
    InTrain = Train(:,1:end-1);
    OutTrain = Train(:,end);

    % set up testing data set
    test_rows = itemp.*(c.test);
    test_rows = test_rows(test_rows~=0);

    Test = Table(test_rows,:);
    InTest = Test(:,1:end-1);
    OutTest = Test(:,end);
    %% PERFORM SUPERVISED CLASSIFICATION

    % set up parallel processing
    mypool = parpool(numWorkers);

    % train model
    Mdl = fitcensemble(Train, 'class',...
        'OptimizeHyperparameters','all',...
        'HyperparameterOptimizationOptions',...
        struct(...
        'AcquisitionFunctionName','expected-improvement-plus',...
        'MaxObjectiveEvaluations',30,...
        'UseParallel',true)...
        );

    % delete parallel pool
    delete(mypool);
end