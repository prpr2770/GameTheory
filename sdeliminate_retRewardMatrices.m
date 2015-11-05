function [A1, A2] = sdeliminate_retRewardMatrices(M1,M2)
% -------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------
%  STRICTLY DOMINANT ELIMINATION
% -------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------
% 
% Write a Matlab script that executes iterated elimination of strictly dominated strategies for
% 2 player matrix games. The input/output syntax should be of the form:
% [A1,A2] = sdeliminate(M1,M2)
% where
% • M1 and M2 are reward matrices for players 1 and 2, respectively.
% -------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------
% • A1 and A2 are REWARD MATRICES of the surviving actions for player 1 and 2, respectively.
% -------------------------------------------------------------------------------------------
% -------------------------------------------------------------------------------------------


if (size(M1) ~= size(M2))
   warning('Mismatch of size of input Matrices'); 
else

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
        
        % ==============================================================
        % AGENT 1: ELIMINATE ROWS
        [rows,cols] = size(M1);
        row = rows;       % First examine the Last Column
        while (eliminate4Agent == 1 && eliminated == 0)
            % determine one col to eliminate
            vec = M1(row,:);
            rep_vec = repmat(vec,rows,1);
            diff_rewards = rep_vec - M1;
            % determine which rows are all negative
            negValues = (diff_rewards < 0);
            sumNegEntries = sum(negValues,2);   % find the column-wise sums
            % Strictly dominated strategy: Atleast one of the columns will have
            % a sum equal to the total number of rows
            yesDominated = sum(sumNegEntries == cols);
            if yesDominated > 0
                % eliminate col = identify all other cols
                rowsToInclude = ~ismember(1:rows,[row]);
 
                M1 = M1(rowsToInclude,:);
                M2 = M2(rowsToInclude,:);
                eliminated = 1; % Break from loop!
                eliminate4Agent = 2;
            else 
                row = row - 1;
            end
            if (row == 0)
                eliminate4Agent = 2;
                rowEliminationOver = 1;
            end
        end
        
        % reset eliminated flag
        eliminated = 0; 
        
        % ==============================================================
        % AGENT 2: ELIMINATE COLUMNS
        [rows,cols] = size(M2);
        col = cols;       % First examine the Last Column
        while (eliminate4Agent == 2 && eliminated == 0)
            % determine one col to eliminate
            vec = M2(:,col);
            rep_vec = repmat(vec,1,cols);
            diff_rewards = rep_vec - M2;
            % determine which colums are all negative
            negValues = (diff_rewards < 0);
            sumNegEntries = sum(negValues,1);   % find the column-wise sums
            % Strictly dominated strategy: Atleast one of the columns will have
            % a sum equal to the total number of rows
            yesDominated = sum(sumNegEntries == rows);
            if yesDominated > 0
                % eliminate col = identify all other cols
                colsToInclude = ~ismember(1:cols,[col]);
 
                M1 = M1(:,colsToInclude);
                M2 = M2(:,colsToInclude);
                eliminate4Agent = 1;
                eliminated = 1; % Break from loop!
            else 
                col = col - 1;
            end
            if (col == 0)
                colEliminationOver = 1;
                eliminate4Agent = 1;
            end
        end
        
        % reset eliminated flag
        eliminated = 0 ;

        % ==============================================================
        if (rowEliminationOver && colEliminationOver)
           eliminate4Agent = 0; 
        end
    
    end % eliminate4Agent == 0

    A1 = M1;
    A2 = M2;
end % if sizes aren't same 

