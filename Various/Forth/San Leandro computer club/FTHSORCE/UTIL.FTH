hex
: interactive ?interactive on ;
: batch ?interactive off ;

: (s [compile] ( ; immediate

: immediate? ( cfa -- f )  1- c@ 40 and 0<> ;
: printable? ( n -- f ) ( is n a printable ascii character ? )
  bl 7f within
;
: c.id ( cfa -- ) >name .id ;
: >user#  ( cfa -- user# )
  >body @ l->w
;
: 'user# ( --name  user# )
    '  ( cfa-of-user-variable )
    >user#
;
decimal
