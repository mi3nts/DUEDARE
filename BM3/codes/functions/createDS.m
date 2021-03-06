% FUNCTION TO CREATE NEW DATA SHEET STUCTURE FROM ID

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function DS = createDS(ID)

    % get info from input ID
    [YEAR, MONTH, DAY, TRIAL, USER, DEVICE] = decodeID(ID);

    % define fields and values
    DS = struct;
    DS.ID = strcat(YEAR, '_', MONTH, '_', DAY, '_', TRIAL, '_',USER);
    DS.YEAR = YEAR;
    DS.MONTH = MONTH;
    DS.DAY = DAY;
    DS.TRIAL = TRIAL;
    DS.USER = USER;

    DS.AGE = '';
    DS.WEIGHT = '';
    DS.HEIGHT = '';
    DS.HANDEDNESS = '';

    DS.CURRENT_MEDICATION = '';
    DS.TIME_OF_MOST_RECENT_MEAL = '';
    DS.MOST_RECENT_SLEEP_DURATION = '';
    DS.SKULL_DEFECTS = '';
    DS.RELEVANT_MEDICAL_HISTORY = '';

    DS.DEVICES = [DEVICE];

    DS.TRIAL_TYPE = '';
    DS.TRIAL_DESCRIPTION = '';
    DS.TRIAL_NOTES = '';

    DS.TECHNOLOGIST_NAME = '';