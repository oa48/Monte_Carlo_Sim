function copySegment(root, satName, MT)
% copySegment(root, satName, MT)

% MT = 'M' or 'P';
% root must be defined in the primary code
% satName specifies which satellite you are working with 

if strcmp(MT, 'M')
% duplicate Maneuver
sat = root.GetObjectFromPath(sprintf('*/Satellite/%s', satName));
prop = sat.Propagator;
mcs = prop.MainSequence;
sequence = mcs.Item(2);
mcs.InsertCopy(sequence, 'STOP')

else 
% duplicate Propagate
sat = root.GetObjectFromPath(sprintf('*/Satellite/%s', satName));
prop = sat.Propagator;
mcs = prop.MainSequence;
sequence = mcs.Item(3);
mcs.InsertCopy(sequence, 'STOP')

end