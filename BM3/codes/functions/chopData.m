% FUNCTION TO REMOVE DATA OUTSIDE X NUMBER OF STANDARD DEVIATIONS FOR 
% VISUALIZATION PURPOSES

% INPUTS:
%     InputArray - 1D INPUT ARRAY OF NUMBERS
%     X - NUMBER OF STANDARD DEVIATIONS DESIRED FOR CHOPPING

% OUTPUT:
%     choppedArray - 1D ARRAY WHERE VALUES OUTSIDE SPECIFIED NUMBER OF
%         STANDARD DEVIATIONS ARE NANs

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function choppedArray = chopData(InputArray, X)

meanOfInput  = nanmean(InputArray);
sd = nanstd(InputArray);

% find records with in 2 standard deviations
iwantXsigma = find(InputArray > meanOfInput - X*sd &...
    InputArray < meanOfInput + X*sd);

% store chopped data in array
choppedArray = NaN(size(InputArray));
choppedArray(iwantXsigma) = InputArray(iwantXsigma);