\ Assembler for the 68000.  The syntax is reverse-polish, ie the
\ operands come before the op-code.  The addressing mode syntax
\ is mostly the same as in Mike Perry's 68000 assembler which
\ was published in Dr. Dobb's Journal sometime in 1983
\ Documentation is sorely needed.

decimal
: lobyte 255 and ;
vocabulary assembler
: [forth] forth ; immediate
: [assembler] assembler ; immediate

also assembler definitions
: assembottom ; ( for unlinking assembler vocabulary and moving it )

( redefine here , c! as deferred so the meta compiler can )
( change them )

defer here
defer ,
defer c!
defer normal
defer amove
defer n#

variable deferb 14 allot
variable sstart variable send
: sclear 0 sstart ! 0 send ! ;
sclear
: push send @ deferb + ! /n send +! ;
: lpush lwsplit push push ;
: pop /n negate send +! send @ deferb + @ ;
: 2pop pop pop ;
: deque ( -- stackbot? )
  sstart @ send @ <
  if   sstart @ deferb + @  /n sstart +!  true
  else false
  then
;
variable immlo   variable immhi   variable nimm 0 nimm !
: imm 1 nimm ! immlo ! ;
: limm 2 nimm ! lwsplit immhi ! immlo ! ;  \ for 16 bit
: undefer ( --- )
  nimm @
  if nimm @ 2 =
    if immhi @ , then
    immlo @ ,
  then
  begin deque while , repeat
  sclear
  0 nimm !
;
: finish ( part1 part2 --- ) or , undefer ;

\ 68k assembler registers and address modes     wmb,21sep82
hex
: d0 0 ; : d1 1 ; : d2 2 ; : d3 3 ; : d4 4 ; : d5 5 ; : d6 6 ;
: d7 7 ; : a0 8 ; : a1 9 ; : a2 a ; : a3 b ; : a4 c ; : a5 d ;
: a6 e ; : a7 f ; : sr 3e ; : ccr 3f ;
: fixadd swap 7 and or ;    : ) 10 fixadd ;
: )+ 18 fixadd ; : -) 20 fixadd ; : d) 28 fixadd swap push ;
: #) push 38 ; : l#) lpush 39 ; : # imm 3c ; : l# limm 3c ;
: << ( n cnt --- n1 ) ( left  shift by cnt ) 0 do 2* loop ;
: >> ( n cnt --- n1 ) ( right shift by cnt ) 0 do 2/ loop ;
: reg\mode dup 7 and swap 38 and ;
: di) ( offset index-reg addr-reg -- )
  swap 0c << rot lobyte or push   dup 3a = if drop 3b
  else reg\mode 8 <> abort" bad add. mode for indexing"
  30 or then ;
: di)l ( offset index-reg addr-reg -- )
  di) pop 800 or push ;

\ 68k assembler error checks                    wmb,21sep82
: betw 2 pick > swap 2 pick < and ; ( n low-1 high+1 --- n f )
: ?isaltmem 0f 3a betw ;
: ?altmem ?isaltmem 0= abort" alterable memory operand reqd" ;
: ?isdatalt ?isaltmem over 8 < or ;
: ?datalt ?isdatalt 0= abort" data alterable operand reqd" ;
: ?isalt dup 3a < ;
: ?alt ?isalt 0= abort" alterable operand reqd" ;
: ?isdat 8 f betw 0= ;
: ?dat ?isdat 0= abort" data operand reqd" ;
: ?isctl f 18 betw over 20 3c betw swap drop or ;
: ?ctl ?isctl 0= abort" control operand reqd" ;
: ?ispostinc 17 20 betw ;
: ?postinc ?ispostinc 0= abort" postincrement operand reqd" ;
: ?ispredec 1f 28 betw ;
: ?predec ?ispredec 0= abort" predecrement operand reqd" ;

\ 68k assembler error checks cont               wmb,21sep82
: ?isdatreg dup 8 < ;
: ?datreg ?isdatreg 0= abort" data register operand reqd" ;
: ?isaddreg 7 10 betw ;
: ?addreg ?isaddreg 0= abort" address register operand reqd" ;
: ?isspec dup 3c > ;
: ?isusp dup 3d = ;
: ?usp ?isusp 0= abort" expecting usp as an operand" ;
: ?issr dup 3e = ;
: ?sr ?issr 0= abort" expecting sr as an operand" ;
: ?isccr dup 3f = ;
: ?ccr ?isccr 0= abort" expecting ccr as an operand" ;
: ?isimmed dup 3c = ;
: ?immed ?isimmed 0= abort" immediate operand reqd" ;
: ?isdisp 0 ;
: ?absolute ;
: ?disp ?isdisp 0= abort" better fix this displaced!" ;
variable size 40 size ! ( initially word )
: ?long size @ 80 = ;

: specialmove ?isspec
        if ?isusp if drop ?addreg 4e60
                 else  ?isccr if drop 44c0
                              else ?sr drop 46c0
                              then swap ?dat
                 then
        else swap ?isusp if drop ?addreg 4e68
                         else ?sr drop ?datalt 40c0
                         then
        then finish ;
: toregfld 9 << ;     : toopmodfld 3 << ;

: movesize size @ 0= if ( byte ) 1000
  else size @ 40 = if ( word ) 3000 else 2000 then then ;

: normalmove
  ?alt dup 7 and toregfld swap 38 and toopmodfld or or
  movesize finish ;

: move swap ?isspec >r swap ?isspec r> or
  if specialmove else normalmove then ;
: word 40 size ! ; : long 80 size ! ; : byte 0 size ! ;
: lmove size @ >r long move r> size ! ;
: wmove size @ >r word move r> size ! ;
: bmove size @ >r byte move r> size ! ;
: ?movemmr dup 2 < over 4 = or over 3c = or
  abort" this addressing mode not allowed for movem" ;
: ?movemrm dup 2 < over 4 = or over 39 > or
  abort" this addressing mode not allowed for movem" ;
: movem
  ?isimmed if drop ?movemmr 4c80
           else swap drop ?movemrm 4880
           then 
  1 nimm !
  ?long  if  40 or  then
  finish
;

: 1reg swap ?datreg or , ;    : swapw 4840 1reg ;
: extw 4880 1reg ;  : link 4e50 1reg ;  : unlk 4e58 1reg ;
: extl 48c0 1reg ;
: trap ?immed drop immlo @ dup 0f > abort" trap vector must be in 0-15"
       4e40 or , sclear 0 nimm ! ;
: dbuntil ( target-addr condition reg -- )
  ?datreg or 50c8 or , ( target-addr ) here - , ;
: db: create [forth] , [assembler] does> ( label reg pfa --- )
  @ ( label reg cond ) swap dbuntil ;
400 db: dbcc   c00 db: dbge   300 db: dbls  a00 db: dbpl
500 db: dbcs   e00 db: dbgt   d00 db: dblt  000 db: dbt
700 db: dbeq   200 db: dbhi   b00 db: dbmi  800 db: dbvc
100 db: dbf    f00 db: dble   600 db: dbne  900 db: dbvs
: dbra dbf ;
: illegal 4afc , ;  : reset 4e70 , ;  : nop 4e71 , ;
: stop    4e72 , ;  : rte   4e73 , ;  : rts 4e75 , ;
: trapv   4e76 , ;  : rtr   4e77 , ;

: ea1 swap ?datalt or size @ finish ;
: negx 4000 ea1 ;  : neg 4400 ea1 ;  : clr 4200 ea1 ;
: not 4600 ea1 ;  : tst 4a00 ea1 ;
: nbcd size @ >r 0 size ! 4800 ea1 r> size ! ;
: pea ?ctl 4840 finish ;
: tas size @ >r 0 size ! 4ac0 ea1 r> size ! ;
: jsr ?ctl 4e80 finish ; : jmp ?ctl 4ec0 finish ;
: scc 54c0 ea1 ;  : scs 55c0 ea1 ;  : seq 57c0 ea1 ;
: sf  51c0 ea1 ;  : sge 5cc0 ea1 ;  : sgt 5ec0 ea1 ;
: shi 52c0 ea1 ;  : sle 5fc0 ea1 ;  : sls 53c0 ea1 ;
: slt 5dc0 ea1 ;  : smi 5bc0 ea1 ;  : sne 56c0 ea1 ;
: spl 5ac0 ea1 ;  : st  50c0 ea1 ;  : svs 58c0 ea1 ;
: svc 59c0 ea1 ;

: imm1 rot ?immed drop ea1 ;  : subi 0400 imm1 ;
: addi 0600 imm1 ;  : cmpi 0c00 imm1 ;
: imm2 rot ?immed drop swap ?datalt
    ?isspec
    if   1 nimm !
         ?issr
         if   drop 7c
         else ?ccr drop 3c
         then
    else or size @
    then
  finish ;
: ori 0000 imm2 ;  : andi 0200 imm2 ;  : eori 0a00 imm2 ;
: shiftop
  swap ?isdatreg
  if                        ( register is being shifted )
     or                     ( set the destination register field )
     swap ?isdatreg
     if                     ( shift count in register )
        swap 20 or swap     ( set the "i/r" bit )
     else                   ( immediate shift count )
        ?immed drop 0 nimm !
        immlo @ 7 and       ( get the immediate operand )
     then
     toregfld or            ( set the count/register field )
     size @ or              ( set size field )
  else                      ( memory is being shifted )
     ?altmem                ( address mode validation )
     swap dup 0018 and 6 << ( move shift type bits 3,4 to their new place )
     swap f9ff and or       ( at bits 9,10 )
     or 00c0                ( set bits 6,7 to indicate a memory shift )
     or                     ( put in address mode )
  then
  ,                         ( emplace instruction )
;
: rol e118 shiftop ; : ror e018 shiftop ; : roxl e110 shiftop ;
: asl e100 shiftop ; : asr e000 shiftop ; : roxr e010 shiftop ;
: lsl e108 shiftop ; : lsr e008 shiftop ;

: bitop ( bit_no_or_register destination instruction_mask --- )
  rot ?isdatreg
  if
    toregfld 0100 or ( destination instr_mask reg_field ) or
  else
    ?immed drop 0800 or 1 nimm !
  then
  swap ?datalt
  finish
;
: btst 0000 bitop ;
: bset 00c0 bitop ; : bchg 0040 bitop ; : bclr 0080 bitop ;
: multop
  swap ?datreg
  toregfld or
  swap ?dat
  finish
;
: chk  4180 multop ; : divs 81c0 multop ; : divu 80c0 multop ;
: muls c1c0 multop ; : mulu c0c0 multop ;
: lea
  41c0
  swap ?isaddreg
  if
     7 and toregfld or
  then
  swap ?ctl
  finish
;
: arithop
  >r ?isdatreg
  if
     0
  else
     ?altmem swap ?datreg 0100
  then
  swap toregfld or or
  r> or size @
  finish
;
: sub 9000 arithop ; : add d000 arithop ;

: arithaop
  swap ?addreg
  7 and toregfld or
  ?long
  if
     100 or
  then
  finish
;
: suba 90c0 arithaop ; : adda d0c0 arithaop ; : cmpa b0c0 arithaop ;
: movep
  ?isdatreg
  if
     swap ?disp 7 and 0108 or swap
  else
     ?disp 7 and 0188 or swap ?datreg
  then
  toregfld ?long
  if
     400 or
  then
  finish
;
: bc:
  create [forth] , [assembler]
  does> @ swap here 2+ -
    dup abs 80 < 
    if
       lobyte or , 
    else
       swap , , 
    then
;
6000 bc: bra   6100 bc: bsr   6200 bc: bhi   6300 bc: bls
6400 bc: bcc   6500 bc: bcs   6600 bc: bne   6700 bc: beq
6800 bc: bvc   6900 bc: bvs   6a00 bc: bpl   6b00 bc: bmi
6c00 bc: bge   6d00 bc: blt   6e00 bc: bgt   6f00 bc: ble
: cond constant ;
000 cond always 100 cond never 200 cond hi   300 cond ls
400 cond cc     500 cond cs    600 cond ne   700 cond eq
800 cond vc     900 cond vs    a00 cond pl   b00 cond mi   
c00 cond ge     d00 cond lt    e00 cond gt   f00 cond le

( 000 cond t   100 cond f  )   200 cond u>   300 cond u<=
400 cond u>=   500 cond u<     600 cond 0<>  700 cond 0=
( 800 cond vc  900 cond vs )   a00 cond 0>=  b00 cond 0<
c00 cond >=    d00 cond <      e00 cond >    f00 cond <=

: ?brange ( offword --- offbyte ) dup abs 07f [forth] > [assembler]
   abort" branch offset out of 1-byte range" lobyte ;
: offset ( start dest --- offbyte ) swap 2+ - ?brange ;

: complement-condition ( condition -- not-condition )
  100 xor
;
: brif ( where condition -- ) 6000 or here rot offset or , ;
: setif ( ea condition -- ) ( set according to condition codes )
  50c0 or ea1
;

: moveq
  ?datreg toregfld 7000 or swap
  ( ?immed drop immlo @ 0 nimm ! )
  lobyte or ,
;

: arithq swap ?alt or swap ( ?immed drop 0 nimm ! immlo @ )
  7 and toregfld or size @ or , ;
: addq 5000 arithq ;  : subq 5100 arithq ;
: bcdop
  swap ?isdatreg
  if
     toregfld or swap ?datreg
  else
     ?predec 7 and toregfld or swap ?predec 8 or
  then
  finish
;
: sbcd 8100 bcdop ; : abcd c100 bcdop ;
: addx d100 size @ or bcdop ;  : subx 9100 size @ or bcdop ;
: cmp
  ?datreg toregfld or b000 or size @
  finish
;
: eor
  ?datalt b100 or swap ?datreg toregfld or
  size @
  finish
;
: cmpm  ( a-reg-postinc  a-reg-postinc -- )
  ?postinc 7 and toregfld b108 or swap ?postinc 7 and or
  size @ or ,
;

: exg
  ?isdatreg
  if
     swap ?datreg c140
    ( **** what?   else ?addreg 7 and swap )
  else
     ?addreg 7 and
     swap ?isdatreg
     if
        c188
     else
        ?addreg 7 and
     then
  then
  swap toregfld or or ,
;
: logicop
  >r ?isdatreg
  if
     swap ?dat swap 0
  else
     ?altmem swap ?datreg 0100
  then
  swap toregfld or or
  r> or size @
  finish
;
: orw 8000 logicop ; : andw c000 logicop ;

: if ( condition -- here )
  here dup rot ( here here condition )
  complement-condition ( here here not-condition )
  brif ( here )
;
: then   dup here offset swap 1+ c! ;
: else   never if swap then ;
: begin  here ;
: while  if ;
: until  complement-condition brif ;
: repeat swap never until then ;
: again  bra ;

\ save these for last because they override useful kernel words
: swap swapw ;
: or  orw ;
: and andw ;
: not not ;
: ext size @ 80 = 
  [forth] if   [assembler]
    extl
  [forth] else [assembler]
    extw
  [forth] then [assembler]
;

: up a3 ;  : rp a6 ;  : w a4 ;  : ip a5 ; : sp a7 ;
\c : up a2 ;  : rp a3 ;  : w d7 ;  : ip a5 ; : sp a4 ; : tos d6 ;

: rmove  ( src-mode dest-mode -- )
\t16  [ forth ] swap [ assembler ] d7 wmove
\t16  d7 [ forth ] swap [ assembler ] lmove
\t32  lmove
;

\ Since next compiles a relative branch to the "next" code, and the range
\ of relative branches on the 68000 is 32K, a new copy of the "next" code
\ has to be made when the dictionary size approaches 32K.  The user
\ variable "nextaddr" holds the address of the most-recent copy of the
\ "next" code.

\itc tuser nextaddr (next nextaddr w!
: next ( -- )
\itc  nextaddr token@ bra
\dtc   [ assembler ] ip )+ a0 rmove
\dtc   a0 ) jmp
\c     rts
;
: getw, ( -- )
 \  \dtc  sp )+ w lmove
;
: fix-code-field ( -- )
\itc  here dup /w - w! ( fix code field )
\dtc  -6 allot
\c    306 here body> token!
;

: end-code ( -- )
  sp@ csp @ <>
  [forth] if last @ .id ." : stack depth changed" cr then [assembler]
  current @ context !   ( go back to old context )
;
: c; ( -- )  next end-code  ;

also forth definitions
: ;code
  ?csp compile (;code getw,
  [compile] [ reveal
  [compile] assembler
  normal
; immediate
: code
  create ( make header )
  fix-code-field
  !csp     ( for error check later )
  [compile] assembler
  normal
;
only forth also definitions
