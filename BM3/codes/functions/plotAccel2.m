% FUNCTION TO PLOT CGX AND TOBII ACCELEROMETER VALUES FROM 2 SEPERATE
% TIMETABLES

% INPUT:
%     TobiiTimetable = TIMETABLE WITH TOBII ACCELEROMTER VARIABLES
%     EEGAccelTimetable = TIMETABLE WITH TOBII ACCELEROMTER VARIABLES

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = plotAccel2(TobiiTimetable, EEGAccelTimetable)
   % plot accelerometer values excluding outliers (>4 stdev)
    try
        % plot x accelerometer
        subplot(3,1,1)
        plot(TobiiTimetable.Datetime, ...
        normalize(chopData(TobiiTimetable.AccelerometerX,4)))
        hold on
        plot(EEGAccelTimetable.Datetime, ...
            normalize(chopData(EEGAccelTimetable.AccelX,4)))
        title('Accelerometer X', 'Fontsize', 18);
        l = legend;
        l.String = {'Tobii' 'CGX'};
        l.Location = 'best';
        l.FontSize = 16;
        hold off

        % plot y accelerometer
        subplot(3,1,2)
        plot(TobiiTimetable.Datetime, ...
        normalize(chopData(TobiiTimetable.AccelerometerY,4)))
        hold on
        plot(EEGAccelTimetable.Datetime, ...
            normalize(chopData(EEGAccelTimetable.AccelY,4)))
        title('Accelerometer Y', 'Fontsize', 18);
        hold off

        % plot z accelerometer
        subplot(3,1,3)
        plot(TobiiTimetable.Datetime, ...
        normalize(chopData(TobiiTimetable.AccelerometerZ,4)))
        hold on
        plot(EEGAccelTimetable.Datetime, ...
            normalize(chopData(EEGAccelTimetable.AccelZ,4)))
        title('Accelerometer Z', 'Fontsize', 18);
        hold off
        
    catch
        disp('---something went wrong---')
    end
end
