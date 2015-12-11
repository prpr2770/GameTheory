function congestion = getRoadCongestionCosts(numAgentsOnResources)
if size(numAgentsOnResources,2) == 3
    congestion = [40 20 1] + [1 0 0].*numAgentsOnResources + [0 1 5].*numAgentsOnResources.^2;
    
else
    error('getRoadCongestionCosts defined only for 3 roads.');
end
end