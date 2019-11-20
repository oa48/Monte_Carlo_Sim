function [Segments] = removeTargeters(root, satName, Segments)

% function [Segments] = removeTargeters(root, satName, Segments)

% This code changes the names of the segments to one that pulls out subsegments as individual components for easier use later


% root must be defined in main code
% satName is satellite name
% Segments is list of Astrogator segments from Mission Control Sequence




% define the structs 
List = struct;
Seg = struct;



%remove 'stop' and '-' segments from mission control sequence list
for i =1:length(Segments)-2
    
   subseg = IsSubSeg(root,satName, Segments(i).names);      %refer to IsSubSeg.m
   
   %If section is a targeter and subsegments, this will rewrite them out in a "path" form to access later
   if subseg(1).bool
       
       for g = 1:length(subseg)
       Seg(length(Seg)+1).List= sprintf('%s.SegmentList.%s', Segments(i).names, subseg(g).names);
       end
       
   else         %if there is no subsegment, store the maneuver or propaagte as is
       Seg(length(Seg)+1).List = Segments(i).names;
   end
end
% puts info back into segments struct
for i = 1:length(Seg)
Segments(i).List = Seg(i).List;
end
end