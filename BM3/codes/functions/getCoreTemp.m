% FUNCTION TO COMPUTE CORE TEMPERATURE FROM HEART RATE MEASURE AND CREATE
% NEW TIMETABLE WITH CORE TERMPERATURE AS AN ADDED VARIABLE

% INPUTS:
%     inTimetable = TIMETABLE WITH HR DATA
%     hrVarName = STRING OR CHAR. VARIABLE NAME FOR HR DATA

% OUTPUT:
%     outTimetable = TIMETABLE WITH ORIGINAL DATA PLUS CORE TEMPERATURE

% CORE TEMPERATURE FROM HR DATA USING MODEL IN:
% Buller MJ, Tharion WJ, Cheuvront SN, et al. Estimation of human core 
% temperature from sequential heart rate observations. Physiol Meas. 2013;
% 34(7):781-798. doi:10.1088/0967-3334/34/7/781

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function outTimetable = getCoreTemp(inTimetable, hrVarName)

    %% GET HR VAR INDEX
    
    hrIndex = strcmp(string(inTimetable.Properties.VariableNames), hrVarName);

    %% DEFINE MODEL PARAMETERS

    % define quadratic model parameters
    a = -4.5714;
    b = 384.4286;
    c = -7887.1;

    % define parameters for inverted quadratic model
    alpha = a;
    beta = b/(2*a);
    gamma = c - (b^2/(4*a));
    
    %% COMPUTE CORE TEMPERATURE FOR HR VARIABLE

    % express core temperature in terms of HR according to inverted version of
    % model in (Buller 2013)
    CT = (-((inTimetable(:,hrIndex).Variables - gamma)/alpha).^(1/2)) - beta;
    
    %% DEFINE CORE TEMPERATURE VARIABLE NAME BASED HR VARIABLE NAME
    
    ctVarName = strcat(strrep(hrVarName, 'HR', 'CT'), '_buller');

    %% ADD CORE TEMPERTATURE TO EQVTIMETABLE

    outTimetable = addvars(inTimetable, CT, ...
        'After', hrVarName, ...
        'NewVariableNames', ctVarName);