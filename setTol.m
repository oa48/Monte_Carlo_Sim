function setTol(root, satName, velTol, posTol)
% setTol(root, satName, velTol, posTol)

% root must be defined in the primary code

% changes the tolerance of the differential corrector

root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.Results.Propagate2_:_Vx.Tolerance %g km/sec', satName, velTol ));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.Results.Propagate2_:_Vy.Tolerance %g km/sec', satName, velTol ));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.Results.Propagate2_:_Vz.Tolerance %g km/sec', satName, velTol ));

root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.Results.Propagate2_:_X.Tolerance %g km', satName, posTol ));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.Results.Propagate2_:_Y.Tolerance %g km', satName, posTol ));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.Targeter.Profiles.Differential_Corrector1.Results.Propagate2_:_Z.Tolerance %g km', satName, posTol ));

end



