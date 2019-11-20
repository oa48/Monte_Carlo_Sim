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
path1 = 'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Monte Carlo\Scenarios\Test2\feb2019-oct18copy-nothing_post_cap.sc';

%used to test 

%path1 = 'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Trajectories\Spring 2019\date change\copy of trajectories\copy-of-date-change.sc';
%path1 =  'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Monte Carlo\Scenarios\Test1\test-Trajec.sc';
path2 = 'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Monte Carlo\Scenarios\Maneuvercalc\Maneuvercalc.sc';

loadScen(root, path1)

loadScen(root2, path2)

% Name desired satellite here
satName = 'CurrentNom';

numRuns = 3;
%% Retrieve the segments we are iterating through
clc
% Pulls out all the segments in the current trajectory
ASTGSegments = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList', satName));
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
[Segments] = removeTargeters(root, satName, Segments);



%% Get Final Locations of each maneuver 

% spacecraft solar radiation pressure
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.SRPAreaAction Set to new value'));
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.SRPAreaVal %g m^2', .03));

%spacecraft dry mass

root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.DryMassAction Set to new value'));
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.DryMassVal %g kg', 6.11));

%spacecraft wet mass
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.FuelMassAction Set to new value'));
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom SetValue MainSequence.SegmentList.Update.FuelMassVal %g kg', 1.104));


% run the Mission Control Sequence
root.ExecuteCommand(sprintf('Astrogator */Satellite/CurrentNom RunMCS'));

Start_date =  root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.InitialEpoch', satName, Segments(6).List));
Start_date = Start_date.Item(0);
Key = '= ';   
% Finds the spaces (key) and gets the number stored in the cetner)
Index = strfind(Start_date, Key);  
Start_date= Start_date(Index+2:length(Start_date));

for i = 6:length(Segments)
    [Locs.finOpt(i-5)] = pullCartesianMP(root,satName, Segments(i).List, 'FinalState');
end
[Locs.intOpt] = pullCartesianMP(root,satName, Segments(5).List, 'InitialState');

%% Retrieve Initial Contions of Each Maneuver

for i = 6:length(Segments)
    Init(i-5) = pullInitial2(root, satName, Segments(i).List);
end


%% Run Iterations 
clc;
fail = 0;
for i = 1:1
    % Create a new Satellite to run the new trajectory on. Using copy on a satellite that has one maneuver, one propagate, and all correct paramters
    % This is so that later, I will not need to set all the parameters for a new maneuver, but rather just duplicate and change duration and angle
    
    root2.ExecuteCommand(sprintf('Copy / */Satellite/TrajecToDup Name Trajec_%g', i));
    satName_temp = sprintf('Trajec_%g', i);
    
    
    
    
    % spacecraft solar radiation pressure
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Update.SRPAreaAction Set to new value', satName_temp));
    % root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Update.SRPAreaVal %g m^2', satName_temp, variables.SRP(i)));
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Update.SRPAreaVal %g m^2', satName_temp, .03));
    
    %spacecraft dry mass
    
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Update.DryMassAction Set to new value', satName_temp));
    %root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Update.DryMassVal %g kg', satName_temp, variables.dryMass(i)));
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Update.DryMassVal %g kg', satName_temp, 6.11));
    
    %spacecraft wet mass
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Update.FuelMassAction Set to new value', satName_temp));
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Update.FuelMassVal %g kg', satName_temp, variables.propMass(i) ));
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Update.FuelMassVal %g kg', satName_temp, 1.104));
    
    %spacecraft thruster alignment angle
    
    % root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.first_Flyby.SegmentList.Maneuver3.FiniteMnvr.Cartesian.Y %g', satName_temp, runprops(i).thrustAlign_Y));
    % root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.first_Flyby.SegmentList.Maneuver3.FiniteMnvr.Cartesian.Z %g', satName_temp, runprops(i).thrustAlign_Z));
    
    
    
    
    
    % Set the initial state for the trajectory
    X = Locs.intOpt.X; Y = Locs.intOpt.Y; Z = Locs.intOpt.Z;
    Vx = Locs.intOpt.Vx; Vy = Locs.intOpt.Vy; Vz = Locs.intOpt.Vz;
    
    
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.X %g km', satName_temp, X));
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Y %g km', satName_temp, Y));
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Z %g km', satName_temp, Z));
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vx %g km/sec', satName_temp, Vx));
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vy %g km/sec', satName_temp, Vy));
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vz %g km/sec', satName_temp, Vz));
    
    root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch %s', satName_temp,Start_date));
    
    
    
    propMass = variables.propMass(i);
    
    Epoch_start = Start_date;
    
    for k = 1:length(Locs.finOpt)
        Xf = Locs.finOpt(k).X; Yf = Locs.finOpt(k).Y; Zf = Locs.finOpt(k).Z;
        Vxf = Locs.finOpt(k).Vx; Vyf = Locs.finOpt(k).Vy; Vzf = Locs.finOpt(k).Vz;
        
        [status, Outputs] = calcManeuver(root2, 'MnvrCalc', X, Y, Z, Vx, Vy, Vz, Xf, Yf, Zf, Vxf, Vyf, Vzf, variables.dryMass(i), variables.SRP(i), propMass, Epoch_start, Init(k));
        
        if status
            propMass = Outputs.fuel;
            
            last_seg = addTrajec(root2, satName_temp, Outputs);
            
            root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s RunMCS', satName_temp));
            
            [Locs.finSeg] = pullCartesianMP(root2, satName_temp, last_seg, 'FinalState');
            Epoch_start = Locs.finSeg.t;
            
%             
%             X = Locs.finSeg.X+100*randn(1); Y = Locs.finSeg.Y+100*randn(1); Z = Locs.finSeg.Z+100*randn(1);
%             Vx = Locs.finSeg.Vx+.1*randn(1); Vy = Locs.finSeg.Vy+.1*randn(1); Vz = Locs.finSeg.Vz+.1*randn(1);

              X = Locs.finSeg.X; Y = Locs.finSeg.Y; Z = Locs.finSeg.Z;
              Vx = Locs.finSeg.Vx; Vy = Locs.finSeg.Vy; Vz = Locs.finSeg.Vz;



        else
            fail = fail+1;
            break
        end
        
    end
end









%%
% close all;
% 
% for i=1:numRuns
% dist(i) = sqrt((Xf-runprops(i).Xf)^2+(Yf-runprops(i).Yf)+(Zf-runprops(i).Zf));
% L(i) = runprops(i).dryMass;
% L1(i) = runprops(i).SRP;
% L2(i) = runprops(i).propMass;
% L3(i) = runprops(i).thrustAlign_Y;
% L4(i) = runprops(i).thrustAlign_Z;
% end
% 
% subplot(3, 2, 1)
% plot(L(:), dist(:),'.')
% title('DryMass')
% xlabel('Mass (Avg 6.11 kg)')
% ylabel('Dist (m)')
% 
% subplot(3, 2, 2)
% plot(L1(:), dist(:),'.')
% title('SRP')
% xlabel('SRP (Avg .03 m^2)')
% ylabel('Dist (m)')
% 
% subplot(3, 2, 3)
% plot(L2(:), dist(:),'.')
% title('Wetmass')
% xlabel('Mass (Avg 1.104)')
% ylabel('Dist (m)')
% 
% subplot(3, 2, 4)
% plot(L3(:), dist(:),'.')
% title('Yalign')
% xlabel('Y angle offset (rad)')
% ylabel('Dist (m)')
% 
% subplot(3, 2, 5)
% plot(L4(:), dist(:),'.')
% title('ZAlign')
% xlabel('Z angle offset (rad)')
% ylabel('Dist (m)')


%} 
%%


%%





%%
%a= root2.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValues MainSequence.SegmentList.Targeter.SegmentList.Maneuver.StoppingConditions.Duration.TripValue', 'MnvrCalc')); 
% a= root2.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValues MainSequence.SegmentList.Targeter.SegmentList.Propagate.StoppingConditions.Duration.TripValue 5 day', 'MnvrCalc')); 
% for i  = 0:a.count-1
%     a.Item(i)
% end

