function [last_seg] = addTrajec(root, satName, Outputs)
%% Create new maneuvers
copySegment(root, satName, 'P');
copySegment(root, satName, 'M');
copySegment(root, satName, 'P');
copySegment(root, satName, 'M');
copySegment(root, satName, 'P');

%% Gets the current list of segments 

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

last_seg = Segments( length(Segments)-2).names;
%% Propagate durations

root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.StoppingConditions.Duration.TripValue %g sec', satName, Segments(length(Segments)-6).names, Outputs.Propagate(1)));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.StoppingConditions.Duration.TripValue %g sec', satName, Segments(length(Segments)-4).names, Outputs.Propagate(2)));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.StoppingConditions.Duration.TripValue %g sec', satName, Segments(length(Segments)-2).names, Outputs.Propagate(3)));


%% Maneuver Properties

root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.FiniteMnvr.Cartesian.X %g', satName, Segments(length(Segments)-5).names, Outputs.Mnvr(1).x));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.FiniteMnvr.Cartesian.Y %g', satName, Segments(length(Segments)-5).names, Outputs.Mnvr(1).y));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.FiniteMnvr.Cartesian.Z %g', satName, Segments(length(Segments)-5).names, Outputs.Mnvr(1).z));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.StoppingConditions.Duration.TripValue %g sec', satName, Segments(length(Segments)-5).names, Outputs.Mnvr(1).t));


root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.FiniteMnvr.Cartesian.X %g', satName, Segments(length(Segments)-3).names, Outputs.Mnvr(2).x));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.FiniteMnvr.Cartesian.Y %g', satName, Segments(length(Segments)-3).names, Outputs.Mnvr(2).y));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.FiniteMnvr.Cartesian.Z %g', satName, Segments(length(Segments)-3).names, Outputs.Mnvr(2).z));
root.ExecuteCommand(sprintf('Astrogator */Satellite/%s SetValue MainSequence.SegmentList.%s.StoppingConditions.Duration.TripValue %g sec', satName, Segments(length(Segments)-3).names, Outputs.Mnvr(2).t));

end


