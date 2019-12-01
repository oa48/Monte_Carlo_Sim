 function [status,Outputs] = calcManeuver(root, satName, X, Y, Z, Vx, Vy, Vz, Xf, Yf, Zf, Vxf, Vyf, Vzf, dryMass, SRPArea, wetMass, Epoch_Start, Init, pFail)

% [Status, Maneuver1, Propagates] = calcManeuver(root, satName, X, Y, Z, Vx, Vy, Vz, Xf, Yf, Zf, Vxf, Vyf, Vzf, dryMass, SRPArea, wetMass)

%iterationCond = [dryMass, SRP, wetMass, thrustAlign]

% This code will take the cartesian initial conditions (X, Y, Z, Vx, Vy, Vz) and cartesian final conditions (Xf, Yf, Zf, Vxf, Vyf, Vzf) and calculate a maneuver between them
% locations must be in km and velocities in km/s
% dryMass (kg), wetMass (kg), and SRPArea(m^2) are also varied in this. these values will change on each trajectory iteration but not the segment iterations. 
% root must be defined in the inital code. 

% This code will output a series of maneuvers and trajectories that will make up the new trajectory. 
% The status will determine if the differntial correcter was able to converge or not - this will determine failure conditions for a trajectory. 

% note**** this targeter has 5 set segments - propagate, maneuver, propagate, maneuver, propagate
% adding more is perfectly okay, but you will need to add them to controls section. This is easily done in stk gui. Since this stk scenario
% is never saved, it does reset each time it is used. 



%% intial Conditions - this will set the initial conditions of the satellite to calculate maneuver

% drymass, wetmass, and solar radiation pressure
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.DryMass %g kg', satName, dryMass));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.FuelMass %g kg', satName, wetMass));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.MaxFuelMass %g kg', satName, wetMass));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.SRPArea %g m^2', satName, SRPArea));


% Cartesian location and velocity 
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.X %g km', satName, X));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Y %g km', satName, Y));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Z %g km', satName, Z));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vx %g km/sec', satName, Vx));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vy %g km/sec', satName, Vy));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vz %g km/sec', satName, Vz));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vz %g km/sec', satName, Vz));

% date
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch %s', satName ,Epoch_Start));


%% Final Conditions - this sets the final conditions of the manevuer 
% note**** this targeter has 5 set segments - propagate, maneuver, propagate, maneuver, propagate
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayResults.Propagate2_:_Vx.Desired %g km/sec', satName, Vxf));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayResults.Propagate2_:_Vy.Desired %g km/sec', satName, Vyf));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayResults.Propagate2_:_Vz.Desired %g km/sec', satName, Vzf));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayResults.Propagate2_:_X.Desired %g km', satName, Xf));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayResults.Propagate2_:_Y.Desired %g km', satName, Yf));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayResults.Propagate2_:_Z.Desired %g km', satName, Zf));

%% Tolerance?

%% Reset Initial Values 
% set all parameters back to zero
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Propagate.StoppingConditions.Duration.TripValue 0 sec', satName)); 
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.StoppingConditions.Duration.TripValue 0 sec', satName)); 
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Propagate1.StoppingConditions.Duration.TripValue 0 sec', satName)); 
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver1.StoppingConditions.Duration.TripValue 0 sec', satName)); 
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Propagate2.StoppingConditions.Duration.TripValue 0 sec', satName)); 


root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.Cartesian.X %g', satName, 0));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.Cartesian.Y %g', satName, 0));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.Cartesian.Z %g', satName, 0));

root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver1.Cartesian.X %g', satName, 0));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver1.Cartesian.Y %g', satName, 0));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver1.Cartesian.Z %g', satName, 0));

%% Apply Initial Values 
% sit = 1 means we have a maneuver which will recieve access to control the thrust of maneuver
% sit = 2 means we have a propagation which will not reeive maneuver control
% sit = 3 means we have a propagation which will recieve maneuver control

% 
if Init.X == 0
    Init.X = .01;
end
if Init.Z == 0
    Init.Z = .01;
end
if Init.Y == 0
    Init.Y = .01;
end



if strcmp(Init.type, 'M')
    root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.Cartesian.X %g', satName, Init.X));
    root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.Cartesian.Y %g', satName, Init.Y));
    root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.Cartesian.Z %g', satName, Init.Z));
    root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.StoppingConditions.Duration.TripValue %g sec', satName, Init.t));
    
    sit = 1;
    thrustControl(root, satName, sit)
    root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.MaxIterations %g', 'MnvrCalc', 100));
    
else
    if pFail == 1
        sit = 3;
        
        root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.SegmentList.Maneuver.StoppingConditions.Duration.TripValue 1000 sec', satName));
        root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.Cartesian.X %g', satName, .01));
        root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.Cartesian.Y %g', satName, .01));
        root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.Cartesian.Z %g', satName, .01));
        root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.MaxIterations %g', 'MnvrCalc', 100));
        root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Propagate1.StoppingConditions.Duration.TripValue %g sec', satName, 1000));
        Init.t = Init.t-2000;
        
    else
        sit = 2;
        root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.MaxIterations %g', 'MnvrCalc', 50));
    end
    
    thrustControl(root, satName, sit)
    root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Propagate.StoppingConditions.Duration.TripValue %g sec', satName, Init.t));
    
end


%% Run MCS
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Action Run active profiles', satName));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s RunMCS', satName));

%% Converged?

a = root.ExecuteCommand(sprintf('Astrogator_Rm */Satellite/%s GetValues MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.Status', satName));

Key = '= ';   
% Finds the spaces (key) and gets the number stored in the cetner)
Index = strfind(a.Item(0), Key);
status = a.Item(0);
status = sscanf(status((Index+1):length(status)), '%s');
status = strcmp('Converged', status);

%% Pull Segment data
clc
%a = root2.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.Targeter.SegmentList.Propagate.StoppingConditions.Duration'));
%a = root.ExecuteCommand(sprintf('Astrogator_Rm */Satellite/%s GetValues MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1'))
%a = root.ExecuteCommand(sprintf('Astrogator_Rm */Satellite/%s GetValues MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.Controls.'))
Mnvr = struct;
Outputs = struct;


% Propagate 1 duration 
temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Propagate StoppingConditions.Duration.TripValue FinalValue', satName));
temp = temp.Item(0);
Index = strfind(temp, ' ');  
Outputs.Propagate(1) = sscanf(temp(1:Index), '%g');




% Maneuver 1 xyz, t 
temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Maneuver FiniteMnvr.Cartesian.X FinalValue', satName));
temp = temp.Item(0);
Outputs.Mnvr(1).x = sscanf(temp, '%g');


temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Maneuver FiniteMnvr.Cartesian.Y FinalValue', satName));
temp = temp.Item(0);
Outputs.Mnvr(1).y = sscanf(temp, '%g');


temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Maneuver FiniteMnvr.Cartesian.Z FinalValue', satName));
temp = temp.Item(0);
Outputs.Mnvr(1).z = sscanf(temp, '%g');

 
temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Maneuver FiniteMnvr.StoppingConditions.Duration.TripValue FinalValue', satName));
temp = temp.Item(0);
Index = strfind(temp, ' ');  
Outputs.Mnvr(1).t = sscanf(temp(1:Index), '%g');



% Propagate 2 duration 
temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Propagate1 StoppingConditions.Duration.TripValue FinalValue', satName));
temp = temp.Item(0);
Index = strfind(temp, ' ');  
Outputs.Propagate(2) = sscanf(temp(1:Index), '%g');



% Maneuver 1 xyz, t 
temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Maneuver1 FiniteMnvr.Cartesian.X FinalValue', satName));
temp = temp.Item(0);
Outputs.Mnvr(2).x = sscanf(temp, '%g');


temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Maneuver1 FiniteMnvr.Cartesian.Y FinalValue', satName));
temp = temp.Item(0);
Outputs.Mnvr(2).y = sscanf(temp, '%g');


temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Maneuver1 FiniteMnvr.Cartesian.Z FinalValue', satName));
temp = temp.Item(0);
Outputs.Mnvr(2).z = sscanf(temp, '%g');

 
temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Maneuver1 FiniteMnvr.StoppingConditions.Duration.TripValue FinalValue', satName));
temp = temp.Item(0);
Index = strfind(temp, ' ');  
Outputs.Mnvr(2).t = sscanf(temp(1:Index), '%g');




% Propagate 3 duration 
temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1 Propagate2 StoppingConditions.Duration.TripValue FinalValue', satName));
temp = temp.Item(0);
Index = strfind(temp, ' ');  
Outputs.Propagate(3) = sscanf(temp(1:Index), '%g');

% Propagate 3 fuel
temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.Targeter.SegmentList.Propagate2.FinalState.FuelMass', satName));
temp = temp.Item(0);
Index = strfind(temp, '= ');
Outputs.fuel = sscanf(temp((Index+length(Index)):length(temp)), '%g');
 end