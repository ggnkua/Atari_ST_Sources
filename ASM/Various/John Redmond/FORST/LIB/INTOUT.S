( basic number output words)
( assumes on stack: addr,#chars,integer)

decimal

variable base  10 base !
create ipad 20 allot
ipad 20 + address padend

another u/mod  \ copy up from the system

: <# ( integer--addr,0,integer)
  >r  padend 0  r> ;  called
: #> ( addr,#chars,integer--addr,#chars)
  drop ;  
  
: hold ( addr,#chars,integer,char--addr',#chars',integer)
  { 4 args ptr #chars value char }
  char ptr dec c!
  ptr #chars 1+ value ;  
: sign  0< if 45 hold then ;  
: abs  dup 0< if negate then ;  

: #  ( addr,#chars,integer--addr,#chars',integer')
  base @ u/mod  swap
  dup 10 <  if 48 else 55 then +  hold ;  
: #s  ( addr,#chars,integer--addr',#chars',0)
  begin  # dup  0= until ;  
  
: (u.)  <# #s #> ;
: u.  (u.) type space ;
: (.)  dup >r abs <# #s r> sign #> ;
: .  (.) type space ;
