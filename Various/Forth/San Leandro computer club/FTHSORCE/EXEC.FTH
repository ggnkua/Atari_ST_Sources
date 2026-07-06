\ these routines allow you to run other applications from within forth, and 
\ then return back into forth once the application ends.

hex
variable memory-shrunk  memory-shrunk off

: ?shrink-memory  ( -- )
 memory-shrunk @  0=
  if   origin @ 
	68000 over -
	swap 0 m_shrink  abort" Can't shrink memory "
	memory-shrunk on
  then
;

nuser child-status  create nullstring 0 ,

: (exec  ( name command tail -- )
 ?shrink-memory swap 0  -rot  0  p_exec  child-status !
;

: get-tail  ( -- string )
 delimiter @ linefeed =
  if   nullstring
  else linefeed word
  then
;

: exec  ( -- )
 [compile] ""  get-tail  (exec
;

: (cold-hook
 (cold-hook  memory-shrunk off
;

' (cold-hook  is  cold-hook

: command:  ( -- )
 create bl word  ",
 does>  get-tail  (exec
;

command: emacs me.ttp

decimal

 
