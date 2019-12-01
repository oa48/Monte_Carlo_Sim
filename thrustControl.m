function thrustControl(root, satName, sit)
% thrustControl(root, satName, tf)

%tf is a string 'True' or 'False' to determine whether the first maneuver is allowed satellite control
% root must be defined in the main code
%satName is the maneuver calculator targeter 

% sit = 1 means we have a maneuver which will recieve access to control the thrust of maneuver
% sit = 2 means we have a propagation which will not reeive maneuver control
% sit = 3 means we have a propagation which will recieve maneuver control


%%
if sit == 1
    tf = 'true';
    hom = 'false';
    tf2 = 'false';
    
elseif sit ==2
    tf = 'false';
    hom = 'false';
    tf2 = 'false';
    
elseif sit == 3
    tf = 'true';
    hom = 'false';
    tf2 = 'true';
end



%% Targeter Access to first Maneuver (axes)

%activates or disables the angle control for the thruster. 
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayControls.Maneuver_:_FiniteMnvr_Cartesian_X.Active %s', satName, tf));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayControls.Maneuver_:_FiniteMnvr_Cartesian_Y.Active %s', satName, tf));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayControls.Maneuver_:_FiniteMnvr_Cartesian_Z.Active %s', satName, tf));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayControls.Maneuver_:_FiniteMnvr_StoppingConditions_Duration_TripValue.Active %s', satName, tf));

root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.DisplayControls.Propagate1_:_StoppingConditions_Duration_TripValue.Active %s', satName, tf2));



% enables or disables homotopy. this is used when the initial guess is bad. 
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.UseHomotopy %s', 'MnvrCalc', hom));



    



















end