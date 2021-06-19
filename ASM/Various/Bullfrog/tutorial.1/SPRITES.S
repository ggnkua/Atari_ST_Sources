*****************************************************************************
*                   SET YOUR TAB SIZE TO 4 !!!!!!!!!!!!                     *
*          OTHERWISE IT WILL LOOK LIKE A TOTAL MESS !!!!!!!!!!!             *
*****************************************************************************
REZ			equ	$ff8260
H_PAL  		equ $fffff8240
VBI			equ	$70
KB_DATA		equ $fffffc02
KB_SPACE	equ $39
*****************************************************************************
PRINTLINE	equ	$9
FOPEN		equ $3d
FCLOSE		equ	$3e
FREAD		equ	$3f
*****************************************************************************
*            This is about the cleanest startup I can think of              *
*****************************************************************************
start
	clr.l	-(sp)						OS startup stuff
	move.w	#$20,-(sp)
	trap	#1   						stick it in supervisor mode
	addq.l	#6,sp
	move.l	d0,old_ssp
    move.w	#3,-(sp)					logbase to find the screen
	trap	#14
	addq.l	#2,sp
	move.l	d0,_d_screen				currently displayed screen
	move.l	d0,old_screen
    move.l	#w_screen,d0
	addi.l	#256,d0						ensure it's on a 256 byte boundry
	andi.l	#$ffffff00,d0
	move.l	d0,_w_screen				and you have another screen
	move.l  VBI,old_vbi					back up the old vbi
	move.l	#_vbi,VBI					patch in the new one
	bsr		_main						yer actual startup
	move.l  old_vbi,VBI
    move.l	old_ssp,sp					clean exit

	move.w	#-1,-(sp)					res
	move.l	old_screen,-(sp)			reset the screen pos
	move.l	old_screen,-(sp)
	move.w	#5,-(sp)
	trap    #14
	lea		12(sp),sp
	clr.w	-(sp)
	trap	#1
*****************************************************************************
_main
	lea		spr32_fname,a0				the sprite file name
    lea		_spr_32,a1					the address to load the file to
	move.l	#256*10*32,d0				the size of the file
	jsr     _load_file					read 32*32 sprites
	blt.s	error_end
		bsr		_display				the main game loop
error_end
	rts
*****************************************************************************
_display
	move.b  REZ,old_rez					store the old resolution
	move.b	#0,REZ						whack it into lo rez
	movem.l	palette,d0-d7
	movem.l	d0-d7,H_PAL                 how to set the palette in 2 instructions

disploop
		bsr		_wait_vbi				wait for the vbi
		move.l	_w_screen,a0
		bsr		_clear_screen			clear the screen

* draw the sprites

		move.w	#32,d0					the sprites coordinates
		move.w	#32,d1
		move.w	#0,d2					the image number to draw
		jsr		_spr3232				draw a 32x32 sprite

* flip screens

		bsr		_swap_screens

* now do any non graphic work like moving the sprites
* in here goes any routines to adjust the coordinates of the sprites



* look to see if the space bar is pressed if so quit

		cmp.b	#KB_SPACE,KB_DATA
		bne		disploop
	move.b	old_rez,REZ					stick it back in original mode
	rts
*****************************************************************************
; a0-> screen to clear, this is the quickest way I can think of to clear screen
_clear_screen
	lea		32000(a0),a0    move to end of screen
	moveq	#0,d1			clear 13 registers
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
;	we can clear 13*4 (52) bytes in one go
;	615 * 52 is 31980, 20 bytes short of the screen size
	move.w	#615-1,d0		loop counter, -1 coz of the way dbra works
cs_loop
		movem.l	d1-d7/a1-a6,-(a0)
		dbra	d0,cs_loop
	movem.l d1-d5,-(a0)		do the odd 20 bytes (5 regs)
	rts
*****************************************************************************
_wait_vbi
	tst.b	_vbi_done
	beq.s   _wait_vbi
	rts
*****************************************************************************
_vbi
    st		_vbi_done
	rte
*****************************************************************************
_swap_screens
	move.l	_w_screen,d0			d0 = screen address
	move.l	_d_screen,d1
	move.l	d1,_w_screen
	move.l	d0,_d_screen			d0 = xxxx high low	0000

	lsr.w	#8,d0
	move.l	d0,$ffff8200.w			d0 = xxxx high xxxx low

	sf		_vbi_done
	rts
*****************************************************************************
; d0 = x, d1 = y, d2 = sprite number
_spr3232
	move.l	_w_screen,a0		draw on _w_screen
	lea		_spr_32,a1
	mulu	#640,d2				size of a 32*32 sprite
	add.w	d2,a1
	moveq	#32,d2
	bsr		_s32_draw
	rts
*****************************************************************************
*	16 pixel wide sprite draw												*
*	d0.w = QX																*
*	d1.w = QY																*
*	d2.w = sprite height													*
*   a0 -> screen                         							        *
*	a1	-> the sprite data													*
*****************************************************************************
LINES_HIGH	set	200
_s16_draw
	tst.w	d1					is y less than 0
	bge.s	y_not_minus_16		no, ok.
*****************************************************************************
*	QY is negative
	neg.w	d1
	sub.w	d1,d2				do we see any of it ?
	ble		not_drawn_16		no, dont draw it at all
; a 16 pixel wide sprite has 10 bytes a line, so we have to multiply by 10
	add.w	d1,d1				*2
	move.w	d1,d7
	add.w	d1,d1				*4
	add.w	d1,d1				*8
	add.w	d7,d1				In2Data and QY are the same reg
	adda.w	d1,a1				move into the source the required no. of line
	bra.s	y_clipped_16
*********
y_not_minus_16
	moveq	#256-LINES_HIGH,d6
	neg.b	d6					quicker than move.w #LINES_HIGH,d6
	cmp.w	d6,d1
	bge 	not_drawn_16
	move.w	d1,d7
	add.w	d7,d7				*2
	add.w	d7,d7				*4
	add.w	d1,d7				*5
	lsl.w	#5,d7				*5*32 (28 clock cycles, less than 70 for *160
	adda.w	d7,a0				move down the screen
	add.w	d2,d1
	subi.w	#LINES_HIGH,d1
	blt.s	y_clipped_16
	sub.w	d1,d2				adjust height of sprite to fit it on
y_clipped_16
*****************************************************************************
*	I suppose I better do the QX stuff now
	tst.w	d0
	bge.s	x_not_minus_16		x ok, well at least it isn't negative!
	cmpi.w	#-16,d0
	ble.s	not_drawn_16		it is off screen
	moveq	#0,d1
	bra		_left_16
x_not_minus_16
	move.w	d0,d7
	andi.w	#$f,d0				QX and QShift are the same Reg

* we want . . . 0-15 ->0, 16-31->8 etc.........

	andi.w	#$fff0,d7
	lsr.w	#1,d7
	moveq	#256-160,d6
	neg.b	d6
	cmp.w	d6,d7				is it off the right side of the screen ?
	bge.s	not_drawn_16		yes
	adda.w	d7,a0				adjust destination
	subq.w	#8,d6
	cmp.w	d6,d7
	bne		_all_16

*	right hand only case

	moveq	#0,d1
	bra		_right_16
not_drawn_16
	rts

*****************************************************************************
*	32 pixel wide sprite draw												*
*	d0.w = QX																*
*	d1.w = QY																*
*	d2.w = sprite height													*
*   a0 -> screen                         							        *
*	a1	-> the sprite data													*
*****************************************************************************
_s32_draw
	tst.w	d1					is y less than 0
	bge.s	y_not_minus_32		no, ok.
*****************************************************************************
*	QY is negative
	neg.w	d1
	sub.w	d1,d2				do we see any of it ?
	ble		not_drawn_32		no, dont draw it at all
; a 32 pixel wide sprite has 20 bytes a line, so we have to multiply by 20
	move.w	d1,d7
	add.w	d1,d1				*2
	add.w	d1,d1				*4
	add.w	d7,d1				*5
	add.w	d1,d1				*10
	add.w	d1,d1				*20
	adda.w	d1,a1				move into the source the required no. of line
	bra.s	y_clipped_32
*********
y_not_minus_32
	moveq	#256-LINES_HIGH,d6
	neg.b	d6					quicker than move.w #LINES_HIGH,d6
	cmp.w	d6,d1
	bge 	not_drawn_32
	move.w	d1,d7
	add.w	d7,d7				*2
	add.w	d7,d7				*4
	add.w	d1,d7				*5
	lsl.w	#5,d7				*5*32 (28 clock cycles, less than 70 for *160
	adda.w	d7,a0				move down the screen
	add.w	d2,d1
	subi.w	#LINES_HIGH,d1
	blt.s	y_clipped_32
	sub.w	d1,d2				adjust height of sprite to fit it on
y_clipped_32
*****************************************************************************
*	I suppose I better do the QX stuff now
	tst.w	d0
	bge.s	x_not_minus_32		x ok, well at least it isn't negative!
	cmpi.w	#-16,d0
	ble.s	may_be_32
	moveq	#0,d1
	bra		_left_32
may_be_32
	cmpi.w	#-32,d0
	ble.s	not_drawn_32
	moveq	#10,d1
	bra		_left_16
x_not_minus_32
	move.w	d0,d7
	andi.w	#$f,d0				QX and QShift are the same Reg

* we want . . . 0-15 ->0, 16-31->8 etc.........

	andi.w	#$fff0,d7
	lsr.w	#1,d7
	moveq	#256-(160-16),d6
	neg.b	d6
	adda.w	d7,a0				adjust destination
	cmp.w	d6,d7				is it definately on screen ?
	bmi		_all_32				yes
	addq.w	#8,d6
	moveq	#0,d1
	cmp.w	d6,d7
	bmi		_right_32
	addq.w	#8,d6
	moveq	#10,d1
	cmp.w	d6,d7
	bmi		_right_16
not_drawn_32
	rts
*****************************************************************************
*	The low level routines, may be useful for other stuff at some stage..	*
*****************************************************************************
DO_RIGHT	macro
	moveq	#-1,d3
	move.w	(a1)+,d3			get the QTemplate
	ror.l	d0,d3				rotate it

	moveq	#0,d4
	move.w	(a1)+,d4			get QPlane 0
	ror.l	d0,d4				rotate it
	move.w	(a0)+,d5
	and.w	d3,d5
	or.w	d5,d4				QPlane 0 made

	moveq	#0,d5
	move.w	(a1)+,d5			get QPlane 1
	ror.l	d0,d5				rotate it
	move.w	(a0)+,d6
	and.w	d3,d6
	or.w	d6,d5				QPlane 1 made

	moveq	#0,d6
	move.w	(a1)+,d6			get QPlane 2
	ror.l	d0,d6				rotate it
	move.w	(a0)+,d7
	and.w	d3,d7
	or.w	d7,d6				QPlane 0 made

	moveq	#0,d7
	move.w	(a1)+,d7			get QPlane 3
	ror.l	d0,d7				rotate it
	and.w	(a0)+,d3			may as well corrupt the QTemplate this time
	or.w	d3,d7				QPlane 3 made
	endm
*************
DO_LEFTM	macro
	swap	d3
	swap	d4
	move.w	(a0)+,d5
	and.w	d3,d5
	or.w	d5,d4				QPlane 0 made

	swap	d5
	move.w	(a0)+,d6
	and.w	d3,d6
	or.w	d6,d5				QPlane 1 made

	swap	d6
	move.w	(a0)+,d7
	and.w	d3,d7
	or.w	d7,d6				QPlane 2 made

	swap	d7
	and.w	(a0)+,d3			corrupting QTemplate
	or.w	d3,d7				QPlane 3 made
	endm
*******
DO_LEFT macro
	moveq	#-1,d3
	move.w	(a1)+,d3			get the QTemplate
	rol.l	d0,d3				rotate it

	move.w	(a1)+,d4			get QPlane 0
	lsl.w	d0,d4				rotate it
	move.w	(a0)+,d5
	and.w	d3,d5
	or.w	d5,d4				QPlane 0 made

	move.w	(a1)+,d5			get QPlane 1
	lsl.w	d0,d5				rotate it
	move.w	(a0)+,d6
	and.w	d3,d6
	or.w	d6,d5				QPlane 1 made

	move.w	(a1)+,d6			get QPlane 2
	lsl.w	d0,d6				rotate it
	move.w	(a0)+,d7
	and.w	d3,d7
	or.w	d7,d6				QPlane 0 made

	move.w	(a1)+,d7			get QPlane 3
	lsl.w	d0,d7				rotate it
	and.w	(a0)+,d3			may as well corrupt the QTemplate this time
	or.w	d3,d7				QPlane 3 made
	ENDM
*****************************************************************************
_all_16
; A0 = QSource, A1 = QDest, D0 = QShift, D2 = Height

	moveq	#256-(160-16),d1
	neg.b	d1
	subq.w	#1,d2				for dbra
a16_loop
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	DO_LEFTM
	movem.w d4-d7,-8(a0)		another one
	adda.w	d1,a0
	dbra	d2,a16_loop
	rts
********************************************************************
_left_16
; A0 = QSource, A1 = QDest, D0 = QShift, D1 = QSkip, D2 = Height
	subq.w	#1,d2
	neg.w	d0
	andi.w	#$f,d0
l16_loop
	adda.w	d1,a1
	DO_LEFT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	lea		160-8(a0),a0
	dbra	d2,l16_loop
	rts
********************************************************************
_right_16
; A0 = QSource, A1 = QDest, D0 = QShift, D1 = QSkip, D2 = Height
	subq.w	#1,d2
r16_loop
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	lea		160-8(a0),a0
	adda.w	d1,a1
	dbra	d2,r16_loop
	rts

*****************************************************************************
_all_32
; A0 = QSource, A1 = QDest, D0 = QShift, D2 = Height

	moveq	#256-(160-24),d1
	neg.b	d1
	subq.w	#1,d2				for dbra
a32_loop
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	DO_LEFTM
	subq.l	#8,a0
	movem.w d4-d7,(a0)		 	another one
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	DO_LEFTM
	movem.w d4-d7,-8(a0)		another one
	adda.w	d1,a0
	dbra	d2,a32_loop
	rts
*****************************************************************************
_left_32
; A0 = a1, A1 = QDest, D0 = QShift, D1 = QSkip, D2 = Height
	subq.w	#1,d2
	move.w	d0,d4
	neg.w	d4
	moveq	#$f,d5
	and.w	d5,d4
	and.w	d5,d0
	swap	d0
	move.w	d4,d0
l32_loop
	adda.w	d1,a1
	DO_LEFT
	subq.l	#8,a0
	movem.w d4-d7,(a0) 			i had to get a movem in there somewhere
	swap	d0
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	DO_LEFTM
	movem.w d4-d7,-8(a0)		another one
	swap	d0
	lea		160-16(a0),a0
	dbra	d2,l32_loop
	rts
*****************************************************************************
_right_32
; A0 = QSource, A1 = QDest, D0 = QShift, D1 = QSkip, D2 = Height
	subq.w	#1,d2
	andi.w	#$f,d0
r32_loop
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	DO_LEFTM
	subq.l	#8,a0
	movem.w d4-d7,(a0) 			another one
	DO_RIGHT
	movem.w d4-d7,-8(a0)		i had to get a movem in there somewhere
	lea		160-16(a0),a0
	adda.w	d1,a1
	dbra	d2,r32_loop
	rts
*****************************************************************************
; a0-> filename a1-> destination d0 = length
; on return d0 = file length actually read or -1 if read failed
_load_file
	move.l	d0,d6
	clr.w	-(sp)               read
	move.l	a0,-(sp)			-> filename
	move.w	#FOPEN,-(sp)
	trap	#1					open the file
	addq.l	#8,sp				readjust the stack
	move.w	d0,d7				handle
	ble.s   file_not_found
*
	move.l  a1,-(sp)			destination memory
	move.l	d6,-(sp)
	move.w	d7,-(sp)			file handle
	move.w	#FREAD,-(sp)
	trap	#1					read the file
	lea		12(sp),sp			the quick way of adding 12 to the stack
	move.l	d0,d6				length read
*
	move.w	d7,-(sp)			file handle
	move.w	#FCLOSE,-(sp)
	trap	#1					close the file
	addq.l	#4,sp
	move.l	d6,d0				so we can return the file length
	rts
file_not_found
	pea		fnf_msg(pc)			address of the error message
	move.w	#PRINTLINE,-(sp)
	trap	#1					print it
	addq.l	#6,sp
	moveq	#-1,d0
	rts
*****************************************************************************
fnf_msg		dc.b    7,'FILE NOT FOUND',10,13,7,0
spr16_fname	dc.b	'sprite16.dat',0
spr32_fname	dc.b	'sprite32.dat',0
	even
palette		dc.w	$000,$321,$432,$543,$400,$520,$630,$651
			dc.w	$331,$441,$551,$661,$013,$034,$345,$555
*****************************************************************************
;	section	bss			use this line on devpac 2, it saves a lot of disk access
old_rez		ds.b	1
_vbi_done	ds.b	1
	even
old_vbi		ds.l	1
old_ssp		ds.l	1
old_screen	ds.l	1
_d_screen	ds.l	1
_w_screen	ds.l	1
w_screen	ds.b	32000+256	screen has to be on a 256 byte boundry
_spr_32		ds.b    256*10*32	the max size of the file from art studio

*
