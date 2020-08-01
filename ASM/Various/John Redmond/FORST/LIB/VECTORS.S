( VECTORS: installation of INTEGERS and REALS vectors)

decimal
: module ;

create ints  72 allot
  vectors ints 72 cmove	( ForST system default integer vectors)

create flts		( comma in compilation records)
  comp, fnumber		comp, f.	comp, f+	comp, f-
  comp, f*		comp, f/	comp, fmod	comp, fabs
  comp, fnegate
  
( words to switch maths State Table:)

: integers  ints vectors 72 cmove ;  immediate

: reals  flts vectors 72 cmove ;  immediate

( word to cast the following number as an integer)

: ?lit  state @  if [compile] literal then ;
: integer  32 word number ?lit ; immediate

( word to cast the following number as a real)

: real  32 word fnumber  ?lit ; immediate

from module

  keep integers  keep reals  keep integer  keep real

public
