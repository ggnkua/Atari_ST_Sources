hex

: nip   swap drop ;

: bmask  1 swap lshift ;
: map  swap FOR AFT >r dup @ r@ execute over !  cell+ r> THEN NEXT 2drop ;
: dupcells  cells 2dup + swap cmove ;
: callot  cells allot ;

: esc 1b emit ;
: home  esc 48 emit ;
: inv   esc 70 emit ;

esc 76 emit

: .table    FOR AFT dup . dup @ . cr cell+ THEN NEXT drop ;

: #8bit  base @ >r 2 base ! # # # # # # # # r> base ! ;
: #.     2e hold ;
: .b     <# #8bit #. #8bit #. #8bit #. #8bit #> type ;

supenter

: vbase@ ffff8201 c@ 100 * ffff8203 c@ + 100 * ffff820d c@ + ;
: vbase@ dolit [ vbase@ ] , ;
: vcell  a0 * vbase@ +  over 5 rshift 2 lshift + ;
: mask   not 1f and 1 swap lshift ;
: bdot   vcell  swap  mask      over @ or   swap ! ;
: wdot   vcell  swap  mask not  over @ and  swap ! ;
: bdot   2dup 3c0 u< swap 500 u< and IF bdot exit THEN 2drop ;
: wdot   2dup 3c0 u< swap 500 u< and IF wdot exit THEN 2drop ;
: cls    vbase@ 9600 0        fillcells ;
: bls    vbase@ 9600 ffffffff fillcells ;

variable startcnt variable endcnt
: vbclock 462 ;
: .vblstats home cls decimal startcnt @ . cr endcnt @ . cr endcnt @ startcnt @ - . cr hex ;
: vblbench vbclock @ startcnt !  execute vbclock @ endcnt !  .vblstats ;

: seq  FOR AFT r@ over ! cell+ THEN NEXT drop ;
: exg   2dup @ swap @ rot ! swap ! ;
: +random   swap random and cells + ;
: shuffle  dup 1 - rot rot  FOR AFT  2dup +random  over r@ cells +  exg THEN NEXT 2drop ;

: ycenter 1e0 swap - ;
variable plotscale
8 plotscale !
: svdot   plotscale @ arshift  ycenter over swap bdot ;
: plot    0 swap FOR AFT 2dup cells + @ svdot 1+ THEN NEXT 2drop ;

: map2bmask  xtalit bmask map ;
: newfadetab  create here  20 dup 2 * callot  2dup seq 2dup shuffle 2dup map2bmask dupcells ;

newfadetab fadetab

variable phase  0 phase !
variable speed  1 speed !
: nextphase  phase dup @ 1 + 7f and swap ! ;
: fadestep  phase @ vbase@ fadetab fade2black ;
: o  speed @ FOR AFT fadestep THEN NEXT nextphase ;
: s  7f FOR o NEXT ;
: t  home cls words s ;
: q  xtalit s vblbench ;

: rndxy random ff and 500 * 8 rshift  random ff and 3c0 * 8 rshift ;

variable x  280 x !    variable y  1e0 y !

: rndline  rndxy 2dup vbase@ rot rot   x @ y @  whiteline  y ! x ! ;
: main do_console fadestep rndline nextphase ;

: fadeterm xtalit main 'mainloop !  inv bls home ;

