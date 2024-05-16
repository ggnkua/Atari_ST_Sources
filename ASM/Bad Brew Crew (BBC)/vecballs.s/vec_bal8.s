; Vector balls
; (c) 1991 Andy the Arfling productions
; Created 28/4/91 by
;
;  AAAAAAA N     N DDDDDD  Y     Y         TTTTTTT H     H EEEEEEE
;  A     A NNN   N D     D Y     Y            T    H     H E      
;  AAAAAAA N  N  N D     D  YYYYY             T    HHHHHHH EEEE   
;  A     A N   NNN D     D    Y               T    H     H E
;  A     A N     N DDDDDD     Y               T    H     H EEEEEEE
;
;        AAAAAAA RRRRRR  FFFFFFF L       III N     N GGGGGGG
;        A     A R     R F       L        I  NNN   N G
;        AAAAAAA RRRRRR  FFFF    L        I  N  N  N G    GG
;        A     A R     R F       L        I  N   NNN G     G
;        A     A R     R F       LLLLLLL III N     N GGGGGGG

step	equ	0

start
	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.w	#6,a7
	move.l	d0,old_sp
	
; Init demo
	lea	free_ram,a7
	move.w	#$25,-(a7)
	trap	#14
	addq.w	#2,a7
	move.b	$ffff8201.w,old_8201
	move.b	$ffff8203.w,old_8203
	move.b	$ffff8260.w,old_8260
	clr.b	$ffff8260.w
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_pal
	move.b	$fffffa07.w,old_fa07
	move.b	$fffffa09.w,old_fa09

	lea	$ffff8240.w,a0	Clear pallette
	moveq	#7,d0
.clr_pal	clr.l	(a0)+
	dbf	d0,.clr_pal

	clr.b	screens+3		Put screens on page boundaries
	clr.b	screens+7
	clr.b	screens+11
	move.l	screens+8,screen
	move.l	screens,a0
	move.l	screens+4,a1
	move.l	screens+8,a2
	moveq	#0,d0
	move.w	#$1f3f,d1
.clr	move.l	d0,(a0)+
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	dbf 	d1,.clr

	bsr	init_balls	Make sprite roots,div & hash tables
	bsr	music		Initialise music
.init_txt	bsr	text		Get first line of text on screen
	cmp.w	#1,text_com
	bne.s	.init_txt

	move.l	#mfp,$120.w
	move.b	#1,$fffffa07.w
	move.b	#1,$fffffa13.w
	ifeq	step
	clr.b	$fffffa09.w
	endc
	move.l	$70.w,old_vbl
	move.l	#vbl,$70.w

; Main loop

loop
	bsr	parse		Get next demo step
	bsr	vec_balls		Do balls
	bsr	text		Do text
;	move.w	#$700,$ffff8240.w

	move.l	scrn_ptr,a0	Flip screen
.wait	tst.w	wait_vbl
	bne.s	.wait
	move.b	screen+1,$ffff8201.w
	move.b	screen+2,$ffff8203.w
	st	wait_vbl
	move.l	(a0)+,screen
	tst.l	(a0)
	bne.s	.ok
	lea	screens,a0
.ok	move.l	a0,scrn_ptr

	ifeq	step
	cmp.b	#$b9,$fffffc02.w
	bne.s	loop
	endc
	ifne	step
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	cmp.w	#' ',d0
	beq.s	loop
	endc	
; Clean up

	move.b	old_fa07,$fffffa07.w
	move.b	old_fa07,$fffffa13.w
	move.b	old_fa09,$fffffa09.w
	move.l	old_vbl,$70.w
	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	move.b	old_8260,$ffff8260.w
	move.b	old_8201,$ffff8201.w
	move.b	old_8203,$ffff8203.w
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	old_sp,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.w	#6,a7
	clr.w	-(a7)
	trap	#1

; Interrupts

vbl
	clr.w	$ffff8240.w	Test frame rate and clear flag
	tst.w	wait_vbl
	bne.s	.1_frame
	ifeq	step
	move.w	#$700,$ffff8240
	endc
.1_frame	clr.w	wait_vbl

	move.b	#8,$fffffa21.w	Set up MFP
	move.b	#8,$fffffa1b.w

	tst.w	fade_del		Fade text if necessary	
	beq.s	.no_fade
	move.w	d0,-(a7)
	move.l	a0,-(a7)
	move.w	fade_del,d0
	subq.w	#1,d0
	move.w	d0,fade_del
	and.w	#3,d0
	bne.s	.faded
	move.l	fade1,a0
	add.w	#$111,(a0)
	move.l	fade2,a0
	sub.w	#$111,(a0)
.faded	move.l	(a7)+,a0
	move.w	(a7)+,d0
.no_fade	move.w	col1,$ffff8242.w
	move.w	col2,$ffff8244.w
	move.w	#$777,$ffff8246.w

	bsr	music+8		Call music
	rte

mfp
col1b	equ	*+2
	move.w	#0,$ffff8242.w
col2b	equ	*+2
	move.l	#0,$ffff8244.w
	clr.b	$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte

; Standard vars

old_sp	dc.l	0
old_vbl	dc.l	0
old_pal	ds.w	16
old_8201	dc.b	0
old_8203	dc.b	0
old_8260	dc.b	0
old_fa07	dc.b	0
old_fa09	dc.b	0
	even
wait_vbl	dc.w	0
screen	dc.l	0
scrn_ptr	dc.l	screens
screens	dc.l	free_ram+254,free_ram+254+$7d00,free_ram+254+2*$7d00,0


*********************
***   P A R S E   ***
*********************

; This routine controls the whole demo
; It decides what happens next

parse
	subq.w	#1,parse_del
	bne.s	.rts
	move.l	parse_ptr,a0
	move.w	(a0)+,parse_del
	move.w	(a0)+,d0
	bpl.s	.obj
	subq.w	#1,text_com	Show text
	bra.s	.pd
.obj	st	new_shape
	move.w	d0,obj_no
.pd	tst.w	(a0)
	bpl.s	.no_rpt
	lea	parser,a0
	moveq	#-1,d0
	bra.s	.obj	
.no_rpt	move.l	a0,parse_ptr
.rts	rts

parse_del	dc.w	1
parse_ptr	dc.l	parser
parser	dc.w	3*50,-1		Welcome
	dc.w	4*50,0*4		Cube
	dc.w	5*50,-1		Mess
	dc.w	1*50,-1		Mess
	dc.w	4*50,1*4		Tree
	dc.w	5*50,-1		Mess
	dc.w	5*50,2*4		BBC
	dc.w	5*50,-1		Mess
	dc.w	1*50,3*4		Cube 2
	dc.w	3*50,-1		Watch ...
	dc.w	28,-1		Here we go
	dc.w	15*50,4*4		Cube 2 spinning
	dc.w	4*50,-1		Restart
	dc.w	3*50,-1		Blank
	dc.w	-1		

*******************
***   T E X T   ***
*******************

; Three possible states:
;   0) Swap messages on screen and start writing new one
;   1) Doing nothing
;   2) Writing new message

text
	cmp.w	#1,text_com
	blt	.new_mess
	beq	.rts		Do nothing
; Add a new letter to the message
	tst.w	fade_del		Still fading?
	bne	.rts		Yep, so don't change gfx
	move.l	text_ptr,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	move.l	a0,text_ptr
	move.l	screens,a0	Get screen positions
	move.l	screens+4,a1
	move.l	screens+8,a2
	move.w	text_cnt,d1	Calculate offsets
	move.w	d1,d2
	and.w	#1,d1
	eor.w	d1,d2
	lsl.w	#2,d2
	add.w	d1,d2
	add.w	text_off,d2	Get correct bitplane
	add.w	d2,a0		Calculate char posns
	add.w	d2,a1
	add.w	d2,a2
	lea	charset,a3
	sub.w	#$40,d0
	lsl.w	#3,d0
	add.w	d0,a3		a3 now char gfx
x	set	0
	rept	8
	move.b	(a3)+,d0
	move.b	d0,x(a0)
	move.b	d0,x(a1)
	move.b	d0,x(a2)
x	set	x+160
	endr
	addq.w	#1,text_cnt	Another one bites the dust!
	cmp.w	#40,text_cnt
	blt.s	.rts
	subq.w	#1,text_com	End of text, go to delay mode
	rts

; Next message, fade these two
.new_mess
	move.l	fade1,d0		Swap over two cols
	move.l	fade2,fade1
	move.l	d0,fade2	
	move.w	#7*4,fade_del
	clr.w	text_cnt		No chars printed yet
	move.w	#2,text_com	Print new message
	eor.w	#2,text_off	Swap bitplanes
	cmp.l	#mess_end,text_ptr
	blt.s	.rts
	move.l	#messages,text_ptr
.rts	rts

fade_del	dc.w	0
fade1	dc.l	col2
fade2	dc.l	col1
col1	dc.w	0
col2	dc.w	$777
text_cnt	dc.w	0		Number of letters plotted
text_off	dc.w	0		Bitplane select
text_com	dc.w	2		Current command mode
text_ptr	dc.l	messages		Pointer to next char

messages ;Time shown (frames), object number, text

	dc.b	'@@@WELCOME@TO@THE@VECTOR@BALL@SCREEN@@@@'
	dc.b	'@@CODED@BY@ANDY@THE@ARFLING@OF@THE@BBC@@'
	dc.b	'@@@ALL@CALCULATIONS@DONE@IN@REALTIME@@@@'
	dc.b	'@@OVER@A@HUNDRED@BALLS@IN@SOME@OBJECTS@@'
	dc.b	'@@@@@ALL@PRESENTED@INSIDE@ONE@FRAME@@@@@'
	dc.b	'@@@@@@@@@@@@@WATCH@A@CORNER@@@@@@@@@@@@@'
	dc.b	'@@@@@@@@@@@@@@@HERE@WE@GO@@@@@@@@@@@@@@@'
	dc.b	'@@@@@@@@@@@TIME@FOR@A@RESTART@@@@@@@@@@@'
	dc.b	'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
mess_end

charset
	dcb.b	8,0		Space gfx by me ;-}
	incbin	8_by_8.dat

***********************************
***   V E C T O R   B A L L S   ***
***********************************

max_balls	equ	120
min_z	equ	$380-$80		Min distance + Min x
max_z	equ	$680+$80		Max distance + Max x

******************************************************************************

init_balls
	bsr	mk_roots
	bsr	mk_tab
	bsr	init_hash
	rts

mk_roots
; Check this out!
; This BUILDS the sprite routines!!!!!
	lea	spr_ptrs,a0	Pointer to sprite routines
	lea	spr_roots,a1	Space for routines

	lea	ball1_gfx,a2	Gfx for ball 1 (Medium size)
	moveq	#15,d0		Height of sprite
	bsr	build_16_wide_sprite_routine_in_planes_0_and_1

	lea	ball1_gfx,a2	Gfx for ball 1
	lea	spr_ptrs,a4	Ptr to routines with same clear
	moveq	#15,d0		Height of sprite
	bsr	build_16_wide_sprite_routine_in_planes_2_and_3

	lea	ball3_gfx,a2	Gfx for ball 2 (Small Size)
	moveq	#11,d0		Height of sprite
	bsr	build_16_wide_sprite_routine_in_planes_0_and_1

	lea	ball3_gfx,a2	Gfx for ball 2
	lea	spr_ptrs+2*64,a4	Ptr to routines with same clear
	moveq	#11,d0		Height of sprite
	bsr	build_16_wide_sprite_routine_in_planes_2_and_3
	rts

build_16_wide_sprite_routine_in_planes_0_and_1
	move.l	a1,-(a7)		Save ptr pos for clears
; Draw sprite routine
	moveq	#0,d1		Shifts
.1	move.l	a1,(a0)+
	move.w	#$28fc,(a1)+	move.l #clear_rout,(a4)+
	clr.l	(a1)+
	moveq	#0,d6		Offset
	move.l	a2,a3
	move.w	d0,d2		Height
.2	moveq	#0,d3
	moveq	#0,d4
	move.w	(a3)+,d3		Gfx to d3-d4
	move.w	(a3)+,d4
	ror.l	d1,d3		Shift gfx
	ror.l	d1,d4
	move.l	d3,d5		Build mask in d5
	or.l	d4,d5
	not.l	d5
	cmp.w	#-1,d5		Anything in first 16 pixels?
	beq.s	.3		Nope!
	move.w	#$2a8,(a1)+	'and.l #xxxx,oo(a1)
	move.w	d5,(a1)+		xx
	move.w	d5,(a1)+		xx
	move.w	d6,(a1)+		oo
	move.w	#$a8,(a1)+	'or.l  #yyyy,oo(a1)
	move.w	d3,(a1)+		yy
	move.w	d4,(a1)+		yy
	move.w	d6,(a1)+		oo
.3	addq.w	#8,d6
	swap	d5
	cmp.w	#-1,d5		Anything in next 16 pixels?
	beq.s	.4		Nope!
	swap	d3
	swap	d4
	move.w	#$2a8,(a1)+	'and.l #xxxx,oo(a1)
	move.w	d5,(a1)+		xx
	move.w	d5,(a1)+		xx
	move.w	d6,(a1)+		oo
	move.w	#$a8,(a1)+	'or.l #yyyy,oo(a1)
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	move.w	d6,(a1)+
.4	add.w	#152,d6
	dbf	d2,.2		Next line
	move.w	#$4e75,(a1)+	'rts
	addq.w	#1,d1		Next shift
	cmp.w	#16,d1
	blt.s	.1
; Clear sprite routine
	move.l	(a7)+,a2		Start of sprite routines
	moveq	#15,d0		16 sprite routines
.5	addq.w	#2,a2		Get past 'move.l #,(a4)+'
	move.l	a1,(a2)+		Add in clear routine address
.6	move.w	(a2)+,d1
	cmp.w	#$4e75,d1		'RTS'?
	beq.s	.7
	addq.w	#4,a2		Get past mask
	move.w	#$2140,(a1)+	'MOVE.L D0,xxxx(A0)'
	move.w	(a2)+,(a1)+	Add in offset
	addq.w	#8,a2		Get past 'OR.L #xxxx,ooo(A0)'
	bra.s	.6
.7	move.w	#$4e75,(a1)+
	dbf	d0,.5
	rts


build_16_wide_sprite_routine_in_planes_2_and_3
; Draw sprite routine
	moveq	#0,d1		Shifts
.1	move.l	a1,(a0)+
	move.l	#$58acfffc,(a1)+	addq.l #4,-4(a4)
	move.w	#$28fc,(a1)+	move.l #clear_rout,(a4)+
	move.l	(a4)+,a5		Ptr to sprite routine
	move.l	2(a5),(a1)+	Address of clear routine
	moveq	#0,d6		Offset
	move.l	a2,a3
	move.w	d0,d2		Height
.2	moveq	#0,d3
	moveq	#0,d4
	move.w	(a3)+,d3		Gfx to d3-d4
	move.w	(a3)+,d4
	ror.l	d1,d3		Shift gfx
	ror.l	d1,d4
	move.l	d3,d5		Build mask in d5
	or.l	d4,d5
	not.l	d5
	cmp.w	#-1,d5		Anything in first 16 pixels?
	beq.s	.3		Nope!
	tst.w	d6		Any offset?
	beq.s	.no_off1
	move.w	#$41e8,(a1)+	'lea oo(a0),a0
	move.w	d6,(a1)+		oo
	moveq	#0,d6
.no_off1	move.w	#$263c,(a1)+	'move.l #xxxx,d3
	move.w	d5,(a1)+		xx
	move.w	d5,(a1)+		xx
	move.l	#$c798c790,(a1)+	'and.l d3,(a0)+ ; and.l d3,(a0)
	move.w	#$98,(a1)+	'or.l  #yyyy,(a0)+
	move.w	d3,(a1)+		yy
	move.w	d4,(a1)+		yy
	subq.w	#8,d6
.3	addq.w	#8,d6
	swap	d5
	cmp.w	#-1,d5		Anything in next 16 pixels?
	beq.s	.4		Nope!
	swap	d3
	swap	d4
	tst.w	d6		Any offset?
	beq.s	.no_off2
	move.w	#$41e8,(a1)+	'lea oo(a0),a0
	move.w	d6,(a1)+
	moveq	#0,d6
.no_off2	move.w	#$263c,(a1)+	'move.l #xxxx,d3
	move.w	d5,(a1)+		xx
	move.w	d5,(a1)+		xx
	move.l	#$c798c790,(a1)+	'and.l d3,(a0)+ ; and.l d3,(a0)
	move.w	#$98,(a1)+	'or.l  #yyyy,(a0)+
	move.w	d3,(a1)+		yy
	move.w	d4,(a1)+		yy
	subq.w	#8,d6
.4	add.w	#152,d6
	dbf	d2,.2		Next line
	move.w	#$4e75,(a1)+	'rts
	addq.w	#1,d1		Next shift
	cmp.w	#16,d1
	blt	.1
	rts

mk_tab
	lea	div_ptr,a0
	lea	div_tab,a1
	move.w	#min_z,d0		z value
.1	move.l	#-$180,d1		x,y value
.2	move.l	d1,d2
	asl.l	#8,d2
	divs	d0,d2
	muls	#6,d2		Multiply by 6 for lookup tables
	move.w	d2,(a1)+
	addq.l	#2,d1		x,y increase in steps of 2
	bne.s	.3
	move.l	a1,(a0)+
.3	cmp.w	#$180,d1
	ble.s	.2
	addq.w	#4,d0		z increase in steps of 4
	cmp.w	#max_z,d0
	ble.s	.1
	rts

init_hash
	lea	hash_tab,a0
	move.w	#(max_z-min_z)/4-1,d0
	moveq	#0,d1
.clr	move.l	d1,(a0)+
	dbf	d0,.clr
	rts

******************************************************************************


vec_balls
	bsr	kill_old		Delete old object
	tst.w	obj_no
	bmi.s	.rts
	bsr	object		Controlling routine for object
	bsr	calc_xyz		Calculate x,y,z vectors
	move.l	calc_pts,a0	Build shape from these
	jsr	(a0)
	bsr	sort_pts		Sort them in reverse z order
	bsr	draw_balls	Plot them on screen
.rts	rts


object
; Set up speeds and object and change them
	move.w	obj_no,d0
	jmp	obj_root(pc,d0.w)
obj_root
	bra	cube
	bra	tree
	bra	bbc
	bra	cube2a
	bra	cube2b

calc_xyz
	;Generate 3D rotation matrix
	;Entry-(angle)+(ang_sp):x-axis angle
	;      2(angle)+2(ang_sp):y-axis angle
	;      4(angle)+4(ang_sp):z-axis angle
	;Exit - table stored in (matrix)
	;	All angles updated
	;	All registers buggered up

	;Time optimised version

	; Coded by Simon

	move.w	#$3fe,d6
	lea	x_vel(pc),a0
	lea	x_vecx(pc),a6
	lea	sin_tab(pc),a2
	lea	sin_tab+256(pc),a3
	move.w	(a0)+,d7		;Alpha
	add.w	(a0),d7
	move.w	d7,(a0)+
	and.w	d6,d7
	move.w	(a2,d7.w),d2	;Sin(A)
	move.w	(a3,d7.w),d3	;Cos(A)	
	move.w	(a0)+,d7		;Beta
	add.w	(a0),d7
	move.w	d7,(a0)+
	and.w	d6,d7
	move.w	(a2,d7.w),d0	;Sin(B)
	move.w	(a3,d7.w),d1	;Cos(B)
	move.w	(a0)+,d7		;Gamma
	add.w	(a0),d7
	move.w	d7,(a0)
	and.w	d6,d7
	move.w	(a2,d7.w),a0	;sin(G)
	move.w	(a3,d7.w),a1	;cos(G)
	move.w	d3,d5		;d5 - cos(A)
	move.w	d0,12(a6)		;12 - sin(B)
	move.w	d1,d6		;d6 - cos(B)
	move.w	d1,d4
	muls	d2,d4		;d4=sin(A)*cos(B)
	asl.l	#1,d4
	swap	d4
	move.w	d4,6(a6)		;6 - sin(A)*cos(B)
	neg.w	d2		;d2=-sin(A)
	move.w	d2,d7		;d7 -sin(A)
	move.w	d2,d4
	muls	d0,d4		;d4= -sin(A)*sin(B)
	asl.l	#1,d4
	swap	d4
	muls	d3,d1		;d1 = cos(A)*cos(B)
	asl.l	#1,d1
	swap	d1
	move.w	d1,(a6)		;0 - cos(A)*cos(B)
	muls	d0,d3		;d3 = cos(A)*sin(B)
	asl.l	#1,d3
	swap	d3
	neg.w	d3
	move.w	a0,d0
	move.w	a1,d1
	muls	d7,d1
	muls	d3,d0
	add.l	d1,d0
	asl.l	#1,d0
	swap	d0
	move.w	d0,2(a6)
	move.w	a0,d0
	move.w	a1,d1
	muls	d5,d1
	muls	d4,d0
	add.l	d1,d0
	asl.l	#1,d0
	swap	d0
	move.w	d0,8(a6)
	move.w	a0,d0
	muls	d6,d0
	asl.l	#1,d0
	swap	d0
	move.w	d0,14(a6)
	move.w	a0,d0
	neg.w	d0		;d0=-sin(G)
	move.w	a1,d1
	muls	d1,d6
	asl.l	#1,d6
	swap	d6
	move.w	d6,16(a6)		;Cos(B)*Cos(G)
	move.w	d0,d6
	muls	d7,d6
	muls	d3,d1
	add.l	d1,d6		;d1=-Sin(G)*-Sin(A)
	asl.l	#1,d6
	swap	d6
	move.w	d6,4(a6)
	move.w	a1,d1
	muls	d5,d0		;d1=cos(A)*cos(G)
	muls	d4,d1
	add.l	d0,d1
	asl.l	#1,d1
	swap	d1
	move.w	d1,10(a6)

	moveq	#9,d0		Divide for my balls(!)
	rept	9
	move.w	(a6),d1
	asr.w	d0,d1
	move.w	d1,(a6)+
	endr
	rts

sort_pts
; Sort points into reverse z order
; Also convert from x,y,z coords to x',y' in the process
; Uses a hash table with chaining
; My own method, takes O(n) time :-)
	lea	ball_pts(pc),a0
	lea	hash_tab(pc),a1
	lea	div_ptr,a2
	lea	hash_ram(pc),a3
	move.w	no_balls,d0
	moveq	#$fffffffc,d2
	moveq	#$fffffffe,d3
	move.w	distance,d4
	sub.w	#min_z,d4
	and.w	d2,d4
	add.w	d4,a1
	add.w	d4,a2
	move.l	a1,a5		Max table entry
.sort	movem.w	(a0)+,d4-d7	Read x,y,z,ball
	and.w	d2,d6		Translate z into 4*d6
	move.l	0(a2,d6.w),a4	Get division table line
	and.w	d3,d4		Translate x into 2*d4
	move.w	0(a4,d4.w),d4	Divide by z
	swap	d4		
	and.w	d3,d5		Translate y into 2*d5
	move.w	0(a4,d5.w),d4	Divide by z, d4 now (x,y).l
	lea	0(a1,d6.w),a4
	cmp.l	a4,a5
	bgt.s	.not_max
	move.l	a4,a5
.not_max	move.l	(a4),d5		Remeber pos of next elm.
	move.l	a3,(a4)		Add this one to front
	move.l	d5,(a3)+		Store posn of next elm
	move.l	d4,(a3)+		Store x,y posn.
	move.w	d7,(a3)+		Store sprite no.
	subq.w	#1,d0
	bne.s	.sort
	addq.w	#4,a5
	move.l	a5,hash_max
	rts

draw_balls
; Draw all the balls on screen
	move.l	hash_max,a1
	lea	spr_ptrs,a2
	move.l	screen,a3
	move.l	save_ptr3,a4
	moveq	#0,d0		Constant

	move.l	cx_ptr,a0		Get x centre
	move.w	(a0)+,d1
	tst.w	(a0)
	bpl.s	.ok1
	move.l	cx_rpt,a0
.ok1	move.l	a0,cx_ptr

	move.l	cy_ptr,a0		Get y centre
	move.w	(a0)+,d2
	tst.w	(a0)
	bpl.s	.ok2
	move.l	cy_rpt,a0
.ok2	move.l	a0,cy_ptr

	move.w	no_balls,d7	Sprite counter
.loop	rept	(max_z-min_z)/4
	tst.l	-(a1)		Find next chain
	bne	.sprite
	endr
	illegal
.sprite	move.l	(a1),a5
	move.l	d0,(a1)
.chain	move.l	(a5)+,a6		Pointer to next in chain
	move.w	(a5)+,d3		x'
	move.w	(a5)+,d4		y'
	add.w	d1,d3		Add x centre
	add.w	d2,d4		Add y centre
	move.l	pt_tab(pc,d3.w),d3	Calc x offset
	add.w	pt_tab+4(pc,d4.w),d3	Add y offset
	lea	0(a3,d3.w),a0	a0 is ptr to screen
	move.l	a0,(a4)+		Save it
	swap	d3		d3 now shift routine offset
	add.w	(a5)+,d3		d5 sprite routine offset
	move.l	0(a2,d3.w),a5	a5 sprite routine
	jsr	(a5)
	subq.w	#1,d7		Another sprite plotted
	move.l	a6,a5
	cmp.l	d0,a5
	bne.s	.chain
	tst.w	d7
	bne	.loop
	rts

pt_tab
x	set	0
y	set	0
	rept	20
	dc.w	0,x,y
	dc.w	4,x,y+1*160
	dc.w	8,x,y+2*160
	dc.w	12,x,y+3*160
	dc.w	16,x,y+4*160
	dc.w	20,x,y+5*160
	dc.w	24,x,y+6*160
	dc.w	28,x,y+7*160
	dc.w	32,x,y+8*160
	dc.w	36,x,y+9*160
	dc.w	40,x,y+10*160
	dc.w	44,x,y+11*160
	dc.w	48,x,y+12*160
	dc.w	52,x,y+13*160
	dc.w	56,x,y+14*160
	dc.w	60,x,y+15*160
x	set	x+8
y	set	y+16*160
	endr

kill_old
	lea	_rts(pc),a2
	move.l	save_ptr1(pc),a3
	move.l	save_ptr2(pc),save_ptr1
	move.l	save_ptr3(pc),save_ptr2
	move.l	a3,save_ptr3
	moveq	#0,d0
	rept	max_balls
	move.l	(a3)+,a0
	move.l	(a3),a1
	move.l	a2,(a3)+
	jsr	(a1)
	endr
_rts	rts

x_vel	dc.w	0
x_ang	dc.w	0
y_vel	dc.w	0
y_ang	dc.w	0
z_vel	dc.w	0
z_ang	dc.w	0
distance	dc.w	0
dist_vel	dc.w	0

x_vecx	dc.w	0
x_vecy	dc.w	0
x_vecz	dc.w	0

y_vecx	dc.w	0
y_vecy	dc.w	0
y_vecz	dc.w	0

z_vecx	dc.w	0
z_vecy	dc.w	0
z_vecz	dc.w	0

cx_ptr	dc.l	0
cy_ptr	dc.l	0
cx_rpt	dc.l	0
cy_rpt	dc.l	0

hash_max	dc.l	0		Ptr to max hash table entry

obj_no	dc.w	-1		-1 for no object
no_balls	dc.w	1
new_shape	dc.w	-1		True when shape just changed
ball_pts	ds.w	max_balls*4	(x,y,z,sprite)
save_ptr1	dc.l	save_ptrs
save_ptr2	dc.l	save_ptrs+8*max_balls
save_ptr3	dc.l	save_ptrs+16*max_balls
save_ptrs	rept	3*max_balls
	dc.l	free_ram
	dc.l	_rts
	endr
calc_pts	dc.l	0		Pointer to object routine

sin_tab	incbin	sintab.dat

cx_sin0	dc.w	152*6,-1
cy_sin0	dc.w	92*6,-1
cx_sin1	incbin	horiz1.sin
	dc.w	-1
cy_sin1	incbin	vert1.sin
	dc.w	-1

*********************
*   O B J E C T S   *
*********************

; Control routines

cube
	tst.w	new_shape
	beq.s	.standard
	clr.w	new_shape
	movem.l	ball1_pal,d0-d7
	move.w	d0,col1b
	move.l	d1,col2b
	movem.l	d2-d7,$ffff8248.w
	move.l	#_cube_,calc_pts
	move.w	#16,x_vel
	move.w	#8,y_vel
	move.w	#4,z_vel
	move.l	#cx_sin1,cx_ptr
	move.l	#cx_sin1,cx_rpt
	move.l	#cy_sin1,cy_ptr
	move.l	#cy_sin1,cy_rpt
.standard	lea	sin_tab,a0
	move.w	dist_vel,d0
	add.w	#8,d0
	and.w	#$3ff,d0
	move.w	d0,dist_vel
	and.w	#$fffe,d0
	move.w	0(a0,d0.w),d0
	asr.w	#7,d0
	add.w	#$500,d0
	move.w	#$500,distance
	rts
tree
	tst.w	new_shape
	beq.s	.standard
	clr.w	new_shape
	movem.l	ball1_pal,d0-d7
	move.w	d0,col1b
	move.l	d1,col2b
	movem.l	d2-d7,$ffff8248.w
	move.l	#_tree_,calc_pts
	move.w	#14,x_vel
	move.w	#6,y_vel
	move.w	#2,z_vel
	move.l	#cx_sin1,cx_ptr
	move.l	#cx_sin1,cx_rpt
	move.l	#cy_sin1,cy_ptr
	move.l	#cy_sin1,cy_rpt
	move.w	#$480,distance
.standard	rts

bbc
	tst.w	new_shape
	beq.s	.standard
	clr.w	new_shape
	movem.l	ball1_pal,d0-d7
	move.w	d0,col1b
	move.l	d1,col2b
	movem.l	d2-d7,$ffff8248.w
	move.l	#_bbc_,calc_pts
	move.w	#11,x_vel
	move.w	#7,y_vel
	move.w	#5,z_vel
	move.l	#cx_sin0,cx_ptr
	move.l	#cx_sin0,cx_rpt
	move.l	#cy_sin0,cy_ptr
	move.l	#cy_sin0,cy_rpt
	move.w	#$480,distance
.standard	rts

cube2a
	tst.w	new_shape
	beq	.standard
	clr.w	new_shape
	movem.l	ball1_pal,d0-d7
	move.w	d0,col1b
	move.l	d1,col2b
	movem.l	d2-d7,$ffff8248.w
	move.l	#_cube2_,calc_pts
	move.w	#8,x_vel
	clr.w	y_ang
	clr.w	y_vel
	clr.w	z_ang
	clr.w	z_vel
	clr.w	dist_vel
	move.l	#cx_sin0,cx_ptr
	move.l	#cx_sin0,cx_rpt
	move.l	#cy_sin0,cy_ptr
	move.l	#cy_sin0,cy_rpt
	move.w	#$400,distance
.standard	rts

cube2b
	tst.w	new_shape
	beq.s	.standard
	clr.w	new_shape
	movem.l	ball1_pal,d0-d7
	move.w	d0,col1b
	move.l	d1,col2b
	movem.l	d2-d7,$ffff8248.w
	move.l	#_cube2_,calc_pts
	move.w	#8,x_vel
	move.w	#6,y_vel
	move.w	#4,z_vel
	move.l	#cx_sin1,cx_ptr
	move.l	#cx_sin1,cx_rpt
	move.l	#cy_sin1,cy_ptr
	move.l	#cy_sin1,cy_rpt
	move.w	#$400,distance
.standard	rts

; Building routines
; All objects hard coded for efficiency

neg_all	macro
	neg.l	d0		Negate all coords
	swap	d1
	neg.w	d1
	swap	d1
	neg.l	d2
	swap	d3
	neg.w	d3
	swap	d3
	neg.l	d4
	swap	d5
	neg.w	d5
	swap	d5
	neg.l	d6
	swap	d7
	neg.w	d7
	swap	d7
	endm

_cube_
	move.w	#56,no_balls
; Set up 56 x coordinates
	lea	ball_pts,a4
	move.w	x_vecx,d0
	move.w	d0,d2
	neg.w	d0
	add.w	d0,d0
	add.w	d0,d0
	sub.w	d2,d0
	asr.w	#1,d0
	swap	d0
	swap	d2
	move.w	x_vecy,d0
	move.w	d0,d2
	neg.w	d0
	add.w	d0,d0
	add.w	d0,d0
	sub.w	d2,d0
	asr.w	#1,d0
	moveq	#0,d1
	moveq	#0,d3
	move.w	x_vecz,d1
	move.w	d1,d3
	neg.w	d1
	add.w	d1,d1
	add.w	d1,d1
	sub.w	d3,d1
	asr.w	#1,d1
	swap	d1
	swap	d3		; Now d0,d1 = -2.5; d2,d3 = 1
	move.l	d0,a0		a0,a1=-2.5
	move.l	d1,a1
	add.l	d2,d0
	add.l	d3,d1
	move.l	d0,a2		a2,a3=-1.5
	move.l	d1,a3
	add.l	d2,d0
	add.l	d3,d1
	move.l	d0,d4		d4,d5=-0.5
	move.l	d1,d5
	add.l	d2,d0
	add.l	d3,d1
	move.l	d0,d6		d6,d7=0.5
	move.l	d1,d7
	add.l	d2,d0		d0,d1=1.5
	add.l	d3,d1
	add.l	d0,d2		d2,d3=2.5
	add.l	d1,d3		
	movem.l	d0-d7/a0-a3,(a4)		-2.5 -> 2.5
x	set	6*8
	rept	4
	movem.l	d2-d3/a0-a1,x(a4)		-2.5,2.5
x	set	x+16
	endr
	movem.l	d0-d7/a0-a3,x(a4)		-2.5 -> 2.5
x	set	x+6*8
	rept	8
	movem.l	d2-d3/a0-a1,x(a4)		-2.5,2.5
x	set	x+16
	endr
	movem.l	d0-d7/a0-a3,x(a4)		-2.5 -> 2.5
	movem.l	d0-d7/a0-a3,x+6*8(a4)	-2.5 -> 2.5
x	set	x+12*8
	rept	4
	movem.l	d2-d3/a0-a1,x(a4)		-2.5,2.5
x	set	x+16
	endr

; Set up 56 y coordinates
	lea	ball_pts,a4
	move.w	y_vecx,d0
	move.w	d0,d2
	neg.w	d0
	add.w	d0,d0
	add.w	d0,d0
	sub.w	d2,d0
	asr.w	#1,d0
	swap	d0
	swap	d2
	move.w	y_vecy,d0
	move.w	d0,d2
	neg.w	d0
	add.w	d0,d0
	add.w	d0,d0
	sub.w	d2,d0
	asr.w	#1,d0
	moveq	#0,d1
	moveq	#0,d3
	move.w	y_vecz,d1
	move.w	d1,d3
	neg.w	d1
	add.w	d1,d1
	add.w	d1,d1
	sub.w	d3,d1
	asr.w	#1,d1
	swap	d1
	swap	d3		; Now d0,d1 = -2.5; d2,d3 = 1
	move.l	d0,a0		a0,a1=-2.5
	move.l	d1,a1
	add.l	d2,d0
	add.l	d3,d1
	move.l	d0,a2		a2,a3=-1.5
	move.l	d1,a3
	add.l	d2,d0
	add.l	d3,d1
	move.l	d0,d4		d4,d5=-0.5
	move.l	d1,d5
	add.l	d2,d0
	add.l	d3,d1
	move.l	d0,d6		d6,d7=0.5
	move.l	d1,d7
	add.l	d2,d0		d0,d1=1.5
	add.l	d3,d1
	add.l	d0,d2		d2,d3=2.5
	add.l	d1,d3		
	exg	a0,d0
	exg	a1,d1
	rept	6
	add.l	d0,(a4)+		Add on -2.5 * 6
	add.l	d1,(a4)+	
	endr
	exg	d0,a2
	exg	d1,a3
	add.l	d0,(a4)+		Add on -1.5 * 2
	add.l	d1,(a4)+	
	add.l	d0,(a4)+	
	add.l	d1,(a4)+	
	add.l	d4,(a4)+		Add on -0.5 * 2
	add.l	d5,(a4)+	
	add.l	d4,(a4)+	
	add.l	d5,(a4)+	
	add.l	d6,(a4)+		Add on 0.5 * 2
	add.l	d7,(a4)+	
	add.l	d6,(a4)+	
	add.l	d7,(a4)+	
	exg	d0,a0
	exg	d1,a1
	add.l	d0,(a4)+		Add on 1.5 * 2
	add.l	d1,(a4)+	
	add.l	d0,(a4)+	
	add.l	d1,(a4)+	
	rept	6
	add.l	d2,(a4)+		Add on 2.5 * 6
	add.l	d3,(a4)+
	endr
	exg	d0,a2
	exg	d1,a3
	rept	4
	add.l	d0,(a4)+		Add on -2.5 * 2 * 4
	add.l	d1,(a4)+
	add.l	d0,(a4)+
	add.l	d1,(a4)+
	add.l	d2,(a4)+		Add on 2.5 * 2 * 4
	add.l	d3,(a4)+
	add.l	d2,(a4)+
	add.l	d3,(a4)+
	endr
	rept	6
	add.l	d0,(a4)+		Add on -2.5 * 6
	add.l	d1,(a4)+
	endr
	rept	6
	add.l	d2,(a4)+		Add on 2.5 * 6
	add.l	d3,(a4)+
	endr
	move.l	a0,d0
	move.l	a1,d1
	add.l	d0,(a4)+		Add on -1.5 * 2
	add.l	d1,(a4)+
	add.l	d0,(a4)+
	add.l	d1,(a4)+
	add.l	d4,(a4)+		Add on -0.5 * 2
	add.l	d5,(a4)+
	add.l	d4,(a4)+
	add.l	d5,(a4)+
	add.l	d6,(a4)+		Add on 0.5 * 2
	add.l	d7,(a4)+
	add.l	d6,(a4)+
	add.l	d7,(a4)+
	move.l	a2,d0
	move.l	a3,d1
	add.l	d0,(a4)+		Add on 1.5 * 2
	add.l	d1,(a4)+
	add.l	d0,(a4)+
	add.l	d1,(a4)+

; Set up 56 z coordinates
	lea	ball_pts,a0
	move.w	z_vecx,d0
	move.w	d0,d2
	neg.w	d0
	add.w	d0,d0
	add.w	d0,d0
	sub.w	d2,d0
	asr.w	#1,d0
	swap	d0
	swap	d2
	move.w	z_vecy,d0
	move.w	d0,d2
	neg.w	d0
	add.w	d0,d0
	add.w	d0,d0
	sub.w	d2,d0
	asr.w	#1,d0
	moveq	#0,d1
	moveq	#0,d3
	move.w	z_vecz,d1
	move.w	d1,d3
	neg.w	d1
	add.w	d1,d1
	add.w	d1,d1
	sub.w	d3,d1
	asr.w	#1,d1
	swap	d1
	swap	d3		; Now d0,d1 = -2.5; d2,d3 = 1
	rept	20		Do one side
	add.l	d0,(a0)+
	add.l	d1,(a0)+
	endr
	rept	4		Do middle bits
	add.l	d2,d0
	add.l	d3,d1
	add.l	d0,(a0)+
	add.l	d1,(a0)+
	add.l	d0,(a0)+
	add.l	d1,(a0)+
	add.l	d0,(a0)+
	add.l	d1,(a0)+
	add.l	d0,(a0)+
	add.l	d1,(a0)+
	endr
	add.l	d2,d0
	add.l	d3,d1
	rept	20		Do other side
	add.l	d0,(a0)+
	add.l	d1,(a0)+
	endr
	rts

_cube2_
	move.w	#98,no_balls
; Set up 99 x coordinates
	lea	ball_pts,a0
	moveq	#0,d0
	move.l	#128,d1		Ball 1
	rept	16
	move.l	d0,(a0)+		16 * (x=0), Ball 1
	move.l	d1,(a0)+
	endr
	move.w	x_vecx,d0
	move.w	x_vecy,d1
	move.w	x_vecz,d2
	move.w	d0,d3	
	move.w	d1,d4	
	move.w	d2,d5
	add.w	d3,d3	
 	add.w	d4,d4	
	add.w	d5,d5

	move.w	d3,d6		d6.l,d7.l (z=2), Ball 2
	swap	d6
	move.w	d4,d6
	move.w	d5,d7	
	swap	d7
	move.w	#128,d7

	neg.w	d3
	neg.w	d4
	neg.w	d5
	swap	d5
	move.w	#128,d5
	swap	d4
	move.w	d3,d4
	swap	d4		d4.l,d5.w (z=-2), Ball 2

	move.w	d2,d3
	swap	d3
	move.w	#128,d3
	move.w	d0,d2
	swap	d2
	move.w	d1,d2		d2.l,d3.w (z=1), Ball 2

	neg.w	d0
	neg.w	d1
	swap	d0
	move.w	d1,d0
	move.w	x_vecz,d1
	neg.w	d1
	swap	d1
	move.w	#128,d1		d0.l,d1.w (z=-1), Ball 2

	rept	16
	move.l	d2,(a0)+		16 * (x=1)
	move.l	d3,(a0)+
	endr
	rept	16
	move.l	d0,(a0)+		16 * (x=-1)
	move.l	d1,(a0)+
	endr
	rept	25
	move.l	d4,(a0)+		25 * (x=-2)
	move.l	d5,(a0)+
	endr
	rept	25
	move.l	d6,(a0)+		25 * (x=2)
	move.l	d7,(a0)+
	endr

	clr.l	(a0)+		Central ball
	clr.l	(a0)+

; Set up 98 y coordinates
	lea	ball_pts,a0
	move.w	y_vecx,d0	
	move.w	y_vecy,d1	
	move.w	y_vecz,d2
	move.w	d0,d3	
	move.w	d1,d4	
	move.w	d2,d5
	add.w	d3,d3	
	add.w	d4,d4	
	add.w	d5,d5
	move.w	d3,d6
	swap	d6
	move.w	d4,d6
	move.w	d5,d7
	swap	d7
	clr.w	d7		d6.l,d7.l (z=2), Same ball
	neg.w	d3
	neg.w	d4
	neg.w	d5
	swap	d5
	clr.w	d5
	swap	d4
	move.w	d3,d4
	swap	d4		d4.l,d5.l (z=-2), Same ball
	move.w	d2,d3
	swap	d3
	clr.w	d3
	move.w	d0,d2
	swap	d2
	move.w	d1,d2		d2.l,d3.l (z=1), Same ball
	neg.w	d0
	neg.w	d1
	swap	d0
	move.w	d1,d0
	move.w	y_vecz,d1
	neg.w	d1
	swap	d1
	clr.w	d1		d0.l,d1.l (z=-1), Same ball

	rept	3		Set up 3 * 16 (48) balls
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	add.l	d0,(a0)+		-1
	add.l	d1,(a0)+
	add.l	d0,(a0)+		-1
	add.l	d1,(a0)+
	lea	16(a0),a0		0,0
	add.l	d2,(a0)+		1
	add.l	d3,(a0)+
	add.l	d2,(a0)+		1
	add.l	d3,(a0)+
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	endr

	rept	5		Set up 25 balls
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	endr
	rept	5
	add.l	d0,(a0)+		-1
	add.l	d1,(a0)+
	endr
	lea	40(a0),a0		5 * 0
	rept	5
	add.l	d2,(a0)+		1
	add.l	d3,(a0)+
	endr
	rept	5
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	endr

	rept	5		Set up 25 balls
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	endr
	rept	5
	add.l	d0,(a0)+		-1
	add.l	d1,(a0)+
	endr
	lea	40(a0),a0		5 * 0
	rept	5
	add.l	d2,(a0)+		1
	add.l	d3,(a0)+
	endr
	rept	5
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	endr

; Set up 98 z coordinates
	lea	ball_pts,a0
	move.w	z_vecx,d0	
	move.w	z_vecy,d1	
	move.w	z_vecz,d2
	move.w	d0,d3	
	move.w	d1,d4	
	move.w	d2,d5
	add.w	d3,d3	
	add.w	d4,d4	
	add.w	d5,d5
	move.w	d3,d6
	swap	d6
	move.w	d4,d6
	move.w	d5,d7
	swap	d7
	clr.w	d7		d6.l,d7.l (z=2), Same ball
	neg.w	d3
	neg.w	d4
	neg.w	d5
	swap	d5
	clr.w	d5
	swap	d4
	move.w	d3,d4
	swap	d4		d4.l,d5.l (z=-2), Same ball
	move.w	d2,d3
	swap	d3
	clr.w	d3
	move.w	d0,d2
	swap	d2
	move.w	d1,d2		d2.l,d3.l (z=1), Same ball
	neg.w	d0
	neg.w	d1
	swap	d0
	move.w	d1,d0
	move.w	z_vecz,d1
	neg.w	d1
	swap	d1
	clr.w	d1		d0.l,d1.l (z=-1), Same ball

	rept	3		Set up 3 * 16 (48) balls
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	add.l	d0,(a0)+		-1
	add.l	d1,(a0)+
	addq.w	#8,a0		0
	add.l	d2,(a0)+		1
	add.l	d3,(a0)+
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+

	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+

	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	add.l	d0,(a0)+		-1
	add.l	d1,(a0)+
	addq.w	#8,a0		0
	add.l	d2,(a0)+		1
	add.l	d3,(a0)+
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	endr

	rept	10		Set up 10 * 5 (50) balls
	add.l	d4,(a0)+		-2
	add.l	d5,(a0)+
	add.l	d0,(a0)+		-1
	add.l	d1,(a0)+
	addq.w	#8,a0		0
	add.l	d2,(a0)+		1
	add.l	d3,(a0)+
	add.l	d6,(a0)+		2
	add.l	d7,(a0)+
	endr

; Put big balls at corners
	lea	ball_pts+6,a0
	moveq	#64,d0
	move.w	d0,48*8(a0)
	move.w	d0,52*8(a0)
	move.w	d0,68*8(a0)
	move.w	d0,72*8(a0)
	move.w	d0,73*8(a0)
	move.w	d0,77*8(a0)
	move.w	d0,93*8(a0)
	move.w	d0,97*8(a0)
	rts	

_bbc_
	move.w	#54,no_balls
; Set up 27 x coordinates
	lea	ball_pts,a0
	moveq	#0,d0
	moveq	#0,d1
	rept	5
	move.l	d0,(a0)+		5 * (x=0), Ball 0
	move.l	d1,(a0)+
	endr
	move.w	x_vecx,d0
	move.w	x_vecy,d1
	move.w	x_vecz,d2
	move.w	d0,d3	
	move.w	d1,d4	
	move.w	d2,d5
	add.w	d3,d3	
 	add.w	d4,d4	
	add.w	d5,d5

	move.w	d3,d6		d6.l,d7.l (z=2), Ball 0
	swap	d6
	move.w	d4,d6
	move.w	d5,d7	
	swap	d7
	clr.w	d7

	neg.w	d3
	neg.w	d4
	neg.w	d5
	swap	d5
	clr.w	d5
	swap	d4
	move.w	d3,d4
	swap	d4		d4.l,d5.w (z=-2), Ball 0

	move.w	d2,d3
	swap	d3
	clr.w	d3
	move.w	d0,d2
	swap	d2
	move.w	d1,d2		d2.l,d3.w (z=1), Ball 0

	neg.w	d0
	neg.w	d1
	swap	d0
	move.w	d1,d0
	move.w	x_vecz,d1
	neg.w	d1
	swap	d1
	clr.w	d1		d0.l,d1.w (z=-1), Ball 0

	movem.l	d0-d7,(a0)	4 balls, -2,-1,1,2 For B
	movem.l	d0-d7,32(a0)	4 balls, -2,-1,1,2
	movem.l	d0-d7,64(a0)	4 balls, -2,-1,1,2 For B
	movem.l	d0-d7,96(a0)	4 balls, -2,-1,1,2
	movem.l	d0-d7,128(a0)	4 balls, -2,-1,1,2 For C
	movem.l	d4-d7,160(a0)	2 balls, -2,2

; Set up 27 y coordinates
	lea	ball_pts,a0
	move.w	y_vecx,d0	
	move.w	y_vecy,d1	
	move.w	y_vecz,d2
	neg.w	d0
	neg.w	d1
	neg.w	d2
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5			
	asl.w	#1,d0
	asl.w	#1,d1
	asl.w	#1,d2
	move.w	d3,d6		d6,d7 as y=-0.5
	swap	d6
	move.w	d4,d6
	move.w	d5,d7
	swap	d7
	clr.w	d7		Ball 0
	move.l	d7,-(a7)
	move.l	d6,-(a7)

	add.w	d0,d3
	add.w	d1,d4
	add.w	d2,d5
	move.w	d3,d6		d4,d5 as y=-1.5
	swap	d6
	move.w	d4,d6
	move.w	d5,d7
	swap	d7
	clr.w	d7		Ball 0
	move.l	d7,-(a7)
	move.l	d6,-(a7)

	add.w	d0,d3
	add.w	d1,d4
	add.w	d2,d5
	move.w	d3,d6		d2,d3 as y=-2.5
	swap	d6
	move.w	d4,d6
	move.w	d5,d7
	swap	d7
	clr.w	d7		Ball 0
	move.l	d7,-(a7)
	move.l	d6,-(a7)

	add.w	d0,d0
	add.w	d1,d1
	add.w	d2,d2
	swap	d0		d0,d1 as y=-2
	move.w	d1,d0
	move.w	d2,d1
	swap	d1
	clr.w	d1		Ball 0
		
	movem.l	(a7)+,d2-d7

	add.l	d2,(a0)+		1 * -2.5	
	add.l	d3,(a0)+	
	add.l	d0,(a0)+		1 * -2
	add.l	d1,(a0)+	
	add.l	d6,(a0)+		1 * -.5
	add.l	d7,(a0)+
	addq.w	#8,a0		1 * Skip
	move.l	a0,a1		Save for later
	addq.w	#8,a0		1 * Skip
	rept	4
	add.l	d2,(a0)+		4 * -2.5	
	add.l	d3,(a0)+
	endr
	rept	2	
	add.l	d4,(a0)+		2 * 1.5
	add.l	d5,(a0)+
	endr
	rept	2
	add.l	d0,(a0)+		2 * -2
	add.l	d1,(a0)+	
	endr
	rept	4
	add.l	d6,(a0)+		4 * -.5
	add.l	d7,(a0)+
	endr

	neg_all

	add.l	d4,(a1)+		1 * 1.5 (Fill gap)
	add.l	d5,(a1)+
	rept	2
	add.l	d6,(a0)+		2 * 0.5
	add.l	d7,(a0)+
	endr
	lea	16(a0),a0		2 * Skip
	rept	2
	add.l	d4,(a0)+		2 * 1.5 
	add.l	d5,(a0)+
	endr
	rept	2
	add.l	d0,(a0)+		2 * 2.0
	add.l	d1,(a0)+
	endr
	rept	2
	add.l	d2,(a0)+		2 * 2.5
	add.l	d3,(a0)+
	endr

; Add z vector to 27 of them
	lea	ball_pts,a0
	lea	ball_pts+54*8,a1
	move.w	z_vecx,d0
	swap	d0
	move.w	z_vecy,d0
	move.w	z_vecz,d1
	swap	d1
	clr.w	d1		d0,d1 (z=1)
	rept	9
	movem.l	(a0)+,d2-d7
	add.l	d0,d2
	add.l	d1,d3
	add.l	d0,d4
	add.l	d1,d5
	add.l	d0,d6
	add.l	d1,d7
	movem.l	d2-d7,-(a1)
	endr
	rts

_tree_
	move.w	#40,no_balls
; Set up 16 x coordinates
	lea	ball_pts,a0
	move.w	x_vecx,d0	
	move.w	x_vecy,d1	
	move.w	x_vecz,d2
	neg.w	d0
	neg.w	d1
	neg.w	d2
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5			
	asr.w	#1,d3
	asr.w	#1,d4
	asr.w	#1,d5
	move.w	d3,d6		d6,d7 as x=-0.5
	swap	d6
	move.w	d4,d6
	move.w	d5,d7
	swap	d7
	clr.w	d7		Ball 0
	add.w	d0,d3		d4,d5 as x=-1.5
	add.w	d1,d4
	add.w	d2,d5
	swap	d4
	move.w	d3,d4
	swap	d4
	swap	d5
	clr.w	d5		Ball0
	swap	d0		d0,d1 as x=1
	move.w	d1,d0
	move.w	d2,d1
	swap	d1
	clr.w	d1
	move.l	d0,d2		d3,d3 as x=2
	add.l	d2,d2
	move.l	d1,d3
	add.l	d3,d3

	movem.l	d0-d7,(a0)	4 x coords
	lea	32(a0),a0
	rept	4		4 x coords
	move.l	d6,(a0)+
	move.l	d7,(a0)+
	endr

	neg_all

	movem.l	d0-d7,(a0)	4 x coords
	lea	32(a0),a0
	rept	4		4 x coords
	move.l	d6,(a0)+
	move.l	d7,(a0)+
	endr

; Set up next 16 z coords	
	move.w	z_vecx,d0	
	move.w	z_vecy,d1	
	move.w	z_vecz,d2
	neg.w	d0
	neg.w	d1
	neg.w	d2
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5			
	asr.w	#1,d3
	asr.w	#1,d4
	asr.w	#1,d5
	move.w	d3,d6		d6,d7 as x=-0.5
	swap	d6
	move.w	d4,d6
	move.w	d5,d7
	swap	d7
	clr.w	d7		Ball 0
	add.w	d0,d3		d4,d5 as x=-1.5
	add.w	d1,d4
	add.w	d2,d5
	swap	d4
	move.w	d3,d4
	swap	d4
	swap	d5
	clr.w	d5		Ball0
	swap	d0		d0,d1 as x=1
	move.w	d1,d0
	move.w	d2,d1
	swap	d1
	clr.w	d1
	move.l	d0,d2		d3,d3 as x=2
	add.l	d2,d2
	move.l	d1,d3
	add.l	d3,d3

	movem.l	d0-d7,(a0)	4 x coords
	lea	32(a0),a0
	rept	4		4 x coords
	move.l	d6,(a0)+
	move.l	d7,(a0)+
	endr

	neg_all

	movem.l	d0-d7,(a0)	4 x coords
	lea	32(a0),a0
	rept	4		4 x coords
	move.l	d6,(a0)+
	move.l	d7,(a0)+
	endr

; Add on 36 y coords
	lea	ball_pts,a0
	move.w	y_vecx,d0	
	move.w	y_vecy,d1	
	move.w	y_vecz,d2
	neg.w	d0
	neg.w	d1
	neg.w	d2
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5			
	asl.w	#1,d0
	asl.w	#1,d1
	asl.w	#1,d2
	move.w	d3,d6		d6,d7 as x=-0.5
	swap	d6
	move.w	d4,d6
	move.w	d5,d7
	swap	d7
	clr.w	d7		Ball 0
	add.w	d0,d3		d4,d5 as x=-1.5
	add.w	d1,d4
	add.w	d2,d5
	swap	d4
	move.w	d3,d4
	swap	d4
	swap	d5
	clr.w	d5		Ball0
	swap	d0		d0,d1 as x=1
	move.w	d1,d0
	move.w	d2,d1
	move.l	d0,d2		d3,d3 as x=2
;	add.l	d2,d2
	add.w	d2,d2
	swap	d2
	add.w	d2,d2
	swap	d2
	move.l	d1,d3
	add.w	d3,d3
	swap	d1
	swap	d3
	clr.w	d1
	clr.w	d3

	rept	4		Repeat four each branch (4)
	add.l	d6,(a0)+		1 * 0.5
	add.l	d7,(a0)+
	add.l	d4,(a0)+		1 * 1.5
	add.l	d5,(a0)+
	add.l	d0,(a0)+		1 * 1.0
	add.l	d1,(a0)+
	addq.w	#8,a0
	move.l	a0,-(a7)		Save for 4-7
	lea	32(a0),a0
	endr	
	movem.l	d0-d7,(a0)	4 * 0.5 - 2.0

	neg_all

	movem.l	d0-d7,32(a0)	4 * 0.5 - 2.0

	rept	4		Repeat four each branch (4)
	move.l	(a7)+,a0		Make trunk 4 * 0.5 -20
	add.l	d0,(a0)+		
	add.l	d1,(a0)+
	add.l	d2,(a0)+
	add.l	d3,(a0)+
	add.l	d4,(a0)+
	add.l	d5,(a0)+
	add.l	d6,(a0)+
	add.l	d7,(a0)+
	endr
	rts

ball1_pal	dc.w	$000,$415,$526,$636
	dc.w	$300,$415,$526,$636
	dc.w	$500,$415,$526,$636
	dc.w	$700,$415,$526,$636

ball1_gfx
	dc.w	$0000,$0000,$0140,$02a0,$0a88,$07f0,$1564,$0ff8
	dc.w	$28b2,$17fc,$3558,$0afe,$7aac,$057f,$7f55,$00be
	dc.w	$7faa,$005f,$7fd5,$002e,$7fe2,$001f,$3fd4,$002e
	dc.w	$3FEA,$0014,$1FF4,$0008,$0FF8,$0000,$03E0,$0000

ball2_pal	dc.w	$000,$003,$007,$005
	dc.w	$300,$300,$300,$300
	dc.w	$500,$500,$500,$500
	dc.w	$700,$700,$700,$700

ball2_gfx ; 16*16 2 plane sprite (my chuffy one!)
	dc.w	%0000000110000000,%0000000000000000
	dc.w	%0000001111000000,%0000000000000000
	dc.w	%0000011111100000,%0000000110000000
	dc.w	%0000111111110000,%0000001111000000
	dc.w	%0001111111111000,%0000011111100000
	dc.w	%0011111111111100,%0000111111110000
	dc.w	%0111111111111110,%0001111111111000
	dc.w	%1111111001111111,%0011111111111100
	dc.w	%1111111001111111,%0011111111111100
	dc.w	%0111111111111110,%0001111111111000
	dc.w	%0011111111111100,%0000111111110000
	dc.w	%0001111111111000,%0000011111100000
	dc.w	%0000111111110000,%0000001111000000
	dc.w	%0000011111100000,%0000000110000000
	dc.w	%0000001111000000,%0000000000000000
	dc.w	%0000000110000000,%0000000000000000

ball3_gfx ; 8*8 2 plane sprite
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	$140,$80,$220,$1c0,$750,$e0,$780,$70,$7d0
	dc.w	$20,$3e0,$0,$1c0,0
	dc.w	0,0,0,0,0,0,0,0

ball4_gfx ; 8*8 2 plane sprite (another of my chuffy ones!)
	ds.w	2*4
	dc.w	%0000000110000000,%0000000000000000
	dc.w	%0000001111000000,%0000000110000000
	dc.w	%0000011111100000,%0000001111000000
	dc.w	%0000111111110000,%0000011001100000
	dc.w	%0000111111110000,%0000011001100000
	dc.w	%0000011111100000,%0000001111000000
	dc.w	%0000001111000000,%0000000110000000
	dc.w	%0000000110000000,%0000000000000000
	ds.w	2*4

music	incbin	tristar.max

	section	bss
hash_tab	ds.l	(max_z-min_z)/4
hash_ram	ds.w	max_balls*10	10 bytes/entry
spr_ptrs	ds.l	4*16		Pointer to sprite routines
spr_roots	ds.b	$6000		Space for sprite routines
div_ptr	ds.l	max_z-min_z+1
div_tab	ds.w	$81*(max_z-min_z+1)
	ds.b	$100		Space for stack
free_ram	ds.b	$7d00*2+254	Space for screens
