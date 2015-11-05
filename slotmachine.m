function binary_out = slotmachine(id)
p = [0.5,0.5,0.5,0.5,0.6,0.5,0.4,0.5,0.5,0.4] ;
global token reward
binary_out  = 0 ;
if token==0
    error('out of token') ;   
else
    token = token - 1 ;
    if (rand<p(id))
        binary_out = 1 ;
        reward = reward + 1 ;
    end
end

