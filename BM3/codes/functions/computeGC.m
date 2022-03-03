% FUNCTION TO COMPUTE GRANGER CAUSALITY TERM BETWEEN 2 VECTORS

% INPUTS
%     Y = DOUBLE VECTOR. RESPONSE OR OUTCOME
%     X = DOUBLE VECTOR. PREDICTOR OR SOURCE
%     numlags = number of lags to include

% OUTPUT
%     gc = GRANGER CAUSALITY TERM FROM SOURCE TO OUTCOME

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function gc = computeGC(Y, X, numlags)

    % initialize vector autoregressive model with one response variable
    Mdl = varm(1,numlags);

    % generate data set with lags
    predictorData = [];
    for i=1:numlags

      predictorData = [predictorData lagmatrix(Y,i) lagmatrix(X,i)];

    end

    % 1. estimate autoregressive model with just electrode1
    EstMdl1 = estimate(Mdl, Y);
    % 2. estimate autoregressive model with electrode1 and electrode2
    EstMdl2 = estimate(Mdl, Y, ...
        'X', predictorData);

    % get variance of innovation term in each autoregressive model
    e1 = EstMdl1.Covariance;
    e2 = EstMdl2.Covariance;

    % compute granger casaulity term from electrode1 to electrode2
    gc = log(e1/e2);
end