( integer output package )

decimal
variable base  10 base !  ( decimal default )
32 constant blank
45 constant minus
48 constant zero
20 constant maxlen
65 10 - constant hexdigit

: type  ( ptr,len)
  { 2 args ptr len }
  for len  ptr inc c@ emit next ;
  
: i. ( numb)
  { 1 arg numb  4 locals sign ptr len numbase  maxlen locbuff string }

  numb to sign  numb abs to numb  base @ to numbase
  0 to len  addr string maxlen +  to ptr   ( output pointer)  

  begin
     numb numbase u/mod  to numb
     dup 10 < if zero  else hexdigit then  +
     ptr dec c!  1 addto len  ( store char )
  numb 0= until     
  sign 0<  if  minus ptr dec c!  1 addto len  then
  
  ptr len type  blank emit ;
