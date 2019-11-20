%function pullData(root, satName, Segname)

% Load a scenario with the name defined by "scenName"

% "root" should be defined in the main code to allow Matlab to send commands to STK


 segname = 'first_Flyby';

properties =  root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s', satName, segname)); 
   
Key   = ' ';
for i= 0:properties.Count-1  
    
   % pulls each string out 
   props(i+1).string = sprintf(properties.Item(i));
   
   %reads just segment name from string 
   Index = strfind(props(i+1).string, Key);
   props(i+1).names = sscanf(props(i+1).string(1:Index), '%s');
end


str1 = 'SegmentList';
comp = 0;
i= 0;
while comp == 0 && i < properties.count
    i = i+1;
    comp = strcmp(props(i).names, str1)
    
end


if comp = 1
      
   %reads just segment name from string 
   Index = strfind(props(i).string, Key2);
   
   for k = 2:length(Index)
       subnames = sscanf(props(i+1).string(1:Index), '%s');
   end
    
    
    
else
    
end
    


% Key   = '=';
% Index = strfind(Max_fuel_mass, Key);
% Max_fuel_mass = sscanf(Max_fuel_mass(Index(1) + length(Key):end), '%g', 1)



% 
% Max_fuel_mass = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList.Initial State.MaxFuelMass'));
% Max_fuel_mass = Max_fuel_mass.Item(0);
% 
% Key   = '=';
% Index = strfind(Max_fuel_mass, Key);
% Max_fuel_mass = sscanf(Max_fuel_mass(Index(1) + length(Key):end), '%g', 1)


% Max_fuel_mass = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList.Initial State.MaxFuelMass'));
% Max_fuel_mass = Max_fuel_mass.Item(0);
% 
% Key   = '=';
% Index = strfind(Max_fuel_mass, Key);
% Max_fuel_mass = sscanf(Max_fuel_mass(Index(1) + length(Key):end), '%g', 1)


% a  = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList.Propagate'))
% properties(a)
% a1 = a.Item(0)
% a2 = a.Item(1)
% a3 = a.Item(2)
% a4 = a.Item(3)
% a5 = a.Item(4) 
% a6 = a.Item(5)





%a= root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList'))
%a1 = a.Item(0); a2 = a.Item(1); a3 = a.Item(2); a4 = a.Item(3); a5 = a.Item(4); a6 = a.Item(5)

%a = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList.Maneuver.FiniteMnvr.ThrustAxes')) ;   
%a1 = a.Item(0); a2 = a.Item(1); %a3 = a.Item(2); a4 = a.Item(3); a5 = a.Item(4); a6 = a.Item(5)

%a = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList.Maneuver.ImpulsiveMnvr.ThrustAxes'))  
%a1 = a.Item(0); a2 = a.Item(1); %a3 = a.Item(2); a4 = a.Item(3); a5 = a.Item(4); a6 = a.Item(5)



%end