( expect package )

decimal

32 constant blank
13 constant cret
8 constant bs
27 constant esc


(  : fill  { 3 regargs dest len char }
  for len  char dest inc c! next ;
  
: key  7 a7 dec w!  gemdos  d0 255 and  2 addto a7 ;
: emit  a7 dec w!  2 a7 dec w!  gemdos  4 addto a7 ; )

: backup  bs emit  blank emit  bs emit ; 
: bspaces  0 do backup loop ;

: docontrol { 4 regargs char &ptr &got &more  1 reg sofar }

  &got @ to sofar

  char case
  bs of
   sofar 0>
    if  -1 &got +!
	 1 &more +!
	-1 &ptr +!  blank &ptr @ c!
	backup
    then
  endof
     
  esc of
   sofar 0>
    if  0 &got !
        sofar &more +!
        sofar negate &ptr +!
        &ptr @ sofar blank fill 
        sofar bspaces
    then
  endof
  endcase
;

: expect { 2 args ptr #chars 3 locals char #got #more }

	ptr #chars blank fill
	0 to #got  #chars to #more
	
	begin #more 0=  if leave then
	      key to char
	      char cret -
	while char blank <
	      if  char  addr ptr  addr #got  addr #more  docontrol
	      else char ptr inc c!
	        1 addto #got
	        -1 addto #more
	        char emit
	      then
	repeat
;      
