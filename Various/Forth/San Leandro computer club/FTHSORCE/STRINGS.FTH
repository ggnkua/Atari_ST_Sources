\ Primitives to concatenate ( "cat ), and print ( ". ) strings.
: "cat  ( startstr endstr -- ) \ append startstr to the end of endstr
   2dup c@ swap c@ + >r
   swap count 1+ 2 pick dup c@ + 1+ swap cmove
   r> swap c!
;
: ". ( str -- ) count type ;
