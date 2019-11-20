function loadScen(root, scenPath)

% Load a scenario with the location defined by "scenPath"
% Input to scen path must include single quotes

% scenPath entry example: 
% 'C:\Users\CisLunar\Documents\LunarCubeSat\STK\Trajectories\Spring 2019\date change\copy of trajectories\copy-of-date-change.sc'

% "root" should be defined in the main code to allow Matlab to send commands to STK



    root.ExecuteCommand(sprintf('Load / Scenario "%s" ', scenPath));
    
     
end