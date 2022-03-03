% FUNCTION TO COMPUTE GRANGER CAUSALITY TERMS BETWEEN 2 VECTORS FOR SOME
% INPUT SLIDING WINDOW LENGTH

% INPUTS
%     Y = DOUBLE VECTOR. RESPONSE OR OUTCOME
%     X = DOUBLE VECTOR. PREDICTOR OR SOURCE
%     numlags = number of lags to include
%     window = window length. NOTE: must be even number

% OUTPUT
%     gc = GRANGER CAUSALITY TERM FROM SOURCE TO OUTCOME

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function gcVector = computeSlidingGC(Y, X, numlags, window)

    % define half window length parameter
    halfWin = window/2;

    % initialize ganger causality term vector
    gcVector = NaN(length(Y),1);

    % turn off warnings
    warning('off')

    % iteraivetly compute ganger causality terms
    for i=halfWin:length(Y)-halfWin

        % compute ith gc term    
        gcVector(i) = computeGC(Y(i-halfWin+1:i+halfWin), ...
            X(i-halfWin+1:i+halfWin), ...
            numlags);

    end
    % turn on warnings
    warning('on')