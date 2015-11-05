 function [A1, A2] = cournot_probabilistic(M1, M2, a1, a2, N, p)
% Simulate Cournot adjustment dynamics for 2 player matrix games with each
% agent having FINITE ACTION SET.

% ---------------------------------------------------
% M1, M2              : Reward matrices for players 1,2 respectively
% a1, a2              : Initial actions of each player
% N                   : Number of stages of play
% A1, A2              : Action history for each player.
% ---------------------------------------------------

% Modify the algorithm:
% At each stage k, each player:
% 1. Plays the best response to the opponent's action at time k-1 w.p. 1, OR
% 2. Plays the same action that was played at (k-1)

% Illustrate that this modification can break oscillations in BoS! HOW??

% Initalize column vectors 
A1 = zeros(N+1,1);
A2 = zeros(N+1,1);

A1(1) = a1; A2(1) = a2;

% Determine rewards
rwd_1 = M1(a1,a2);
rwd_2 = M2(a1,a2);

%iterate over time-stages
for t=2:N+1
coin = rand();
    % Determine Agent_1 BestResponse to Agent2's previous Action
[maxVal, maxIndx] = max(M1(:,a2));
if (coin <= p)
    A1(t) = maxIndx; % play the best response w.p p
else % plays previous action w.p (1-p)
    A1(t) = A1(t-1);
end

% Determine Agent_2 BestResponse to Agent1's previous Action
coin = rand();
[maxVal, maxIndx] = max(M2(a1,:));
if (coin <= p)
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