function [A1, A2] = cournot(M1, M2, a1, a2, N)
% Simulate Cournot adjustment dynamics for 2 player matrix games with each
% agent having FINITE ACTION SET.

% ---------------------------------------------------
% M1, M2              : Reward matrices for players 1,2 respectively
% a1, a2              : Initial actions of each player
% N                   : Number of stages of play
% A1, A2              : Action history for each player.
% ---------------------------------------------------

% Initalize column vectors 
A1 = zeros(N+1,1);
A2 = zeros(N+1,1);

A1(1) = a1; A2(1) = a2;

% Determine rewards
rwd_1 = M1(a1,a2);
rwd_2 = M2(a1,a2);

%iterate over time-stages
for t=2:N+1

    % Determine Agent_1 BestResponse to Agent2's previous Action
[maxVal, maxIndx] = max(M1(:,a2));
if (maxVal > rwd_1)
    A1(t) = maxIndx;
else 
    A1(t) = A1(t-1);
end

% Determine Agent_2 BestResponse to Agent1's previous Action
[maxVal, maxIndx] = max(M2(a1,:));
if (maxVal > rwd_2)
    A2(t) = maxIndx;
else 
    A2(t) = A2(t-1);
end

% Update the actions and rewards
a1 = A1(t);
a2 = A2(t);
 
rwd_1 = M1(a1,a2);
rwd_2 = M2(a1,a2);

end