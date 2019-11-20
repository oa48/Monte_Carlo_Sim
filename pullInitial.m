%pullInitial(root, Segments)





i = 8;
segment = Segments(i).List;

Key = '.';
Index = strfind(segment, Key);
skip = isempty(Index)

if skip==0
%% Pull out the segments name, targeter name, and type of segment
% this pulls out from the segment name whether it is a maneuver or propagation to determine what data needs to be pulled out
temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Type', satName, segment));
 if strcmp('Type = Maneuver', temp.Item(0))
     type = 'M';
 else 
     type = 'P';
 end
 
 % Separate the segment name back into "targeter" name and "segment" name
 Key = '.';
 Index = strfind(segment, Key);
 targName = segment(1:Index(1)-1);
 segName = segment(Index(length(Index))+1:length(segment));

%% Pull out the Possible differential correcters inside the targeter

temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList.%s.Profiles',targName));

Key   = ' ';
for i= 0:temp.count-1
    
   % pulls each string out 
   diffCor = temp.Item(i);
   
   %reads just segment name from string 
   Index = strfind(diffCor, Key);
   diffCorr(i+1).names= sscanf(diffCor(1:Index(1)), '%s');
end

%% determines whether a segment is in the differential correcter. 
clc
for i = 1:length(diffCorr)
    temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Profiles.%s.Controls',satName, targName, diffCorr(i).names));
    
    for k = 0:temp.Count-1
        temp1 = temp.Item(k);
        Key = '_';
        Index = strfind(temp1, Key);
        found = strcmp(segName, temp1(1:Index(1)-1));
        
        
        if found
            active = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Profiles.%s.DisplayControls.%s_:_FiniteMnvr_StoppingConditions_Duration_TripValue.Active', satName, targName, diffCorr(i).names, segName));
            active1 = active.Item(0);
            
            Key = '= ';
            Index = strfind(active1, Key);
            found2 = strcmp('true', active1(Index+2:length(active1)));
            if found2
                break
            end
        end
    end
    if found2
        break
    end
    
end
diff_name = diffCorr(i).names;



    %% Pull the data out of the determined differential corrector
if found2

    if strcmp(type, 'M')
        temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Profiles.%s.DisplayControls.%s_:_FiniteMnvr_StoppingConditions_Duration_TripValue.Active', satName, targName, diff_name, segName));
    else
        temp = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Profiles.%s.DisplayControls.%s_:_FiniteMnvr_StoppingConditions_Duration_TripValue.Active', satName, targName, diff_name, segName ));
    end
      
    
end

end

% %%
% clc
% %a = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList.firstFlyby.Profiles.Differential_Corrector1.Controls'))
% clc
% %a = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList.firstFlyby.Profiles.Differential_Corrector1.DisplayControls'))
% %a = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Profiles.%s.DisplayControls.%s_:_FiniteMnvr_StoppingConditions_Duration_TripValue.Active', satName, targName, diffCorr(1).names, segName ));
% a = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s.Profiles.%s.DisplayControls', satName, targName, diff_name, segName));


clc;
a = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetMCSControlValue MainSequence.SegmentList.%s.Profiles.%s %s FiniteMnvr.StoppingConditions.Duration.TripValue FinalValue',  satName, targName, diff_name, segName));
%a = root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/CurrentNom GetValue MainSequence.SegmentList.firstFlyby.Profiles.Differential_Corrector1'));




for i  = 0:a.count-1
    a.Item(i)
end
i = 10;






