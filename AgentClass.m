classdef AgentClass
    properties
        % parameters about self
        totalActions = 3;       % equal to totalRosources
        epsilon = 0.1;          % jsfp with inertia
        
        % parameters about Game
        totalIter = 10;         % number of iterations of simulations
        totalPlayers = 0;
        
        % properties of my-behavior
        myAction = 0;
        myAction_Indicator = [];
        myAction_t = [];
        
        % -----------------------------------------------------------------
        % implementation using iterative algorithm
        
        % storing regret for action-choices
        % regretActions = zeros(totalIter,totalActions);
        expUtilityOverActions = [];       % zeros(totalIter,totalActions) %avgCongestion on route upto day t, if agent chose each of
        regretOverActions = [];
        
        
        averageCongestionCosts = [];       % Is this needed? How is it computed? What does it compute?
        
        % ---------------------------------------------------------------
        %{
        % implementation using empirical frequencies
        
        % otherAgentsActionFrequency -> each dimension corresponds to each
        % resource. At any given time, max number of agents on each resource is
        % (totalAgents-1). Every agent uses this much memory to track the
        % frequecies of other agent's play.
        otherAgents_JointActionFrequency = [];
        othersActionProfileIndex = [];
        
        %}
        % ---------------------------------------------------------------
    end
    
    methods
        % Constructor
        function obj = AgentClass(numActions, epsilon, totalPlayers, iterations)
            if nargin > 0
                
                obj.totalActions = numActions;
                obj.epsilon = epsilon;
                
                obj.totalIter =  iterations;
                obj.totalPlayers = totalPlayers;
                
                % update myAction
                obj.myAction_t = zeros(iterations,1);
                obj.getAction(0);
                obj.expUtilityOverActions = zeros(iterations,numActions);
                obj.regretOverActions = zeros(iterations,numActions);
                obj.averageCongestionCosts = zeros(iterations,numActions);
                
                % ------------------------------------------------------
                %{
                % initialize joint-action-freq.
                % set up JointAction_Frequency for agents
                % |{0,1,2,... (totalAgents-1)}| = totalAgents
                jaf_agentFactor = (totalPlayers)*ones(1,numActions);
                obj.otherAgents_JointActionFrequency = zeros(jaf_agentFactor);
                %}
                
            else
                error('Requires 4 parameters to construct class')
            end
        end
        % -----------------------------------------------------------------
        % General Methods   : function that DO NOT have the OBJ as
        % input/output
        
        function othersActionProfileIndex = getOthersActionProfileIndex(obj, num_OtherAgents_OnResources)
            if sum(num_OtherAgents_OnResources < 0,2) == 0 % if no values are negative
                
                othersActionProfileIndex = num_OtherAgents_OnResources + ones(size(num_OtherAgents_OnResources));
                
            else
                error('num_OtherAgents_OnResources < 0');
            end
        end
        
        % -----------------------------------------------------------------
        % General Methods   : function that DO have the OBJ as
        % input/output
        function myActionIndicator = getMyActionIndicator(obj, action)
            myActionIndicator = zeros(1,obj.totalActions);
            myActionIndicator(action) = 1;
            
        end
        
        function [action , obj] = getAction(obj, time)
            % function action = getAction(obj, time)
            if time > 1
                learningAlgo = 'jsfp_inertia';
            else
                learningAlgo = 'random';
            end
            
            switch learningAlgo
                case 'random'
                    % randomly generate action
                    action = ceil(obj.totalActions * rand());
                    
                case 'jsfp'
                    disp('jsfp');
                    [val action]= min(obj.expUtilityOverActions(time-1,:));

                        
                    
                case 'jsfp_inertia'
%                     disp('jsfp_inertia');
                    coinToss = rand();
                    if coinToss <= obj.epsilon
                        % play past action
                        action = obj.myAction;
                    else
                        % choose the min-action from expectedUtility
                       [val action]= min(obj.expUtilityOverActions(time-1,:)); 
                    end
                    
            end
            
            % update internal state variables
            obj.myAction = action;
            obj.myAction_Indicator = obj.getMyActionIndicator(action);
            if time > 1
                obj.myAction_t(time) = action; 
            end
            
            
        end
        
        function obj = updateAgentExpectedUtility(obj, numAgentsOnResources, actualCongestionCosts, time)
           
            % remove the contribution of the present player
%             msg = sprintf('Agent: numAgentsOnResources = \n');
%             warning(msg)
%             numAgentsOnResources
            num_OtherAgents_OnResources = numAgentsOnResources - obj.myAction_Indicator;

            % -------------------------------------------------------------
            % update expectedUtility of each action
            agentUtility = zeros(1,3);
            for road=1:3
                roadIndicator = obj.getMyActionIndicator(road);
                numAgentsOnRoad = num_OtherAgents_OnResources + roadIndicator;
                roadCongestionCost =  getRoadCongestionCosts(numAgentsOnRoad);
                agentUtility(road) = roadCongestionCost(road);
            end
            
            if time > 1
                % implement the update algorithm
                obj.averageCongestionCosts(time,:) = (1/time)*( (time-1)*obj.averageCongestionCosts(time-1,:) + actualCongestionCosts)
                obj.expUtilityOverActions(time,:)  = (1/time)*( (time-1)*obj.expUtilityOverActions(time-1,:) + agentUtility );
                obj.regretOverActions(time,:) = obj.expUtilityOverActions(time,:) - actualCongestionCosts; % obj.averageCongestionCosts(time,:);
            else
                % initialize to costs when no cars are on roads
                obj.averageCongestionCosts(time,:) = actualCongestionCosts;
                obj.expUtilityOverActions(time,:)  = zeros(1,obj.totalActions);
                obj.regretOverActions(time,:) = zeros(1,obj.totalActions);
            end
    
        end
        
        
        
        function plotAgentRegret(obj)
                       fig2 = figure()
           subplot(2,1,1)
           plot(obj.expUtilityOverActions)
           xlabel('Time')
           ylabel('expUtility over Roads')
           title('Expected Utility of Agent over time')
           legend('r1', 'r2', 'r3')
           
           subplot(2,1,2)
           plot(obj.regretOverActions)
           xlabel('Time')
           ylabel('Agent Regret')
           title('Agent Regret over time')
           legend('r1', 'r2', 'r3')
           
           
           fig3 = figure()
           plot(obj.myAction_t)
           title('Action-choice of agent')
        end

        %{
        % =================================================================
        function obj = updateAgentJointActionFrequency(obj, numAgentsOnResources, congestionCosts, time)
            
            % why is this being done?
            obj.congestionCostsOverTime(time,:) = congestionCosts;
            
            % remove the contribution of the present player
            msg = sprintf('Agent: numAgentsOnResources = \n');
            warning(msg)
            numAgentsOnResources
            num_OtherAgents_OnResources = numAgentsOnResources - obj.myAction_Indicator;
            
            % if sum(num_OtherAgents_OnResources<1,2) == 0
            if sum(num_OtherAgents_OnResources>1,2) > 0
                % compute the new empiricalFrequencies of other players
                jaf_updateMatrix = zeros(size(obj.otherAgents_JointActionFrequency));
                num_OtherAgents_OnResources
                obj.othersActionProfileIndex = obj.getOthersActionProfileIndex(num_OtherAgents_OnResources);
                jaf_updateMatrix(obj.othersActionProfileIndex) = 1;
                obj.otherAgents_JointActionFrequency = ((time-1)*obj.otherAgents_JointActionFrequency + jaf_updateMatrix) *(1/time);
            else
                % error('No contribution of other players to empirical frequency.')
                warning('No contribution of other players to empirical frequency.')
                
                size(obj.otherAgents_JointActionFrequency)
                obj.otherAgents_JointActionFrequency = ((time-1)/time)*obj.otherAgents_JointActionFrequency;
            end
            

        end
        %}
        % ==================================================================
        
    end % methods
    
end % agentClass