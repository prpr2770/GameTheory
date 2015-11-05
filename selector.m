function selector()

% Parameters given by Prof:
global token reward
horizon = 500;
% ---------------------------------------------------------------------

numArms = 10; %numSlotMachines the Agent shall play
algoName = 'ucb2'; % 'greedy' 'softmax' 'ucb1' 'ucb2' 'thompson' 
AG = MABAgent(numArms,reward, algoName, horizon);

% Plotting Function:
% ---------------------------------------
trackArms = zeros(1,horizon);
trackRewards = zeros(1,horizon);
% ---------------------------------------------------------------------
% Simulation Run of the Agent's Finite Time-step play 
for k=1:horizon
    arm = AG.agentArmSelect(k, reward); % select new arm and archive old rewardValue
    slotmachine(arm) ; % ENVIRONMENT
    AG.agentArmUpdate(arm, reward); % update slotMachineModel with reward info obtained.
    
    % ----------------
    trackArms(k) = arm;
    trackRewards(k) = reward;
end


fig1 = figure(1)
subplot(2,1,1)
plot(trackArms)
subplot(2,1,2)
hist(trackArms)

fig2 = figure(2)
plot(trackRewards)