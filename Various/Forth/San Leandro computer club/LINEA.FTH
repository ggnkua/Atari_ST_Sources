\ "line A" Graphics 	
\ This is an interface to the line A graphics routines
\ I have implemented only the routines that I could figure out.

decimal
\ These fields reflect the offsets into the table pointed to by A0 when the
\ line A graphics are first initialized.

variable a-vars
\ Create a name which will return the address stored in a-vars plus an offset
: afield:  ( offset -- )
  create ,
\ does> @ a-vars @ +
  ;code
  sp )+       a0 lmove
  a0 )        a0 lmove    
  a-vars l#)  a0 adda
  a0       sp -) lmove
c;

  0 afield: v_planes
  2 afield: v_lin_wr
  4 afield: contrl
  8 afield: intin
 12 afield: ptsin
 16 afield: intout 
 20 afield: ptsout
 24 afield: _fg_bp_1	
 26 afield: _fg_bp_2
 28 afield: _fg_bp_3
 30 afield: _fg_bp_4
 32 afield: _lstlin
 34 afield: _ln_mask
 36 afield: _wrt_mod
 38 afield: _x1
 40 afield: _y1
 42 afield: _x2
 44 afield: _y2
 46 afield: _patptr
 50 afield: _patmsk
 52 afield: _multifill
 54 afield: _clip
 56 afield: _xmn_clip
 58 afield: _ymn_clip
 60 afield: _xmx_clip
 62 afield: _ymx_clip 
 64 afield: _xacc_dda
 66 afield: _dda_inc
 68 afield: _t_sclsts  		
 70 afield: _mono_status
 72 afield: _sourcex
 74 afield: _sourcey
 76 afield: _destx
 78 afield: _desty
 80 afield: _delx
 82 afield: _dely 
 84 afield: _fbase
 86 afield: _fwidth
 90 afield: _style
 92 afield: _litemask
 94 afield: _skewmask
 96 afield: _weight
 98 afield: _r_off
100 afield: _l_off
102 afield: _scale
104 afield: _chup
106 afield: _text_fg
108 afield: _scrtchchp
112 afield: _scrpt2
114 afield: _text_bg
116 afield: _copytran

\ these are the regular program variables
variable patmskv  7 patmskv !
hex

decimal
\ this is a table containing the three resilution modes on the st
 create rez-table   320 w, 200 w,  640 w, 200 w,  640 w, 400 w,

hex
 44c constant rez-flag

: get-rez  ( -- x y )  ( return current screen rezolution )
  rez-flag c@  4 *  rez-table + dup w@ swap 2+ w@ 
;	decimal


hex
code init-a  ( -- addr )  ( line A graphics init routine ) 
  a000 w, decimal
  a0   a-vars l#)  lmove
c;

hex
code put-pix  ( -- )   ( low level set pixel routine )
 a001 w, 
c;

code get-pix  ( -- n )  ( low level get pixel routine )
 a002 w, decimal
 d0 sp -) lmove
c;

hex
code do-line  ( -- )  ( low level line draw call )
 a003 w,
c;

code h-line  ( -- )  ( low level horizontal line routine )
 a004 w,
c;

code fill-rec  ( -- )  ( low level filled rectangle routine )
 a005 w,
c;

code fill-poly  ( -- )  ( low level filled polygon routine )
 a006 w,
c;

code show-mouse  ( -- )  ( low level show mouse routine )
 a009 w,
c;

code hide-mouse  ( -- )  ( low level hide mouse routine )
 a00a w,
c;

code transform-mouse  ( -- )  ( low level mouse transform routine )
 a00b w,
c;

code copy-raster  ( -- )  ( low level raster copy routine )
 a00e w,
c;

decimal

: set-clip  ( x1 y1 x2 y2 --  ) ( set the clipping rectangle )
 _ymx_clip  w!   _xmx_clip w!
 _ymn_clip  w!   _xmn_clip w!
;

: color  ( pl1 pl2 pl3 pl4 -- )  ( set the 4 color planes )
 _fg_bp_4 w!  _fg_bp_3 w!   _fg_bp_2 w!  _fg_bp_1 w!
;

: lmask!  ( n -- )  ( set the line mask variable )
  _ln_mask w!
;

: line-a-init  ( -- )  ( high level line a initialization routine )
  init-a
   -1 lmask!
   -1  _lstlin     w!   
   0   _multifill  w!
   1 0 0 0 color
   patmskv @  _patmsk w!
   0 0 640 400 set-clip
;

: !pix  ( x y value --  ) ( high level pixel setting routine )
  intin @  w!
  ptsin @ swap  over 2+ w!  w!
  put-pix
;

: @pix  ( x y -- value )  ( high level pixel fetching routine )
  ptsin @  swap over 2+  w!  w!  get-pix
;

: draw  ( x1 y1 x2 y2 -- )  ( high level line routine )
  _y2 w!   _x2 w!    _y1 w!   _x1 w!
  do-line
;



\ this allows you to scale your line routines to work in any mode
: yscale  200 640 */   ;

: rectangle ( x1 y1 x2 y2 --  )  ( draw a filled rectangle )
 _y2 w!   _x2 w!    _y1 w!   _x1 w!
   fill-rec
;
decimal

: poly-line  ( addr n --  )  ( draw a line polygon )
 4* over + swap
  do   i w@  i 2+ w@  i 4 + w@  i 6 + w@  draw   4 +loop
;

code polygon  ( y1 y2 addr n --  )  ( fast polygon innner loop )
 sp )+          d0          lmove
 a-vars l#)     a1          lmove   
 ' contrl >body @  a1 d)    a2          lmove 
 d0             2 a2 d)     wmove
 ' ptsin >body @  a1 d)     d7          lmove
 sp )+    ' ptsin >body @  a1 d)    lmove 
 sp )+          d6          lmove
 sp )+          d5          lmove
 a3             sp -)       lmove   \ Save a3
 a1             a3          lmove   \ a1 gets clobbered so we use a3
 d5             d6          sub
 begin
	d5 ' _y1 >body @  a3 d) wmove
	hex a006 w, decimal
	1 d5 addq
 d6 dbra
 d7  ' ptsin >body @  a3 d) lmove
 sp )+          a3          lmove
c;

\ this is an example of the use of the polygon routine
\ create poly1
\		100 w, 100 w,    100 w, 200 w,
\		1   w, 300 w,    600 w, 250 w,
\		200 w, 375 w,    100 w, 100 w,
\ : polytest
\  poly1 5  poly-line
\ ;

hex 44e @ constant scradr  decimal

create mfdb
 scradr ,
 rez-flag c@ dup  4*  rez-table + dup w@ swap @ ,
 16 / w,
 0 w,
 2* 1 max 4 swap - 1 max  w,
 0 w,
 0 ,


\ raster copy routine is a low level bit map move routine it is fast

decimal

: rasmove  ( sx1 sy1 sx1 sx2 dx1 dy1 dx2 dy2 m -- )
 mfdb dup  contrl @  14 + 2!
 intin @  w!
 ptsin @  dup 14 +
  do  i w!  -2 +loop
 copy-raster
;

\ patterns 
create p0
-1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 ,
-1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 ,
-1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 ,
hex
create p1
-1 , c000c000 , c000c000 , c000c000 ,
     c000c000 , c000c000 , c000c000 , c000c000 ,
-1 , c000c000 , c000c000 , c000c000 ,
     c000c000 , c000c000 , c000c000 , c000c000 ,
-1 , c000c000 , c000c000 , c000c000 ,
     c000c000 , c000c000 , c000c000 , c000c000 ,

create p2
cccc3333 , cccc3333 , cccc3333 , cccc3333 ,
cccc3333 , cccc3333 , cccc3333 , cccc3333 ,
cccc3333 , cccc3333 , cccc3333 , cccc3333 ,
cccc3333 , cccc3333 , cccc3333 , cccc3333 ,
cccc3333 , cccc3333 , cccc3333 , cccc3333 ,
cccc3333 , cccc3333 , cccc3333 , cccc3333 ,  

create p3
c0c03030 , 0c0c0303 ,  c0c03030 , 0c0c0303 ,
c0c03030 , 0c0c0303 ,  c0c03030 , 0c0c0303 ,
c0c03030 , 0c0c0303 ,  c0c03030 , 0c0c0303 ,
c0c03030 , 0c0c0303 ,  c0c03030 , 0c0c0303 ,
c0c03030 , 0c0c0303 ,  c0c03030 , 0c0c0303 ,
c0c03030 , 0c0c0303 ,  c0c03030 , 0c0c0303 ,

create p4
03030c0c , 3030c0c0 ,  03030c0c , 3030c0c0 ,
03030c0c , 3030c0c0 ,  03030c0c , 3030c0c0 ,
03030c0c , 3030c0c0 ,  03030c0c , 3030c0c0 ,
03030c0c , 3030c0c0 ,  03030c0c , 3030c0c0 ,
03030c0c , 3030c0c0 ,  03030c0c , 3030c0c0 ,
03030c0c , 3030c0c0 ,  03030c0c , 3030c0c0 ,

create p5
c003300c , 0c3003c0 ,  03c00c30 , 300cc003 ,
c003300c , 0c3003c0 ,  03c00c30 , 300cc003 ,
c003300c , 0c3003c0 ,  03c00c30 , 300cc003 ,  
c003300c , 0c3003c0 ,  03c00c30 , 300cc003 ,
c003300c , 0c3003c0 ,  03c00c30 , 300cc003 ,
c003300c , 0c3003c0 ,  03c00c30 , 300cc003 ,

create p6
c3c33c3c , 3c3cc3c3 , c3c33c3c , 3c3cc3c3 ,
c3c33c3c , 3c3cc3c3 , c3c33c3c , 3c3cc3c3 ,
c3c33c3c , 3c3cc3c3 , c3c33c3c , 3c3cc3c3 ,
c3c33c3c , 3c3cc3c3 , c3c33c3c , 3c3cc3c3 ,
c3c33c3c , 3c3cc3c3 , c3c33c3c , 3c3cc3c3 ,
c3c33c3c , 3c3cc3c3 , c3c33c3c , 3c3cc3c3 ,

create p7
ffff8001 , 80018001 , ffff0180 , 01800180 ,
ffff8001 , 80018001 , ffff0180 , 01800180 ,
ffff8001 , 80018001 , ffff0180 , 01800180 ,
ffff8001 , 80018001 , ffff0180 , 01800180 ,
ffff8001 , 80018001 , ffff0180 , 01800180 ,
ffff8001 , 80018001 , ffff0180 , 01800180 , 

create p8
40a08040 , 80a05515 , 08081004 , 10048aaa ,
40a08040 , 80a05515 , 08081004 , 10048aaa ,
40a08040 , 80a05515 , 08081004 , 10048aaa ,
40a08040 , 80a05515 , 08081004 , 10048aaa ,
40a08040 , 80a05515 , 08081004 , 10048aaa ,
40a08040 , 80a05515 , 08081004 , 10048aaa ,

create p9
44440000 , 44440000 , 44440000 , 44440000 ,
44440000 , 44440000 , 44440000 , 44440000 ,
44440000 , 44440000 , 44440000 , 44440000 ,
44440000 , 44440000 , 44440000 , 44440000 ,
44440000 , 44440000 , 44440000 , 44440000 ,
44440000 , 44440000 , 44440000 , 44440000 ,

create p10
ffff2222 , ffff1111 , ffff8888 , ffff4444 ,
ffff2222 , ffff1111 , ffff8888 , ffff4444 ,
ffff2222 , ffff1111 , ffff8888 , ffff4444 , 
ffff2222 , ffff1111 , ffff8888 , ffff4444 ,
ffff2222 , ffff1111 , ffff8888 , ffff4444 ,
ffff2222 , ffff1111 , ffff8888 , ffff4444 ,

create p11
44448282 , 01010202 , 04040808 , 10102828 ,
44448282 , 01010202 , 04040808 , 10102828 ,
44448282 , 01010202 , 04040808 , 10102828 ,
44448282 , 01010202 , 04040808 , 10102828 ,
44448282 , 01010202 , 04040808 , 10102828 ,
44448282 , 01010202 , 04040808 , 10102828 ,

create p12
80808888 , 8080aaaa , 80808888 , 8080aaaa ,
80808888 , 8080aaaa , 80808888 , 8080aaaa ,
80808888 , 8080aaaa , 80808888 , 8080aaaa ,
80808888 , 8080aaaa , 80808888 , 8080aaaa ,
80808888 , 8080aaaa , 80808888 , 8080aaaa ,
80808888 , 8080aaaa , 80808888 , 8080aaaa , 

create p13
00001010 , 44440000 , 00001010 , 44440000 ,
00001010 , 44440000 , 00001010 , 44440000 ,
00001010 , 44440000 , 00001010 , 44440000 ,
00001010 , 44440000 , 00001010 , 44440000 ,
00001010 , 44440000 , 00001010 , 44440000 ,
00001010 , 44440000 , 00001010 , 44440000 ,

create p14
01018080 , 40400000 , 04040808 , 10100000 ,
01018080 , 40400000 , 04040808 , 10100000 ,
01018080 , 40400000 , 04040808 , 10100000 ,
01018080 , 40400000 , 04040808 , 10100000 ,
01018080 , 40400000 , 04040808 , 10100000 ,
01018080 , 40400000 , 04040808 , 10100000 ,

create p15
77778888 , 77770000 , dddd2222 , dddd0000 ,
77778888 , 77770000 , dddd2222 , dddd0000 ,
77778888 , 77770000 , dddd2222 , dddd0000 , 
77778888 , 77770000 , dddd2222 , dddd0000 ,
77778888 , 77770000 , dddd2222 , dddd0000 ,
77778888 , 77770000 , dddd2222 , dddd0000 ,

create p16
7e7e8181 , c0c03f3f , 00006666 , 99990000 ,
7e7e8181 , c0c03f3f , 00006666 , 99990000 ,
7e7e8181 , c0c03f3f , 00006666 , 99990000 ,
7e7e8181 , c0c03f3f , 00006666 , 99990000 ,
7e7e8181 , c0c03f3f , 00006666 , 99990000 ,
7e7e8181 , c0c03f3f , 00006666 , 99990000 ,

create p17
e640ffff , ffffe640 , e640ffff , e640e640 ,
e640ffff , ffffe640 , e640ffff , e640e640 ,
e640ffff , ffffe640 , e640ffff , e640e640 ,
e640ffff , ffffe640 , e640ffff , e640e640 ,
e640ffff , ffffe640 , e640ffff , e640e640 ,
e640ffff , ffffe640 , e640ffff , e640e640 , 

create p18
3838c6c6 , 38380000 , 83836c6c , 83830000 ,
3838c6c6 , 38380000 , 83836c6c , 83830000 ,
3838c6c6 , 38380000 , 83836c6c , 83830000 ,
3838c6c6 , 38380000 , 83836c6c , 83830000 ,
3838c6c6 , 38380000 , 83836c6c , 83830000 ,
3838c6c6 , 38380000 , 83836c6c , 83830000 ,
decimal
create patterns
 p0 ,  p1 ,  p2 ,  p3 ,  p4 ,  p5 ,  p6 ,
 p7 ,  p8 ,  p9 ,  p10 , p11 , p12 ,
 p13 , p14 , p15 , p16 , p17 , p18 ,

: set-pattern  ( n -- )  ( set the current fill pattern )
  4 *  patterns +  @  _patptr  !
;
