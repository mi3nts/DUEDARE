% FUNCTION TO PLOT CGX AND TOBII ACCELEROMETER VALUES

% INPUT:
%     TIMETABLE = TIMETABLE WITH CGX AND TOBII ACCELEROMTER VARIABLES

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-SCALE INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

function [] = plotAccel(Timetable)
   % plot accelerometer values excluding outliers (>4 stdev)
    try
        % plot x accelerometer
        subplot(3,1,1)
        plot(Timetable.Datetime, ...
        normalize(chopData(interpolNaNs(Timetable.AccelerometerX),4)))
        hold on
        plot(Timetable.Datetime, ...
            normalize(chopData(Timetable.AccelX,4)))
        title('Accelerometer X', 'Fontsize', 18);
        l = legend;
        l.String = {'Tobii' 'CGX'};
        l.Location = 'best';
        l.FontSize = 16;
        hold off
        
        % plot y accelerometer
        subplot(3,1,2)
        plot(Timetable.Datetime, ...
        normalize(chopData(interpolNaNs(Timetable.AccelerometerY),4)))
        hold on
        plot(Timetable.Datetime, ...
            normalize(chopData(Timetable.AccelY,4)))
        title('Accelerometer Y', 'Fontsize', 18);
        hold off
        
        % plot z accelerometer
        subplot(3,1,3)
        plot(Timetable.Datetime, ...
        normalize(chopData(interpolNaNs(Timetable.AccelerometerZ),4)))
        hold on
        plot(Timetable.Datetime, ...
            normalize(chopData(Timetable.AccelZ,4)))
        title('Accelerometer Z', 'Fontsize', 18);
        hold off
        
    catch
        disp('---something went wrong---')
    end
end
