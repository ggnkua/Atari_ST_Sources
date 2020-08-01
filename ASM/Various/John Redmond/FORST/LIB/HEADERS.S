decimal

: >link 8 + ;

: stopper create head >link , 0 w,
  does>  { 1 regarg body  2 regs target new }
  	 body @ to target  body 4+ w@ to new
  	 target w@  body 4+ w!   new target w! ;
  	 

stopper u1  upto
stopper q1  quit

: t1 ;
: t2 ;

  	 
