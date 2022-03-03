% FUNCTION TO READ PUPIL DIAMETER AND ACCELEROMETER DATA FROM LIVEDATA.JSON 
% FILE FOR TOBII PRO GLASSES 2

% CODE AUTHORED BY: SHAWHIN TALEBI
% THE UNIVERSITY OF TEXAS AT DALLAS
% MULTI-INTEGRATED REMOTE SENSING AND SIMULATION (MINTS)

% -------------------------------------------------------------------------

function[] = TobiiQuickRead(YEAR, MONTH, DAY, TRIAL, USER, Tobii)
    % define ID number and pathID
    ID = strcat(YEAR, '_', MONTH, '_',DAY, '_',TRIAL, '_',USER, '_', Tobii);
    pathID = strrep(ID,'_','/');

    % change directory to proper parent
    str = pwd;
    if strcmp(str(end-4:end), 'Tobii')
        idcs = strfind(pwd,filesep);
        eval(strcat("cd ", (str(1:idcs(end-3)))))
    end

    % change number format to long
    format long

    % check if livedata.json file exists, if not uncompress it
    if ~exist(strcat('raw/', pathID,'/', ID,...
            '/segments/1/livedata.json'), 'file')

        gunzip(strcat('raw/', pathID,'/', ID,...
            '/segments/1/livedata.json.gz'), ...
            strcat('raw/', pathID,'/', ID,...
            '/segments/1'))
    end

    % read segment .json file
    string1 = fileread(strcat('raw/', pathID,'/', ID, ...
        '/segments/1/segment.json'));

    % -------------------------------------------------------------------------
    % GET START AND END TIMESTAMPS
    % -------------------------------------------------------------------------
    % decode segment.json file
    string_decoded = jsondecode(string1);

    % get date and time info and create duration objects
    start_datetime = string_decoded.seg_t_start;
    start_date = datetime(start_datetime(1:10), 'InputFormat', 'yyyy-MM-dd');
    start_time = duration(start_datetime(12:19),'format','hh:mm:ss.SSSS');

    stop_datetime = string_decoded.seg_t_stop;
    stop_date = datetime(stop_datetime(1:10), 'InputFormat', 'yyyy-MM-dd');
    stop_time = duration(stop_datetime(12:19),'format','hh:mm:ss.SSSS');

    % define duration object for elapsed time
    elapsed_time = (stop_date+stop_time) - (start_date+start_time);

    % -------------------------------------------------------------------------
    % INITIALIZE TABLES
    % -------------------------------------------------------------------------
    % open livedata file
    file = fopen(strcat('raw/', pathID,'/', ID,...
            '/segments/1/livedata.json'));

    % DEFINE VARIABLE NAMES FOR TABLES BASED ON EVERY POSSIBLE LINE TYPE

    % variable names of pupil diameter tables (4 vars) (5 fields)
    NamesPD = {'Datetime', 'Error', 'GazeIndex', 'PupilDiameter'};

    % variable names of API-sync package table (5 vars) (5 fields)
    NamesAPI = {'Datetime', 'Error', 'EventDatetime', 'Type', 'Tag'};

    % variable names of sync port signal package table (4 vars) (4 fields)
    NamesSyncPort = {'Datetime', 'Error', 'Direction', 'Signal'};

    % variable names of presentation Datetime sync package table (4 vars) (4 fields)
    NamesPTS = {'Datetime', 'PresentationDatetime', 'PipelineVersion','Error'};

    % variable names of gyroscope table (5 vars) (3 fields)
    NamesGyro = {'Datetime', 'GyroscopeX', 'GyroscopeY', 'GyroscopeZ', 'Error'};

    % variable names of accelerometer table (5 vars) (3 fields)
    NamesAccel = {'Datetime', 'AccelerometerX', 'AccelerometerY',...
        'AccelerometerZ', 'Error'};

    % variable names of video Datetime sync package table (3 vars) (3 fields)
    NamesVTS = {'Datetime', 'VideoDatetime','Error'};

    % variable names of eye camera video Datetime sync package table (3 vars) (3 fields)
    NamesEVTS = {'Datetime', 'Error', 'EyeVideoTimestamp'};


    initial3 = {NaN NaN NaN};
    initial4 = {NaN NaN NaN NaN};
    initial5 = {NaN NaN NaN NaN NaN};
    initial6 = {NaN NaN NaN NaN NaN NaN};

    % TobiiTable = cell2table(initial,'VariableNames',Names);

    % INTIALIZE TABLES
    LeftPupilDiameter_Table = cell2table(initial4, 'VariableNames', NamesPD);
    RightPupilDiameter_Table = cell2table(initial4, 'VariableNames', NamesPD);
    Gyroscope_Table = cell2table(initial5, 'VariableNames', NamesGyro);
    Accelerometer_Table = cell2table(initial5, 'VariableNames', NamesAccel);
    PTS_Table = cell2table(initial4, 'VariableNames', NamesPTS);
    VTS_Table = cell2table(initial3, 'VariableNames', NamesVTS);
    EVTS_Table = cell2table(initial3, 'VariableNames', NamesEVTS);
    Sync_Table = cell2table(initial4, 'VariableNames', NamesSyncPort);
    API_Table = cell2table(initial5, 'VariableNames', NamesAPI);

    % INTIALIZE TABLE COUNTERS
    LeftPupilDiameter_counter = 1;
    RightPupilDiameter_counter = 1;
    Gyroscope_counter = 1;
    Accelerometer_counter = 1;
    PTS_counter = 1;
    VTS_counter = 1;
    EVTS_counter = 1;
    Sync_counter = 1;
    API_counter = 1;

    % read each line of the file loop
    while feof(file)==0

        line = fgetl(file);
        line_decoded = jsondecode(line);
        field_names = fieldnames(line_decoded);

        switch length(field_names)

            % evaluate case of 5 field names. (LeftPC, RightPC, LeftPD,
            % RightPD, LeftGD, RightGD, GP, API)
            case 5

                last_field = field_names(5,1);

                % evaluate if line contains field 'eye'. (LeftPC, RightPC,
                % LeftPD, RightPD, LeftGD, RightGD)
                if strcmp(last_field, 'eye')
                    field4 = field_names(4,1);

                    % evaluate if 'eye' field is = left. (LeftPC, LeftPD, LeftGD)
                    if strcmp(line_decoded.eye, 'left')
                        % evaluate if line contains 'pd'. (LeftPD)
                        if strcmp(field4, 'pd')

                            tempRow = {(line_decoded.ts * 10^-6) line_decoded.s ...
                                line_decoded.gidx line_decoded.pd};

                            LeftPupilDiameter_Table(LeftPupilDiameter_counter,:) ...
                                = tempRow;

                            LeftPupilDiameter_counter = LeftPupilDiameter_counter + 1;
                        % other wise continue
                        else
                            continue
                        end
                    end

                    % evaluate if 'eye' field is = left. (RightPC, RightPD, RightGD)
                    if strcmp(line_decoded.eye, 'right')

                        % evaluate if line contains 'pd'. (RightPD)
                        if strcmp(field4, 'pd')

                            tempRow = {(line_decoded.ts * 10^-6) line_decoded.s ...
                                line_decoded.gidx line_decoded.pd};

                            RightPupilDiameter_Table(RightPupilDiameter_counter,:) ...
                                = tempRow;

                            RightPupilDiameter_counter = RightPupilDiameter_counter + 1;

                        % other wise continue
                        else
                            continue
                        end

                    end

                % evaluate if line contains field 'gp' (GP)
                elseif strcmp(last_field, 'gp')

                    continue

                % evaluate if line contains field 'tag' (API)
                elseif strcmp(last_field, 'tag')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.s line_decoded.ets...
                        string(line_decoded.type) string(line_decoded.tag)};

                    API_Table(API_counter,:) = tempRow;

                    API_counter = API_counter + 1;

                end

            % evaluate case of 4 field names. (GP3D, SYNC, PTS) 
            case 4
                last_field = field_names(4,1);

                % evaluate if line contains field 'gp3' (GP3D)
                if strcmp(last_field, 'gp3')

                    continue

                % evaluate if line contains field 'sig' (SYNC)
                elseif strcmp(last_field, 'sig')

                    if strcmp(line_decoded.dir, 'in')
                        tempDir = 1;
                    elseif strcmp(line_decoded.dir, 'out')
                        tempDir = 0;
                    end

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.s ...
                        tempDir line_decoded.sig};

                    Sync_Table(Sync_counter,:) = tempRow;

                    Sync_counter = Sync_counter + 1;

                % evaluate if line contains field 's' (PTS)    
                elseif strcmp(last_field, 's')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.pts line_decoded.pv...
                        line_decoded.s};

                    PTS_Table(PTS_counter,:) = tempRow;

                    PTS_counter = PTS_counter + 1;

                end

            % evaluate case of 3 field names. (Gyro, Accel, VTS, EVTS)     
            case 3
                field2 = field_names(2,1);
                field3 = field_names(3,1);

                % evaluate if line contains field 'gy' (Gyro) 
                if strcmp(field2,'gy') || strcmp(field3,'gy')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.gy(1)...
                        line_decoded.gy(2) line_decoded.gy(3) line_decoded.s};

                    Gyroscope_Table(Gyroscope_counter,:) = tempRow;

                    Gyroscope_counter = Gyroscope_counter + 1;

                % evaluate if line contains field 'ac' (Accel)
                elseif strcmp(field2,'ac') || strcmp(field3,'ac')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.ac(1)...
                        line_decoded.ac(2) line_decoded.ac(3) line_decoded.s};

                    Accelerometer_Table(Accelerometer_counter,:) = tempRow;

                    Accelerometer_counter = Accelerometer_counter + 1;

                % evaluate if line contains field 'vts' (VTS)    
                elseif strcmp(field2,'vts') || strcmp(field3,'vts')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.vts line_decoded.s};

                    VTS_Table(VTS_counter,:) = tempRow;

                    VTS_counter = VTS_counter + 1;

                % evaluate if 2nd field is 's' (EVTS)   
                elseif strcmp(field2,'evts') || strcmp(field3,'evts')

                    tempRow = {(line_decoded.ts * 10^-6) line_decoded.evts line_decoded.s};

                    EVTS_Table(EVTS_counter,:) = tempRow;

                    EVTS_counter = EVTS_counter + 1;

                end

        end

    end 
    % end of read each line of the file loop

    % CONVERT Datetime COLUMNS TO DURATION objects 

    LeftPupilDiameter_Table.Datetime = seconds(LeftPupilDiameter_Table.Datetime);
    RightPupilDiameter_Table.Datetime = seconds(RightPupilDiameter_Table.Datetime);
    Gyroscope_Table.Datetime = seconds(Gyroscope_Table.Datetime);
    Accelerometer_Table.Datetime = seconds(Accelerometer_Table.Datetime);
    PTS_Table.Datetime = seconds(PTS_Table.Datetime);
    VTS_Table.Datetime = seconds(VTS_Table.Datetime);
    EVTS_Table.Datetime = seconds(EVTS_Table.Datetime);
    Sync_Table.Datetime = seconds(Sync_Table.Datetime);
    API_Table.Datetime = seconds(API_Table.Datetime);

    % COMPUTE MIN Datetime VALUES FOR EACH TABLE

    minDatetimeValues = [...
        min(LeftPupilDiameter_Table.Datetime); ...
        min(RightPupilDiameter_Table.Datetime); ...
        min(Gyroscope_Table.Datetime); ...
        min(Accelerometer_Table.Datetime); ...
        min(PTS_Table.Datetime); ...
        min(VTS_Table.Datetime); ...
        min(EVTS_Table.Datetime); ...
        min(Sync_Table.Datetime); ...
        min(API_Table.Datetime)];

    minDatetime = min(minDatetimeValues);

    % SUBTRACT LOWEST Datetime VALUE FROM ALL DatetimeS AND ADD START TIME

    LeftPupilDiameter_Table.Datetime = start_date + start_time + ... 
        LeftPupilDiameter_Table.Datetime - minDatetime;
    RightPupilDiameter_Table.Datetime = start_date + start_time + ... 
        RightPupilDiameter_Table.Datetime - minDatetime;
    Gyroscope_Table.Datetime = start_date + start_time + ...
        Gyroscope_Table.Datetime - minDatetime;
    Accelerometer_Table.Datetime = start_date + start_time + ...
        Accelerometer_Table.Datetime - minDatetime;
    PTS_Table.Datetime = start_date + start_time + PTS_Table.Datetime ...
        - minDatetime;
    VTS_Table.Datetime = start_date + start_time + VTS_Table.Datetime ...
        - minDatetime;
    EVTS_Table.Datetime = start_date + start_time + EVTS_Table.Datetime ...
        - minDatetime;
    Sync_Table.Datetime = start_date + start_time + Sync_Table.Datetime ...
        - minDatetime;
    API_Table.Datetime = start_date + start_time + API_Table.Datetime ...
        - minDatetime;

    % change default datetime format
    datetime.setDefaultFormats('default', 'dd-MMM-uuuu HH:mm:ss.SSSS');


    % SORT TABLES BY Datetime

    LeftPupilDiameter_Table = sortrows(LeftPupilDiameter_Table);
    RightPupilDiameter_Table = sortrows(RightPupilDiameter_Table);
    Gyroscope_Table = sortrows(Gyroscope_Table);
    Accelerometer_Table = sortrows(Accelerometer_Table);
    PTS_Table = sortrows(PTS_Table);
    VTS_Table = sortrows(VTS_Table);
    EVTS_Table = sortrows(EVTS_Table);
    Sync_Table = sortrows(Sync_Table);
    API_Table = sortrows(API_Table);

    % CONVERT TABLES TO TIMETABLES

    LeftPupilDiameter_Timetable = table2timetable(LeftPupilDiameter_Table);
    RightPupilDiameter_Timetable= table2timetable(RightPupilDiameter_Table);
    Gyroscope_Timetable = table2timetable(Gyroscope_Table);
    Accelerometer_Timetable = table2timetable(Accelerometer_Table);
    PTS_Timetable = table2timetable(PTS_Table);
    VTS_Timetable = table2timetable(VTS_Table);
    EVTS_Timetable = table2timetable(EVTS_Table);
    Sync_Timetable = table2timetable(Sync_Table);
    API_Timetable = table2timetable(API_Table);

    % retime timetables to coincide
    LeftPupilDiameter_Timetable = retime(LeftPupilDiameter_Timetable,'regular'...
        ,'linear','SampleRate', 100);
    RightPupilDiameter_Timetable = retime(RightPupilDiameter_Timetable,'regular'...
        ,'linear','SampleRate', 100);
    Gyroscope_Timetable = retime(Gyroscope_Timetable,'regular'...
        ,'linear','SampleRate', 100);
    Accelerometer_Timetable = retime(Accelerometer_Timetable,'regular'...
        ,'linear','SampleRate', 100);

    % SYNCRONIZE TIMETABLES

    % construct timetable of biometric measurements
    TobiiPDTimetable = synchronize(...
        LeftPupilDiameter_Timetable, RightPupilDiameter_Timetable, ...
        Gyroscope_Timetable, Accelerometer_Timetable, 'intersection');

    % -------------------------------------------------------------------------
    % CREATE FINAL TIMETABLES
    % -------------------------------------------------------------------------
    TobiiPDTimetable = unique(TobiiPDTimetable);

    % construct timetable of auxiliary parameters that were measured during run
    % build command
    command = 'TobiiAuxTimetable = synchronize(';

    if length(PTS_Timetable.Datetime) > 1 
        command = [command 'PTS_Timetable, '];
    end

    if length(VTS_Timetable.Datetime) > 1 
        command = [command 'VTS_Timetable, '];
    end

    if length(EVTS_Timetable.Datetime) > 1 
        command = [command 'EVTS_Timetable, '];
    end

    if length(API_Timetable.Datetime) > 1
        command = [command 'API_Timetable, '];
    end

    if length(Sync_Timetable.Datetime) > 1 
        command = [command 'Sync_Timetable'];  
    end

    % evaluate command
    if length(command) > 34
        command = [command ');'];
        eval(command)
    end

    % -------------------------------------------------------------------------
    % TABLES 
    % -------------------------------------------------------------------------
    % create table for Tobii Data
    TobiiTable = timetable2table(TobiiPDTimetable);
    TobiiAuxTable = timetable2table(TobiiAuxTimetable);

    % -------------------------------------------------------------------------
    % Save objects 
    % -------------------------------------------------------------------------
    % save timetables
    % check if proper folder in tables exists, if not create it
    if ~exist(strcat('objects/', pathID), 'dir')
        mkdir(strcat('objects/', pathID))
    end

    % save timetables
    save(strcat('objects/', pathID,'/', ID,'_TobiiPDTimetable'),...
        'TobiiPDTimetable');
    % save(strcat('objects/', pathID,'/', ID,'_TobiiAuxTimetable'),...
    %     'TobiiAuxTimetable');