\ Defining words to construct forth interfaces to C subroutines
\ and Gem traps.

\ Defines:
\
\ trap:
\ 
\ subroutine:
\
\ Several optimizations are performed:
\ * If the leftmost argument is a long or an address, it is just left
\   on the stack, no pushing or popping.
\ * The leftmost string pushes the c-string address straight from a0,
\   without first saving it in a D register

only forth assembler also forth also definitions

variable #bytes
variable #pops
variable #strings
variable reg#

\ Could start to use the return stack after we've used up all the D registers
: +reg ( -- reg# ) reg# @   1 reg# +! ;
: -reg ( -- reg# ) -1 reg# +!   reg# @ ;
: trap-call ( trap-arg trap# -- )
  swap  ( trap# trap-arg )
  [ assembler ]
  # sp -) wmove
  # trap
  [ forth ]
  /w #bytes +!
;
: trap:  ( trap-arg trap# -- trap-arg trap# 'trap-call ) ( Input stream: name )
  ['] trap-call   code
;
: subroutine-call   ( subroutine-addr -- )
  l#) jsr
;
: subroutine: ( addr -- addr 'subroutine-call ) ( Input stream: name )
  ['] subroutine-call code
;

6 /l * stack: callstack

: push-long   ( -- ) -reg sp -) lmove ;
: push-word   ( -- ) -reg sp -) wmove ;
: push-string ( -- ) a0   sp -) lmove ;

: convert-long ( -- )  sp )+  +reg  lmove   ['] push-long  callstack push ;
: convert-word ( -- )  sp )+  +reg  lmove   ['] push-word  callstack push ;
: convert-string ( -- )
  f>cstr l#) jsr
  #strings @ 1 >
  if
       ['] push-long    a0 +reg lmove   -1 #strings +!
  else
       ['] push-string
  then
  callstack push
;

: do-call ( ??? 'call-assembler -- ) \ ??? is args specific to the call type
  execute
  #bytes @ ?dup
  if   dup 8 >  if   sp d) sp lea   else   sp addq   then   then
;

: scan-args ( -- )
  begin
    bl word  1+ c@
    case
      ascii l of  #pops @ if ['] convert-long   1 else 0 then /l  true  endof 
      ascii a of  #pops @ if ['] convert-long   1 else 0 then /l  true  endof
      ascii w of             ['] convert-word   1             /w  true  endof 
      ascii s of  1 #strings +!  ['] convert-string 1         /l  true  endof 
      ascii - of  false endof
      ascii } of  ." Where's the -- ?" abort endof
      ( default ) ." Bad type specifier: " dup emit abort
    endcase
  while
    #bytes +!  #pops +!
  repeat
  \ push arguments
  #strings @  if    cstrbuf l#  a1 lmove   then
  #pops @   0  ?do  execute  loop
  begin   callstack sdepth   while   callstack pop execute  repeat
;
: scan-results ( -- )
  begin
    bl word  1+ c@
    case
      ascii l of  d0 sp -) lmove                   false endof 
      ascii a of  d0 sp -) lmove                   false endof 
      ascii w of  d0 extl  d0 sp -) lmove          false endof 
      ascii b of
            [ assembler ]  th ff. l# d0 and  d0 sp -) lmove  [ forth ]
                                                   false endof 
      ascii s of  c>fstr l#) jsr                   false endof 
      ascii } of                                   true  endof
      ( default ) ." Bad type specifier: " dup emit
    endcase
  until
;
: {
  #bytes off  #pops off  reg# off   #strings off
  scan-args
  do-call
  scan-results
  next
;
: bdos: 1 trap: ;
