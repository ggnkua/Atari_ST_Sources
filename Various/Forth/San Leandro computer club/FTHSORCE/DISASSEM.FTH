\ 68000/68010 disassembler
\ Use:  dis <word-name>
\ Or:   <address> (dis
\
\ Disassembly stops when a jmp or rts instruction is encountered.
\ To continue:  +dis

needs case case.fth
needs string-array stringar.fth

only forth definitions  vocabulary disassembler
also disassembler definitions

\ 2 definitions which are specific to the virtual machine implementation:

: >code ( cfa-of-code-word -- address-of-start-of-machine-code )
\itc >body
;
\ Display address registers using the symbolic names which represent
\ their use in implementing the Forth virtual machine
\ A simple-minded version which just prints the register name
\ follows later, commented out
string-array aregs
 ( 0 )  ," a0 "
 ( 1 )  ," a1 "
 ( 2 )  ," a2 "
 ( 3 )  ," up "
 ( 4 )  ," w "
 ( 5 )  ," ip "
 ( 6 )  ," rp "
 ( 7 )  ," sp "
end-string-array
\ string-array aregs  \ For Atari 4xForth
\  ( 0 )  ," a0 "
\  ( 1 )  ," a1 "
\  ( 2 )  ," a2 "
\  ( 3 )  ," w "
\  ( 4 )  ," up "
\  ( 5 )  ," ip "
\  ( 6 )  ," sp "
\  ( 7 )  ," rp "
\ end-string-array
: .a ( reg -- )  aregs ". ;

\ The disassembler

variable pc
variable size
variable next-found

hex
: bits ( instr mask shift -- field ) rot swap >> and ;
: bit? ( instr bit# -- f ) 1 swap << and ;
: !size size ! ;
: s-byte 0 !size ;
: s-word 1 !size ;
: s-long 2 !size ;
: setsize ( instr -- instr ) dup 3 6 bits !size ;

string-array sizes
 ( 0 ) ," byte "
 ( 1 ) ," word "
 ( 2 ) ," long "
 ( 3 ) ," ??? "
end-string-array
: .size ( -- )  size @ sizes ". ;

: @pc ( -- ) pc @ <w@ 2 pc +! ;
: l@pc ( -- ) pc @ l@ 4 pc +! ;

: rx ( instruction -- instruction ) dup  7 9 bits  ;
: ry ( instr -- instr ) dup 7 and ;
: reg\mode ( ea -- reg mode )   ry swap  7 3 bits ;
: byte-disp ( instr -- instr byte-displacement-field )
  dup ff and dup   7 bit?   if   -80 or   then
;
: .inst ( instruction -- ) ." (" 0 u.r ." )" ;
\ : .a ( reg -- )   ." a" . ;
: .d ( reg -- )   ." d" . ;
: .wdisp ( -- )   @pc  . ;
: .ldisp ( -- )   l@pc l. ;
: .index ( -- )
  @pc                       ( index-word )

  \ Print displacement
  byte-disp .   ( index-word )

  \ Register number
  dup 7 0c bits ( index-word reg )

  \ Address or data register?
  over  0f bit?  if  .a  else .d then

  \ Word or Long displacement
      0c bit?  if  ." .L " else ." .W " then
;
: long? ( -- flag ) \ Flag is true if the immediate operand is long
  size @ 2 =
;
: .immed ( -- )   long?  if  l@pc l. ." l#  "  else  @pc . ." #  " then  ;
: .-) ." -)  " ;
: .)+ ." )+  " ;
: .rm ( reg mode -- )
  case
  0 of  .d                  endof
  1 of  .a                  endof
  2 of  .a ." )  "          endof
  3 of  .a .)+              endof
  4 of  .a .-)              endof
  5 of  .wdisp .a ." d)  "  endof
  6 of  .index .a ." di)  " endof
  7 of
     case
     0 of .wdisp ." #)  "     endof
     1 of .ldisp ." l#)  "    endof
     2 of .wdisp ." pc d)  "  endof
     3 of .index ." pc di)  " endof
     4 of .immed              endof
     ( default ) ." ??? "
     endcase
   endof
  endcase
;
: .ea ( instr -- instr )  dup reg\mode ( reg mode ) .rm  ;

: .move ( instruction -- )
  dup 7 0c bits
  \ convert  1 3 2 into 0 1 2
  1- dup if 3 swap - then  !size
  .ea
  6 >> reg\mode swap .rm .size ." move"
;

: .movep ( instr -- ) ." movep" .inst ;
string-array bitops
 ( 0 ) ," btst"
 ( 1 ) ," bchg"
 ( 2 ) ," bclr"
 ( 3 ) ," bset"
end-string-array
: .bit ( instr -- )    .ea     3 6 bits   bitops ".  ;

: .bitd  s-byte  rx .d   .bit ;
: .bits  s-byte .immed   .bit ;

string-array immops
 ( 0 ) ," or"
 ( 1 ) ," and"
 ( 2 ) ," sub"
 ( 3 ) ," add"
 ( 5 ) ," eor"
 ( 6 ) ," cmp"
 ( 7 ) ," moves"  \ Should be decoded separately
end-string-array
: .imm
  setsize  .immed  .ea
  7 9 bits  immops ".
;

string-array conds
 ( 0 ) ," t"
 ( 1 ) ," f"
 ( 2 ) ," hi"
 ( 3 ) ," ls"
 ( 4 ) ," cc"
 ( 5 ) ," cs"
 ( 6 ) ," ne"
 ( 7 ) ," eq"
 ( 8 ) ," vc"
 ( 9 ) ," vs"
 ( a ) ," pl"
 ( b ) ," mi"
 ( c ) ," ge"
 ( d ) ," lt"
 ( e ) ," gt"
 ( f ) ," le"
end-string-array
: .cond ( instr -- )    f 8 bits conds ".  ;  

: .dbcc  pc @  @pc +  u.  ry .d   ." db" .cond  ;
: .scc   s-byte .ea  ."  s" .cond ;
: .bcc
  byte-disp pc @ swap  ( instr pc byte-displacement )
  case
    0  of  @pc endof
   ff  of l@pc endof  \ For 68020
   ( default ) dup
  endcase
  +  u.  \ branch target
  ." b" .cond
;
: .quick setsize  rx .   .ea  8 bit?  if ." subq"  else  ." addq"  then ;
: .moveq byte-disp . rx .d ." moveq" ;
: .muldiv  s-word  .ea  rx .d
  dup  0e bit?  if ." mul" else ." div"  then
       0c bit?  if ." s"   else ." u"    then
;
: .x/bcd ( instr -- inst )
  dup 3 bit?
  if   ry .a .-)   rx .a .-)
  else ry .d       rx .d
  then
;
: .x   setsize .x/bcd  .size    0e bit? if  ." addx" else ." subx" then ;
: .bcd         .x/bcd           0e bit? if  ." abcd" else ." sbcd" then ;
: .cmpm  setsize ry .a .)+   rx .a .)+  drop .size ." cmpm" ;
: .eor  setsize  rx .d  .ea .size ." eor" ;
: .exg
  dup 1f 3 bits
  case
   08 of  ry .d  rx .d  endof
   09 of  ry .a  rx .a  endof
   11 of  ry .a  rx .d  endof
  endcase
  drop  ." exg"
;
string-array shifts
 ( 0 ) ," as"
 ( 1 ) ," ls"
 ( 2 ) ," ro"
 ( 3 ) ," rox"
end-string-array
: shifttype ( instr type -- ) 
  shifts ".   8 bit?  if ." l" else ." r" then
;
: .shift
  setsize
  rx over 5 bit?  if  .d  else  .  then    \ Shift count
  ry .d                                    \ Destination register
  .size
  dup 3 3 bits shifttype
;
: .shiftmem    s-byte .ea  dup 3 9 bits shifttype  ;
: .fline ." F-Line" .inst ;
: .aline ." A-Line" .inst ;
: .bogus ." Illegal Instruction" .inst ;

string-array aops
 ( 0 ) ," suba"
 ( 1 ) ," cmpa"
 ( 2 ) ," adda"
 ( 3 ) ," ???"
end-string-array
: .1eaa
  dup 8 bit? if s-long else s-word then
  .ea  rx .a   .size   3 0d bits aops ".
;

string-array binops
 ( 0 ) ," or"
 ( 1 ) ," sub"
 ( 2 ) ," ???"  \ a-line trap, should have already been handled
 ( 3 ) ," cmp"
 ( 4 ) ," and"
 ( 5 ) ," add"
 ( 6 ) ," ???"  \ shift, should have already been handled
 ( 7 ) ," ???"  \ f-line/coprocessor trap, should have already been handled
end-string-array

: .1ea   setsize
  dup 8 bit?
  if   rx .d   .ea
  else .ea     rx .d
  then
  .size
  7 0c bits binops ".
;  
\ ffff  4afc  .illegal
\ ffc0  4e40  .1regx
\ : .1regx 30 30 mask-match if ( reset nop stop rte rts trapv rtr )
\   else ( trap  or   1reg link unlk  move to usp  move from usp )
\ ;
string-array misc
 ( 0 ) ," reset"
 ( 1 ) ," nop"  
 ( 2 ) ," stop" 
 ( 3 ) ," rte"  
 ( 4 ) ," rtd"  
 ( 5 ) ," rts"
 ( 6 ) ," trapv"
 ( 7 ) ," rtr"  
end-string-array
: .0addr    07 0 bits dup misc ".   5 = next-found ! ;

: .movec ." movec" .inst  ." Extension = " @pc u. ;
: getn ( -- n )
  bl word  number?
  0= abort" Bad number"  l->n
;

: mask/match: ( -- )
  create
   begin   getn dup w,   getn w,   ' token,  0=  until
  does> ( test pfa )
   begin
     2dup w@ and     ( test pfa masked )
     over wa1+ w@ <> ( test pfa mismatch? )
   while
     2 wa+ /token +
   repeat            ( test pfa )
   2 wa+ token@ execute
;
: .trap f and . ." trap" ;
: .1reg ry .d
  7 3 bits
  case
   2 of @pc s. ." link"   endof
   3 of ." unlk"          endof
   4 of ." move to usp"   endof
   5 of ." move from usp" endof
  endcase
;
: size6   dup  6 bit? if s-long else s-word then  ;
: .ext    size6  rx .d  .size ." ext" ;
: .swap   ry .d  ." swap" ;
: .movem
  size6
  dup 0a bit?
  if  @pc swap .ea swap  .  else  @pc .  .ea then
  drop ." movem"
;
: .jmp/jsr
  s-long  .ea
  6 bit?
  if ." jmp"   next-found on  else ." jsr"  then
;
: .chk   s-word  .ea  rx .d  ." chk" ;
: .lea   s-long  .ea  rx .a  ." lea" ;

string-array smoves
 ( 0 ) ," move from sr"
 ( 1 ) ," move from ccr"
 ( 2 ) ," move to ccr"
 ( 3 ) ," move to sr"
end-string-array
: .smove s-word  .ea   3 9 bits smoves ". ;

string-array unaries
 ( 0 ) ," negx"
 ( 1 ) ," clr"
 ( 2 ) ," neg"
 ( 3 ) ," not"
 ( 4 ) ," nbcd"
 ( 5 ) ," tst"
 ( 6 ) ," ???"
 ( 7 ) ," ???"
end-string-array
: .unary  setsize .ea  .size  7 9 bits unaries ".  ;
: .pea s-long .ea ." pea" ;

\ XXX swapped .1eaa with .x

mask/match: decode
f138  0108  .movep
ff00  0800  .bits
f100  0100  .bitd
f000  0000  .imm
fff8  4e70  .0addr
fff8  4e70  .movec
fff0  4e40  .trap
ffc0  4e40  .1reg
fff8  4840  .swap
ffb8  4800  .ext
fb80  4880  .movem
ff80  4e80  .jmp/jsr
f1c0  4180  .chk
f1c0  41c0  .lea
f9c0  40c0  .smove
ffc0  4840  .pea
f100  4000  .unary
f0f8  50c8  .dbcc
f0c0  50c0  .scc
f000  5000  .quick
f000  6000  .bcc
f000  7000  .moveq
b1f0  8100  .bcd
b0c0  80c0  .muldiv
90c0  90c0  .1eaa
b130  9100  .x
f138  b108  .cmpm
f100  b100  .eor
f130  c100  .exg
f0c0  e0c0  .shiftmem
f000  e000  .shift
f000  a000  .aline
f000  f000  .fline
c000  0000  .move
8000  8000  .1ea
0000  0000  .bogus

\ Continue disassembling where we last left off
: +dis
  hex
  next-found off
  begin
    pc @ u. 3 spaces
     @pc decode
    cr
  next-found @ until
;

\ Disassemble given the starting address
: (dis ( pfa -- )    pc !  +dis ;

\ Disassemble given a cfa
: cdis ( cfa -- )    >code (dis ;

\ Disassemble the word whose name is next in the input stream
: dis ( -- )    ' >code (dis  ;

only forth definitions disassembler also forth

: +dis +dis ;
: (dis (dis ;
: cdis cdis ;
: dis dis ;

\ Assumes that the decompiler (which defines "defer disassemble") is
\ already loaded.
only forth also hidden also disassembler
' cdis is disassemble

only forth also definitions
