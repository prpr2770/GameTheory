function [b1, b2] = fictitiousPlay(M1,M2,a1,a2,N)
% Write a Matlab script that executes fictitious play and plots the empirical frequencies of
% players 1 and 2 on different subplots (see subplot command).
% The input/output syntax should be of the form:
% [b1,b2] = fp(M1,M2,a1,a2,N)
% where
% • M1 and M2 are reward matrices for players 1 and 2, respectively.
% • a1 and a2 are the initial actions of players 1 and 2, respectively, at stage 0.
% • N is the number of stages.
% • b1 and b2 are matrices with the history of beliefs for players 1 and 2, respectively.

if (size(M1) ~= size(M2))
    warning('|M1| ~= |M2|: Check the matrix sizes! ')
    % =====================================================================
    % =====================================================================
else

   % Parameter to indicate how much an agent weights its prior beliefs with
   % the empirical-belief(frequentist).
   % alpha = 0 <Pure Fictitious Play>
   % alpha = 1 <No Belief Update - Mixed Strategy Game>
   alpha = 0.5;
    
    [rows,cols] = size(M1);
   
   numTimesActionIsPlayed_Ag1 = zeros(1,rows);
   numTimesActionIsPlayed_Ag2 = zeros(1,cols);
   
   freqActionPlayed_Ag1 = zeros(N,rows);
   freqActionPlayed_Ag2 = zeros(N,cols);
   %----------------------------------------------------------
   % Belief (empirical frequency) maintained by each agent about
   % Oppositions preference over actions
   Ag2_rivalActionBeliefs = (1/rows)*ones(1,rows);
   Ag1_rivalActionBeliefs = (1/cols)*ones(1,cols);


% % %    %----------------------------------------------------------
% % %    % Simulation to test the outcome of Zero-Sum game
% % %    Ag2_rivalActionBeliefs = [0.75 0.25];
% % %    Ag1_rivalActionBeliefs = [0.75 0.25];
   
   %----------------------------------------------------------
   % Initialize output matrices: Archiving the History of Beliefs
   b1 = zeros(N+1,cols); %History of beliefs of agent1 over agent2's actions
   b2 = zeros(N+1,rows); %History of beliefs of agent2 over agent1's actions
   
   b1(1,:) = Ag1_rivalActionBeliefs;
   b2(1,:) = Ag2_rivalActionBeliefs;
   
   % a1, a2 : initial actions of player 1 and player 2 at step 1
    a1
    a2
    
    
   % =====================================================================
   % Simulating the time-evolution
   for epoch = 1:N
        
       % ----------------------------------------------------------------
       % Determine ACTION to be played, Update ACTION_COUNTS and BELIEFS
       
       if epoch == 1
           % Agent Actions are Determined/Given: (a1,a2)

           % ---------------------------------------
           % Agent 1:
           
           
           % update the actionPlayedCounts
           numTimesActionIsPlayed_Ag1(a1) = numTimesActionIsPlayed_Ag1(a1) + 1;         
           % update the beliefs
           Ag1_rivalActionBeliefs = alpha*Ag1_rivalActionBeliefs + (1-alpha)* (1/epoch* numTimesActionIsPlayed_Ag2);
           % archive beliefs
           b1(epoch+1,:) = Ag1_rivalActionBeliefs;
           
           % ---------------------------------------
           % Agent 2:
           
           % update the actionPlayedCounts
           numTimesActionIsPlayed_Ag2(a2) = numTimesActionIsPlayed_Ag2(a2) + 1;
           % update the beliefs
           Ag2_rivalActionBeliefs = alpha*Ag2_rivalActionBeliefs + (1-alpha)* (1/epoch* numTimesActionIsPlayed_Ag1);
           % archive beliefs
           b2(epoch+1,:) = Ag2_rivalActionBeliefs;

       else
           % ---------------------------------------
           % Agent 1:
           
           % Ag_1 chooses Best_Response to his beliefs about Ag2_Preferences
           % Choose the action that gives the greatest expected utility

           Ag1_rivalActionBeliefMatrix = repmat(Ag1_rivalActionBeliefs,rows,1);
           %verify that the beliefMatrix is of size == Mi
           assert(all(size(Ag1_rivalActionBeliefMatrix) == size(M1)),'BeliefMatrix_Ag1 is not of size(M1).');
           % dot product with the Utility Matrix for Ag_i, 
           rewardsVector = sum(Ag1_rivalActionBeliefMatrix.*M1,2); %rowSum for Ag1

           %determine the action to take
           [val,idx] = max(rewardsVector);
           a1 = idx;

           % play the selected action
           numTimesActionIsPlayed_Ag1(a1) = numTimesActionIsPlayed_Ag1(a1) + 1;         
           % update the beliefs
           Ag1_rivalActionBeliefs = alpha*Ag1_rivalActionBeliefs + (1-alpha)* (1/epoch* numTimesActionIsPlayed_Ag2);
           % archive beliefs
           b1(epoch + 1,:) = Ag1_rivalActionBeliefs;
           
           % ---------------------------------------
           % Agent 2:
           
           Ag2_rivalActionBeliefMatrix = repmat(Ag2_rivalActionBeliefs',1,cols);
           %verify that the beliefMatrix is of size == Mi
           assert( all(size(Ag2_rivalActionBeliefMatrix) == size(M2)),'BeliefMatrix_Ag2 is not of size(M2).');
           % dot product with the Utility Matrix for Ag_i, 
           rewardsVector = sum(Ag2_rivalActionBeliefMatrix.*M2,1); %rowSum for Ag1

           %determine the action to take
           [val,idx] = max(rewardsVector);
           a2 = idx;

           % play the selected action
           numTimesActionIsPlayed_Ag2(a2) = numTimesActionIsPlayed_Ag2(a2) + 1;         
           % update the beliefs
           Ag2_rivalActionBeliefs = alpha*Ag2_rivalActionBeliefs + (1-alpha)* (1/epoch* numTimesActionIsPlayed_Ag1);
           % archive beliefs
           b2(epoch + 1,:) = Ag2_rivalActionBeliefs;
       end
            % update the frequency
            freqActionPlayed_Ag1(epoch,:) = 1/epoch*numTimesActionIsPlayed_Ag1;
            freqActionPlayed_Ag2(epoch,:) = 1/epoch* numTimesActionIsPlayed_Ag2;

       
   end
   
   % =====================================================================
   % Plot Final frequencies of play
   fig1 = figure(1)
   subplot(2,1,1)
   scatter(1:size(M1,1),1/N * numTimesActionIsPlayed_Ag1,'r')
   ylabel('Frequency of Play')
   xlabel('Agent1: actionID')
   title('Agent 1: Frequency of playing Action in Fictitious Play')
   subplot(2,1,2)
   scatter(1:size(M1,2),1/N * numTimesActionIsPlayed_Ag2,'r')
   ylabel('Frequency of Play')
   xlabel('Agent2: actionID')
   title('Agent 2: Frequency of playing Action in Fictitious Play')
   
   % =====================================================================
   % Plot time-evolution of frequencies
   fig2 = figure(2)
   subplot(2,1,1)
   plot(freqActionPlayed_Ag1)
   ylabel('Frequency of Play')
   xlabel('iteration')
   title('Agent 1: Frequency of playing Action in Fictitious Play')
   
   subplot(2,1,2)
   plot(freqActionPlayed_Ag2)
   ylabel('Frequency of Play')
   xlabel('iteration')
   title('Agent 2: Frequency of playing Action in Fictitious Play')
   
   % =====================================================================
   % Plot time-average of frequencies
   timeAvgFrequencies_Ag2 = zeros(size(freqActionPlayed_Ag2));
   timeAvgFrequencies_Ag1 = zeros(size(freqActionPlayed_Ag1));
   
   for iter = 1:size(freqActionPlayed_Ag2,1)
        timeAvgFrequencies_Ag2(iter,:) = 1/iter*sum(freqActionPlayed_Ag2(1:iter,:),1);
        timeAvgFrequencies_Ag1(iter,:) = 1/iter*sum(freqActionPlayed_Ag1(1:iter,:),1);
   end
   
   
   fig3 = figure(3)
   subplot(2,1,1)
   plot(timeAvgFrequencies_Ag1)
   ylabel('Frequency of Play')
   xlabel('iteration')
   title('Agent 1: Frequency of playing Action in Fictitious Play')
   
   subplot(2,1,2)
   plot(timeAvgFrequencies_Ag2)
   ylabel('Frequency of Play')
   xlabel('iteration')
   title('Agent 2: Frequency of playing Action in Fictitious Play')
   
   
   fig4 = figure(4)
   subplot(2,1,1)
   plot(timeAvgFrequencies_Ag1)
   hold on
   plot(freqActionPlayed_Ag1)
   hold off
   ylabel('Frequency of Play')
   xlabel('iteration')
   title('Agent 1: Frequency of playing Action in Fictitious Play')
   
   subplot(2,1,2)
   plot(timeAvgFrequencies_Ag2)
   hold on
   plot(freqActionPlayed_Ag2)
   hold off
   ylabel('Frequency of Play')
   xlabel('iteration')
   title('Agent 2: Frequency of playing Action in Fictitious Play')
end

end