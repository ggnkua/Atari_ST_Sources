( conin )

decimal

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

