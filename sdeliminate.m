function [A1, A2] = sdeliminate(M1,M2)
% -------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------
%  STRICTLY DOMINANT ELIMINATION
% -------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------
% Write a Matlab script that executes iterated elimination of strictly dominated strategies for
% 2 player matrix games. The input/output syntax should be of the form:
% [A1,A2] = sdeliminate(M1,M2)
% where
% • M1 and M2 are reward matrices for players 1 and 2, respectively.
% • A1 and A2 are vectors of the surviving actions for player 1 and 2, respectively.

if (size(M1) ~= size(M2))
   warning('Mismatch of size of input Matrices'); 
else
    [Rows, Cols] = size(M1);
    
    % Initialize Set of Valid Actions as binary vector
    A1_actionSet = 1:Rows;
    A2_actionSet = 1:Cols;
    A1 = ones(1,Rows);
    A2 = ones(1,Cols);
    
    
    % Determining dominated strategies: 
    % select column, subtract all other columns from it. 
    % if resultant vector has all elements negative, the chosen column is
    % strictly dominated. 
    
    eliminate4Agent = 2; % (0,1,2) = (complete,agent1,agent2)
    eliminated = 0;     % Flag to indicate if an elimination event has occured.
    
    % Flags to indicate which particular tasks are over
    rowEliminationOver = 0;
    colEliminationOver = 0;
    
    while eliminate4Agent > 0 
        %==============================================================
        % AGENT 1: ELIMINATE ROWS
        
        % determine set of valid actions
        rowValidActions = intersect(A1_actionSet, A1.*A1_actionSet);
        colValidActions = intersect(A2_actionSet, A2.*A2_actionSet);
        numValidRows = sum(A1);       % First examine the Last Column
        numValidCols = sum(A2);
        rowActionsIndex = numValidRows; %Initialize to totalValidRows
        
        while (eliminate4Agent == 1 && eliminated == 0)
        
            N1 = M1(rowValidActions,colValidActions);
            
            % Examine Last Index of ValidRows_Set
            row = rowValidActions(rowActionsIndex);
            % determine one col to eliminate
            vec = M1(row,colValidActions);
            rep_vec = repmat(vec,numValidRows,1);
            diff_rewards = rep_vec - N1;
            % determine which rows are all negative
            negValues = (diff_rewards < 0);
            sumNegEntries = sum(negValues,2);   % find the row-wise sums
            % Strictly dominated strategy: Atleast one of the columns will have
            % a sum equal to the total number of rows
            yesDominated = sum(sumNegEntries == numValidCols);
            if yesDominated > 0
                % eliminate col = identify all other cols
                A1(row) = 0; 
                eliminated = 1; % Break from loop!
                eliminate4Agent = 2;
            else 
                rowActionsIndex = rowActionsIndex - 1;
            end
            if (rowActionsIndex == 0)
                eliminate4Agent = 2;
                rowEliminationOver = 1;
            end
        end
        
        % reset eliminated flag
        eliminated = 0; 
        %==============================================================
        % AGENT 2: ELIMINATE COLS

        % determine set of valid actions
        rowValidActions = intersect(A1_actionSet, A1.*A1_actionSet);
        colValidActions = intersect(A2_actionSet, A2.*A2_actionSet);

        numValidRows = sum(A1);       % First examine the Last Column
        numValidCols = sum(A2);
        
        colActionsIndex = numValidCols; %Initialize to totalValidRows
        while (eliminate4Agent == 2 && eliminated == 0)

            N2 = M2(rowValidActions,colValidActions);
            
            col = colValidActions(colActionsIndex);
            % determine one col to eliminate
            vec = M2(rowValidActions,col);
            rep_vec = repmat(vec,1,numValidCols);
            diff_rewards = rep_vec - N2;
            % determine which rows are all negative
            negValues = (diff_rewards < 0);
            sumNegEntries = sum(negValues,1);   % find the column-wise sums
            % Strictly dominated strategy: Atleast one of the columns will have
            % a sum equal to the total number of rows
            yesDominated = sum(sumNegEntries == numValidRows);
            if yesDominated > 0
                % eliminate col = identify all other cols
                A2(col) = 0; 
                eliminated = 1; % Break from loop!
                eliminate4Agent = 1;
            else 
                colActionsIndex = colActionsIndex - 1;
            end
            if (colActionsIndex == 0)
                eliminate4Agent = 1;
                colEliminationOver = 1;
            end
        end
        
        % reset eliminated flag
        eliminated = 0; 

        %==============================================================
        % Completed Elimination Process
        if (rowEliminationOver && colEliminationOver)
           eliminate4Agent = 0; 
        end
    
    end % eliminate4Agent == 0

A1 = intersect(A1_actionSet, A1_actionSet.*A1);
A2 = intersect(A2_actionSet, A2_actionSet.*A2);
    
    
end