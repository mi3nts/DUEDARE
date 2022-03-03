% NAIVE FUNCTION TO DETECT GUNSHOTS

% INPUTS:
%     audio = AUDIO SIGNAL AS NUMERIC ARRAY.
%     Fs = SAMPLE RATE OF INPUT SIGNAL

% OUTPUTS:
%     gunshot_idx = INDEXES WHERE GUNSHOTS OCCUR FOR DOWNSAMPLED SIGNAL
%     time_fromStart = TIME IN SECONDS FROM START OF DOWNSAMPLED SIGNAL
%     total_power = TOTAL POWER OF SIGNAL AT DOWNSAMPLED TIME RESOLUTION
%     downsampled_audio = DOWNSAMPLED SIGNAL BASED ON SHORT TIME FOURIER TRANSFORM
    
% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [gunshot_idx, time_fromStart, total_power, downsampled_audio] ...
    = naiveGunshotDetection(audio, Fs)

    % perform short time fourier transform
    s = stft(audio,Fs);

    % downsample signal from STFT length (128) with 75% overlap
    downsampled_audio = downsample(audio,32);
    % downsample timesteps
    time_fromStart = (1:32:length(audio))*seconds(1/Fs);

    % compute total power of signal at each time step
    total_power = sum(abs(s))';
    % define threshold to be 5 times the standard deviation
    threshold = 5*std(total_power);
    
    % smooth total power with moving average
    smoothed_total_s = movmean(total_power, Fs/50);

    % if smoothed total power is greater than threshold consider it a gunshot
    gunshot_idx = find(smoothed_total_s>=threshold);