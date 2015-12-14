%{
Log Linear Learning:

Pay-off matrix for the 2-player 2-action game.
          a2          b2
a1      (3,3)       (0,4)
b1      (4,0)       (1,1)


PHI
        -2              -1
        -1              0
%}

function playLogLinearLearning()
clear all; close all;

T = 100; % 0.1 1, 10, 100
totalIterations = 10000;
totalAgents = 2;
totalActions = 2

% Define the payoff matrix
payoffMatrix =zeros(totalActions,totalActions,totalAgents);
if totalActions == 2 && totalAgents == 2
    payoffMatrix(:,:,1) = [3 0; 4 1];
    payoffMatrix(:,:,2) = [3 4; 0 1];
else
    error('Code is written for 2agents, 2 actions only.')
end

% Define the UtilityMatrix
utilityMatrix = exp((1/T)*payoffMatrix);

PHI = [-2 -1; -1 0];
PHI_utility = exp(1/T*PHI);
PHI_utility = PHI_utility./sum(PHI_utility(:));
PHI_utility_t = repmat(PHI_utility,1,1,totalIterations);

% Define the JointAction_Frequency
jaf_Matrix = zeros(2,2,totalIterations);

% store actions over time
agentActions_overTime = zeros(totalIterations,totalAgents);

for t=1:totalIterations
    % ----------------------------------------------------------------
    % slect new actions
    if t>1
        prevActions = agentActions_overTime(t-1,:);
        
        
        % player 1
        plyrID = 1; oppID = 2;
        p1_action = getPlayerAction_LogLinear(plyrID, oppID, prevActions, utilityMatrix);
        
        % player 2
        plyrID = 2; oppID = 1;
        p2_action = getPlayerAction_LogLinear(plyrID, oppID, prevActions, utilityMatrix);
        
        newActions = [p1_action p2_action];
        
        newAction_Indicator = getActionIndicatorMatrix(newActions);
        jaf_Matrix(:,:,t) = (1/t)*( (t-1)*jaf_Matrix(:,:,t-1) + newAction_Indicator );
    else
        % initialize game by agents' selecting random actions
        newActions = ceil(2*rand(1,totalAgents));
        newAction_Indicator = getActionIndicatorMatrix(newActions);
        jaf_Matrix(:,:,t) = newAction_Indicator;
    end
    
    % ----------------------------------------------------------------
    % store presentActions
    agentActions_overTime(t,:) = newActions;
    
    % ----------------------------------------------------------------
    
    
    
end% time-iterations

% ----------------------------------------------------------------------
% Plot Iterations:

fig1 = figure(1)
colormap parula
count = 0;
for i = 1:2
    for j = 1:2
        count = count + 1;
        subplot(2,2,count)
        y = reshape(jaf_Matrix(i,j,:), 1,[]);
        plot(1:totalIterations, y,'g')
        hold on
        y = reshape(PHI_utility_t(i,j,:), 1,[]);
        axis([1 totalIterations 0 0.5])
        plot(1:totalIterations, y,'r')
        hold off
    legend('emp.freq', 'analytical dist.')
    msg = sprintf('(ROW,COL) = (%d, %d)',i,j);
    title(msg)        
    end
end

disp('Analytical Frequencies for the different states:')
PHI_utility
disp('Temp. parameter')
T 

end

function action = getPlayerAction_LogLinear(playerID, opponentID, prevActions, utilityMatrix)

oppAction = prevActions(opponentID);

if opponentID == 2
    % extract probability of choosing between actions
    agentUtility = reshape(utilityMatrix(:,oppAction,playerID),1,[]); % row-vector
else
    % extract probability of choosing between actions
    agentUtility = reshape(utilityMatrix(oppAction,:,playerID),1,[]); % row-vector
end
probVector = agentUtility./sum(agentUtility);
coinToss = rand();
if coinToss <= probVector(1)
    action = 1;
else
    action = 2;
end

end

function newAction_Indicator = getActionIndicatorMatrix(actionProfile)

if length(actionProfile) == 2
    newAction_Indicator = zeros(2,2);
    newAction_Indicator(actionProfile(1),actionProfile(2)) = 1;
else
    error('length(actionProfile) ~= 2:  More than 2 agents assumed!')
    
end

end