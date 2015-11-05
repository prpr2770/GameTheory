function playFictitiousGame
clc; clear all;
% M1 = [4 5 6; 2 8 3; 3 9 2]
% M2 = [3 1 2; 1 4 6; 0 6 8]

M1 = [1 3; 4 2]
M2 = [-1 -3; -4 -2]


a1 = 2; a2 = 1;

% Number Of Epochs 
N = 1000;

% [A1, A2] = sdeliminate(M1,M2);
[b1, b2] = fictitiousPlay(M1,M2,a1,a2,N)

end
