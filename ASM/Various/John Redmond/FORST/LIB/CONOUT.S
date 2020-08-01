( conout)

decimal

: count  ( addr--addr+1,cnt) to a0  a0 inc c@ to d0  a0 d0 ;

: even  to a1  a1 1 and addto a1  a1 ;
: (")  r> count  over over + 1+ even  >r ;

: abs  to a1  a1 0< if 0 a1 -  else a1 then ;

: emit
  a7 dec w! ( char) 2 a7 dec w! gemdos
  4 addto a7 ;
  
: cr 13 emit 10 emit ;
: space  32 emit ;
: cls  27 emit [ascii] E emit ;
  
: type  ( ptr,len)
  { 2 args ptr len }
  for len  ptr inc c@ emit next ;

