( apputils.s:  redefinitions for stand-alone code
  assumes that vector words have been loaded from preface.s)

decimal

another u/mod

( string package )

: count  ( addr--addr+1,cnt) to a0  a0 inc c@ to d0  a0 d0 ;

: even  to a1  a1 1 and addto a1  a1 ;
: (")  r> count  over over + 1+ even  >r ;   head (") is >(")

: abs  to a1  a1 0< if 0 a1 -  else a1 then ;

: emit
  a7 dec w! ( char) 2 a7 dec w! gemdos
  4 addto a7 ;
  
: cr 13 emit 10 emit ;
  
: key
  7 a7 dec w! gemdos
  d0 a6 dec w!  0 a6 dec w! ( extend char to long word)
  2 addto a7 ;

: wait  key drop ;

: key? 
  11 a7 dec w!  gemdos  d0 a6 dec w! 0 a6 dec w!
  2 addto a7 ;
  
: ?key  key?  if wait wait then ;

: type  ( ptr,len)
  { 2 args ptr len }
  for len  ptr inc c@ emit next ;  head type is >type

: fill { 3 regargs ptr len val }
  for len  val ptr inc c!  next ;

: cmove  ( orig,dest,len)
  { 3 regargs orig dest len }
  for len orig inc c@ dest inc c! next ;

: cmove>  ( orig,dest,len)
  { 3 regargs orig dest len }
  len addto orig  len addto dest
  for len orig dec c@ dest dec c! next ;
  
: move
  { 3 args orig dest len }
  orig dest len
  dest orig >  if  cmove>  else  cmove  then ;
  
( expect package)
: expects ;

32 constant blank
13 constant cret
8 constant bs
27 constant esc

: backup  bs emit blank emit bs emit ; 
: bspaces  { 1 regarg cnt }
  for cnt  backup  next ;

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

: (expect) { 2 args ptr #chars 3 locals char #got #more }

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

from expects keep expect public

( integer output package )
: dots ;

variable base  10 base !  ( decimal default )
32 constant blank
45 constant minus
48 constant zero
20 constant maxlen
65 10 - constant hexdigit

another u/mod

: (.) ( numb)
  { 1 arg numb  4 locals sign ptr len numbase  maxlen locbuff string }

  numb to sign  numb abs to numb  base @ to numbase
  0 to len  string maxlen +  to ptr   ( output pointer)  

  begin
     numb numbase u/mod  to numb
     dup 10 < if zero  else hexdigit then  +
     ptr dec c!  1 addto len  ( store char )
  numb 0= until     
  sign 0<  if  minus ptr dec c!  1 addto len  then

  ptr len type  blank emit ;

from dots keep base keep (.) public
