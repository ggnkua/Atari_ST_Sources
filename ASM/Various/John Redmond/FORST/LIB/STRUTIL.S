( strutil.s: utility string words )

decimal

: fill  to d0 to d1 to a0  ( load registers)
  for d1  d0 a0 inc c!  next ;
  
: cmove   to d1 to a1 to a0 ( load registers)
  for d1 a0 inc c@  a1 inc c!  next ;

: cmove>  to d1 to a1 to a0 ( load registers)
  d1 addto a0  d1 addto a1
  for d1  a0 dec c@ a1 dec c! next
;
  
: move  to d1 to a1 to a0  a0 a1 d1 ( replace them on the stack)
  a1 a0 >  if cmove> else cmove then
;

: type ( address,len)
  { 2 regargs string length }
  for length  string inc c@ emit  next
;
  
  
( expect package)
: expectmod ;

32 constant blank
13 constant cret
8 constant bs
27 constant esc

: backup  bs emit blank emit bs emit ; 
: bspaces  0 do backup loop ;

: docontrol { 4 args char &ptr &got &more  1 local sofar }

  &got @ to sofar

  char bs =
  if sofar 0>
    if  -1 &got +!
	 1 &more +!
	-1 &ptr +!  blank &ptr @ c!
	backup
    then  exit
  then

  char esc =
  if  sofar 0>
    if  0 &got !
        sofar &more +!
        sofar negate &ptr +!
        &ptr @ sofar blank fill 
        sofar bspaces
    then
  then
;

: expect { 2 args ptr #chars 3 locals char #got #more }

	ptr #chars blank fill
	0 to #got  #chars to #more
	
	begin #more if  key to char  then
	      #more  char cret = not  and
	while char blank <
	      if  char  addr ptr  addr #got  addr #more  docontrol
	      else char ptr inc c!
	        1 addto #got
	        -1 addto #more
	        char emit
	      then
	repeat
;      

from expectmod keep expect public

( integer output package )
: integermod ;

variable base  10 base !  ( decimal default )
32 constant blank
45 constant minus
48 constant zero
32 constant maxlen
65 10 - constant hexdigit

: . ( numb)
  { 1 arg numb  4 locals sign ptr len numbase  maxlen locbuff string }

  numb to sign  numb abs to numb  base @ to numbase
  0 to len  addr string maxlen +  to ptr   ( output pointer)  

  begin
     numb numbase u/mod  to numb
     dup 10 < if zero
              else hexdigit then +
     ptr dec c!  ( store char )   1 addto len
  numb 0= until
       
  sign 0<  if  1 addto len  minus ptr dec c!  then
  
  ptr len type  blank emit ;

from integermod  keep base  keep .  public
