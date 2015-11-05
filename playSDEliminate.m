function playSDEliminate
clc; clear all;
M1 = [4 5 6; 2 8 3; 3 9 2]
M2 = [3 1 2; 1 4 6; 0 6 8]

% [A1, A2] = sdeliminate(M1,M2);
[A1, A2] = sdeliminate_retActionSet(M1,M2);
A1
A2

end
