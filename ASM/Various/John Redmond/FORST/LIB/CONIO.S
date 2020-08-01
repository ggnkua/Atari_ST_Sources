( assumes that vector words have been loaded from preface.s)

decimal

: count  ( addr--addr+1,cnt) to a0  a0 inc c@ to d0  a0 d0 ;

: even  to a1  a1 1 and addto a1  a1 ;
: (")  r> count  over over + 1+ even  >r ;

: abs  to a1  a1 0< if 0 a1 -  else a1 then ;

: emit
  save2  a7 dec w! ( char) 2 a7 dec w! gemdos
  4 addto a7  retrieve2 ;
  
: cr 13 emit 10 emit ;
: space  32 emit ;
: cls  27 emit [ascii] E emit ;
  
: key
  7 a7 dec w! gemdos
  d0 a6 dec w!  0 a6 dec w! ( extend char to long word)
  2 addto a7 ;

: key?
  11 a7 dec w! gemdos
  d0 a6 dec w!  0 a6 dec w! ( extend flag to long word)
  2 addto a7 ;
  
: wait  key drop ;

: ?key  key?  if wait wait then ;

: type  ( ptr,len)
  { 2 args ptr len }
  for len  ptr inc c@ emit next ;

