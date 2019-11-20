function [subseg] = IsSubSeg(root, satName, segName)

% [subseg] = IsSubSeg(root, satName, segName)
%this code determines if the name is the segment list is a targeter or the base segment. 

%this pulls out the properties of the entire segment.
properties =  root.ExecuteCommand(sprintf('Astrogator_RM */Satellite/%s GetValue MainSequence.SegmentList.%s', satName, segName));
   

% Converts all the strings to just the property name 
Key   = ' ';
for i= 0:properties.Count-1  
    
   % pulls each string out 
   props(i+1).string = sprintf(properties.Item(i));
   
   %reads just segment name from string 
   Index = strfind(props(i+1).string, Key);
   props(i+1).names = sscanf(props(i+1).string(1:Index), '%s');
end


%if there is a property title "SegmentList", then there are base segments within the targeter that we would like to introduce uncertainty to
str1 = 'SegmentList';
comp = 0;
i= 0;
while comp == 0 && i < properties.count
    i = i+1;
    comp = strcmp(props(i).names, str1);
end

% Comp establishes whether or not the string "SegmentList" exists in the list of properties

if comp == 1
      
   %reads just segment name from string 
   Index = strfind(props(i).string, Key);
   subseg.bool(1) = comp;
   for k = 2:length(Index)-1
       subseg(k-1).names = sscanf(props(i).string(Index(k):Index(k+1)), '%s');
   
   end
else 
    subseg.bool(1) = comp;
end
end