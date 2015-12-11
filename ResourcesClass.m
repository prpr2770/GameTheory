classdef ResourcesClass
    %{
    Congestion on each road:
    c1(n1) = 40 + n1;
    c2(n2) = 20 + n2^2;
    c3(n3) = 1 + 5 n3^2

    [c1 c2 c3]' = [40 20 1]' + [1 0 0]'.*[n1 n2 n3]' + [0 1 1]'.*[n1 n2 n3].^2;
    %}
    properties
        totalResources = 3;       % equal to totalRosources
        totalIter = 10;
        
        
        % measurements by platform
        
        numAgentsOnEachResource = [];   %zeros(1,numResources);
        resourceCongestion = [];        %zeros(1,numResources);

        numAgentsOnResources_t = [];    %zeros(totalIter, totalResources);
        resourceCongestion_t = [];      %zeros(totalIter, totalResources);
    end
    
    methods
        % Constructor
        function obj = ResourcesClass(numResources, totalIter)
            if (nargin > 0)
                if isnumeric(numResources)
                    obj.totalResources = numResources;
                    obj.totalIter = totalIter;
                    obj.numAgentsOnEachResource = zeros(1,numResources);
                    obj.resourceCongestion = zeros(1,numResources);
                    obj.numAgentsOnResources_t = zeros(totalIter, numResources);
                    obj.resourceCongestion_t = zeros(totalIter, numResources);
                else
                    error('numResources should be numeric.')
                end
            end
        end
        
        
        % General Method
        function [congestion, obj] = getResourceCosts(obj, numAgentsOnResources, time)
            % present code is only for 3 resources
            if (size(numAgentsOnResources,2) == 3)
                
                congestion = getRoadCongestionCosts(numAgentsOnResources);
                
                obj.numAgentsOnEachResource = numAgentsOnResources;   %zeros(1,numResources);
                obj.resourceCongestion = congestion;        %zeros(1,numResources);
                
                % archive in time-based manner
                obj.numAgentsOnResources_t(time,:) = numAgentsOnResources;
                obj.resourceCongestion_t(time,:) = congestion;
                
            else
                error('ResourceClass defined only for 3 resources.');
            end
            
        end % GET_RESOURCES_COST
        
        function plotResourceCongestion(obj)
            
           fig1 = figure()
           subplot(2,1,1)
           plot(obj.numAgentsOnResources_t)
           xlabel('Time')
           ylabel('number of agents on each road')
           title('Road Occupancy over time')
           legend('r1', 'r2','r3')
           
           subplot(2,1,2)
           plot(obj.resourceCongestion_t)
           xlabel('Time')
           ylabel('congestion costs on each road')
           title('Congestion costs over time')
           legend('r1', 'r2', 'r3')
           
            
        end
        
    end % METHODS
    
end % CLASSDEF