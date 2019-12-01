clear; clc; close all;format long;format compact;
%Make sure there are no current instances of STK open, otherwise this code will not work. 

%% Generate normal distribution of variables
%per iteration variables
variables.mass = 5.2+.2*randn(1000,1); % kg, Spacecraft mass
variables.thrustTime = .1+.02*randn(1000,1); %sec, thruster pulse time
variables.thrustAlign = deg2rad(2*randn(1000,1)); %radians, thruster on axis alignment 
variables.orientAcc = deg2rad(2*randn(1000,1)); %radians, re-orientation/ADCS accuracy 
variables.specImp = 270+40*randn(1000,1); %sec, specific impulse
variables.propMass = .9 + 5E-3*randn(1000,1); %kg, propellant mass
variables.PPP = 1E-3+(1E-3)*.05*randn(1000,1); %kg, propellant per pulse
variables.clockERR = 1*randn(1000,1); %clock error, fire @time inaccuracy 

%per segment variables
variables.thrustForce = 1+.1*randn(1000,1); %newtons, thruster force
variables.posAcc = 1000*randn(1000,1); %km, position knowledge accuracy
variables.posVel = 10*randn(1000,1); %m/s velociy knowledge accuracy


%% Open the desired Scenario 
% Run STK and create new instance 
app = actxserver('STK10.application');
app.UserControl = 1;
root = app.Personality2;    % Grab handle on the STK application root to execute commands

%loads the desired scenario; INPUTS: (root, 'Scenario Path')
%main Trajec
%loadScen(root, 'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Trajectories\Spring 2019\Original_copy\feb2019-oct18copy.sc')

%used to test 
loadScen(root, 'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Trajectories\Spring 2019\date change\copy of trajectories\copy-of-date-change.sc')

% Name desired satellite here
satName = 'CurrentNom';
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


% for i to end of sgment list
k=1;
for i = 1:ASTGSegments.count
[subseg] = IsSubSeg(root, satName, Segments(i).names)

% if subseg(1).names == 1
%     for
%         
%     end
% end
% 














