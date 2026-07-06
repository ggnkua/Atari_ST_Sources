( Temporary hex and temporary decimal.  "th" interprets the next word )
( as though the base were hex, regardless of what the base happens to be. )
( "td" interprets the next word as though the base were decimal. )

: th ( temporarily set hex mode and interpret next word )
  base @ >r hex  bl word "compile  r> base !
; immediate

: td ( temporarily set decimal mode and interpret next word )
  base @ >r decimal  bl word "compile  r> base !
; immediate
