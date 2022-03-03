% FUNCTION TO MUTILATE ECG SIGNAL TO MAKE R PEAKS MORE PROMINENT

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function mutilatedECG = mutilateECG(ECG, DEVICE)

    % if ECG is from cognionics system do following processing
    if strcmp(DEVICE(1:3), 'EEG')

        % normalize ECG data
        ECG = normalize(ECG);

        % heavily filter CGX signal
        ECG = bandstop(ECG,[0.2 0.3],'Steepness',0.85,'StopbandAttenuation',60);
        ECG = bandstop(ECG,[0.45 0.5],'Steepness',0.85,'StopbandAttenuation',60);
        ECG = highpass(ECG,0.01,'Steepness',0.85,'StopbandAttenuation',60);
        ECG = smoothdata(ECG,'movmean');

        % remove points outside 3 standard deviations
        ECG = chopData(ECG,3);

        % replace nans with 0
        ECG(isnan(ECG)) = 0;

        % normalize signals again
        mutilatedECG = normalize(ECG);

    % if ECG is from equivial system do following processing
    elseif strcmp(DEVICE(1:3), 'EQV')

        % normalize ECG data
        ECG = normalize(ECG);

        % remove points outside 3 standard deviations
        ECG = chopData(ECG,3);

        % replace nans with 0
        ECG(isnan(ECG)) = 0;

        % normalize signals again
        mutilatedECG = normalize(ECG);
    end

end
