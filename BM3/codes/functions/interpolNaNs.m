% FUNCTION TO PERFORM INTERPOLATION OF 1D SAMPLE WITH NANVALUES

% ROUTINE BASED ON Jan's CODE HERE: 
% https://www.mathworks.com/matlabcentral/answers/34346-interpolating-nan-s

% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)
% CODE AUTHORED BY: SHAWHIN TALEBI

function x = interpolNaNs(x)

    % get elements of x that are nan
    nanx = isnan(x);
    % generate vector of sample points
    t = 1:numel(x);
    % interpolate nan parts of input array
    x(nanx) = interp1(t(~nanx), x(~nanx), t(nanx));
    
end