% FUNCTION TO COMPUTE RESPIRATION RATE FROM RESPIRATION ELECTRODE SIGNAL

% INPUTS:
    % v = a vector of the respiraton values for each time
    % t = a vector of the times
    % Fs = sampling rate of signal
    
% OUTPUT:

    % rr = respiration rate for entire signal

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function br = computeBR(v,t,Fs)

    % convert nans to zeros
    v(isnan(v)) = 0;

    % apply high pass filter to signal
    y = highpass(v,0.133,Fs,'Steepness',0.85,'StopbandAttenuation',60);
    % apply high pass filter to filtered signal
    y = lowpass(y,0.333,Fs,'Steepness',0.85,'StopbandAttenuation',60);
    % apply moving average to smooth signal
    y = smoothdata(y,'movmean','SamplePoints',t);
    % find peaks associated with breaths
    [pks,~]=findpeaks(y,'MinPeakProminence',0.1,'MinPeakDistance',3*Fs);

    % compute respiration rate
    br=length(pks)/minutes(t(end)-t(1));
    
end