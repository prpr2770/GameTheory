classdef Agent < handle
    properties(SetAccess = private) 
        % These can be modified only by class methods
       slotModels = zeros(1,numSlotMachines);  
       pastReward = 0; % Records the rewards obtained till Last Step
       numSlotMachines = 10; %Initial random integer value
    end %properties
    
    methods
        % Constructor 
        function AG = Agent(numArms, rewards)
            AG.numSlotMachines = numArms; %Modify as per question
            AG.slotModels = zeros(1,numArms);
            AG.pastReward = rewards;
        end
        
        % Arm-Selector
        function arm = agentArmSelect(obj,k,oldReward)
            obj.pastReward = oldReward;
            %random choice of arm
            arm = randi(obj.numSlotMachines);
        end
        
        function agentArmUpdate(obj,arm,newReward)
            response = newReward - obj.pastReward;
            if response >0:
                % the given arm obtained 1$ as output
            else
                % the given arm obtained 0$ as output
            end
        end
    end %methods
end %classdef
