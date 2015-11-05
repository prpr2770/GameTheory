%% Model describing the MAB-Agent playing the competition. 
classdef MABAgent < handle
    properties(SetAccess = private)
        % These can be modified only by class methods
        numSlotMachines = 10; %Initial random integer value
        pastReward = 0; % Records the rewards obtained till Last Step
        algoChoice = '';
        horizon = 0;
        
        % Model of the Environment
        slotCounts = [];        % Counts the #times Arm is pulled.
        slotMeans = [];
        
        % for UCB2 algo
        slotEpochs = [];
        inEpoch = 0;      
        prevArm = 0;
        
        % for THOMPSON Sampling
        slotSuccs = [];
        slotFails = [];
        
    end %properties
    
    methods
        % Constructor
        function AG = MABAgent(numArms, rewards, algoName, horizon)
            AG.numSlotMachines = numArms; %Modify as per question
            AG.pastReward = rewards;
            AG.algoChoice = algoName;
            AG.horizon = horizon;
            
            % Initialize model of the Environment
            AG.slotMeans = (1/numArms)*ones(1,numArms); 
            dims = size(AG.slotMeans);
            AG.slotCounts = zeros(dims);
            
            % For UCB-Algo
            AG.slotEpochs = zeros(size(AG.slotMeans));
            AG.inEpoch = 0;
            AG.prevArm = 0;
            
            % For THOMPSON SAMPLING
            AG.slotSuccs = zeros(size(AG.slotMeans));
            AG.slotFails = zeros(size(AG.slotMeans));

            %{
            % ==========================================================
            %For UCB-IMPROVED
            AG.BagOfArms = 1:totalArms;
            AG.InBagOfArms = ones(1,totalArms);
            AG.armsPulled = zeros(size(BagOfArms));
            %set epoch
            AG.Delta = 1;
            AG.inRound = floor(0.5*log2(Horizon/exp(1)));
            % #times Each Arms hould be pulled
            AG.timesEachArm = ceil(2*log(totalSteps*Delta^2)./Delta^2);
            % ==========================================================
            %}
        end
        
        % Arm-Selector
        function arm = agentArmSelect(obj,k,oldReward)
            
            % update the Rewards obtained by Agent : For given design of
            % competition code!
            obj.pastReward = oldReward;
            
            % Proceed with choosing arm
            switch obj.algoChoice
                case 'greedy'
                    arm = agentArmSelect_Greedy(obj, k);
                case 'softmax'
                    arm = agentArmSelect_Softmax(obj, k);
                case 'ucb1'
                    arm = agentArmSelect_UCB1(obj, k);
                case 'ucb2'
                    arm = agentArmSelect_UCB2(obj, k);
                case 'ucb-imp'
                    arm = agentArmSelect_UCBIMP(obj, k);
                case 'thompson'
                    arm = agentArmSelect_Thompson(obj,k);
                otherwise
                    arm = agentArmSelect_Random(obj, k);
            end
            
        end
        
        function agentArmUpdate(obj,arm,newReward)
            response = newReward - obj.pastReward;

            % Update ENV-MODEL with the information obtained!
            % -------------------------------------------------
            
            switch obj.algoChoice
                case 'greedy'
                    agentArmUpdate_Greedy(obj, arm, response)
                case 'softmax'
                    agentArmUpdate_Softmax(obj, arm, response)
                case 'ucb1'
                    agentArmUpdate_UCB1(obj, arm, response)
                case 'ucb2'
                    agentArmUpdate_UCB2(obj, arm, response)
                case 'ucb-bayes'
                    agentArmUpdate_UCBayes(obj, arm, response)
                case 'thompson'
                    agentArmUpdate_Thompson(obj, arm, response)
                otherwise %'random'
                    agentArmUpdate_Random(obj, arm, response)

            end
        end % AgentArmUpdate

        % ======================================================
        % RANDOM ALGORITHM 
        function arm = agentArmSelect_Random(obj, iter)
            %random choice of arm
            arm = randi(obj.numSlotMachines);
        end
           
        function agentArmUpdate_Random(obj, arm, response)
                    % update Value of Arms
                    if response >0
                        % the given arm obtained 1$ as output
                        fprintf('Last Reward %d \n',1);
                    else
                        % the given arm obtained 0$ as output
                        fprintf('Last Reward %d \n',0);
                    end    
                    
                    % increment count of ArmPulled!
                    obj.slotCounts(arm) = 1 + obj.slotCounts(arm) ;
            
        end
        % ======================================================
        % ======================================================
        % EPSILON-GREEDY ALGORITHM
        function arm = agentArmSelect_Greedy(obj, iter)
            epsilon = 0.1;
            if iter <=obj.numSlotMachines
                arm = iter;
            else
                coin = rand(1);
                if coin <= epsilon % Choose randomly
                    arm = randi(obj.numSlotMachines);
                else
                    [maxVal,maxInd] = max(obj.slotMeans);
                    arm = maxInd; % pick the best arm - Greedy
                end
            end
            
        end
        
        function agentArmUpdate_Greedy(obj, arm, response)
            % obtain past values
            oldCount = obj.slotCounts(arm);
            oldValue = obj.slotMeans(arm);
            % revise computations
            % NewEstimate = OldEstimate + (step-size)(Target - oldEstimate)
            newCount = oldCount + 1;  
            newValue = oldValue + (1/newCount)*(response - oldValue);
            %update the ENV-MODEL
            obj.slotCounts(arm) = newCount;
            obj.slotMeans(arm) = newValue;
        end
        % ======================================================
        % ======================================================
        % SOFTMAX ALGORITHM
        function arm = agentArmSelect_Softmax(obj, iter)
            tau = 0.07;
            if iter <=obj.numSlotMachines
                arm = iter;
            else
                coin = rand(1);
                %softmax-action selection rules
                armProbs = exp(obj.slotMeans / tau)/sum(exp(obj.slotMeans / tau))
                armChoices = 1:obj.numSlotMachines;
                arm = randsample(armChoices,1,true,armProbs);
            end
            
        end
        
        function agentArmUpdate_Softmax(obj, arm, response)
            % obtain past values
            oldCount = obj.slotCounts(arm);
            oldValue = obj.slotMeans(arm);
            % revise computations
            % NewEstimate = OldEstimate + (step-size)(Target - oldEstimate)
            newCount = oldCount + 1; 
            newValue = oldValue + (1/newCount)*(response - oldValue);
            %update the ENV-MODEL
            obj.slotCounts(arm) = newCount;
            obj.slotMeans(arm) = newValue;
        end
        % ======================================================
        % ======================================================
        % UCB1 : Peter Auer, Bianchi[2002]
        function arm = agentArmSelect_UCB1(obj,iter)
            if iter <= obj.numSlotMachines
                arm = iter;
            else
               armUCBs = obj.slotMeans + sqrt(2*log(iter-1)./ (obj.slotCounts));
               [maxVal, maxInd] = max(armUCBs);
               arm = maxInd;
            end
        end
        
        function agentArmUpdate_UCB1(obj,arm, response)
            % obtain past values
            oldCount = obj.slotCounts(arm);
            oldValue = obj.slotMeans(arm);
            % revise computations
            % NewEstimate = OldEstimate + (step-size)(Target - oldEstimate)
            newCount = oldCount + 1; 
            newValue = oldValue + (1/newCount)*(response - oldValue);
            %update the ENV-MODEL
            obj.slotCounts(arm) = newCount;
            obj.slotMeans(arm) = newValue;
            
        end
        
        % ======================================================
        % ======================================================
        % UCB2 : Peter Auer, Bianchi[2002]
        
        % Plays are divided into epochs. In each epoch, a machine i is
        % picked and then played [tau(r_i + 1) - tau(r_i)] times!
        % where,
        % tau(): exponential function
        % r_i : number of epochs played by the machine so far.
        % machine picked in each new epoch is hte one maximizing
        % bar(x_i) + a_{n,r_i}
        % n : current number of plays
        % a_{n,r} = sqrt( \frac {(1+alpha)ln(en/tau(r))}{2 tau(r)} )
        % tau(r) = ceil((1 + alpha)^r)
        %
        
        function arm = agentArmSelect_UCB2(obj,iter)
            alpha = 0.001;
            if iter <= obj.numSlotMachines
                arm = iter;
            else
                tau_epochs = ceil((1+alpha).^(obj.slotEpochs));
                UCBest_iter_epochs = sqrt((1+alpha).*(1 + log((iter-1)./tau_epochs))./(2*tau_epochs));
                armValues = obj.slotMeans + UCBest_iter_epochs;
                [maxVal, maxInd] = max(armValues);
                arm = maxInd;
                
                if (obj.inEpoch >0)
                    % COMPLETE PREVIOUS EPOCH
                    % play Arm j, exactly the number of times indicated in
                    arm = obj.prevArm;
                    % update the #times to play the arm!
                    obj.inEpoch = obj.inEpoch - 1;
                    % update epochCount at END of EPOCH
                    if obj.inEpoch == 0
                        obj.slotEpochs(arm) = obj.slotEpochs(arm) + 1;
                    end
                    
                else %(obj.inEpoch ==0)
                    % START A NEW EPOCH
                    arm = maxInd;
                    % determine #times to play ARM in this EPOCH
                    r = obj.slotEpochs(arm);
                    tau_oldRun = ceil((1+alpha)^r);
                    tau_newRun = ceil((1+alpha)^(r+1));
                    obj.inEpoch = tau_newRun - tau_oldRun -1;
                end % epoch-Conditions
            end % iter-loop
        end % function
        
        function agentArmUpdate_UCB2(obj,arm,response)
            % obtain past values
            oldCount = obj.slotCounts(arm);
            oldValue = obj.slotMeans(arm);
            % revise computations
            % NewEstimate = OldEstimate + (step-size)(Target - oldEstimate)
            newCount = oldCount + 1;
            newValue = oldValue + (1/newCount)*(response - oldValue);
            %update the ENV-MODEL
            obj.slotCounts(arm) = newCount;
            obj.slotMeans(arm) = newValue;
        end
        

        % ======================================================
        % ======================================================
        % Thompson Sampling: Agrawal
        
        function arm = agentArmSelect_Thompson(obj,iter)
            % Sample from Beta(S_i + 1, F_i + 1) distributions for each arm 
            succs = obj.slotSuccs + 1;
            fails = obj.slotFails + 1;
            thetaSamples = betarnd(succs,fails)
            [maxVal, maxInd] = max(thetaSamples);
            arm = maxInd;
        end
        
        function agentArmUpdate_Thompson(obj,arm, response)
            if response == 1
                % S_i = S_i + 1;
                obj.slotSuccs(arm) = obj.slotSuccs(arm) + 1;
            else
                % F_i = F_i + 1;
                obj.slotFails(arm) = obj.slotFails(arm) + 1;
            end
            
        end

        
        %{
        % ======================================================
        % ======================================================
        % UCB-Improved : Peter Auer, Ronald Ortner[2004]
        
        function arm = agentArmSelect_UCBIMP(obj,iter)
            %{
            %For UCB-IMPROVED
            AG.BagOfArms = 1:totalArms;
            AG.InBagOfArms = ones(1,totalArms);
            AG.armsPulled = zeros(size(BagOfArms));
            %set epoch
            AG.Delta = 1;
            AG.inRound = floor(0.5*log2(Horizon/exp(1)));
            % #times Each Arms hould be pulled
            AG.timesEachArm = ceil(2*log(totalSteps*Delta^2)./Delta^2);
                        
            %}
            totalArms = obj.numSlotMachines;
            if (sum(obj.armsPulledFlag) == 0 && obj.inRound > 0)%If no arms have been pulled
                
                %arbitrarily choose an Arm in the current BagOfArms
                validArms = length(obj.BagOfArms);
                arm = obj.BagOfArms(randi(validArms));
                obj.prevArm = arm;
                obj.armsPulledFlag(arm) = 1;
                obj.prevArmCount = 1;
            elseif (sum(obj.armsPulledFlag) > 0 && sum(obj.armsPulledFlag) < length(obj.BagOfArms))
                % ARM SELECTION
                if obj.prevArmCount <= obj.timesEachArm
                    arm = obj.prevArm;
                    obj.prevArmCount = obj.prevArmCount + 1;
                else % select new Arm in Bag
                    arm = obj.prevArm - 1;
                    obj.prevArm = arm;
                    obj.armsPulledFlag(arm) = 1;
                    obj.prevArmCount = 1;
                end
            else
                % ARM ELIMINATION
                n = obj.timesEachArm;
                horizon = obj.horizon;
                Delta = obj.Delta;
                UCB = sqrt(log(horizon*Delta^2)/2*n);
                slotLCBs = obj.slotMeans - UCB;
                maxLCB = max(slotLCBs);
                slotUCBs = obj.slotMeans + UCB;
                newArmsBag = (slotUCBs - maxLCB > 0);
                
                %update NewBagOfArms
                obj.InBagOfArms = newArmsBag;
                % create new BAG
                obj.BagOfArms = find(newArmsBag);
                obj.armsPulledFlag = zeros(size(obj.BagOfArms));
                
                %update Delta
                obj.Delta = obj.Delta/2;
                % update Rounds
                obj.inRound = obj.inRound - 1;
            end
        end
        
        function agentArmUpdate_UCBIMP(obj,arm, response)
            % obtain past values
            oldCount = obj.slotCounts(arm);
            oldValue = obj.slotMeans(arm);
            % revise computations
            % NewEstimate = OldEstimate + (step-size)(Target - oldEstimate)
            newCount = oldCount + 1;
            newValue = oldValue + (1/newCount)*(response - oldValue);
            %update the ENV-MODEL
            obj.slotCounts(arm) = newCount;
            obj.slotMeans(arm) = newValue;
        end
        
        %}
        % ======================================================
        % ======================================================
        
        
    end %methods
end %classdef

%% Notes about the above codes:
% 1. Algo: GREEDY - Determine Optimal epsilon to use for N=500.
% 2. Algo: SOFTMAX - Determine Optimal temperature to use for N=500.