% Joint Strategy Fictitious Play with Inertia
%{
3 parallel roads; 60 vehicles;
n_r be number of vehicles on road r. 

time - determines number of rows of matrix! time varies along a col.

%}

close all; clear all;clc;

totalAgents = 60;            % 
totalResources = 3;         % roads
epsilon = 0.1;              % learning-inertia

numIterations = 200;             % total-iterations of the game-play.


% -------------------------------------------------------------------------
% initialize Agents
numActions = totalResources;
for i = 1:totalAgents    % iterate over agents to make them update their internal state
    msg = sprintf('P%d = AgentClass(numActions, epsilon, totalAgents, numIterations);',i);
    eval(msg);
end

% -------------------------------------------------------------------------
% initialize roads
ROADS = ResourcesClass(totalResources, numIterations);

% -------------------------------------------------------------------------
% time-iterations of jsfp_inertia

for t=1:numIterations
   
    % obtain Agents' action-choices
    actionProfile = zeros(1,totalAgents);
    for i = 1:totalAgents    % iterate over agents to get their action-choice
        msg1 = sprintf('P%d',i);
        msg2 = sprintf('P%d.getAction(t);',i);
        eval(['[actionProfile(i), ',msg1,'] = ',msg2,';']);
    end
%    msg = sprintf('Platform: actionProfile = \n');
%    disp(msg)    % warning(msg)
%    actionProfile
   
   %----------------------------------------------------------------------
   % compute number of agents on each resource
   numAgentsOnResources = zeros(1,totalResources);
   for i = 1: totalResources
      numAgentsOnResources(i) =  sum((actionProfile == i),2) ;
   end
%    msg = sprintf('Platform: numAgentsOnResources = \n');
%    disp(msg)    % warning(msg)
%    numAgentsOnResources
   
    %----------------------------------------------------------------------
    % compute congestion costs experienced
   [congestionCosts, ROADS] = ROADS.getResourceCosts(numAgentsOnResources,t);
   
    %----------------------------------------------------------------------
   % provide Utility to Agents
   for i = 1:totalAgents    % iterate over agents to make them update their internal state
       
       % update Expected-Utility of each arm
       msg = sprintf('P%d = P%d.updateAgentExpectedUtility(numAgentsOnResources, congestionCosts, t) ;', i, i);
       eval(msg);
       
       
%        % update JointAction Empirical Frequency
%        msg = sprintf('P%d = P%d.updateAgentJointActionFrequency(numAgentsOnResources, congestionCosts, t);', i, i)
%        eval(msg);

   end
   
   
   
end

ROADS.plotResourceCongestion();
P1.plotAgentRegret();
% -------------------------------------------------------------------------