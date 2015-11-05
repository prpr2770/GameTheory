function playCournotGame
% Simulation of Cournot Dynamics for 2 player finite-action set games.

% set number of stages for simulating dynamics
N = 10;

% Set size of ActionSet
lenActnSet_1 = 5;
lenActnSet_2 = 5;

% initalize reward matrices
M1 = floor(10*randn(lenActnSet_1, lenActnSet_2));
M2 = floor(10*randn(lenActnSet_1, lenActnSet_2));

% initialize actions for each agent
a1 = 1+ floor(lenActnSet_1*rand());
a2 = 1+ floor(lenActnSet_2*rand())


% simulate cournot dynamics
[A1, A2] = cournot(M1, M2, a1, a2, N)

% plot results
fig1 = figure(1)
scatter(A1,A2,'ro')

fig2 = figure(2)
plot(A1,A2,'r--')

fig3 = figure(3)
plot(A1,'b')
hold on
plot(A2,'g')
hold off

end
