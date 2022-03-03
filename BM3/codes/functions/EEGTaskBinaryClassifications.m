% FUNCTION TO GENERATE EEG BINARY CLASSIFICATION MODELS FOR A GIVEN NUMBER
% OF COGNITIVE/PHYSICAL TASKS. INPUTS ARE OUTLINED BELOW. OUTPUT IS A SINGLE
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
    % classLabels = ["EyesClosed" "EyesOpen" "Reading" "Arithmetic"];  (STRING ARRAY) 
    % numWorkers = 24;  (INTEGER)

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function Models = EEGTaskBinaryClassifications(YEAR, MONTH,DAY, USER, EEG,...
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
    %% LABEL EACH CLASS

    % convert labels to categorical data types
    classCats = categorical(classLabels);

    % label classes for each of 4 timetables
    for i = firstClassNum:lastClassNum
        % create temperary categorical array (class) with class categories
        eval(strcat("class(1:height(EEGAccelTimetable_T0", string(i),...
            "),1) = classCats(",string(i),");"));
        % label ith timetable with proper class name
        eval(strcat("EEGAccelTimetable_T0", string(i),...
            " = addvars(EEGAccelTimetable_T0",string(i),", class);"));
        clear class
    end
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
    %% ADD FALSE CLASSES TO EACH DATA TIMETABLE

    % define sample size to randomly sample Timetables 
    sampleSize = round(numRecords/(numClasses-1));

    % define array of randomly permuted indicies
    randi = randperm(numRecords);

    % take first n (= sampleSize) elements from array of randomly permuted indicies
    randi = randi(1:sampleSize)';

    % define timetables consisting of n (= sampleSize) random rows from each timetable
    for i=firstClassNum:lastClassNum

        eval(strcat("randTimetable",string(i)," = EEGAccelTimetable_T0",...
            string(i),"(randi,:);"));

    end

    % define not class labels
    notClassLabels = strcat('Not',classLabels);
    % convert not labels to categorical data types
    notClassCats = categorical(notClassLabels);

    % append randTimetables to all timetables where i ~= j
    for i=firstClassNum:lastClassNum
        for j = firstClassNum:lastClassNum
            if i==j
                continue
            end
            % change class category for jth randTimetable to the corresponding
            % NOT category (i.e. the ith NOT category)
            eval(strcat("randTimetable", string(j),...
                ".class(1:end) = notClassCats(",string(i),");"));

            % append jth randTimetable to ith EEGAccelTimetable
            eval(strcat("EEGAccelTimetable_T0", string(i),...
                " = [EEGAccelTimetable_T0", string(i),...
                "; randTimetable", string(j),"];"));

        end
    end
    %% SETUP TRAINING AND TESTING DATA SETS
    for i=firstClassNum:lastClassNum

        % convert ith timetable to ith table
        eval(strcat("Table", string(i),...
            " = timetable2table(EEGAccelTimetable_T0", string(i),");"));

        % create a partition of training and testing data from ith table
        eval(strcat("c = cvpartition(height(Table", string(i),...
            "),'HoldOut',0.1);"));

        % set up ith training data set (exclude datetime variable)
        eval(strcat("Train", string(i)," = Table", string(i),"(c.training,2:end);"));
        eval(strcat("InTrain", string(i)," = Train", string(i), "(:,1:end-1);"));
        eval(strcat("OutTrain", string(i)," = Train", string(i),"(:,end);"));

        % set up ith testing data set (exclude datetime variable)
        eval(strcat("Test", string(i)," = Table", string(i),"(c.test,2:end);"));
        eval(strcat("InTest", string(i)," = Test", string(i), "(:,1:end-1);"));
        eval(strcat("OutTest", string(i)," = Test", string(i),"(:,end);"));

    end
    %% PERFORM SUPERVISED CLASSIFICATION

    % set up parallel processing
    mypool = parpool(numWorkers);

    for i=firstClassNum:lastClassNum

        % train ith model
        eval(strcat("Mdl", string(i)," = fitcensemble(Train", string(i),", 'class',",...
            "'OptimizeHyperparameters','all',",...
            "'HyperparameterOptimizationOptions',",...
            "struct(",...
            "'AcquisitionFunctionName','expected-improvement-plus',",...
            "'MaxObjectiveEvaluations',30,",...
            "'UseParallel',true)",...
            ");"));

    end

    % delete parallel pool
    delete(mypool);

    %% CREATE OUTPUT STRUCTURE

    for i=firstClassNum:lastClassNum 
        eval(strcat("Models.Mdl", string(i)," = Mdl", string(i),";"));
    end
end