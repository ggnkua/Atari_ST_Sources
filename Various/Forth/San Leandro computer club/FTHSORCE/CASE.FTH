\ Dr. Charles Eaker's case statement
\ Example of use:
\ : foo ( selector -- )
\   case
\     0  of  ." It was 0"   endof
\     1  of  ." It was 1"   endof
\     2  of  ." It was 2"   endof
\     ( selector) ." **** It was " dup u.
\   endcase
\ ;
\ The default clause is optional.
\ When an of clause is executed, the selector is NOT on the stack
\ When a default clause is executed, the selector IS on the stack.
\ The default clause may use the selector, but must not remove it
\ from the stack (it will be automatically removed just before the endcase)

\ At run time, (of tests the top of the stack against the selector.
\ If they are the same, the selector is dropped and the following
\ forth code is executed.  If they are not the same, execution continues
\ at the point just following the the matching ENDOF

code (of  ( selector test -- [ selector ] )
   sp )+ d0 move  sp ) d0 cmp
   0= if   2 ip addq  sp )+ d0 move  next
   else    word ip ) ip adda  next
   then
c;
: of      ( [ addresses ] 4 -- 5 )
  4 ?pairs
\  compile over compile =  compile ?branch  \ for totally high level version
\  >mark compile drop        \ for totally high level version
  compile (of    >mark       \ for version using machine-code (of
  5
; immediate

: case    ( -- 4 )
  ?comp  csp @ !csp  4
; immediate

: endof   ( [ addresses ] 5 -- [ one more address ] 4 )
  5 ?pairs
  compile  branch     >mark
  swap  >resolve
  4
; immediate

: endcase ( [ addresses ] 4 -- )
  4 ?pairs
  compile drop
  begin sp@  csp @ <>
  while >resolve
  repeat
  csp !
; immediate
