% CODE TO WRITE BASIC INFORMATION TO ALL DATA SHEETS OF A PARTICUALAR USER
% 
% INPUTS
%     USER = CHARACTER ARRAY. USER ID. EX: 'U00T';
%     AGE = CHARACTER ARRAY. USER AGE. EX: '24';
%     WEIGHT = CHARACTER ARRAY. USER WEIGHT. EX: '160';
%     HEIGHT = CHARACTER ARRAY. USER HEIGHT. EX: '5ft 7in';
%     HANDEDNESS = CHARACTER ARRAY. USER HANDEDNESS. EX: 'Right';
%     CURRENT_MEDICATION = CHARACTER ARRAY. USER MEDICATION. EX: '';
%     SKULL_DEFECTS = CHARACTER ARRAY. USER SKULL DEFECTS. EX: 'None';
%     RELEVANT_MEDICAL_HISTORY = CHARACTER MEDICAL HISTORY. USER ID. EX: '';
%     TECHNOLOGIST_NAME = CHARACTER ARRAY. TECHNOLOGIST'S NAME. EX: 'SHAWHIN TALEBI';


% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = writeAllUserDS(USER, AGE, WEIGHT, HEIGHT, HANDEDNESS, ...
    CURRENT_MEDICATION, SKULL_DEFECTS, RELEVANT_MEDICAL_HISTORY, ...
    TECHNOLOGIST_NAME)

    % get all file IDs corresponding to data sheets for specified user
    userFileIDs = findAllUserDS(USER);

    % windows case
    if contains(computer, 'WIN')
        seperator = '\';
    % mac and linux case
    else
        seperator = '/';
    end

    for FileID = userFileIDs
        % decode ID
        [YEAR, MONTH, DAY, TRIAL, USER, ~] = decodeID(FileID);

        % get path to data sheet
        filePath = strcat('raw', seperator, ...
            YEAR, seperator, ...
            MONTH, seperator, ...
            DAY, seperator, ...
            TRIAL, seperator, ...
            USER, seperator, ...
            FileID, '_dataSheet.txt');

        % read in data sheet for fileID
        DS = readDS(filePath);

        % edit input attributes
        DS.AGE = AGE;
        DS.WEIGHT = WEIGHT;
        DS.HEIGHT = HEIGHT;
        DS.HANDEDNESS = HANDEDNESS;
        DS.CURRENT_MEDICATION = CURRENT_MEDICATION;
        DS.SKULL_DEFECTS = SKULL_DEFECTS;
        DS.RELEVANT_MEDICAL_HISTORY = RELEVANT_MEDICAL_HISTORY;
        DS.TECHNOLOGIST_NAME = TECHNOLOGIST_NAME;

        % write updated data sheet to file
        writeDS(DS)

    end