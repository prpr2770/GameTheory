function run_competition()
    global token reward ;
    token = 500 ;
    reward = 0 ;
    selector() ;
    display(['Congradulations! You won $',int2str(reward),'!']);
end