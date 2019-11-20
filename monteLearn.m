clear; clc; close all;format long;format compact;
%Make sure there are no current instances of STK open, otherwise this code will not work. 

%% Generate normal distribution of variables
%per iteration variables
variables.dryMass = 6.11+.2*randn(1000,1); % kg, Spacecraft mass
variables.thrustTime = .1+.02*randn(1000,1); %sec, thruster pulse time
%variables.thrustAlign = deg2rad(2*randn(1000,1)); %radians, thruster on axis alignment 

variables.thrustAlign = .035*randn(1000,1); %radians, thruster on axis alignment 

variables.orientAcc = deg2rad(2*randn(1000,1)); %radians, re-orientation/ADCS accuracy 
variables.specImp = 270+40*randn(1000,1); %sec, specific impulse
variables.propMass = .9 + 5E-3*randn(1000,1); %kg, propellant mass
variables.PPP = 1E-3+(1E-3)*.05*randn(1000,1); %kg, propellant per pulse
variables.clockERR = 1*randn(1000,1); %clock error, fire @time inaccuracy 
variables.SRP = abs(.03+.03*randn(1000,1)); %solar radiation pressure 

%per segment variables
variables.thrustForce = 1+.1*randn(1000,1); %newtons, thruster force
variables.posAcc = 1000*randn(1000,1); %km, position knowledge accuracy
variables.posVel = 10*randn(1000,1); %m/s velociy knowledge accuracy


%% Open the desired Scenario 
% Run STK and create new instance 
app = actxserver('STK10.application');
app.UserControl = 1;
root = app.Personality2;    % Grab handle on the STK application root to execute commands

% determines the instance
app2 = actxserver('STK10.application');
app2.UserControl = 1;
root2 = app2.Personality2;    % Grab handle on the STK application root to execute commands


%loads the desired scenario; INPUTS: (root, 'Scenario Path')
%main Trajec
%loadScen(root, 'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Trajectories\Spring 2019\Original_copy\feb2019-oct18copy.sc')

%used to test 
path1 = 'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Trajectories\Spring 2019\date change\copy of trajectories\copy-of-date-change.sc';
%path1 =  'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Monte Carlo\Scenarios\Test1\test-Trajec.sc';
path2 = 'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Monte Carlo\Scenarios\Maneuvercalc\Maneuvercalc.sc';

loadScen(root, path1)

loadScen(root2, path2)

% Name desired satellite here
satName = 'CurrentNom';

numRuns = 100;
%% Retrieve the segments we are iterating through
clc
% Pulls out all the segments in the current trajectory
ASTGSegments = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList', satName))
% Retrieves number of segments
ASTGSegments.Count;

% Retrieves segment names

% key determines the stopping condition for the string scan 
Key   = ' ';
for i= 0:ASTGSegments.Count-1  
    
   % pulls each string out 
   Segments(i+1).string = sprintf(ASTGSegments.Item(i));
   
   %reads just segment name from string 
   Index = strfind(Segments(i+1).string, Key);
   Segments(i+1).names = sscanf(Segments(i+1).string(1:Index), '%s');
end


%% Get Final Location

% spacecraft solar radiation pressure
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.SRPAreaAction Set to new value'));
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.SRPAreaVal %g m^2', .03));

%spacecraft dry mass

root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.DryMassAction Set to new value'));
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.DryMassVal %g kg', 6.11));

%spacecraft wet mass
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.FuelMassAction Set to new value'));
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.FuelMassVal %g kg', 1.104));



root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom RunMCS'))
[Xf, Yf, Zf, Vxf, Vyf, Vzf] = pullCartesianMP(root,satName,'SegmentList.Propagate1', 'FinalState');


%% 
clc;

for i = 1:numRuns
   runprops(i).SRP = variables.SRP(randi(1000));
   runprops(i).dryMass =  variables.dryMass(randi(1000));
   runprops(i).propMass = variables.propMass(randi(1000));
   runprops(i).thrustAlign_Y = variables.thrustAlign(randi(1000));
   runprops(i).thrustAlign_Z = variables.thrustAlign(randi(1000));
   
   
    
% spacecraft solar radiation pressure
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.SRPAreaAction Set to new value'));
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.SRPAreaVal %g m^2', runprops(i).SRP));

%spacecraft dry mass

root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.DryMassAction Set to new value'));
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.DryMassVal %g kg', runprops(i).dryMass));

%spacecraft wet mass
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.FuelMassAction Set to new value'));
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.FuelMassVal %g kg', runprops(i).propMass ));

%spacecraft thruster alignment angle

root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.first_Flyby.SegmentList.Maneuver3.FiniteMnvr.Cartesian.Y %g',runprops(i).thrustAlign_Y));
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.first_Flyby.SegmentList.Maneuver3.FiniteMnvr.Cartesian.Z %g',runprops(i).thrustAlign_Z));




root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom RunMCS'));



[runprops(i).Xf, runprops(i).Yf, runprops(i).Zf, runprops(i).Vxf, runprops(i).Vyf, runprops(i).Vzf] = pullCartesianMP(root,satName,'SegmentList.Propagate1', 'FinalState');

end

%%
close all;

for i=1:numRuns
dist(i) = sqrt((Xf-runprops(i).Xf)^2+(Yf-runprops(i).Yf)+(Zf-runprops(i).Zf));
L(i) = runprops(i).dryMass;
L1(i) = runprops(i).SRP;
L2(i) = runprops(i).propMass;
L3(i) = runprops(i).thrustAlign_Y;
L4(i) = runprops(i).thrustAlign_Z;
end

subplot(3, 2, 1)
plot(L(:), dist(:),'.')
title('DryMass')
xlabel('Mass (Avg 6.11 kg)')
ylabel('Dist (m)')

subplot(3, 2, 2)
plot(L1(:), dist(:),'.')
title('SRP')
xlabel('SRP (Avg .03 m^2)')
ylabel('Dist (m)')

subplot(3, 2, 3)
plot(L2(:), dist(:),'.')
title('Wetmass')
xlabel('Mass (Avg 1.104)')
ylabel('Dist (m)')

subplot(3, 2, 4)
plot(L3(:), dist(:),'.')
title('Yalign')
xlabel('Y angle offset (rad)')
ylabel('Dist (m)')

subplot(3, 2, 5)
plot(L4(:), dist(:),'.')
title('ZAlign')
xlabel('Z angle offset (rad)')
ylabel('Dist (m)')


%%
clc

a= root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList.Update'))
for i  = 0:a.count-1
    a.Item(i)
end