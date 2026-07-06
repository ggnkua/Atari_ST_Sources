hex

\ Kludgey way to get the exception number.
\ The exception number is stored in the high byte of the vector entry.
\ Since the 68000 has only 24 address lines, the high byte doesn't
\ appear externally, but it will be stored in the pc.  Doing the
\ bsr pushes an address on the stack.  The address is boring, since
\ it is always the same address, but the high byte is the exception
\ number.
\
\ This code fragment was copied from the Atari ST BIOS so that the
\ format of the crash dump area would be identical to that produced
\ by the Atari trap handler
create getexc
assembler
  long
  here 4 + bsr
  nop            \ Needed because a 0 branch offset means use 16-bit offset
  sp )+   3c4 #) lmove  \ Save the exception number
  ffff #  384 #) movem  \ Save the registers
  4e68 w,               \ usp     a0     lmove
  a0      3c8 #) lmove

  15 #    d0     wmove  \ Save 16 words from the supervisor stack
  3cc l#  a0     lmove  \ so we can look at the error frame
  sp      a1     lmove
  begin
    a1 )+  a0 )+ wmove
  d0 dbra

  12345678 l#  380 #)  lmove  \ Magic number to validate the crash dump area

\ We ought to save the return stack too

  warm-code l#) jmp
forth

: .exception ( exception-number -- )
  case
  2 of ." Bus Error"            endof
  3 of ." Address Error"        endof
  4 of ." Illegal Instruction"  endof
  5 of ." Divide by Zero"       endof
  endcase
;
: new-warm
  (warm-hook
  3c4 c@  ( Exception number )
  .exception
;
' new-warm is warm-hook

: vec! ( address vector-number -- )
  dup >r
  18 << +            \ Put vector number in the high byte
  r> dup + dup +  !  \ XXX should use trap call
;
: catch-exceptions
  getexc 2 vec!
  getexc 3 vec!
  getexc 4 vec!
  getexc 5 vec!
;
catch-exceptions

variable nextloc
: .cloc ( -- )
  hex
  nextloc @ @ 9 u.r
  /l nextloc +!
;
: show8   8 0 do .cloc  loop  cr ;
: showcrash ( -- )
  380 l@ 1234.5678 <> abort" The crash dump area is invalid"
  384 nextloc !    #out @ if cr then
 ."           0        1        2        3        4        5        6        7"
  cr
  ." D:" show8
  ." A:" show8
  ." Exception # " 3c4 c@ 4 u.r
  3c8 nextloc !
  ."    User Stack Pointer " .cloc 
  ."    Supervisor Stack : " cr
  ."   " show8 ."   " show8
;
