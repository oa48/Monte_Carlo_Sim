function [Init] = pullInitial2(root, satName, segment)

%[Init] = pullInitial2(root, satName, segment)

%This code retrieves the final results of each segment, to insert them as initial conditions for the differential corrector. 

% satName is the satellite name, should be defined in Primary_code.m

% root must be defined in primary_code.m as well

%segment is the segment we are checking



%determines if segment is a maneuver or propagation

temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Type', satName, segment));
if strcmp('Type = Maneuver', temp.Item(0))
    type = 1;
else
    type = 0;
end


%store maneuver or propagation
if type
    Init.type = 'M';
else
    Init.type = 'P';
end



% takes out the duration and X, Y, and Z thruster angles
if type   
    temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Direction.X',  satName, segment));
    temp = temp.Item(0);
    Index = strfind(temp, ' ');
    Init.X = sscanf(temp(Index(2)+1:length(temp)), '%g');
    
    temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Direction.Y',  satName, segment));
    temp = temp.Item(0);
    Index = strfind(temp, ' ');
    Init.Y = sscanf(temp(Index(2)+1:length(temp)), '%g');
    
    temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Direction.Z',  satName, segment));
    temp = temp.Item(0);
    Index = strfind(temp, ' ');
    Init.Z = sscanf(temp(Index(2)+1:length(temp)), '%g');
else
    Init.X = 0;
    Init.Y = 0;
    Init.Z = 0;
    
end

%% Julian Start Date

temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.InitialState.Epoch',  satName, segment));

temp = temp.Item(0);
Key   = ' ';   
Index = strfind(temp, Key);  
Index2 = strfind(temp, ':');
temp1.day = sscanf(temp(Index(2)+1:Index(3)-1), '%g');
temp1.mon = sscanf(temp(Index(3)+1:Index(4)-1), '%s');

temp1.mon = monToNum(temp1.mon);

temp1.year = sscanf(temp(Index(4)+1:Index(5)-1), '%g');
temp1.hr = sscanf(temp(Index(5)+1:Index2(1)-1), '%g');
temp1.min = sscanf(temp(Index2(1)+1:Index2(2)-1), '%g');
temp1.sec = sscanf(temp(Index2(2)+1:Index(6)-1), '%g');

Init.ti = juliandate(temp1.year,temp1.mon,temp1.day,temp1.hr,temp1.min,temp1.sec);

%% Julian Finish Date
temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.FinalState.Epoch',  satName, segment));

temp = temp.Item(0);
Key   = ' ';   
Index = strfind(temp, Key);  
Index2 = strfind(temp, ':');
temp1.day = sscanf(temp(Index(2)+1:Index(3)-1), '%g');
temp1.mon = sscanf(temp(Index(3)+1:Index(4)-1), '%s');

temp1.mon = monToNum(temp1.mon);

temp1.year = sscanf(temp(Index(4)+1:Index(5)-1), '%g');
temp1.hr = sscanf(temp(Index(5)+1:Index2(1)-1), '%g');
temp1.min = sscanf(temp(Index2(1)+1:Index2(2)-1), '%g');
temp1.sec = sscanf(temp(Index2(2)+1:Index(6)-1), '%g');

Init.tf = juliandate(temp1.year,temp1.mon,temp1.day,temp1.hr,temp1.min,temp1.sec);
Init.t= (Init.tf-Init.ti)*86400;



end