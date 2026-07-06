decimal
td 27 constant escape
: ctl ( --arg )
   ?comp [compile] control compile (emit
; immediate
: (esc ( character -- )  escape (emit (emit ;
: esc ( --char )
   ?comp [compile] ascii compile (esc
; immediate

25 constant (#lines
25 constant #lines
80 constant #columns

: at    ( row col -- )
  2dup #out !  #line !
  esc Y swap bl +  (emit bl + (emit
;
: insert-char  ( -- ) (emit ;  \ Doesn't work
: delete-char  ( -- ) ; \ Doesn't work
: left         ( -- ) ctl H -1 #out  +! ;
: right        ( -- ) esc C  1 #out  +! ;
: up           ( -- ) esc A -1 #line +! ;
: down         ( -- ) esc B  1 #line +! ;
: kill-line    ( -- ) esc K ;
: kill-screen  ( -- ) esc J ;
: insert-line  ( -- ) esc L ;
: delete-line  ( -- ) esc M ;
: erase-screen ( -- ) esc E  #out off  #line off ;
: beep         ( -- ) ctl G ;
: dark         ( -- ) esc p ;
: light        ( -- ) esc q ;
