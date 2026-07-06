\ Fix sr!  bad code from assembler

\ Catch exceptions

\ Handle command line

\ Change the order of the operands to the system calls so they
\ are the same as the normal Gem order.  _close returns a value!

\ Fix expect-fopen in-file ! to be cleaner

\ Make interpreter re-entrant - multiple tibs? (pokearound)

\ Handle end-of-file on input stream

\ Change immediate?

\ Fix "" to be state smart

\ Make other defining words besides : use  offset w ) jmp

\ Meta compiler source for the Forth 83 kernel.
\ Name field:
\     name: forth-style packed string, no tag bits
\     flag: 40 bit is immediate bit
\ Padding is optionally inserted between the name and the flags
\ so that the byte after the flag byte is on an even boundary.

\ Debugging aids
0 #words ! 580 threshold ! 20 granularity !

warning off
forth definitions : ` [compile] "" pad "copy pad ;

metaon
meta definitions

initmeta

th 8000 alloc-mem  target-image  \ Allocate space for the target image

\ org sets the lowest address that is used by Forth kernel.
\ This is sort of a funny number, being a target token rather
\ than a real absolute address.
hex

\t16 1.0000 org    0
\t32 5.0000 org  5.0000
   voc-link-t token-t!

200 equ ps-size

assembler

th 100 allot-t            \ Waste some address space for the base page

label cld   9000 bra      \ this branch offset will be patched later

meta
10 allot-t \ reserve some space just for fun

meta assembler definitions

:-h rmove ( src dest-reg -- ) ( move with possible relocation )
\t16  >r d7 word move  d7 r> long move
\t32  lmove
;-h
:-h amove ( src dest -- ) ( move an address )
    lmove
;-h

:-h /n* /n * ;-h

decimal
meta

\itc create (next
\itc assembler label (next)
\itc word ip )+ w rmove
\itc       w )+ a0 rmove   a0 ) jmp

\ This space leaves room for patching next for stuff like
\ single stepping, etc.
\ XXX changed here to here-t  and allot to allot-t
here-t /w -
  20 allot-t
  constant next-end

\ assembler macro to assemble a relative branch to next
meta assembler definitions
:-h next forth-h
\itc   [ labels (next) forth-h ] literal
\itc   [ assembler ]-h bra [ meta ]-h
\dtc   [ assembler ]-h ip )+ a0 rmove
\dtc   a0 ) jmp
;-h

:-h c; next end-code ;-h

meta definitions
code (lit   ip )+ sp -) move   c;
code (llit  ip )+ sp -) lmove   c;
code (dlit  ip )+ sp -) move  ip )+ sp -) move   c;
code execute   (s cfa -- )
\itc      sp )+ w  amove
\itc word  w )+ a0 rmove  a0 ) jmp
( xxx ) sp )+ a0 move  a0 ) jmp   \ FAST
\ \dtc rts
end-code
code perform (s addr-of-cfa -- )
\itc      sp )+ w  amove
\itc       w )+ w  amove
\itc word  w )+ a0 rmove  a0 ) jmp
\dtc sp )+ a0 move  a0 ) a0 rmove  a0 ) jmp
end-code

code branch
label bran1
 word  ip ) ip adda   c;

code ?branch   sp )+ tst   bran1 beq
label skip     2 ip addq   c;

code (loop
  1 rp ) addq   bran1 bvc   ( increment counter and branch if not done )
  word 3 /n * rp d) rp lea  ( done; remove loop params from stack )
  /w ip addq                ( skip the branch offset )
c;
code (+loop
  sp )+ d0 move   d0 rp ) add   bran1 bvc
  word 3 /n * rp d) rp lea
  /w ip addq
c;
code (do  (s l i -- ) ( f83 )
  sp )+ d0 move   sp )+ d1 move
assembler
label pd0  ( -- r: loop-end-offset l+0x8000 i-l-0x8000 )
  ip rp -) move  ( save the do offset address )
  /w ip addq     ( skip the do offset )
  th 8000.0000 l# d1 add  ( 32-bit )
  d1 rp -) move   d1 d0 sub    d0 rp -) move
c;
meta
code (?do  (s l i -- ) ( f83 )
  sp )+ d0 move   sp )+ d1 move  normal d0 d1 cmp
  pd0 bne   bran1 bra
end-code
code i  (s -- n )
  rp ) d0 move   /n rp d) d0 add  d0 sp -) move
c;
code j   (s -- n )
  3 /n * rp d) d0 move
  4 /n * rp d) d0 add
  d0 sp -) move
c;
code (leave  (s -- )
label pleave
  2 /n * rp addq    ( get rid of the loop indices )
   rp )+ ip move   word ip ) ip adda normal
c;
code (?leave  (s f -- )
  sp )+ tst   pleave bne
c;

: bounds over + swap ; ( f83 )

assembler label dofalse  normal sp -) clr   next
meta
hex
code digit ( char base -- digit true | char false )
   sp )+ d0 move ( base )   sp ) d1 move ( char )
  byte   30 # d1 sub  dofalse bmi
   0a # d1 cmp   0>=
   if   31 # d1 cmp   dofalse bmi   27 # d1 sub   then
   d0 d1 cmp   dofalse bpl
  normal
   d1 sp ) move
   -1. l# sp -) move
c;
decimal

code hash  (s str-addr voc-ptr -- thread )
  sp )+ d1 amove  sp )+ a0 amove
  1 a0 addq
 byte a0 )+ d0 move  normal
  ( for 4 threads ) 3. l# d0 and
  d0 d0 add
\t32 d0 d0 add
  d0 d1 add
  d1 sp -) move
c;

hex
code (find    (s string link -- cfa true | str false )
  0 d1 moveq
\t16  sp )+ d0 move
\t16  d0 d7 wmove
\t32  sp )+ d7 move
  begin 0<>
  while
    d7 a1 lmove                 \ a1 is lfa
    sp ) a0 amove               \ a0 is string address
    /link a1 addq               \ bump to name field
    a1 ) d1 bmove               \ get the name field length
    begin
       a1 )+ a0 )+ byte cmpm
    0<> d1 dbuntil
    0=  if                      \ Found a match!
            normal
            a1 d1 lmove
            2 d1 addq
            -2 n# d1 and        \ align to cfa
            d1 sp )  move       \ put cfa on stack
            d1 a1 lmove
            6 # a1 -) byte btst normal 0<> \ Check immediate bit in flags byte
            if     1 n# sp -) move  \ immediate, leave 1
            else  -1 n# sp -) move  \ not immediate, leave -1
            then
            next                \ return
    then
                                \ no match - try next word
    d7 a1 move                  \ Get lfa 
\t16   a1 ) d7 wmove            \ Get next link
\t32   a1 ) d7 lmove            \ Get next link
  repeat
  sp -) clr   ( not found, return 0 on top of string )
c;
/link constant /link
: link@ ( addr -- link )
\t16 wa@
\t32 l@
;
: link! ( link addr -- )
\t16 w!
\t32 l!
;
: link, ( link -- )
\t16 w,
\t32 l,
;
: vfind ( str voc-ptr -- )
  over swap hash link@ (find
;
decimal

code enclose   (s addr  delim -- addr  n1 n2 n3 )
   sp )+ d0 move   sp ) a0 amove   d7 d6 lmove
   begin  byte   a0 )+ d1 move   d1 d0 cmp   normal 0<>
   until   1 a0 subq
   a0 d7 lmove   d6 d7 sub    d7 sp -) move
   byte   a0 ) tst   normal 0=
   if   1 d7 addq   d7 sp -) move   1 d7 subq   d7 sp -) move
        next   then
   begin  a0 )+ d1 bmove  0=
     if   d6 a0 suba   1 a0 subq   a0 sp -) move
          a0 sp -) move   next
     then   byte   d0 d1 cmp   normal  0=
   until  d6 a0 suba   1 a0 subq  a0 sp -) move
                       1 a0 addq  a0 sp -) move   c;

decimal
 
code cmove ( from-addr to-addr cnt -- )
  sp )+ d0 move
  sp )+ a0 amove
  sp )+ a1 amove
  here 4 + bra  ( jump to the dbra instruction )
  begin
     begin
       byte  a1 )+ a0 )+ move  normal
     d0 dbra
    d0 word clr long
    1 d0 subq
  cs until
c;

code cmove>  ( from to count ) 
  sp )+ d0 move
  sp )+ a0 amove   d0 a0 adda
  sp )+ a1 amove   d0 a1 adda
  here 4 + bra  ( jump to the dbra instruction )
  begin
     begin
       byte  a1 -) a0 -) move  normal
     d0 dbra
    d0 word clr long
    1 d0 subq
  cs until
c;

code ul*  ( ul1 ul2 -- lproduct )
  long
  sp )+ d0 move
  0= if   sp ) clr   next   then
  sp )+ d1 move
  0= if   sp -) clr   next   then

  d0 d2 wmove
  d1 d2 mulu
  d0 d3 wmove
  d0 swap
  word  d0 tst long
  0= if
        0 d0 moveq
  else
        d1 d0 mulu
  then
  d1 swap
  word  d1 tst  long
  0<> if   d1 d3 mulu   d3 d0 add   then
  d0 swap
  word  d0 clr  long
  d2 d0 add
  d0 sp -) move
c;

code *  ( l1 l2 -- lproduct )
  long
  sp )+ d0 move
  0= if   sp ) clr   next   then
  0< if   d0 neg
        sp )+ d1 move
        0= if  sp -) clr  next  then
        0>= if  ( 0>=  because 0> doesn't exist in the assembler )
               d0 d2 wmove  d1 d2 mulu  d0 d3 wmove
               d0 swap   d1 d0 mulu   d1 swap   d1 d3 mulu
               d3 d0 add  d0 swap   word d0 clr long
               d2 d0 add  d0 neg    d0 sp -) move
               next
        else   d1 neg
        then
  else
    sp )+ d1 move
    0= if   sp -) clr   next   then
  then
  d0 d2 wmove
  d1 d2 mulu
  d0 d3 wmove
  d0 swap
  word  d0 tst long
  0= if
        0 d0 moveq
  else
        d1 d0 mulu
  then
  d1 swap
  word  d1 tst  long
  0<> if   d1 d3 mulu   d3 d0 add   then
  d0 swap
  word  d0 clr  long
  d2 d0 add
  d0 sp -) move
c;
: l* * ;
code um*  (s uw1 uw2 -- l )  \ Only works if both operands < 16 bits
  sp )+ d0 move  sp )+ d1 move
  d1 d0 mulu
  d0 sp -) lmove
c;

: u*d um* ;

hex

label uldiv ( l l -- l.quot )
assembler
  long
                d1 tst 
        0= if   ( is divisor 0? if so quick trap )
                d1 d0 divu  ( will cause a trap )
        then
                d1 d3 move
                d3 word clr long
                d3 swap
        0= if   ( if divisor <= 16 bits, do easy divide )
                d0 d2 move
                d2 word clr long
                d2 swap
                d1 d2 cmp
          0< if ( if quotient fits in 16 bits, hardware divide is okay )
                d1 d0 divu
                d0 d1 move
                d1 word clr long
                d1 swap
                ffff. l# d0 and
                rts
          then  ( end of <= 16-bit quotient case )
                ( do 32 bit / 16 bit divide )
                d1 d2 divu
              ( dividend.high/divisor in d2.low )
              ( dividend.high%divisor in d2.high )
                d2 d3 move
                d0 d3 word move long
                ( remainder..dividend.low in d3 )
                d1 d3 divu
                d3 d0 move
                d3 d1 move
                d1 word clr long
                d1 swap
                ffff. l# d0 and
                d2 swap
                d2 word clr long
                d2 d0 add
                rts
        then ( end of 16-bit divisor case )

                0 d4 moveq
                d0 d2 move
                3 # d2 lsr
                d1 d2 cmp

         u< if ( if quotient < 8, do repeated subtraction )
           begin
                1 d4 addq
                d1 d0 sub
           u<= until
           0<> if
                1 d4 subq
                d1 d0 add
           then
        d0 d1 move
        d4 d0 move
        rts
    then ( end of repeated subtraction case )

     ( no special cases to take advantage of ! )
     ( however, the quotient has to fit in 16 bits, since the )
     ( divisor is more than 16 bits )
                d0 d2 move
                d1 d3 move
                1 d3 subq
          begin  ( scale divisor to fit in 16 bits )
                1 d4 addq
                1 # d3 lsr
                ffff. l# d3 cmp
          u<= until

                1 d3 addq
                ffff. l# d3 cmp
          u> if
                1 # d3 lsr
                1 d4 addq
          then
     ( d3 is scaled divisor )
     ( d4 is shift count for scaling )
                d4 d2 lsr
     ( d2 is scaled dividend )
                d3 d2 divu
                d1 d3 move
                d1 d5 move
     ( unscaled divisor in d3 and d5 )
                d3 swap
     ( divisor.upper in d3.lower )
     ( divisor.lower in d5.lower )
                d2 d5 mulu
                d2 d3 mulu
                d3 swap
                d3 word clr long
                d3 d5 add
     ( quotient * divisor in d5 )
                d5 d0 sub
     ( remainder in d0 )
                d0 d1 cmp
          <= if ( if remainder >= divisor, tweak the quotient )
                1 d2 addq
                d1 d0 sub
          then

                d0 d1 move
                d2 d0 move
                ffff. l# d0 and
                rts
meta
decimal
code um/mod ( ul.dividend un.divisor -- un.remainder un.quotient )
  long
  sp )+ d1 move   ( divisor in d1 )
  sp )+ d0 move   ( dividend in d0 )
  uldiv bsr
  d1 sp -) move   ( remainder in d1 )
  d0 sp -) move   ( quotient in d0 )
c;

code /mod ( n.dividend n.divisor -- n.rem n.quot )
  long
  sp )+ d1 move   ( divisor in d1 )
  sp )+ d0 move   ( dividend in d0 )
  0< if
         d0 neg
        d1 tst
        0< if
                d1 neg
                uldiv bsr
                d1 neg
                d1 sp -) move
        else
                d1 sp -) move
                uldiv bsr
                d0 neg
                d1 tst
                0<> if
                        1 d0 subq
                        d1 sp ) sub ( fix for floored division )
                else
                        d1 sp ) move
                then
        then
  else
        d1 tst
        0< if
                d1 sp -) move
                d1 neg
                uldiv bsr
                d0 neg
                d1 tst
                0<> if
                        1 d0 subq
                        d1 sp ) add ( fix for floored division )
                else
                        d1 sp ) move
                then
        else
                uldiv bsr
                d1 sp -) move
        then
  then
  d0 sp -) move         ( quotient in d0 )
c;

code and sp )+ d0 move  d0 sp ) and  c;
code or  sp )+ d0 move  d0 sp ) or   c;
code xor sp )+ d0 move  d0 sp ) eor  c;
\ FIXME notw ->not
code not sp ) notw c;

code +   sp )+ d0 move  d0 sp ) add  c;
code -   sp )+ d0 move  d0 sp ) sub  c;
code negate    sp ) neg   c;
code ?negate   sp )+ tst  0< if  sp ) neg  then   c;
code abs   sp )  tst  0< if sp ) neg  then   c;

code l+        long   sp )+ d0 move   d0 sp ) add   c;
code l-        long   sp )+ d0 move   d0 sp ) sub   c;
code lnegate   long   sp ) neg   c;
code ?lnegate   sp )+ tst  0< if   long   sp ) neg  then   c;
code labs  sp )  tst  0< if   long   sp ) neg  then   c;
code l2/ (s d -- d/2 )  long sp ) asr  c;

code min
   sp )+ d0 move   sp ) d0 cmp
   < if   d0 sp ) move   then   c;
code max
   sp )+ d0 move   sp ) d0 cmp
   > if   d0 sp ) move   then   c;

code lmin   long
   sp )+ d0 move   sp ) d0 cmp
   < if   d0 sp ) move   then   c;
code lmax    long
   sp )+ d0 move   sp ) d0 cmp
   > if   d0 sp ) move   then   c;

code up@   up sp -) move   c;
code sp@   sp sp -) move   c;
code rp@   rp sp -) move   c;
code up! ( new-up -- ) sp )+ up amove c;
code sp!   sp )+ sp amove   c;
code rp!   sp )+ rp amove   c;
code >r    sp )+ rp -) move   c;
code r>    rp )+ sp -) move   c;
code r@    rp )  sp -) move   c;
code exit   rp )+ ip amove   c;
code unnest rp )+ ip amove 
  ( duplicate next here to save a microsecond or so every time )
\itc     ip )+ w  rmove
\itc      w )+ a0 rmove   a0 ) jmp
\dtc   next
end-code
code tuck  (s n1 n2 -- n2 n1 n2 )
  sp )+ d0 move  sp )+ d1 move  d0 sp -) move d1 sp -) move  d0 sp -) move
c;
code nip (s n1 n2 -- n2 ) sp )+ sp ) move  c;
code flip  (s w1 -- w2 )  ( byte swap )
  sp ) d0 move  word 8 # d0 rol  normal d0 sp ) move
c;
code wflip  (s l1 -- l2 )  ( word swap )
  sp ) d0 lmove   d0 swap   d0 sp ) lmove
c;

assembler definitions
:-h leaveflag  ( condition -- )
( macro to assemble code to leave a flag on the stack )
\ XXX changed ] to ]-h
    d0 [ forth ] swap [ assembler ]-h setif
     d0 extw
     d0 extl
     d0 sp -) move
;-h
meta definitions
code 0=  sp )+ tst  0=  leaveflag c;
code 0<> sp )+ tst  0<> leaveflag c;
code 0<  sp )+ tst  0<  leaveflag c;
code 0<= sp )+ tst  0= if -1. l# sp -) move next then
                   0<  leaveflag c;
code 0>  sp )+ tst  0= if sp -) clr next then
                   0>= leaveflag c;
code 0>= sp )+ tst  0>= leaveflag c;

\ the odd sense of the comparisons is because the operands
\ come off the stack in the wrong order.
assembler definitions
:-h compare  normal sp )+ d0 move  sp )+ d0 cmp ;-h
meta definitions

code <   compare >   leaveflag c;
code >   compare <   leaveflag c;
code =   compare 0=  leaveflag c;
code <>  compare 0<> leaveflag c;
code u>  compare u<  leaveflag c;
code u<= compare u>= leaveflag c;
code u<  compare u>  leaveflag c;
code u>= compare u<= leaveflag c;
code >=  compare <=  leaveflag c;
code <=  compare >=  leaveflag c;

code drop  sp )+ d0 move   c;
code dup   sp ) sp -) move    c;
code over  /n sp d) sp -) move c;
code swap
   sp )+ d0 move  sp )+ d1 move
   d0 sp -) move  d1 sp -) move
 c;
code rot (s n2 n1 n0 -- n1 n0 n2 )
   sp )+ d1 move   sp )+ d2 move   sp ) d0 move
   d2 sp )  move   d1 sp -) move   d0 sp -) move   c;
code -rot (s n2 n1 n0 -- n0 n2 n1 )
  sp )+ d2 move  sp )+ d0 move  sp ) d1 move
  d2 sp )  move  d1 sp -) move  d0 sp -) move
c;

code 2drop  (s d -- )     sp )+ d0 lmove   sp )+ d0 lmove c;
code 2dup   (s d -- d d ) /n sp d) sp -) move /n sp d) sp -) lmove
c;
code 2over  (s d1 d2 d3 d4 -- d1 d2 d3 d4 d1 d2 )
  3 /n * sp d) sp -) lmove  3 /n * sp d) sp -) move c;
code 2swap     (s d1 d2 d3 d4 -- d3 d4 d2 d1 )
  sp )+ d0 move   sp )+ d1 move   /n sp d) sp -) move  /n sp d) sp -) move
  d0 2 /n * sp d) move   d1  3 /n * sp d) move
c;

code pick    (s nm ... n1 n0 k -- nm ... n2 n0 nk )
  sp )+ d0 move   d0 d0 add
  d0 d0 add
  0 d0 sp di) sp -) move
c;
: roll    (s nk nk-1 ... n1 n0 k -- nk-1 ... n1 n0 nk )
  >r  r@ pick   sp@ dup  na1+
  r> 1+ /n*
  cmove> drop
;

: 3dup (s a b c -- a b c a b c ) dup 2over rot ;
: 4dup (s a b c d-- a b c d a b c d ) 2over 2over ;
: 2rot (s a b c d e f -- c d e f a b ) 5 roll 5 roll ;
 
code 1+   1 sp ) addq   c;
code 2+   2 sp ) addq   c;
code 1-   1 sp ) subq   c;
code 2-   2 sp ) subq   c;

code 2/   sp ) d0 move  1 # d0 asr  d0 sp ) move c;
code u2/  sp ) d0 move  1 # d0 lsr  d0 sp ) move c;
code 2*   sp ) d0 move  1 # d0 asl  d0 sp ) move c;
code 4*   sp ) d0 move  2 # d0 asl  d0 sp ) move c;
code 8*   sp ) d0 move  3 # d0 asl  d0 sp ) move c;

code cset (s byte-mask addr -- )
  sp )+ a0 amove   sp )+ d0 move
  byte  d0 a0 ) or  c;
\ FIXME eorw -> eor
code creset (s byte-mask addr -- )
  sp )+ a0 amove   sp )+ d0 move   d0 notw
  byte   d0 a0 ) and  c;
code ctoggle (s b addr -- )
  sp )+ a0 amove   sp )+ d0 move
  byte   d0 a0 ) eor   c;
code on (s addr -- )
  sp )+ a0 amove
  ( true ) -1. l# a0 ) move
c;
code off (s addr -- )
 sp )+ a0 amove  a0 ) clr c;

code +! (s n addr -- )
  sp )+ a0 amove  a0 ) d0 move sp )+ d0 add  d0 a0 ) move
  c;
code toggle  (s addr byte-mask -- )
  sp )+ d0 move   sp )+ a0 amove
  byte   d0 a0 ) eor   c;

( requires alignment on a word boundary )
code @   sp )+ a0 amove  a0 ) sp -) move c;
code l@   sp )+ a0 amove  a0 ) sp -) lmove c;
code w@  sp )+ a0 amove   d0 clr
  word   a0 ) d0 move  normal  d0 sp -) move
c;
code <w@  sp )+ a0 amove ( with sign extension )
  word   a0 )+ a0 move  normal  a0 sp -) move    c;
code c@  sp )+ a0 amove   d0 clr
  byte   a0 ) d0 move   normal  d0 sp -) move    c;
( requires alignment on a word boundary )
code !   sp )+ a0 amove  sp )+ a0 ) move c;
( doesn't require alignment on a word boundary )
code w!  sp )+ a0 amove
  sp )+ d0 move d0 a0 ) wmove
c;
code c!  sp )+ a0 amove  sp )+ d0 move
  byte   d0 a0 ) move   c;
code 2@  sp )+ a0 amove
  /n a0 d) sp -) move  a0 ) sp -) move  c;
code 2!  sp )+ a0 amove
  sp )+ a0 )+ move  sp )+ a0 )+ move   c;

code fill (s start-addr count char -- )
    sp )+ d1 move
    sp )+ d0 move
    sp )+ a0 amove
    here 4 + bra   ( jump to the dbra instruction )
    begin
       begin
           byte  d1 a0 )+ move   normal
       d0 dbra
      d0 word clr long
      1 d0 subq
    cs until
c;
code noop  c;

\t16 code rel    ( addr -- d.addr )
\t16   sp )+ d0 move d0 sp -) rmove
\t16 c;

\t16 code wa->a  ( 16-bit-addr -- 32-bit-addr )
\t16   sp )+ d0 move d0 sp -) rmove
\t16 c;

code n->l ( n.unsigned -- l ) c;
code s->l ( n.signed -- l )   c;
code l->n ( l -- n ) c;
code n->a c;
code l->w   d0 clr   sp )+ d1 move   d1 d0 wmove   d0 sp -) move c;
code n->w   d0 clr   sp )+ d1 move   d1 d0 wmove   d0 sp -) move c;
code lwsplit ( l -- w.low w.high )  ( split a long into two words )
  sp )+ d0 move  d2 clr
  d0 d2 wmove  d2 sp -) move
  d0 swap  d0 d2 wmove d2 sp -) move
c;
code wljoin ( w.low w.high -- l )
  sp )+ d0 move   d0  sp ) wmove
c;
: lnswap ( l n -- n l ) swap ;
: l0= 0= ;
: ldup dup ;
: nlswap ( n l -- l n ) swap ;
: ldrop drop ;
: l2dup 2dup ;
: lswap swap ;
: l= = ;
: lnover over ;
code lr> ( -- l ) long rp )+ sp -) move  c;
code l>r ( l -- ) long sp )+ rp -) move  c;

\t16 code wa@  ( addr -- address )
\t16   sp )+ a0 amove  a0 ) sp -) rmove
\t16 c;
code ca+  ( addr index -- addr+index*/c )
  sp )+ d0 move d0 sp ) add c;
code wa+  ( addr index -- addr+index*/w )
  sp )+ d0 move   1 # d0 lsl   d0 sp ) add c;
code la+  ( addr index -- addr+index*/l )
  sp )+ d0 move   2 # d0 lsl   d0 sp ) add c;

code na+  ( addr index -- addr+index*/n )
  sp )+ d0 move
  2 # d0 lsl
  d0 sp ) add
c;

code ca1+ ( addr -- addr+/w ) /c d0 moveq  d0 sp ) add c;
code wa1+ ( addr -- addr+/w ) /w d0 moveq  d0 sp ) add c;
code la1+ ( addr -- addr+/l ) /l d0 moveq  d0 sp ) add c;
code na1+ ( addr -- addr+/n ) /n d0 moveq  d0 sp ) add c;

: l! ! ;
1 constant /c
2 constant /w
4 constant /l
/l constant /n

code /c* ( n -- n*/c ) c;
code /w* ( n -- n*/w ) sp ) d0 move  d0 sp ) add c;
code /l* ( n -- n*/l ) sp )+ d0 move  2 # d0 lsl  d0 sp -) move c;
code /n* ( n -- n*/n )
   sp )+ d0 move  2 # d0 lsl  d0 sp -) move
c;

0 constant 0   1 constant 1      2 constant 2
3 constant 3  32 constant bl    64 constant c/l
-1 constant true                 0 constant false

5 equ nvocs
nvocs constant #vocs

user-size-t constant user-size
\ First 5 user variables are used for multitasking
0 /n * user link       \ link to next task
1 /n * user entry      \ entry address for this task
2 /n * user saved-ip
3 /n * user saved-rp
4 /n * user saved-sp

\ next 2 user variables are used for booting
5 /n * user up0     ( initial up )
6 /n * user #user   ( next unallocated user location )
7 /n * next-user-t !

: ualloc ( size -- new-user-number )
  ( allocates size bytes of user space )
  #user @ user-size >= abort" User area used up!"
  #user @  swap #user +!
;

: nuser ( --namex ) ( like user but allocates space for you )
  /n ualloc user
;
: tuser ( --namex ) ( like user but allocates space for you )
  /token ualloc user
;

nuser sp0          \ initial parameter stack
nuser rp0          \ initial return stack
nuser dp           \ dictionary pointer
nuser 'tib         \ terminal input buffer

nuser warning      \ control of warning messages
nuser fence        \ barrier for forgetting
tuser voc-link     \ points to newest vocabulary
nuser >out         \ number of characters emitted
nvocs /n * ualloc-t user context   \ vocabulary searched first
nuser current      \ vocabulary which gets definitions
nuser state        \ compilation or interpretation
nuser base         \ for numeric input and output
nuser dpl          \ numeric input punctuation
nuser csp          \ for stack position error checking
nuser hld          \ points to last character held in pad
nuser ?interactive \ control over prompts

nuser (#out        \ number of characters emitted
nuser (#line       \ the number of lines sent so far

nuser prior        \ used for dictionary searches
nuser last         \ points to nfa of latest definition
nuser span         \ number of characters expected
\ nuser #tib         \ number of characters to interpret

\ Other user locations are used for deferred words

vocabulary forth

\ Emit is a two-level vector.
\ The low level is (emit and the high level is emit.
\ The low-level vector just selects the output device.
\ The high-level vector performs other processing such as keeping
\ track of the current position on the line, pausing, etc.
\ Terminal control with escape sequences should use the low-level vector
\ to prevent a pause from garbling the escape sequence.
\ Key is a two-level vector.
\ The low level is (key and the high level is key.
\ The low-level vector just selects the output device.
\ The high-level vector performs other processing such as switching
\ the input stream between different windows.

defer type  ( addr len -- )
defer (emit ( c -- )   \ Low level emit; just puts out the character
defer emit  ( c -- )   \ Higher level; keeps track of position on the line, etc
defer (key  ( -- c )   \ Low level key; just gets key
defer key   ( -- c )   \ Higher level; may do other nonsense
defer key?  ( -- f )   \ Is a character waiting?
defer bye   ( -- )     \ Exit to the operating system, if any
\ Is input coming from a file (as opposed to a human) ?
defer input-from-file? ( -- f )

defer #out
defer #line
defer cr

: emit1 ( char -- )     \ Default action for high-level emit
  pause (emit 1 #out +!
;

decimal
 7 constant bell
 8 constant bs
10 constant linefeed
13 constant carret
nuser caps

: here   (s -- addr )    dp @   ;
: allot  (s n -- )       dp +!   ;
: ,      (s n -- )       here   /n allot    !   ;
: c,     (s char -- )    here   /c allot   c!   ;
: w,     (s w -- )       here   /w allot   w!   ;
: l,     (s l -- )       here   /l allot   l!   ;
/token constant /token
: token, (s cfa -- )
\t16 w,
\t32 l,
;
: token@ (s addr -- cfa )
\t16 wa@
\t32 l@
;
: token! (s cfa addr -- )
\t16 w!
\t32 l!
;
code ta1+ ( addr -- addr+/token ) /token d0 moveq  d0 sp ) add c;

: space  (s -- )         bl emit   ;
: ?dup   (s n -- [n] n ) dup if   dup   then   ;
: between (s n min max -- f )
   >r over <= swap r> <= and ;
: within (s n1 min max+1 -- f )
   1- between
;

 
: erase      (s addr len -- )   0 fill   ;
: blank      (s addr len -- )   bl fill   ;
: pad        (s -- addr )   here 80 +   ;
: depth      (s -- n )   sp@ sp0 @ swap - /n /   ;

: hex        (s -- )   16 base !  ;
: decimal    (s -- )   10 base !  ;
: (compile  (s cfa -- )  token, ;
: compile   (s -- )   r> dup /token + >r   token@ (compile   ;
: immediate (s -- )   64 last @ name> 1- cset ;
\ NullFix  bl -> 0
: align     (s -- )   here 1 and  if  0 c,  then ;
: even      (s n -- n | n+1 )  dup 1 and + ;

: ?comp   state @  0= abort" Compilation Only " ;
: ?exec   state @     abort" Execution Only " ;
: ?pairs  - abort" Conditionals not paired " ;
: ?stack
   sp@ sp0 @ swap u<
   if   error-output  ." Stack Underflow" where  restore-output
        sp0 @ sp! abort
   then
   sp@  sp0 @  ps-size  -  u<   abort" Stack Overflow"   ;
: ?enough   (s n -- )
   depth 1- >   abort" Not enough Parameters" ;

\ For 32-bit tokens, dodoes just happens to be the same as docolon
here-t doestarget !
assembler label dodoes
  normal
  ip rp -) move   sp )+ ip lmove
\itc   w sp -) move
  next
meta
resolves <dodoes>

: m/mod ( l.dividend n.divisor -- n.remainder n.quotient ) /mod ;

: /     (s n1 n2 -- quot )   /mod  nip ;
: mod   (s n1 n2 -- rem )    /mod  drop  ;

code */mod (s w1 wmult wdiv -- wrem wquot )
   sp )+ d2 move  sp )+ d0 move  sp )+ d1 move
   d1 d0 muls   d2 d0 divs
   d0 d1 move   d1 swapw  d1 extl   d1 sp -) move
   d0 extl  d0 sp -) lmove   next
c;
code */ (s w1 wmult wdiv -- wquot )
   sp )+ d2 move  sp )+ d0 move  sp )+ d1 move
   d1 d0 muls   d2 d0 divs
   d0 extl  d0 sp -) lmove   next
c;

: mu/mod (s d# n1 -- rem d#quot ) ( size dependent )
  um/mod
;

code upc (s char -- upper-case-char )
  sp )+ d6 move   byte ascii a # d6 cmpi  >=
  if   ascii z #  d6  cmpi  <=  if  bl # d6 subi   then
  then   normal d6 sp -) move
c;
code lcc (s char -- lower-case-char )
  sp )+ d6 move   byte ascii A # d6 cmpi  >=
  if   ascii Z #  d6  cmpi  <=  if  bl # d6 addi   then
  then   normal d6 sp -) move
c;
: upper  (s addr len -- )
  bounds  ?do i dup c@ upc swap c!  loop
;
: lower  (s addr len -- )
  bounds  ?do i dup c@ lcc swap c!  loop
;
( string compare - case sensitive )
code comp (s addr1 addr2 len -- -1 | 0 | 1 )
  sp )+ d0 move  1 d0 addq
  sp )+ a0 amove  sp )+ a1  amove
  begin  1 d0 subq  0<>
  while  byte   a1 )+ a0 )+ cmpm   normal
         0<> if   0<  if    1. l# sp -) move
                      else -1. l# sp -) move
                      then  next
             then
  repeat  sp -) clr
c;

( string compare - case insensitive )
: caps-comp (s addr addr2 len -- -1 | 0 | 1 )
  1 abort" caps-comp: fix me, I'm not implemented!"
;
: compare caps @ if  caps-comp  else  comp then ;
: spaces   (s n -- )
   0  max  0 ?do  space  loop  ;
: backspaces (s n -- ) 0 ?do bs emit loop ;
: beep  (s -- ) bell emit ;
: (lf  linefeed emit ;
: (cr  carret emit ;
: lf   (s -- )    (lf  #out off  1 #line +! ;
: crlf   (s -- )  (cr lf ;

: tib     (s -- adr )   'tib @  ;

: hold   (s char -- )   -1 hld +!   hld @ c!   ;
: <#     (s -- )     pad  hld  !  ;
: #>     (s l# -- addr len )    ldrop  hld  @  pad  over  -  ;
: sign   (s l# n1 -- l# )  0< if  ascii -  hold  then  ;
: #      (s n1 l# -- n1 l# ) ( for upper case hex output, change 39 to 7 )
  base @ mu/mod           ( n1 nrem l# )
  nlswap                  ( n1 l# nrem )
  9 over < if  39 + then  ( n1 l# nrem' )
  48  +  hold
;
: #s     (s -- )     begin  #  ldup l0=  until  ;

: (u.)  (s u -- a len )   n->l    <# #s #>   ;
: u.    (s u -- )       (u.)   type space   ;
: u.r   (s u len -- )     >r   (u.)   r> over - spaces   type   ;
: (.)   (s n -- a len )   dup abs n->l   <# #s   nlswap sign   #>   ;
: s.    (s n -- )       (.)   type space   ;
: .r    (s n l -- )     >r   (.)   r> over - spaces   type   ;

: (ul.) (s ul -- a l )  <# #s #>   ;
: ul.   (s ul -- )      (ul.)   type space   ;
: ul.r  (s ul l -- )    >r   (ul.)   r> over - spaces   type  ;

: (l.)  (s l -- a l )   tuck labs   <# #s   rot sign  #>   ;
: l.    (s l -- )       (l.)   type space   ;
: l.r   (s l l -- )     >r   (l.)   r> over - spaces   type   ;
\ smart print that knows that signed hex numbers are uninteresting
: .     (s n -- ) base @ 10 = if s. else u. then ;
: ?     (s addr -- )    @  . ;

: (.s        (s -- )
  depth 0 ?do  depth i - 1- pick .  loop
;
: .s         (s -- )
   depth 0<
   if   ." Stack Underflow "
   else depth
        if (.s else ." Empty " then
   then
;

0 constant "temp  \ 256 allot-t

\ NullFix added 2dup +  0 swap c!
: place     (s str-addr len to -- )
   2dup c!
   2dup +  0 swap c!
   1+ swap move   ;
\ : pack (s str-addr len to -- to )
\    dup >r place r>
\ ;
code pack (s str-addr len to -- to )
  sp )+ a0 move
  sp )+ d0 move
  sp )+ a1 move
  a0 sp -) move
  d0 a0 )+ bmove
  here 4 + bra   \ jump to the dbra instruction
  begin
     a1 )+ a0 )+ bmove
  d0 dbra
  byte a0 ) clr  \ Add a null
c;

: 'word   (s -- addr )
   here 20 + ( out of the way of potential link and view fields )
;

\ Move to a machine alignment boundary.
\ The 68000 requires that words be placed at even addresses.
: aligned (s addr -- addr' ) even ;

\ Nullfix
: +str  (s str -- addr )     count + 1+ aligned ;

\ Copy a packed string from "fromaddr" to "toaddr"
: "copy (s fromaddr toaddr -- )      >r count r> place ;

\ Copy a packed string from "fromaddr" to "toaddr", returning "toaddr"
: "move (s fromaddr toaddr -- to )   >r count r> pack  ;

\ A simple memory allocator
\ Memory is allocated from the space between the top of the dictionary
\ and the parameter stack.   The first memory to be allocated is just below
\ the parameter stack area, and succeding allocations proceed downward from
\ there.
\ The advantage of this over ALLOT is that allot consumes dictionary
\ space which must be stored in a file if a SAVE-FORTH is performed,
\ whereas ALLOC-MEM grabs some unitialized memory at run time.
\ Growing down below the stack only works if the system's memory management
\ will automatically grow the stack.  If not, a different scheme must
\ be used (perhaps just ALLOT).

hex
ps-size constant ps-size
variable next-free-mem

: init-malloc
  sp0 @  ps-size -   next-free-mem !
;
\ Allocates "#bytes" of storage and returns it's starting address
: alloc-mem ( #bytes -- address )
  next-free-mem @ swap -  dup next-free-mem !
;

\ !!!!!!!  Start of file system stuff

\ !! Beginning of autoinc.f

\ &ptr is the address of a pointer.  fetch the pointed-to
\ character and post-increment the pointer
 
code @c@++ ( &ptr --- char )
  sp )+ a0 amove  a0 ) a1 amove
  long   d0 clr
  byte a1 )+ d0 move  normal d0 sp -) move
  normal a1 a0 ) move
c;
 
\ &ptr is the address of a pointer.  store the character into
\ the pointed-to location and post-increment the pointer
 
code @c!++ ( char &ptr --- )
  sp )+ a0 amove  a0 ) a1 amove
  sp )+ d0 move  byte d0 a1 )+ move  normal
  a1 a0 ) move
c;

\ signed mixed mode addition
code ln+ ( l n --- l )
     normal sp )+ a0 move  \ will sign extend if normal is word
     long sp )+ a0 adda
     a0 sp -) lmove
c;

\ !! Beginning of constants.f

\ buffered i/o  constants
-1 constant eof
 
nuser delimiter ( delimiter actually found at end of word )
nuser file

:-h struct 0 ;-h
:-h field create-t compile-t <field> over ,-t + ?debug ;-h

\ field creates words which return their address within the structure
\ pointed-to by the contents of file

: struct 0 ;

: field ( offset size --- offset+size )
  create over , +
\ does> @ file @ + ;
  ;code ( fd --- fd+offset )
\ FIXME  ;code in meta assembler should do getw?
     sp )+ a1 move     \ get address of parameter field
     normal
     'user file a0 lea
     a0 ) a0 rmove
     a1 ) a0  adda
     a0 sp -) move
c;
resolves <field>

\ The file descriptor structure describes an open file.
\ There is a pool of several of these structures.  When a file is opened,
\ a structure is allocated and initialized.  While performing an io
\ operation, the user variable "file" contains a pointer to the file
\ on which the operation is being performed.

struct ( file descriptor )
/n field bfbase     \ starting address of the buffer for this file
/n field bflimit    \ ending address of the buffer for this file
/n field bftop      \ address past last valid character in the buffer
/n field bfend      \ address past last place to write in the buffer
/n field bfcurrent  \ address of the current character in the buffer
/n field bfdirty    \ contains true if the buffer has been modified
/n field fmode      \ not-open, read, write, or modify
/l field fstart     \ Position in file corresponding to first byte in buffer
/n field fid        \ File handle for underlying operating system
/n field fread      \ Points to routine to read blocks from underlying system
/n field fwrite     \ Points to routine to write blocks to underlying system
/n field fclose     \ Points to routine to close file on underlying system
/n field falign     \ Points to routine to align on a block boundary
dup constant /fd  equ /fd

\ values for mode field
-1  constant not-open
 0  constant read   ( XXX ) 0 equ read
 1  constant write  ( XXX ) 1 equ write
 2  constant modify ( XXX ) 2 equ modify
modify constant read-write  ( for old programs )

\ An implementation factor which
\ initializes the current descriptor to use the buffer "bufstart,buflen"
: initbuf ( bufstart buflen -- )
  0. fstart l!
  over + bflimit !  ( bufstart )
  dup bfbase ! dup bfcurrent ! dup bfend !  bftop !
  bfdirty off
;

\ !! Beginning of descs.f

\ File descriptor allocation

 5         constant #fds  ( XXX ) 5 equ #fds
#fds /fd * constant /fds

0 constant fds

\ An implementation factor which
\ allocates memory for the pool of file descriptors
: init-fds
  /fds alloc-mem  ( base-address )
  ['] fds >body !
;

\ An implementation factor which
\ clears a file descriptor
: clear-fd ( fd -- ) file !   not-open  fmode  ! ;

\ An implementation factor which
\ clears all the  file descriptors
: clear-fds ( -- )
  fds  /fds   bounds
  do   i clear-fd   /fd +loop
;

\ An implementation factor which
\ returns true if the file descriptor fd is not currently in use
: fdavail? ( fd -- f ) file !  fmode @ not-open = ;

\ An implementation factor which
\ finds a free fd if there is one
: (get-fd ( -- fd | 0 )
  0
  fds  /fds  bounds          ( 0 end start )
  do                         ( 0 )
      i fdavail?             ( 0 this-fd-available? )
      if  drop i leave then
  /fd +loop                  ( fd | 0 )
;

\ File buffer allocation

#fds constant #fbufs

\ If the underlying operating system requires that files be accessed
\ in fixed-length records, then /fbuf must be a multiple of that length.
\ Even if the system allows arbitrary length file accesses, there is probably
\ a length that is particularly efficient, and /fbuf should be a multiple
\ of that length for best performance.  1K works well for many systems.

td 1024 constant /fbuf

0  constant fbufs

\ An implementation factor which
\ allocates memory for a pool of file buffers
: init-bufs 
  #fbufs /fbuf * ( size-of-buffer-area )
  alloc-mem  ( base-address )
  ['] fbufs >body !
;

\ Buffer allocation strategy - make as many fbufs as there are fds.
\ then if the n-th fd is used, also use the n-th fbuf

\ An implementation factor which
\ gets a file descriptor and attaches a file buffer to it
\ (get-fd has the desireable side effect of setting file
: get-fd ( -- )
  (get-fd                        ( fd )
  ?dup 0= abort" all fds used "  ( fd )
  fds - /fd /                    ( fd-number )
  /fbuf * fbufs +                ( buf )
  /fbuf initbuf
;

\ !! Beginning of gem interface

\ Forth File System interface to the Gem operating system

\ Interfaces to Gem system calls:

\ f_open   ( mode name -- fd )
\ f_close  ( fd -- )
\ f_read   ( address count fd -- actual-count )
\ f_write  ( address count fd -- actual-count )
\ f_lseek  ( whence fd l.position -- l.actual-position )
\ f_creat  ( protection name -- fd )
\ f_delete ( name -- err? )

\ Protection to be assigned to newly-created files
\ Defaults to unprotected

variable file-protection
decimal
0 is file-protection  \ no special protection 

th 1ff not constant u.recmsk

create cstrbuf 257 allot-t
create fstrbuf 257 allot-t
\ Convert a forth-style packed string to a C-style null-terminated string
\ The forth string is first copied to cstrbuf so appending the null won't
\ screw something up.
\ It might be nice to have a version of this that takes as an argument
\ the place to put the c-string, so that several c-strings could be passed
\ to a C routine.
code >cstr ( forth-string c-string-buffer -- c-string-absolute)
  sp )+  a1 rmove
  a1     a2 lmove
  sp )+  a0 rmove
  0      d0 moveq
  a0 )+  d0 bmove
  here 4 + bra  ( jump to the dbra instruction )
  begin
    byte  a0 )+ a1 )+ bmove
  d0 dbra
  0 # a1 ) bmove
  a2 sp -) lmove 
c;
: cstr ( forth-string -- c-string )
  cstrbuf >cstr
;
\ Find the length of a C string
code cstrlen ( l.c-str -- len )
  sp )+ a0 lmove
     a0 d0 lmove
  begin    a0 )+ byte tst  normal   0= until
  d0 a0 suba
   1 a0 subq
  a0 sp -) move
c;
: fstr ( c-string -- forth-string )
  dup cstrlen fstrbuf pack
;
\ : cstr ( forth-string -- c-string )
\   count >r cstrbuf r@ cmove
\   0  cstrbuf r> +  c!   cstrbuf n->a
\ ;

\ Input forth string address on stack, where to put it in a1
\ Output c string address in a0, next available location in a1
create f>cstr  assembler
  sp )+ d6       lmove   \ Return address
  sp )+       a2 lmove
  a1          a0 lmove
  0           d7 moveq   \ Clear high bits
  a2 )+       d7 bmove   \ Length byte
  here 4 + bra
  begin
     a2 )+ a1 )+ bmove
  d7 dbra
  a1 )+ byte clr normal
  d6 a2 lmove
  a2 ) jmp
meta

\ Input c string address in d0, output forth string address on stack
create c>fstr  assembler
  d0          a0 lmove
  'body fstrbuf l#  a1 lmove
  a1          a2 lmove
  1           a1 addq
  begin  a0 )+ a1 )+ bmove  0= until 
  a2    a0  suba
  1     a0  subq
  a0  a2 )  bmove
  sp )+ a0  lmove
  a2 sp -)  move    
  a0 ) jmp         \ Can't use jsr because we pushed something on the stack
meta

: land and ;
\ XXX Make a syscall compiler
hex
code f_close  ( fd -- )
  sp )+ d0 move   d0 sp -) wmove
  3e # sp -) wmove   1 # trap   4 sp addq
c;
code f_delete ( str -- err? )
  'body cstrbuf l# a1 lmove
  'body f>cstr l#) jsr
  a0 sp -) lmove
  41 # sp -) wmove   1 # trap   6 sp addq
  d0 sp -) move
c;
code f_creat ( mode cstr -- fd )
  'body cstrbuf l# a1 lmove
  'body f>cstr l#) jsr
  sp )+ d0 move
  d0 sp -) wmove
  a0 sp -) lmove
  3c # sp -) wmove   1 # trap   8 sp addq
  d0 sp -) move
c;
code f_open ( mode str -- fd )
  'body cstrbuf l# a1 lmove
  'body f>cstr l#) jsr
  sp )+ d0 move
  d0 sp -) wmove
  a0 sp -) lmove
  3d # sp -) wmove   1 # trap   8 sp addq
  d0 sp -) move
c;  
code f_write  ( buf bytes fd -- #written )
  sp )+ d0 move  ( fd )
  d0 sp -) wmove ( fd )
  40 # sp -) wmove   1 # trap   0c sp d) sp lea
  d0 sp -) move
c;
code f_read   ( buf bytes fd -- #read )
  sp )+ d0 move  ( fd )
  d0 sp -) wmove ( fd )
  3f # sp -) wmove   1 # trap   0c sp d) sp lea
  d0 sp -) move
c;
code f_lseek ( whence fd l.byteno -- l.byteno )
  sp )+ d0 move  ( byteno )
  sp )+ d1 move  ( fd )
  sp )+ d2 move  ( whence )
  d2 sp -) wmove ( whence )
  d1 sp -) wmove ( fd )
  d0 sp -) move  ( byteno )
  42 # sp -) wmove   1 # trap   0a sp d) sp lea
  d0 sp -) move
c;

\ Interfaces between the buffering code and the lower level operating
\ system code.  This is the stuff that has to be reimplemented to port
\ to a different operating system.

\ Rounds down to a block boundary.  This causes all file accesses to the
\ underlying operating system to occur on disk block boundaries.  Some
\ systems (e.g. CP/M) require this; others which don't require it (e.g. Gem)
\ usually run faster with alignment than without.

: gemalign ( l.byteno -- l.aligned )
  u.recmsk  s->l   land
;

\ An implementation factor which
\ positions to byte number "l.byteno" in the file "fhandle"
: gemfseek ( l.byteno fhandle -- )
    >r
    0 ( L_SET ) lnover r>  ( l.byteno whence l.byteno fhandle )
    nlswap f_lseek         ( l.byteno l.byteno' )
    l2dup l=
      if   ldrop ldrop   (  )
      else ." f_lseek failed - got " l. ." tried " l. quit then
;

\ Return the current position "l.current-position" within the file "fhandle"
: gemftell ( fhandle -- l.current-position )
  >r 1 ( L_INCR )  r>  0.  f_lseek
;

\ Return the current size "l.size" of the file "fhandle"
: gemfsize ( fhandle -- l.size )
  >r
  \ remember the current position
      r@ gemftell                  ( l.current-position )
  \ seek to end of file to find out where the eof is
      2 ( L_XTND ) r@  0.  f_lseek    ( l.current-position l.size )
  \ return to the original position
      lswap r> gemfseek            ( l.size )
;
 
\ Read at most "count" bytes into the buffer at address "addr" from the
\ file "fhandle" starting at position "l.byteno".  Returns the number of
\ bytes actually read.

: gemfread  ( addr count l.byteno fd -- #read )
  dup >r gemfseek                   ( addr count )
  r> f_read                         ( #read )
  dup 0<  abort" gemfread failed"   ( #read )
;

\ Write "count" bytes from the buffer at address "addr" to the
\ file "fhandle" starting at position "l.byteno".  Returns the number of
\ bytes actually written.

: gemfwrite ( addr count l.byteno fd -- #written )
  dup >r gemfseek                    ( addr count )
  r> f_write                         ( #written )
  dup 0<  abort" gemfwrite failed"   ( #written )
;

\ A "do-nothing" read routine which is used as the read routine for
\ write-only files.

: nullread ( addr count l.byteno fd -- count=0 )
 drop ldrop 2drop 0
;

\ XXX should write to error stream
\ A "error" write routine which is used as the write routine for
\ read-only files.  Trying to write a read-only file causes an abort.

: nullwrite ( addr count l.byteno fd -- )
  ." You tried to write to a read-only file!" abort
; 

\ An implementation factor which
\ initializes the current file descriptor to access the file "fhandle"
\ using mode "mode" (read, write, or modify)

: setupfd ( mode fhandle -- )
  ( mode fhandle )  fid !
  ( mode )    dup fmode !
  ( mode ) dup 1 <>        \ modes 0 and 2 allow reading
  if   ['] gemfread   else  ['] nullread   then  fread ! ( mode )
  0>                       \ modes 1 and 2 allow writing
  if   ['] gemfwrite  else  ['] nullwrite  then  fwrite !
  ['] f_close    fclose !
  ['] gemalign   falign !
;
 
\ Opens the file "name" (a packed string) in mode "mode", returning
\ a file descriptor for later use.  If the file cannot be opened,
\ returns 0.

: open ( name mode -- fd )
  depth 2 < abort" open needs 2 arguments - name and mode"
  dup rot  ( mode mode name )
  f_open             ( mode fhandle )
  dup 0<
  if   2drop 0       \ open failed
  else get-fd        ( mode fhandle )  \ get-fd sets file
       setupfd       ( )
       file @        ( fd )
  then
;

decimal
\ XXX this whole stdio thing needs to be rethought
0 constant stdin  \ /fd allot-t ( XXX )
0 constant stdout \ /fd allot-t ( XXX )
0 constant stderr \ /fd allot-t ( XXX )

0 constant siobufs  \ td 128 3 * allot-t ( XXX )

\ An implementation factor which
\ associates the already-open file "fhandle" with the file descriptor "fd"
\ using mode "mode".  "fhandle" has to be either 0, 1, or 2.
\ The buffer is chosen from one of three 128-byte buffers.
\ This is primarily intended to allow efficient line-buffered access
\ to Unix standard input, output, and error streams.
\ It may or may not make sense for systems other than Unix.

: setup-stdio-fd ( mode fhandle fd -- )
  file !         ( mode fhandle )

\ The next line uses the fhandle as an index into the
\ siobufs array.  The fhandles for stdin, stdout, and stderr
\ are not likely to ever change from 0, 1, and 2

  dup 128 * siobufs +   128  initbuf    ( mode fhandle )
  setupfd
;

\ An implementation factor which
\ sets up file descriptors for the Unix standard input, output, and error
\ streams.  See the comment for "setup-stdio-fd"

: setup-stdio ( -- )
  read  0 stdin  setup-stdio-fd
  write 1 stdout setup-stdio-fd
  write 2 stderr setup-stdio-fd
;

\ Create an empty file with name "name".  The file still must be
\ opened if it is to be accessed.

: make ( name -- f ) \ true success, false failure
  file-protection @ swap ( protection name ) f_creat ( fhandle )
  dup 0<
  if    drop false    else   f_close true     then
;

\ Delete the file with name "name".

: delete ( name -- f ) \ 1 success, 0 failure
  f_delete  0=
;

\ !! Beginning of expect-files.f

\ If we are using buffered output to the output stream, we need to
\ flush the buffer when the system tries to read from the input stream.
\ This ensures that prompt strings do not get stuck in the buffer.

\ Perhaps this should flush the current output stream instead of stdout?
\ Maybe it should check to see if the stream it flushes is actually
\ connected to a terminal?
: ?flushout ( -- )       \ Make sure terminal output gets seen
  file @
  stdout flush
  file !
;

\ Emit and type routines which uses the file system.  These are good to
\ use if the forth program is sending its output to a pipe or to a file.
\ The file system buffering improves the performance relative to doing
\ per-character operating system calls.  If the output stream is going
\ to a terminal, it probably doesn't matter much.

nuser out-file

: femit ( char -- )     out-file @ fputc  ;
: ftype ( addr len -- ) dup #out +!   out-file @ fputs  ;
: fcr ( -- )            #out off      linefeed femit   (flush ;

\ Prompt the user for another line of input.  This is only called
\ when the input stream is coming from a terminal.

: fprompt ( -- )
\   file @   out-file @   stdout out-file !
    #out @ if cr then
    status
    state @ if  ."  ] "  else  ." ok "  then
\     (flush
\   out-file !  file !
;
code goofy1
  ascii 1 # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
  7 # sp -) wmove    1 # trap   2 sp addq
c;
code goofy2
  ascii 2 # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
  7 # sp -) wmove    1 # trap   2 sp addq
c;
code goofy3
  ascii 3 # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
  7 # sp -) wmove    1 # trap   2 sp addq
c;
code goofy4
  ascii 4 # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
  7 # sp -) wmove    1 # trap   2 sp addq
c;
code goofy5
  ascii 5 # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
  7 # sp -) wmove    1 # trap   2 sp addq
c;

\ A file system low-level read routine which uses "expect" to get
\ the next line of input from the user's terminal, doing whatever
\ editing that expect provides.

: expect-fread ( addr count l.byteno fd -- #read )
  fprompt
  drop ldrop
  over >r  expect
  linefeed r> span @ + c!
  span @ 1+
;

\ When using the user's terminal as the input stream, the file descriptor
\ is not writeable, but we don't want an error abort, so we use this
\ low-level write routine which return 0 bytes actually written.

: expect-fwrite ( addr count l.byteno fd -- #written )
  drop ldrop 2drop 0
;

0 constant tib-fd \ /fd allot-t  ( XXX )

decimal

\ Set up and return a file descriptor so the user's terminal is
\ the input device, using "expect" to collect each input line.

: expect-fopen ( -- tib-fd )
  tib-fd  file  !
  tib 80 initbuf

  0                 fid    !
  read              fmode  !
  ['] expect-fread  fread  !
  ['] expect-fwrite fwrite !
  ['] drop          fclose !
  ['] noop          falign !
  tib-fd
;

\ Amount of space needed:
\   #fds * /fd     for automatically allocated file descriptors
\   #fds * /fbuf   for automatically allocated file buffers
\   3 * /fd        for stdio descriptors  ( XXX )
\   3 * 128        for stdio buffers      ( XXX )
\   1 * /fd        for expect descriptor
\   tib            for expect buffer
\
\ #fds = 5, so total of 9 * /fd  = 9 * 56 = 486 for fds
\ 5 * 1024 +  3 * 128  +  tib 
\ Total is ~6K

\ An implementation factor which allocates space for a file descriptor

\ FIXME  This is not ROMable because it requires storing into constants
: alloc-fd ( cfa -- )
  /fd alloc-mem   ( cfa addr )
  dup clear-fd    ( cfa addr )
  swap >body !    ( )
;

\ Initialize the file system.  This involves allocating space for
\ descriptors and buffers, and initializing the descriptors.

: init-files
  init-malloc

  \ Mass storage file descriptors
  init-bufs
  init-fds
  clear-fds

  \ Standard io stream file descriptors
  ['] stdin  alloc-fd
  ['] stdout alloc-fd
  ['] stderr alloc-fd
  128 3 *  alloc-mem ['] siobufs  >body !
  setup-stdio

  \ Interactive input file descriptors
  ['] tib-fd alloc-fd
  expect-fopen drop

  stdout out-file !
  256 alloc-mem ['] "temp >body !
;

\ !! Beginning of files.f
\ These are the words that a program uses to read and write to/from a file.

\ Unsigned minimum
: umin ( u1 u2 -- umin )
  2dup u< if drop else nip then
;

\ An implementation factor which
\ ensures that the bftop is >= the bfcurrent variable.  bfcurrent
\ can temporarily advance beyond bftop while a file is being extended.

: sync ( -- ) ( if current > top, move up top )
  bftop @ bfcurrent @ u<   if    bfcurrent @  bftop !    then
;

\ If the current file's buffer is modified, write it out
\ Need to better handle the case where the file can't be extended,
\ for instance if the file is a memory array
: (flush ( -- )
  bfdirty @   if
    sync
    bftop @ bfbase @  -               ( #bytes-to-write)
    bfbase @  over  fstart l@  fid @  ( #bytes addr #bytes l.position fid )
    fwrite @ execute                  ( #bytes-to-write #bytes-written )
    u>  abort" Flushbuf error"
    bfdirty off
    bfbase @   dup bftop !  bfcurrent !
  then
;

\ An implementation factor to
\ Fill the buffer with a block from the current file.  The block will
\ be chosen so that the file address "laddr" is somewhere within that
\ block.

: fillbuf ( laddr -- )
  falign @ execute fstart l!    \ Align the position to a buffer boundary
  bfbase @   bflimit @ over -          ( addr #bytes-to-read )
  fstart l@  fid @   fread @ execute   ( #bytes-read )
  bfbase @ +   bftop !
  bflimit @  bfend !
;

\ Return the current position within the current file

: (ftell ( -- laddr )
  fstart l@   bfcurrent @  bfbase @  -  ln+
;

\ An implementation factor to
\ return the accress within the buffer which corresponds to the
\ selected position "laddr" within the current file.

: >bufaddr ( laddr -- bufaddr )  fstart l@ l- l->n  bfbase @ +  ;

\ An implementation factor which
\ advances to the next block in the file.  This is used when accesses
\ to the file are sequential (the most common case).

\ Assumes the byte is not already in the buffer!
: shortseek ( bufaddr -- )
  bfbase @ - n->l  fstart l@  l+         ( laddr )
  (flush ldup fillbuf                    ( laddr )
  >bufaddr  bftop @  umin  bfcurrent !
;

\ Close the current file.
: (close ( -- )  (flush    not-open fmode !    fid @ fclose @ execute  ;

\ Starting here, some stuff doesn't have to be in the kernel

\ Seek to the position "laddr" within the current file.

: (fseek ( laddr -- )
  sync

  \ See if the desired byte is in the buffer
  ldup >bufaddr dup           ( laddr bufaddr bufaddr )
  bfbase @  bfend @  within   ( laddr bufaddr inbuf? )
  \ Is the desired byte already in the buffer?
  if
       lnswap ldrop                ( bufaddr )
  else
       drop (flush ldup fillbuf  ( laddr )
       >bufaddr                    ( bufaddr )
  then

  \ Seeking past end of file actually goes to the end of the file
  bftop @  umin   bfcurrent !
;

\ Returns true if the current file has reached the end.
\ XXX This may only be valid after (fseek or shortseek
: (feof? ( -- f )    bfcurrent @  bftop @  u>=  ;

\ Get the byte at the position "laddr" from the current file
: (file@ ( laddr -- byte )
  (fseek   (feof?  if   eof    else   bfcurrent @c@++    then
;

\ Get the next byte from the current file
: (fgetc ( -- byte )
  bfcurrent @   bftop @   u<
  if   \ desired character is in the buffer
       bfcurrent @c@++
  else \ end of buffer has been reached
       bfcurrent @ shortseek
       (feof?  if  eof  else  bfcurrent @c@++  then
  then
;

\ Store a byte into the current file at position "laddr"
: (file! ( byte laddr -- )
  (fseek ( byte )
  \ if daddr is >= eof address, fseek will set up bfcurrent
  \ at the eof address, so appending to the file will occur

  bfcurrent @c!++
  bfdirty on
;

\ Store a byte into the current file at the next position 
: (fputc ( byte -- )
  bfcurrent @   bfend @ u>=
  if   \ buffer is full
       bfcurrent @ shortseek
  then
  bfcurrent @c!++
  bfdirty on
;

\ An implementation factor
\ Copyin copies bytes starting at current into the file buffer at
\ bfcurrent.  The number of bytes copied is either all the bytes from
\ current to end, if the buffer has enough room, or all the bytes the
\ buffer will hold, if not.
\ newcurrent is left pointing to the first byte not copied.

: copyin ( end current -- end newcurrent )
  2dup -                      ( end current remaining )
  bfend @  bfcurrent @  -     ( end current remaining bfremaining )
  min                         ( end current #bytes-to-copy )
  dup if  bfdirty on  then    ( end current #bytes-to-copy )
  2dup  bfcurrent @ swap      ( end current #bytes  current bfcurrent #bytes)
  cmove                       ( end current #bytes )
  dup bfcurrent +!            ( end current #bytes )
  +                           ( end newcurrent)
;

\ Copyout copies bytes from the file buffer into memory starting at current.
\ The number of bytes copied is either enough to fill memory up to end,
\ if the buffer has enough characters, or all the bytes the
\ buffer has left, if not.
\ newcurrent is left pointing to the first byte not filled.

: copyout ( end current -- end newcurrent )
  2dup -                      ( end current remaining )
  bftop @  bfcurrent @  -     ( end current remaining bfrem )
  min                         ( end current #bytes-to-copy)
  2dup bfcurrent @ rot rot    ( end current #bytes  current bfcurrent #bytes)
  cmove                       ( end current #bytes)
  dup  bfcurrent +!           ( end current #bytes)
  +                           ( end newcurrent )
;

\ Write count characters from address addr into the current file
: (fputs ( addr count -- )
  over + swap  ( endaddr startaddr )
  begin  copyin  2dup u>
  while
    \ Here there should be some code to see if there are enough remaining
    \ bytes in the request to justify bypassing the file buffer and writing
    \ directly from the user's buffer.  'Enough' = more than one file buffer
        sync  bfcurrent @ shortseek ( endaddr curraddr )
  repeat
  2drop
;

\ Read up to count characters from the current file into memory starting
\ at address "addr"

: (fgets ( addr count -- nread )
  sync
  over + over  ( startaddr endaddr startaddr )
  begin  copyout  2dup u>
  while
    \ Here there should be some code to see if there are enough remaining
    \ bytes in the request to justify bypassing the file buffer and reading
    \ directly to the user's buffer.  'Enough' = more than one file buffer
        bfcurrent @ shortseek ( startaddr endaddr curraddr )
        (feof?  if  nip swap - exit then
  repeat
  nip swap -
;

\ Versions of the above words which reference an explicit file, rather
\ than using the "current file".  In most cases, it is safer to use these
\ versions instead of the "current file" versions.

: close ( fd -- )                file !  (close  ;
: ftell ( fd -- laddr )          file !  (ftell  ;
: fseek ( laddr fd -- )          file !  (fseek  ;
: file@ ( laddr fd -- byte )     file !  (file@  ;
: fgetc ( fd -- byte )           file !  (fgetc  ;
: file! ( byte laddr fd -- )     file !  (file!  ;
: fputc ( byte fd -- )           file !  (fputc  ;
: flush ( fd -- )                file !  (flush  ;
: fputs ( addr len fd -- )       file !  (fputs  ;
: fgets ( addr len fd -- nread ) file !  (fgets  ;

\ End of stuff that doesn't have to be in the kernel

\ !! Beginning of skip.addr.f

\ Buffer boundaries are transparant
\ end-of-file conditions work correctly
\ The actual delimiter encountered in stored in delimiter.

\ in-file contains the file descriptor which defines the input stream.
nuser in-file

\ ?fillbuf is called by the string scanning routines after skipbl, scanbl,
\ skipto, or scanto has returned.  ?fillbuf determines whether or not
\ the end of a buffer has been reached.  If so, the buffer is refilled and
\ end? is set to false so that the skip/scan routine will be called again,
\ (unless the end of the file is reached).

: ?fillbuf ( endaddr [ addr ]  delimiter -- endaddr' addr' end? )
    dup delimiter !  eof =     ( endaddr [ addr ] end-of-buffer? )
    if
         shortseek  
         bftop @  bfcurrent @  ( endaddr'  addr' )
         2dup u<=              ( endaddr'  addr' end-of-file? )
    else
         true            \ True so we'll exit the loop
    then
;

\ Low-level character processing routines:
\ skipbl   -   skip leading white space     ( interpreter )
\ scanbl   -   collect non-white characters ( interpreter )
\ skipto   -   skip to next occurrence of a character ( comments )
\ scanto   -   collect characters until next occurrence of a character ( word )
\
\ These routines, used solely by getword, getcword, and skipcword,
\ are not intended to be called by the user.  They are written in code
\ so the compiler will be fast.
\
\ These perform roughly the same function as EXPECT in Fig-Forth, except
\ that they do the "right things":
\ a) They allow words to span buffer boundaries
\ b) If the delimiter is not blank, leading delimiters are NOT skipped.
\ c) If the delimiter is blank, leading delimiters are skipped,
\    furthermore all control characters are treated as delimiters.
\    Carriage returns, linefeeds, tabs, form-feeds, etc can thus be
\    included in files.
\ d) A separate word (skipcword) is used for skipping comments.
\    It does not store the characters it scans, so the comment can be
\    arbitrarily long without worry of overflowing the word buffer.
\
\ The 68000 code here may be hard to follow, as it is highly optimized.

code scanbl ( endaddr addr str -- endaddr [ addr' ] delimiter )
  sp )+ a1 move    \ String pointer
  0 d0 moveq       \ Clear high portion
  a1 )+ d0 bmove   \ Length byte
  a1 a2 move       \ Save a copy for later
  d0 a1 adda       \ a1 now points to the end of the string

  sp )+ a0 amove   \ addr in a0
  sp )  d0 move    \ get endaddr
  a0 d0 sub        \ convert to length
  bl #  d1 wmove   \ delimiter in d1

  1 d2 moveq       \ Set condition codes and clear high portion of d2
  here 8 + bra
  begin
    a0 )+ d2 bmove
    d2 a1 )+ bmove
    byte d1 d2 cmp normal
  <= d0 dbuntil
  <= if                  \ Delimiter found; Actual delimiter is in d2
         d1 a1 -) bmove  \ Insert blank at the end
         a0 sp -) move   \ Push addr'
\         1 a1 subq      \ Don't include the delimiter in the count
  else
        -1 d2 moveq      \ EOF delimiter
  then
  d2 sp -) move          \ Push delimiter

  a2 a1 suba             \ New length
  a1 d0 move
  d0 a2 -) bmove         \ Store it
c;

code skipbl ( endaddr addr -- endaddr [ addr' ] delimiter )
  sp )+ a0 amove   \ addr in a0
  sp )  d0 move    \ get endaddr
  a0 d0 sub        \ convert to length
  bl #  d1 wmove   \ delimiter in d1

  0 d2 moveq       \ Set condition codes and clear high portion of d2
  here 4 + bra
  begin
    byte a0 )+ d1 cmp normal
  < d0 dbuntil
  < if                   \ Delimiter found
      a0 -) d2 bmove     \ Actual delimiter
      a0 sp -) move      \ Push addr'
  else
      -1 d2 moveq        \ EOF delimiter
  then
  d2 sp -) move          \ Push delimiter
c;

code scanto ( char endaddr addr str -- char endaddr [ addr' ] delimiter )
  sp )+ a1 move    \ String pointer
  0 d0 moveq       \ Clear high portion
  a1 )+ d0 bmove   \ Length byte
  a1 a2 move       \ Save a copy for later
  d0 a1 adda       \ a1 now points to the end of the string

  sp )+ a0 amove   \ addr in a0
  sp )  d0 move    \ get endaddr
  a0 d0 sub        \ convert to length
  /n sp d)  d1 move    \ char in d1

  1 d2 moveq       \ Set condition codes and clear high portion of d2
  here 8 + bra
  begin
    a0 )+ d2 bmove
    d2 a1 )+ bmove
    byte d2 d1 cmp normal
  0= d0 dbuntil
  0= if            \ Delimiter found; Actual delimiter is in d2
        a0 sp -) move    \ Push addr'
        bl # a1 -) bmove \ Add required trailing blank
  else
       -1 d2 moveq \ EOF delimiter
  then
  d2 sp -) move    \ Push delimiter

  a2 a1 suba       \ New length
  a1 d0 move
  d0 a2 -) bmove   \ Store it
c;

code skipto ( char endaddr addr -- char endaddr [ addr' ] delimiter )
  sp )+ a0 amove   \ addr in a0
  sp )  d0 move    \ get endaddr
  a0 d0 sub        \ convert to length
  /n sp d) d1 move \ char in d1

  1 d2 moveq       \ Set condition codes
  here 4 + bra
  begin
    byte a0 )+ d1 cmp normal
  0= d0 dbuntil
  0= if    \ Delimiter found, it's already in d1
          a0 sp -) move  \ Push addr'
  else   -1 d1 moveq     \ EOF delimiter
  then
  d1 sp -) move          \ Push delimiter
c;

\ The guts of the string scanning routine used by the Forth interpreter.
\ Getword gets the next sequence of printing (not blank or control)
\ characters from the file "fd" and stores them as a packed string at addr.

: getword (s addr fd -- addr )
  file !  >r
  bftop @  bfcurrent @    ( endaddr addr )

  begin
     skipbl               ( endaddr [ addr' ] delimiter )
     ?fillbuf             ( endaddr'  addr'' end? )
  until                   ( endaddr addr' )

  0 r@ c!
  begin
    r@ scanbl             ( endaddr [ addr' ] delimiter )
    ?fillbuf              ( endaddr'  addr'' end?)
  until
  bfcurrent !  bftop !    ( char )

  r>
;

\ The guts of the string scanning routine used to process strings delimited
\ by a character other than blank.
\ Getcword gets the next sequence of characters up to the first occurrence
\ of the delimiter character "char" from the file "fd" and stores them as
\ a packed string at addr.  Leading delimiters are NOT skipped.

: getcword (s addr char fd -- addr )
  file ! swap >r
  bftop @  bfcurrent @    ( char endaddr addr )

  0 r@ c!
  begin
    r@ scanto             ( char endaddr [ addr' ] delimiter )
    ?fillbuf              ( char endaddr'  addr'' end? )
  until
  bfcurrent !  bftop !    ( char )

  drop
  bl r@ count + c!
  r>
;

\ Get a blank-delimited string from the current input file
: blword ( -- str ) 'word in-file @ getword ;

\ The file system version of "word".  This is not quite faithful to the 83
\ standard , because this word only skips leading delimiters if
\ the delimiter is blank, and if the delimiter is blank, any non-printing
\ character is treated as a delimiter.  This allows tabs, carriage returns,
\ linefeeds, form feeds, etc., to be skipped when looking for the next word.

: (word (s char -- str )
  dup bl =
  if   drop 'word      in-file @ getword
  else      'word swap in-file @ getcword
  then
;

\ Skips forward in the file "fd" up to the next occurrence of the delimiter
\ "char".  Does not store the skipped characters anywhere.  This is the
\ mechanism for processing comments.  Since the characters are not stored,
\ arbitrarily-long comments may be handled without worrying about overflowing
\ a buffer.

: skipcword (s char fd -- )
  file !
  bftop @  bfcurrent @    ( char endaddr addr )

  begin
    skipto                ( char endaddr [ addr' ] delimiter )
    ?fillbuf              ( char endaddr'  addr'' end? )
  until
  bfcurrent !  bftop !    ( char )
  drop
;

\ Interpret the already-open file "fd"

: (load (s fd -- )
  in-file @ >r  in-file !
  interpret
  r> in-file !
;

\ Interpret a named file.  name-str is the address of a packed string
\ which is the file name.

: "load ( name-str -- )
  dup ( str str ) read open ?dup  ( str fd fd  |  str 0 )
  if
       nip >r r@ (load   r> close
  else
       error-output ." Can't load " count type cr restore-output abort
  then
;

\ Interpret a named file.  The file name is taken from the input stream.

: fload ( -- ) ( Input Stream: filename ) blword "load ;

\ Close all the open files and reclaim their file descriptors.
\ Use this if you see an "all fds used" message.

: close-fds ( -- )
  fds  /fds   bounds
  do   i file !
       fmode @ not-open <>  if   (close   then
  /fd +loop
;

\ !! Beginning of interpreter.f
\ These words use the string-scanning routines to get strings out of
\ the input stream.

: .(    (s -- ) \ Input stream: )-delimited-string
  ascii ) word count type ; immediate

: (     (s -- ) \ Input stream: )-delimited-string-skipped
  ascii ) in-file @ skipcword ; immediate

: ",    (s str -- )          here "move  +str dp ! ;

: ,"    (s -- ) ( Input stream:  "-delimited-string )
  ascii " word ",   ;

: ."    (s -- ) ( Input stream:  "-delimited-string )
  compile (."   ,"  ; immediate

: "     (s -- str-addr ) ( Input stream:  "-delimited-string )
  ascii " word  "temp "move ;

: ["]   (s Compile-time: --str ) (s Run-time: -- str-addr )
  compile ("s    ,"  ; immediate

: ""    (s -- str-addr ) ( Input stream: blank-delimited-string )
  blword   "temp "move  ;

: [""]  (s Compile-time: -- ) ( Input stream: "-delimited-string )
        (s Run-time: -- str-addr )
  compile ("s  blword  ",   ; immediate

: \ (s -- )      ( Input stream: rest of line skipped )
  delimiter @ linefeed <>
  if  linefeed in-file @ skipcword
  then
; immediate

\ !!!!!!!!!!!!! End of file stuff

\ Get the arguments passed from the program
\
\ Gargv leaves the address of the C-program gargv variable;
\  that variable contains a pointer to a longword which contains
\  the address of the file currently being interpreted.
\ Gargc leaves the address of the C-program gargc variable

\ Return a pointer to a packed string which is the arg#'th next argument.
\ The 0'th argument is the name of the current input file.
\ If the arg#'th argument doesn't exist, returns 0.
: arg ( arg# -- argument-string )
  dup gargc l@ >=  ( arg# f)  ( f is true if that arg doesn't exist )
  if   drop 0
  else gargv l@ swap la+ l@  ( address-of-arg-string )
       fstr
  then
;

variable arg#  0 is arg#
\ Get the next argument from the command line and bump gargc and gargv
\ so that that argument is "eaten", i.e. successive calls to nextarg will
\ get successive arguments.
: nextarg ( -- argument-string )
  arg# @  arg
  dup  if   1 arg# +!  then
;
: process-command-line ( -- )
  nextarg drop   \ The first argument is the name of the current thing
  begin  nextarg ?dup
  while
         dup  1+ c@ ascii - =
         if   drop expect-fopen in-file ! interpret
         else "load
         then
  repeat
;

4 constant #threads

: find   (s str -- cfa flag | addr false )
   prior off
   false   ( str found? )
   #vocs 0   ( loop over all vocabularies in search order)
   do   drop
      context i na+ @ dup               ( str voc-ptr voc-ptr )
      if   dup prior @ over prior !  =  ( str voc-ptr voc-ptr=prior? )
         if   drop false                ( str false )
         else   vfind                   ( cfa [ -1 | 1 ] | str false )
                dup ?leave
         then
      then
   loop
;

: canonical ( str-addr -- str-addr )
  caps @ if dup count lower then
;
: defined   (s -- here 0 | cfa [ -1 | 1 ] )
   blword  canonical  find   ;

defer status (s -- )

: ?missing   (s f -- )
  if   error-output  'word count type  ."  ?"  restore-output abort  then   ;
: literal     (s n -- )
  compile  (lit  , ;  immediate
: lliteral    (s l -- )
   compile  (llit l, ;  immediate
: ascii  (s -- n )
  blword 1+ c@
  do-literal
; immediate
code ('  ip )+ sp -) rmove  c;
: '   (s -- cfa )   defined 0= ?missing   ;
: ['] (s -- )       ' compile (' token, ; immediate
: [compile]   (s -- )   ' (compile   ; immediate
\ Modifies caller's ip to skip over an in-line string
code skipstr ( -- addr len)
  rp ) a0 move    \ Get string address
  0 d0 moveq
  a0 )+ d0 bmove   \ Get count byte
  a0 sp -) move
  d0 sp -) move
  1 d0 addq       \ Add null byte
\ Turn on low bit so that when d0 is added to a0
\ (which has been incremented past the length byte) the result will be even.
  word 1 # d0 orw normal
  d0 a0 adda       \ Now a0 points past the string
  a0 rp ) move
c;
code (" ( -- addr len)
  0 d0 moveq
  ip )+ d0 bmove   \ Get count byte
  ip sp -) move
  d0 sp -) move
  1 d0 addq        \ Skip null byte
\ Turn on low bit so that when d0 is added to a0
\ (which has been incremented past the length byte) the result will be even.
  word 1 # d0 orw normal
  d0 ip adda       \ Now a0 points past the string
c;
: ("s (s -- str-addr )   skipstr ( addr len ) drop 1- ;
: (." (s -- )            skipstr type ;

\ ",  --> given addr\len, emplace the string at here and allot space
\ ,"  --> accept a "-terminated string and emplace it.
\ "   --> accept a "-terminated string and leave it's address on the stack
\ ["] --> accept a "-terminated string and emplace it.
\         At run time, leave it's address on the stack.
\ ""  --> accept a blank delimited string and leave it's address on the stac
\ [""]--> accept a blank delimited string and emplace it.
\         At run time, leave it's address on the stack

: trim   (s faddr voc-addr -- )
   #threads 0
   do   2dup     link@       ( faddr thread  faddr link )
      begin
        2dup u<=               ( faddr thread  faddr link   f )
      while      link@       ( faddr thread  faddr link' )
      repeat
      nip over link!              ( faddr thread )
   /link +   loop
   2drop
;

\t16 origin-t constant origin-rel
\t16 : origin origin-rel rel ;
\t32 origin-t constant origin

: (forget   (s cfa -- )
\  >view 
   >link
   dup fence @ u< abort" below fence"  ( addr )
 ( first forget any vocabularies defined since the word to forget )

   dup voc-link
   begin   link@ 2dup  u>= until     ( addr voc-link-addr )
   dup voc-link link! nip             ( addr voc-link-addr )

 ( now, for all remaining vocabularies, forget words defined )
 ( since the word to forget )
   begin
     dup origin <>  ( any more vocabularies? )
   while
     2dup /n - ( addr voc-link-addr addr voc-pfa )
     >user     ( addr voc-link-addr addr voc-threads-addr )
     trim      ( addr voc-link-addr )
     link@        ( addr new-voc-link-addr )
   repeat
   drop   dp !
;

: forget   (s -- )
   blword   canonical
   current @ vfind 0= ?missing
   (forget
;
defer where
defer ?error
: (?error   (s adr len f -- )
   if  >r >r   sp0 @ sp!   ( printing off )
       r> r> error-output space type space  where restore-output abort
   else  2drop
   then
;
: -?error   (s f adr len -- )
   rot
   if
        error-output space type space  where restore-output
        abort
   else 2drop
   then
;
\ NullFix
: (abort"   (s f -- )
   skipstr -?error
;
: abort"   (s -- )
    compile (abort"  ," ;   immediate

: ?condition   (s f -- )
   not abort" Conditionals Wrong"   ;
: >mark      (s -- addr )    here 0 w,   ;
: >resolve   (s addr -- )    here over - ( addr offset ) swap w!   ;
: <mark      (s -- addr )    here    ;
: <resolve   (s addr -- )    here - w,   ;

: ?>mark      (s -- f addr )   true >mark   ;
: ?>resolve   (s f addr -- )   swap ?condition >resolve  ;
: ?<mark      (s -- f addr )   true   <mark   ;
: ?<resolve   (s f addr -- )   swap ?condition <resolve  ;

: leave   compile (leave                           ; immediate
: ?leave  compile (?leave                          ; immediate

: begin   ?<mark                                   ; immediate
: then    ?>resolve                                ; immediate
: do      compile (do    ?>mark                    ; immediate
: ?do     compile (?do   ?>mark                    ; immediate
: loop
    compile (loop   2dup 2+ ?<resolve ?>resolve    ; immediate
: +loop
    compile (+loop  2dup 2+ ?<resolve ?>resolve    ; immediate
: until   compile ?branch    ?<resolve             ; immediate
: again   compile  branch    ?<resolve             ; immediate
: repeat  2swap [compile] again   [compile] then   ; immediate
: if      compile  ?branch  ?>mark                 ; immediate
: else    compile  branch ?>mark  2swap ?>resolve  ; immediate
: while   [compile] if                             ; immediate

hex
: "create (s str -- )
   warning @                                  ( str f )
   if dup current @ vfind                     ( str [ cfa 1 | str 0 ] )
\ XXX needs to put this on the error stream
     if   ( str cfa ) over count type ."  isn't Unique " cr  then
     drop 
   then                                       ( str )
   align    here 0 link, ( temp link field )  ( str lfa )
   here last !   ( remember nfa )
   swap ( str ) count here pack              ( lfa nfa )
   current @ hash dup link@                  ( lfa tha prev)
   here /link - rot link! ( hook to thread ) ( lfa prev )
   swap link!             ( resolve link field )
   here  c@  1+  allot  0 c, align  ( place flags byte )

\ Put down the code field
\itc   0 w,
\dtc   4eb9 w, 0 l, \ [ assembler ] 0 l#) jsr  [ meta ]
  ;code
\itc     normal  w sp -) move
c;
resolves <variable>
decimal
: dump cr bounds ?do i w@ 8 u.r /w +loop ;
: dumpx blword 10 dump ;
: (create   (s -- )
  blword canonical "create
;

\ Extensible Layer            Defining Words          07SEP83HHL
: !csp   (s -- )   sp@ csp !   ;
: ?csp   (s -- )   sp@ csp @ <>   abort" Stack Changed "  ;
: hide      (s -- )
   last @   dup n>link link@    swap current @ hash link!   ;
: reveal   (s -- )
   last @   dup n>link       swap current @ hash link!   ;
: (;uses      (s -- )   r> @  last @ name>
\itc   w!
\dtc   2+ ( skip over jsr opcode) l!  ( store absolute address)
;
\ vocabulary assembler
: ;uses       (s -- )   ?csp   compile  (;uses
   [compile] [   reveal   ( assembler ) noop  ; immediate
: (;code     (s -- )   r>    last @ name>  ( code-address cfa-of-latest-word)
\itc  w!
\dtc  2+ ( skip over jsr opcode) l!  ( store absolute address)
;
: ;code       (s -- )   ?csp   compile  (;code
    [compile] [   reveal   ( assembler ) noop  ; immediate

hex
\ does> is implemented with a relative branch-to-subroutine to dodoes.
\ The range of a relative branch on the 68000 is only 32K bytes, so
\ a new copy of dodoes needs to be made when the dictionary size approaches
\ 32k.  The address of the new copy should be stored in "dodoesaddr" so
\ that does> will then generate bsr's to the new copy

tuser dodoesaddr

: does>   (s -- )   compile (;code
  ( when does> executes, it compiles a bsr to dodoes )
\t16  6100 w, ( bsr ) dodoesaddr token@ here - w,
\t32  4eb9 w, ( jsr ) dodoesaddr token@ token,
; immediate

\ extensible layer            defining words          27sep83map

hex
: :   (s -- )
   !csp   current @ context !   create hide    ]
\ ( xxx ) 4ef9 here 6 - w!
   -4 allot  4ed4 here 2 - w!   ( w @ jmp )  \ FAST
     ;code
      normal
\itc     ip rp -) move   w ip lmove
\itc ( duplicate next here to save a microsecond or so every time )
\itc     ip )+ w  rmove
\itc      w )+ a0 rmove   a0 ) jmp
\ \dtc  ip  rp -) move   sp )+  ip move   next
\ ( xxx )  ip  rp -) move   6 a0 d)  ip lea   next
           ip  rp -) move   2 a0 d)  ip lea   next   \ FAST
end-code  immediate
resolves <colon>
decimal
: ;   (s -- )
   ?csp   compile unnest   reveal   [compile] [
;   immediate

defer word

code traverse (s addr direction -- addr' )
  sp )+ d0 move  sp )+ a0 amove  d0 a0 adda
  begin
     \ a0 ) 7 # btst   0=
      7 # a0 ) btst 0=
  while
     d0 a0 adda
  repeat
  a0 sp -) move
c;
: forth-83   (s -- )
  ." This implementation is nearly FORTH-83 standard," cr
  ." but it lacks mass storage words and uses 32 bit stacks." cr
; immediate
: .version   (s -- )
  ." %M% %I% %E%"
;
: n>link (s nfa -- lfa )    /link -   ;
: l>name (s lfa -- nfa )    /link +   ;
: name>  (s nfa -- cfa )    count + 1+ aligned ;
: link>  (s lfa -- cfa )    l>name   name>   ;
hex
: body> (s pfa -- cfa )
\itc      /w -
\ \dtc      6 -
  /w - dup w@ 4ed4 <> if /l - dup w@ 4eb9 <> if 6 + then then  \ FAST
;
: >body (s cfa -- pfa )
\itc      /w +
\ \dtc  6 +    ( jsr + offset )
\ \dtc \ xxx should be smarter.  What about 16-bit branch offsets, etc.?
  dup w@ 4ed4 =  if wa1+ else dup w@ 4eb9 = if 6 + then then  \ FAST
;
code >name (s cfa -- nfa )
  sp ) a0 move
  1 a0 subq         \ Skip flags byte
  begin
    a0 -) byte tst normal
  0<> until         \ Skip any padding bytes
  th 20 n# d0 move  \ Length bytes are less than hex 20
  begin
    a0 -) d0 byte cmp normal
  u> until          \ Find the length byte
  a0 sp ) move
c;

: >link (s cfa -- lfa )     >name   n>link   ;

: long? (s -- f ) dpl @ 1+ 0<> ;
: convert (s l addr -- l' addr' )
  ( convert 32-bit number, leaving unconv. addr. *)
   begin  1+  dup  >r     ( l addr' ) ( r: addr+1 )
      c@  base  @  digit  ( l digit )
   while    >r  base @ ul*  r>  l+
      long?  if  1  dpl  +!  then  r>
   repeat  drop  r>
;
: number? ( str -- l flag )
   >r                                                        ( r: str)
   0. r@                         ( 0. str )                  ( r: str)
   dup 1+ c@ ascii - =           ( 0. str -sign?)            ( r: str)
   dup  >r  -                    ( 0. addr-of-first-numeric) ( r: str -sign?)
   -1 dpl !

   \ Convert groups of digits possibly separated by periods
   begin  convert
          dup c@ ascii . =
   while
          0 dpl ! 
   repeat                               ( l addr' )          ( r: str -sign?)

   \ negate if there was a minus sign
   r> if lnswap lnegate nlswap then     ( l addr' )          ( r: str)

   \ success if the string is exhausted
   r> count + =                         ( l flag )
;
: (number (s addr -- d# )
  number? 0= ?missing ;

defer number

decimal

\ : count      (s addr -- addr+1 len )
\    dup 1+   swap c@   ;
code count     (s addr -- addr+1 len )
  sp )+ a0 amove
  d0 clr
  a0 )+ d0 bmove
  a0 sp -) move
  d0 sp -) move
c;
: length      (s addr -- addr+2 len )
   dup 2+   swap @   ;
: move ( from to len -- )
  -rot  2dup u< if  rot cmove>   else  rot  cmove then ;
: (type       (s addr len -- )
   bounds ?do  i c@ emit  loop  ;
: -trailing  (s addr len -- addr len' )
   dup 0 do   2dup + 1- c@   bl <> ?leave  1-    loop   ;

defer expect
\ Use GEM to do the line editing
hex
code _expect ( addr len -- actual )
  sp )+ d0 move    \ Buffer Length
  sp )  a0 move    \ Buffer Address
  d0 a0 ) bmove    \ Gem uses the first byte of the buffer to find its length
  0a # sp -) wmove    1 # trap    6 sp addq
  0 d0 moveq
  1 a0 d) a1 lea   \ Address of actual-length byte
  a1 )+ d0 bmove   \ Actual length in d0, addr-of-first-byte in a1
  d0 sp -) move
  begin
    a1 )+ a0 )+ bmove
  d0 dbra
c;
: cursor-on   control [ (emit  ascii e (emit  ;  \ ESC-e
: cursor-off  control [ (emit  ascii f (emit  ;  \ ESC-f
: (expect   ( addr len -- )
  cursor-on
  _expect  span !
  lf  \   #out off  1 #line +!    is done by lf
  cursor-off
;

defer create

: control  (s -- n )
  blword 1+ c@  bl 1- and
  do-literal
; immediate

\ : complain
\    here count type   ."  not recognized "
\ ;
: (where
 input-from-file?
 if  state @
    if   ." Compiling "
    else ." Latest word was "
    then
    last @ .id cr
  then
;
: lose ." Undefined word encountered " cr abort ;
hex

defer error-output
defer restore-output
defer literal?      ( str -- str false  |  literal true )

defer do-defined    ( cfa -1 | cfa 1  -- ?? )
defer do-literal    ( literal -- ?? )
defer do-undefined  ( str -- )

: "compile ( str -- )
  canonical find ( str 0  |   cfa -1   |   cfa 1 )
  dup
  if   do-defined    (   )
  else drop          ( str )
       literal?      ( str false | ?? true )
       if    do-literal        ( ?? )
       else  do-undefined      (    )
       then
  then
;
: interpret-do-defined  ( cfa -1 | cfa 1 -- ?? )
  drop execute
;
: compile-do-defined    ( cfa -1 | cfa 1 -- )
  0> if   execute   ( if immediate )
     else (compile  ( if not immediate )
     then
;
: (literal?  ( str -- str false  | literal true )
  >r r@ number?   ( l f )
  if    r> drop  true
  else  drop r> false
  then
;
: interpret-do-literal ( l -- l | n )
;
: compile-do-literal ( l -- )
  long? if [compile] lliteral else [compile] literal then
;  
: interpret-do-undefined ( str -- )
  error-output
    count type ."  ?" cr
  restore-output
  quit
;
: compile-do-undefined   ( str -- )
  error-output
    count type ."  ?"  where
  restore-output
  compile lose
;
: [
  ['] (literal?              ['] literal?     (is
  ['] interpret-do-defined   ['] do-defined   (is
  ['] interpret-do-literal   ['] do-literal   (is
  ['] interpret-do-undefined ['] do-undefined (is
  state off
; immediate
: ]
  ['] (literal?              ['] literal?     (is
  ['] compile-do-defined     ['] do-defined   (is
  ['] compile-do-literal     ['] do-literal   (is
  ['] compile-do-undefined   ['] do-undefined (is
  state on
;
: more? ( str -- str f )
  dup c@
;
: (interpret  (s -- )
  begin   ?stack
          blword    ( str )
          more?     ( str f )
  while
          "compile
  repeat
  drop
;
defer interpret

hex
: .id     (s nfa -- )
   dup 1+ dup c@ rot c@ ( length field )
   1f and 0
   ?do
      dup 7f and emit
      80 and  ( if the end has been reached, fill out with _ to length )
      if 0df ( _ with 80 bit set ) else 1+ dup c@ then
   loop
   2drop space
;

\ Extensible Layer            Defining Words          16Oct83map
: recursive (s -- )   reveal ;   immediate

: user
     constant   ;code
\itc     w ) d0    move     \ 12
\itc     up  d0    add      \ 8
\itc     d0  sp -) move     \ 12  --> 32
\dtc     sp )+ a0    move   \ 12
\dtc     a0 )  d0    move   \ 12
\dtc     up    d0    add    \ 8
\dtc     d0    sp -) move   \ 12  --> 44
c;
resolves <user>

: >user ( pfa -- addr-of-user-var ) @  up@ + ;
: constant   (s n -- )
   create ,   ;code
\itc  w  )  sp -) move   \ 20  --> 20
\dtc  sp )+ a0    move   \ 12
\dtc  a0 )  sp -) move   \ 20  --> 32
c;
resolves <constant>

: variable  (s -- )
   create 0 ,
;
: wvariable (s -- )
  create 0 w,
;

\ defer (is is
\ Also known as execution vectors.
\ Usage:   defer bar
\ : foo ." Hello" ;  ' foo is bar
\ Alternatively: ' foo ' bar (is 

\ Since the execution of an execution vector doesn't leave around
\ information about which deferred word was used, we have to try
\ to find it by looking on the return stack
\ if the vector was EXECUTE'd, we don't know what it was.  This
\ will be the case if the deferred word was interpreted from the
\ input stream

: crash ( -- ) ( unitialized execution vector routine )
  r@ /token - token@         ( use the return stack to see who called us )
  dup ['] execute =
  if   'word count type space else   >name .id  then
  ." <--deferred word not initialized" abort
;

\ Allocates a user area location to hold the vector
: defer (s -- )
  create here /n ualloc ,                ( allocate a user location )
  >user  ['] crash   swap !   ( initialize to crash )
  ;code ( -- )
\itc    ( w has the pfa which contains the user # for the vector )
\itc    w ) d0 move                  ( get user number )
\itc    0 d0 up di) w rmove    ( get cfa from user area )
\itc           w )+ a0 rmove   a0 ) jmp
\dtc  ( addr-of-user-number-of-word-to-execute )
\dtc  sp )+ a0 move
\dtc  a0 )  d0 move
\dtc  0 d0 up di)l a0 rmove
\dtc  a0 ) jmp
end-code
\ or in high-level, does> >user @ execute ;
\ XXX added next line
meta
resolves <defer>
: (is ( target-cfa vector-cfa -- ) >body >user token! ;
: is  ( target-cfa --vector-name ) ' (is ;
hex

\ makes a sealed vocabulary with the top-of-voc pointer in user area
\ parameter field of vocabularies contains:
\ user-#-of-voc-pointer ,  voc-link ,
: voc-link, ( -- )  ( links this vocabulary to the chain )
  here   voc-link token@  token,   voc-link token!
;
: vocabulary ( --namex )
  create 
    ( make threads )  #threads /link *   ( size-of-threads )
    dup  ualloc   dup ( user#, ) ,       ( size user# )
    up@ +   swap erase                   ( init threads to 0)
    voc-link,
  does> >user context !
; resolves <vocabulary>
decimal
: definitions   (s -- )
   context @ current !   ;

\ Extensible Layer            Defining Words          06Oct83map
: 2constant
   create   , ,     (s d# -- )
  ;code             (s -- d# )
\itc  w )+ sp -) lmove
\itc  w )+ sp -) lmove
\dtc  sp )+ a0    move   \ 12
\dtc  a0 )+ sp -) move   \ 20
\dtc  a0 )+ sp -) move   \ 20  --> 52
c;
: 2variable
  create 0. , 0. ,   (s -- )
;
\ Could put in a stub assembler here but the metacompiler needs to be
\ able to compile into the target assembler vocabulary, which it can't do.
\ nuser avoc
\ : code   (s -- )      create  hide
\ \itc   here  dup body> w!
\ \dtc   here  dup body> - negate allot   ( get rid of the jsr )
\   context @ avoc !   ( assembler  ) noop ;
\ assembler definitions
\ : end-code  avoc @ context !   reveal   ;
\ forth definitions   meta in-meta

\ Initialization              High Level              29Sep83map
: .ok  #out @ if cr then status ." OK " ;
: ok ;
defer prompt
: (prompt
  ?interactive @ if .ok then
;
defer quit
: (quit   (s -- )
   sp0 @ 'tib !
   [compile] [
   expect-fopen in-file !
   interpret
;
: (abort    sp0 @ sp! quit  ;
defer abort

\ Console I/O for Gem

hex
code gem-emit  ( c -- )
  sp )+ d0 move
  d0  sp -) wmove
  2 # sp -) wmove    1 # trap   4 sp addq
c;

\ XXX should we use the semi-cooked (cbreak?) version (function 8)
code gem-key  ( -- c )
  7 # sp -) wmove    1 # trap   2 sp addq
  ff l# d0 and
  d0 sp -) move
c;

code gem-(key?     ( -- f )
  0b # sp -) wmove   1 # trap   2 sp addq
  d0 sp -) move
c;

code (bye      ( -- )
  0 # sp -) wmove
  4c # sp -) wmove   1 # trap   4 sp addq
c;

: (input-from-file? ( -- f )  false ;

: title ." 68000 Forth 83 - Atari 520 version " .version cr ;
\itc : \itc ; immediate
\itc : \dtc  [compile] \ ; immediate
\dtc : \itc  [compile] \ ; immediate
\dtc : \dtc ; immediate
\t16 : \t16 ; immediate
\t16 : \t32  [compile] \ ; immediate
\t32 : \t16  [compile] \ ; immediate
\t32 : \t32 ; immediate

\ Some hooks for multitasking
\ Main task points to the initial task.  This usage is currently not ROM-able
\ since the user area address has to be later stored in the parameter field
\ of main-task.  It could be made ROM-able by allocating the user area
\ at a fixed location and storing that address in main-task at compile time.

0 constant main-task
: init-user
    up@  up0 @  user-size  cmove  ( copy user area to its new home )
    up0 @ ( final-up ) up!
    up@ ['] main-task >body !
;
: (cold-hook
   [compile] forth definitions
   decimal
   ?interactive on
\   process-command-line
;
: stand-cold-hook ;
defer cold-hook
: cold
   init-user
   init-files
   cold-hook   
   quit
;
defer pause  ( for multitasking )
: single (s -- ) \ Turn off multitasking
  ['] noop ['] pause (is
;
: warm   (s -- )
  single
  warm-hook quit
;
defer warm-hook
: (warm-hook sp0 @ sp!  ;

hex
fffffa00 constant timer
: t@ timer + c@ ;
: t! timer + c! ;

code readbin ( buf -- count )
  sp )+ a0  move
  begin
     begin    fffffa2b l#) d0 bmove
              7 #  d0 btst
     0= while
              3 #  d0 btst    \ look for break
           0<> if  a0  sp -) lmove  next  then
     repeat
     fffffa2f l#)  a0 )+  bmove  \ snarf the character
  again
end-code

code sr! ( new-status-register-value -- )
  sp )+ d0 move
  d0 sr wmove
c;

: readit ( start-addr -- end-addr )
   0  7 t!     \ Turn off usart interrupts
  51 1d t!     \ Make sure prescaler is right (divide by 4)
   2 25 t!     \ Set divide counter to 2 for 9600 baud
  88 29 t!     \ Set USART to 8bits, 1StopBit, NoParity
   0 2b t!     \ Flush receiver
   1 2b t!     \ Enable receiver
  2700 sr!
  ( start-address ) readbin ( end-address )
  2300 sr!
;

variable supervisor-stack-pointer \ 0 is supervisor-stack-pointer
\ Set Supervisor mode; actually this is a toggle
code s_super ( stack -- old-supervisor-stack)
  20 # sp -) wmove  1 # trap  6 sp addq  \ XXX save ssp for later
  d0 sp -) move  
c;
: supervisor-mode ( -- )
  supervisor-stack-pointer @ 0=
  if    0  s_super  supervisor-stack-pointer !
  then
;
: user-mode ( -- )
  supervisor-stack-pointer @
  if   supervisor-stack-pointer @  s_super
       drop supervisor-stack-pointer off
  then
;

/l ualloc-t user caller-stack  ( The initial stack frame )
0 constant gargc
0 constant gargv

\ XXX FIXME should use absolute long branch?
\ Perhaps put the boot code right at the start

create cold-code
  here-t cld 2 + swap over - swap w!-t  ( cold entry point )
\ Executed with the stack containing:
( address-just-past-"cld bsr" -- )
assembler
long

   4 sp d)     d7  move  \ Get TPA address

\   th 7.0000 l# sp -) move
  sp -) clr
  20 # sp -) wmove  1 # trap  6 sp addq  \ XXX save ssp for later

   d7          a2  lmove
   th 0c a2 d) d1  lmove \ Size of text segment
   th 100. l#  d1  add   \ Adjust to include base page
   
\ Copy the dictionary image to its execution address
\ This assumes that the image is being moved up instead of down
\ If the two ranges do not overlap, it doesn't matter which way it is
\ being moved

   d1          a2  adda  \ Point at the end
   origin-t l# a1  lmove \ Where to put it
   d1          a1  adda  \ Point at the end
   a1          up  lmove \ We'll adjust this later

   begin  a2 d7 cmp  u<
   while  a2 -) a1 -) lmove
   repeat

   th 400.  l# up  suba  \ move back to the start of the user area

\ Remember the current value of the stack pointer in "caller-stack"
  sp  'user caller-stack   lmove

  origin-t l# sp  lmove \ Put the stack below the forth image

\ This is also an entry point for the stand-alone code.
\ At this point, the stack pointer has been set to the top of the stack area
\ and the user pointer has been set to the bottom of the initial user area
\ image.

  400. l#  sp  suba  ( allocate user area )
  sp  rp  lmove
  rp  'user up0   lmove
  rp  'user rp0   lmove
  100. l#  sp  suba  ( allocate return stack )
  sp  'user 'tib  lmove
   20. l#  sp  suba  ( for safety )
  sp  'user sp0   lmove

\t16  'body cold  #  ip  rmove
\t32  'body cold l#  ip  rmove
      ' <colon>  l#  w   lmove  \ FAST
\ Display some interesting registers, without assuming very much
\   th 0a # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\   th 0d # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\ \   7 # sp -) wmove    1 # trap   2 sp addq
\ 
\   a7 d4 lmove
\   7 # d5 wmove   begin  1c l# d2 lmove
\     d4 d3 lmove  d2 d3 lsr  0f l# d3 and  ascii 0 l# d3 add  4 # d4 lsl
\     d3 sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\   d5 dbra      th 20 # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\   a6 d4 lmove
\   7 # d5 wmove   begin  1c l# d2 lmove
\     d4 d3 lmove  d2 d3 lsr  0f l# d3 and  ascii 0 l# d3 add  4 # d4 lsl
\     d3 sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\   d5 dbra      th 20 # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\   a5 d4 lmove
\   7 # d5 wmove   begin  1c l# d2 lmove
\     d4 d3 lmove  d2 d3 lsr  0f l# d3 and  ascii 0 l# d3 add  4 # d4 lsl
\     d3 sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\   d5 dbra      th 20 # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\   a4 d4 lmove
\   7 # d5 wmove   begin  1c l# d2 lmove
\     d4 d3 lmove  d2 d3 lsr  0f l# d3 and  ascii 0 l# d3 add  4 # d4 lsl
\     d3 sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\   d5 dbra      th 20 # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\   a3 d4 lmove
\   7 # d5 wmove   begin  1c l# d2 lmove
\     d4 d3 lmove  d2 d3 lsr  0f l# d3 and  ascii 0 l# d3 add  4 # d4 lsl
\     d3 sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
\   d5 dbra      th 20 # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq

  th 0a # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq
  th 0d # sp -) wmove   2 # sp -) wmove    1 # trap   4 sp addq

next
meta

create warm-code
\ XXX here-t wrm 2 + swap over - swap w!-t  ( warm entry point )
assembler word

\t16    th 41fa , 0 ,  ( this is a "lea 0(pc ,a0" instruction )
\t16    a0 d7 lmove
\t16    'body warm      # ip rmove
\t16    'body main-task # a0 rmove     a0 ) up lmove 

\t32    'body warm      l#  ip rmove
\t32    'body main-task l#) up rmove
      ' <colon>  l#  w   lmove  \ FAST

        'user rp0           rp lmove
        'user sp0           sp lmove
next
meta

decimal

here-t   is fence
here-t   is dp

-1       is warning
-1       is ?interactive

' forth >body-t /n +   is voc-link

next-user-t @ is #user
current-t @   is forth

' noop        is pause

' crlf        is cr
\ ' fcr         is cr
' (type       is type
\ ' ftype       is type
' gem-emit   is (emit
\ ' femit       is (emit

' emit1       is emit
' (key        is key
' gem-key     is (key
' gem-(key?   is key?
' (bye        is bye
' (input-from-file?   is input-from-file?
' (expect     is expect
' (word       is word
' (#line      is #line
' (#out       is #out
' (number     is number
' (create     is create
' (interpret  is interpret
' (warm-hook  is warm-hook
' (cold-hook  is cold-hook
' (prompt     is prompt
' (quit       is quit
' (abort      is abort
' (where      is where
' noop        is error-output
' noop        is restore-output
' (?error     is ?error
' noop        is status

assembler dodoes meta   is dodoesaddr

forth-h
metaoff
' 0 is key?
only forth also definitions
' symbols fixall
\t16 fix-does-words
