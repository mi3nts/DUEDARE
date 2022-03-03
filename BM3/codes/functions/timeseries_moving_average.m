function [MovingAverage,MovingVariance,MovingRepresentativeness] = ...
    timeseries_moving_average(t,v,window, UseParallel)
% t: a vector of the times
% v: a vector of the variable values for each time
% window: the size of the window e.g. seconds(1) would be a one second window
% UseParallel: 0 or 1. 1 to use parfor and 0 not to use parfor

% Make the inputs into a timetable so we can use the withtol funtion to 
% define the moving window.

Data=timetable(t,v);

% initialize the output values (initially fill with NaN).
MovingAverage=nan(size(t));
MovingVariance=MovingAverage;
MovingRepresentativeness=MovingAverage;

if UseParallel

    % loop over timesteps in parallel
    parfor i=1:length(t)

        % select the timesteps within the time window of interest
        % select just the subset of times of interest
        W=Data(withtol(t(i),window),:).v;

        MovingAverage(i)=nanmean(W);
        MovingVariance(i)=nanvar(W);
        MovingRepresentativeness(i)=nanstd(W);

    end
    
else
    % loop over timesteps in parallel
    for i=1:length(t)

        % select the timesteps within the time window of interest
        % select just the subset of times of interest
        W=Data(withtol(t(i),window),:).v;

        MovingAverage(i)=nanmean(W);
        MovingVariance(i)=nanvar(W);
        MovingRepresentativeness(i)=nanstd(W);

    end
end