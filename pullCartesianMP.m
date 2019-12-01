function [Locs] = pullCartesianMP(root, satName, segName, state)

%[Locs] = pullCartesianMP(root, satName, segName, state)

% this function pulls out Cartesian values - location and velocity) from a *****maneuver or propogation*******

% state idenitifies if it is the starting or ending state of the propagation: 
%   inputs: 'FinalState' or 'InitialState' (with the apostraphes, it needs the string)

% satName is the satellite name, should be defined in Primary_code.m

% root must be defined in primary_code.m as well

% segName is a string input of the path.
%   inputs: for a segment in the main segment list: 'Maneuver'
%           for a segment within a targeter, etc: 'SegmentList.first_Flyby.SegmentList.Maneuver'



% pulls out the data from the specified segment
props = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.%s.Cartesian', satName, segName, state));


%determines where the spaces are in the string

% pulls out the strings into a useable format (i dont know why but it wont work without changing it to a class)
for i = 0:5
prop(i+1).string = sprintf(props.Item(i));
end


Key   = ' ';   
% Finds the spaces (key) and gets the number stored in the cetner)
Index = strfind(prop(1).string, Key);  
Locs.X = sscanf(prop(1).string((Index(length(Index)-1)):Index(length(Index))), '%g');

Index = strfind(prop(2).string, Key);  
Locs.Y = sscanf(prop(2).string((Index(length(Index)-1)):Index(length(Index))), '%g');

Index = strfind(prop(3).string, Key);  
Locs.Z = sscanf(prop(3).string((Index(length(Index)-1)):Index(length(Index))), '%g');

Index = strfind(prop(4).string, Key);  
Locs.Vx = sscanf(prop(4).string((Index(length(Index)-1)):Index(length(Index))), '%g');

Index = strfind(prop(5).string, Key);  
Locs.Vy = sscanf(prop(5).string((Index(length(Index)-1)):Index(length(Index))), '%g');

Index = strfind(prop(6).string, Key);  
Locs.Vz = sscanf(prop(6).string((Index(length(Index)-1)):Index(length(Index))), '%g');

%pulls out the final Epoch for the maneuver 

Key = '= ';
props2 = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.%s.Epoch', satName, segName, state));
props2 = props2.Item(0);
Index = strfind(props2, Key);  
Locs.t = props2(Index+2:length(props2));
end





