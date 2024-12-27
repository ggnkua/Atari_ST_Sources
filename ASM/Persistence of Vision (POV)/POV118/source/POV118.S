*************************************************************************
*			PERSISTENCE OF VISION 118			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music by: 	The Heavy Killers from the Kidney Bean demo		*
*									*
*									*
* Grafix by: 	Machine System Data					*
*									*
*************************************************************************
*
* The starfield in this menu was written someone else but the
* clear stars routine cleared the whole screen which was wasting CPU
* time so I have patched the routine and written a shit hot fast clear
* star routine.
*
* The screen flip is shit as I have fucked it up (again)
* If you put loads of stars on the screen it naffs the logo up.
*
*

STARS	equ	70	; number of stars to stick on screen

YES=1
NO=0


AUTORUN4=YES	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here


***************************
	SECTION TEXT
***************************


*~~~~~~~~~~~~~~~~~~~~~~~ HERE GOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	opt	o+


	ifeq	AUTORUN4
begin	bra	start
	ds.l	100
ustack	ds.l	1

; filename has already been stored in $200 so we can now P_EXEC
exec	pea	blank
	pea	blank
	pea	$200
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	pea	.reset		;always reset on return from prog
	move.w	#$26,-(sp)
	trap	#14
.reset	move.l	4.w,-(sp)
	rts

blank	dc.l	0

*******************************************************************
start	move.l	4(a7),a0
	move.l	#ustack,a7
	move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
	move.l	a0,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	ENDC


;first we should clear the BSS as most packers don't..
		lea	bss_start,a0
clear		clr.l	(a0)+
		cmp.l	#bss_end,a0
		blt.s	clear

		bsr	set_super

		move.b	#$12,$fffffc02.w

		bsr	shift_logo

		jsr	music		; init music

		bsr	setup		; set up screens and interrupt crap

		bsr	make_yp_tab	; make up a table of Y coordinates
	

main_loop	move.w	#-1,vsync_flag		;vsync to VBL
.sync		tst.w	vsync_flag
		bne.s	.sync

;	move.w	#$123,$ffff8240.w
		bsr	clear_stars	;clear the star field
		bsr	starfield	; move, calculate and print starfield.
		bsr	rippler		;do the TCC logo
		bsr	scroll		;do the scroller
		bsr	put_titles	;put the game/demo titles on screen
;	clr.w	$ffff8240.w

		bsr	flip_screen		; swap screens over to stop flicker.

	move.w	key,d0

	cmp.w	#1,d0		;ESC
	beq	assem

	cmp.w	#11,d0		;0 keyboard
	beq	zero

	cmp.w	#$70,d0		;0 keypad
	beq	zero

	cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
	beq	reset

	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi.s	main_loop
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next
.run	lsr.w	#8,d1
	and.w	#$f,d1
	lsl.w	#2,d1
	lea	filename_table,a0
	move.l	(a0,d1.w),a0
	lea	$200.w,a1
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

	tst.w	hertz_toggle
	beq.s	hz50
	and.b	#%11111101,$ffff820a.w	;60Hz
hz50

exit		move.w	#$2700,sr
		move.l	old118,$118.w
		move.l	old120,$120.w
		move.l	old70,$70.w
		move.b	olda07,$fffffa07.w
		move.b	olda09,$fffffa09.w
		move.b	olda1b,$fffffa1b.w
		move.b	olda21,$fffffa21.w
		bclr	#1,$fffffa13.w
		move.w	#$2300,sr
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		bsr	set_org_pal
		move.b	#8,$fffffc02.w
		bsr	set_user					; user mode
		bsr	set_org_rez		; reset GEM screens

	ifeq	AUTORUN4
	bra	exec

	ELSE
	clr.w	-(sp)
	trap	#1
	ENDC




assem		move.w	#$2700,sr
		move.l	old118,$118.w
		move.l	old120,$120.w
		move.l	old70,$70.w
		move.b	olda07,$fffffa07.w
		move.b	olda09,$fffffa09.w
		move.b	olda1b,$fffffa1b.w
		move.b	olda21,$fffffa21.w
		bclr	#1,$fffffa13.w
		move.w	#$2300,sr
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		bsr	set_org_pal
		move.b	#8,$fffffc02.w
		bsr	set_user					; user mode
		bsr	set_org_rez		; reset GEM screens
		clr.w	-(sp)		; exit to DEVPAC
		trap	#1

zero	;flip hertz indicator...
	tst.w	hertz_delay
	bne	main_loop
	eor.w	#$009,pic+2
	eor.w	#-1,hertz_toggle
	move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
	bra	main_loop


reset	move.l	4.w,-(sp)
	rts


*-------------------------------------------------------------------------*
*				    3D STARFIELD PRINT					  *
*-------------------------------------------------------------------------*

starfield

.move_stars			; this moves the stars around!
	lea	XRAND(pc),a0	; get bank of random x-coords
	lea	YRAND(pc),a1	;  "   "   "    "    y-coords
	lea	ZRAND(pc),a2	;  "   "   "    "    z-coords
	move.w	xi(pc),d0	; xi = X increment, in d0
	move.w	yi(pc),d1	; yi = Y increment, in d1
	move.w	zi(pc),d2	; zi = Z increment, in d2
	move.w	#127,d3		; x/y max limit of stars in space
	move.w	#511,d4		; z max limit of stars in space
	move.w	#STARS,d7	; number of stars to do in d7
.lp	move.w	(a0),d6		; get star x-coord
	add.w	d0,d6		; change x-coord by amount in (xi)
	and.w	d3,d6		; if x<0 then x=127 : if x>127 then x=0
	move.w	d6,(a0)+	; put x-coord back in buffer

	move.w	(a1),d6		; get star y-coord
	add.w	d1,d6		; change y-coord by amount in (yi)
	and.w	d3,d6		; if y<0 then y=127 : if y>127 then y=0
	move.w	d6,(a1)+	; put y-coord back in buffer

	move.w	(a2),d6		; get star z-coord
	add.w	d2,d6		; change z-coord by amount in (zi)
	and.w	d4,d6		; if z<0 then z=511 : if z>511 then z=0
	move.w	d6,(a2)+	; put z-coord back in buffer

	dbra	d7,.lp		; do next star in buffer.



.print_stars			; this sticks the stars on screen
	lea	Y_PLOT,a5	; get list of y-coords on screen
	lea	.plot(pc),a6	; list of plot routs. (colours)
	lea	XRAND(pc),a1	; get coords of stars
	lea	YRAND(pc),a2
	lea	ZRAND(pc),a3
	move.w	#STARS,d0	; number of stars to do in d0
	moveq	#7,d2		; use this later (shift left of 7 = * 128)
.loop	move.w	(a3)+,d1	; z-coord
	move.w	d1,d3		; save for colour (0-511)
	neg.w	d1		;
	move.w	d1,d4		;
	add.w	#511,d1		;
 	ext.l	d4
	lsl.l	d2,d4		;shift left by 7 places = * 128
	divs	d1,d4
	move.w	(a1)+,d1	;get x coords
	sub.w	#64,d1
	move.w	d1,d5
	neg.w	d1
	muls	d4,d1
	lsr.l	d2,d1		;div by 128
	add.w	d1,d5
	move.w	(a2)+,d1
	add.w	#160,d5		; touch this and it will crash!!!
	bmi.s	.end		;
	sub.w	#64,d1
	move.w	d1,d6
	neg.w	d1
	muls	d1,d4
	lsr.l	d2,d4		;div by 128
	add.w	d4,d6
	neg.w	d6
	add.w	#100,d6		; touch this and it will crash!!!
	bmi.s	.end		;
	cmp.w	#319,d5		; (limits of screen coordinates)
	bgt.s	.end		;	low res - 320*200
	cmp.w	#199,d6		;
	bgt.s	.end		;

.log	move.l	scr_now,a4	;get present screen address
	add.w	d6,d6		;add y coords to y coords
	add.w	(a5,d6),a4	;add x to y and get real pos
	move.w	d5,d6
	and.w	#$FF0,d6
	lsr.w	d6  		;div 2
	add.w	d6,a4
	and.b	#$F,d5		;make on 16 byte boundary
	move.w	#%1000000000000000,d6
	lsr.w	d5,d6		;shift to star position
	lsr.w	#3,d3		;div colour by 8
	and.w	#%11111100,d3	;mask by 4
	move.l	(a6,d3),a0

***************
	movem.l	a4/a5,-(sp)	;bit for new clear_stars routine by MAC SYS DATA
	move.l	old_stars_pos,a5
	sub.l	scr_now,a4
	move.l	a4,(a5)+
	move.l	a5,old_stars_pos
	movem.l	(sp)+,a4/a5
**************

	jmp	(a0)

.end	dbra	d0,.loop
	bra.s	.control_stars

.P0	dbra	d0,.loop	; these routines plot pixels in 7 colours
	bra.s	.control_stars
.P1	or.w	d6,(a4)	
	dbra	d0,.loop
	bra.s	.control_stars
.P2	or.w	d6,2(a4)	
	dbra	d0,.loop
	bra.s	.control_stars
.P3	or.w	d6,(a4)+
	or.w	d6,(a4)	
	dbra	d0,.loop
	bra.s	.control_stars
.P4	or.w	d6,4(a4)	
	dbra	d0,.loop
	bra.s	.control_stars
.P5	or.w	d6,(a4)	
	or.w	d6,4(a4)	
	dbra	d0,.loop
	bra.s	.control_stars
.P6	or.w	d6,2(a4)	
	or.w	d6,4(a4)	
	dbra	d0,.loop
	bra.s	.control_stars
.P7	or.w	d6,(a4)+	
	or.w	d6,(a4)+	
	or.w	d6,(a4)	
	dbra	d0,.loop

*-------------------------------*

.control_stars		; this makes the stars change direction
	subq.w	#1,STARTIME
;	and.w	#$3F,STARTIME
	bne.s	.ok

	move.l	star_time_table_pos,a0
	tst.w	(a0)
	bpl.s	.yes
	lea	star_time_table,a0
.yes	move.w	(a0)+,STARTIME
	move.l	a0,star_time_table_pos

	addq	#1,STARDIR
	and.w	#$1F,STARDIR
.ok	addq	#1,FRAME
	and.w	#7,FRAME
	bne.s	.n3	
	lea	DIR_TAB(pc),a0
	move.w	STARDIR(pc),d0
	mulu	#6,d0
	move.w	0(a0,d0),d1
	move.w	2(a0,d0),d2
	move.w	4(a0,d0),d3
	cmp.w	xi(pc),d1
	beq.s	.n1
	bgt.s	.g1
	subq	#1,xi
	bra.s	.n1
.g1	addq	#1,xi
.n1	cmp.w	yi(pc),d2
	beq.s	.n2
	bgt.s	.g2
	subq	#1,yi
	bra.s	.n2
.g2	addq	#1,yi
.n2	cmp.w	zi(pc),d3
	beq.s	.n3
	bgt.s	.g3
	subq	#2,zi
	bra.s	.n3
.g3	addq	#2,zi
.n3	rts

.plot	dc.l	.P1,.P1,.P1,.P1,.P2,.P2,.P3,.P3,.P4,.P4	; list of colour
	dc.l	.P5,.P5,.P6,.P6,.P7,.P0			; plot routs.

*-------------------------------*

make_yp_tab	; make Y-POS > SCREEN conversion table
		lea	Y_PLOT+400,a0
		move.w	#200-1,d0
.lp		move.w	d0,d1
		mulu	#160,d1
		move.w	d1,-(a0)
		dbra	d0,.lp
		rts



scroll	move.l	scr_now,a1
	add.w	#(160*204)+6,a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5

	moveq	#0,d4
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#4*14,d0		;14 lines deep
	add.w	d0,a0
	move.w	d6,d0
	mulu	#14,d0			;14 lines deep
	add.w	d0,a0

.column
OFF	set	0
	REPT	14		;scroll font is 14 lines deep
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR

	subq.w	#1,d5
	beq.s	.finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	addq.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne.s	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl.s	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra.s	next_char

.finish
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	rts







RIPPLER_WIDTH	equ	8
RIPPLER_DEPTH	equ	52

rippler		move.l	ripple_table_pos,a6
		cmp.l	#reset_ripple_flag,a6
		blt.s	.do_rout
		move.l	#ripple_table,ripple_table_pos
.do_rout	lea	ripple_data,a0
		move.l	scr_now,a1
		add.w	#(70*160),a1
		move.w	#RIPPLER_DEPTH-1,d7
		move.b	(a6)+,d0
		move.b	(a6)+,d1
		and.l	#$ff,d0
		and.l	#$ff,d1
		lsl.w	#3,d0		;word offset *8
		mulu	#RIPPLER_WIDTH*8*RIPPLER_DEPTH,d1	;ripple number
		add.l	d1,a0
		add.w	d0,a1
.loop	
OFF	set	0
		REPT	RIPPLER_WIDTH
		move.l	(a0)+,OFF(a1)
		move.l	(a0)+,OFF+4(a1)
OFF	set	OFF+8
		ENDR
		lea	160(a1),a1

		dbf	d7,.loop
		addq.l	#2,ripple_table_pos
		rts


shift_logo	lea	ripple_data,a1
		move.w	#16-1,d1
.loop2		lea	pic+34,a0
		move.w	#RIPPLER_DEPTH-1,d0
OFF		set	0
.loop		REPT	RIPPLER_WIDTH
		move.l	OFF(a0),(a1)+
		move.l	OFF+4(a0),(a1)+
OFF		set	OFF+8
		ENDR
		lea	160(a0),a0
		dbf	d0,.loop

		lea	pic+34,a0
		move.w	#RIPPLER_DEPTH-1,d2
		sub.w	d0,d0		;clear carry flag before shifting
.scroll
OFF		set	0
		REPT	RIPPLER_WIDTH
		roxr.w	OFF(a0)
OFF		set	OFF+8
		ENDR

OFF		set	2
		REPT	RIPPLER_WIDTH
		roxr.w	OFF(a0)
OFF		set	OFF+8
		ENDR

OFF		set	4
		REPT	RIPPLER_WIDTH
		roxr.w	OFF(a0)
OFF		set	OFF+8
		ENDR

OFF		set	6
		REPT	RIPPLER_WIDTH
		roxr.w	OFF(a0)
OFF		set	OFF+8
		ENDR

		lea	160(a0),a0
		dbf	d2,.scroll
		dbf	d1,.loop2
		rts


put_titles	lea	pic+34+(160*140),a5
		move.l	scr_last,a6
		lea	160*10(a6),a6
		REPT	9
	movem.l	(a5)+,d0-d7/a1-a4
	movem.l	d0-d7/a1-a4,(a6)
	movem.l	(a5)+,d0-d7/a1-a4
	movem.l	d0-d7/a1-a4,48(a6)
	movem.l	(a5)+,d0-d7/a1-a4
	movem.l	d0-d7/a1-a4,96(a6)
	move.l	(a5)+,144(a6)
	move.l	(a5)+,148(a6)
	move.l	(a5)+,152(a6)
	move.l	(a5)+,156(a6)
	lea	160(a6),a6
		ENDR

		lea	160*130(a6),a6

		REPT	51
	movem.l	(a5)+,d0-d7/a1-a4
	movem.l	d0-d7/a1-a4,(a6)
	movem.l	(a5)+,d0-d7/a1-a4
	movem.l	d0-d7/a1-a4,48(a6)
	movem.l	(a5)+,d0-d7/a1-a4
	movem.l	d0-d7/a1-a4,96(a6)
	move.l	(a5)+,144(a6)
	move.l	(a5)+,148(a6)
	move.l	(a5)+,152(a6)
	move.l	(a5)+,156(a6)
	lea	160(a6),a6
		ENDR
		rts


setup		move.w	#4,-(sp)		;save old rez
		trap	#14
		addq	#2,sp
		move.w	d0,org_rez

		lea	$ffff8240.w,a0		;save old palette
		lea	old_pal,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)

		move.w	#2,-(sp)
		trap	#14
		addq	#2,sp
		move.l	d0,org_physical

		move.w	#3,-(sp)
		trap	#14
		addq	#2,sp
		move.l	d0,org_logical

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#39680,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		move.l	scr_now,a1
		lea	160*204(a1),a1
		move.l	a1,a2
		add.l	#39680,a2
		lea	pattern+34,a0
		move.w	#160*15/4-1,d0
.fill		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.fill

		
		clr.w	-(sp)		;go for low rez
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.w	#12,sp


;start the border code up so save all old values...
		ori.w	#$700,sr		;stop interrupts
		move.l	$70.w,old70		;save the old bits
		move.l	$118.w,old118
		move.l	$120.w,old120
		move.b	$fffffa07.w,olda07
		move.b	$fffffa09.w,olda09
		move.b	$fffffa1b.w,olda1b
		move.b	$fffffa21.w,olda21
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w

		move.l	#new_70,$70.w		;our new VBL
		move.l	#new_120,$120.w		;our new HBL (timer B)
		move.l	#new_118,$118.w		;our new keyboard

		or.b	#1,$fffffa07.w
		or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w		;auto ISR enable at RTE
		clr.b	$fffffa1b.w		;di timer B
		clr.b	$fffffa21.w		;clr timer B data
		move.w	#$2300,sr		;enable ISR

flip_screen	move.l	scr_now,d0
		move.l	scr_xor,d1
		move.l	d0,scr_last
		eor.l	d1,d0
		move.l	d0,scr_now
		lsr.l	#8,d0
		lea	$ffff8201.w,a6
		movep.w	d0,(a6)
		rts


set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq	#6,sp
		move.l	d0,old_stack
		rts


set_user	move.l	old_stack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq	#6,sp
		rts


set_org_pal	lea	$ffff8240.w,a0
		lea	old_pal,a1
		movem.l	(a1),d0-d7
		movem.l	d0-d7,(a0)
		rts


set_org_rez	move.w	org_rez,-(sp)
		move.l	org_physical,-(sp)
		move.l	org_logical,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.w	#12,sp
		rts





new_70	clr.b	$fffffa1b.w
	movem.l	d0-d7/a0-a6,-(sp)	;preserve regs
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	jsr	music+8
	clr.w	vsync_flag
	move.l	#old_stars,old_stars_pos

	tst.w	hertz_delay
	bne.s	dec_hertz
	movem.l	(sp)+,d0-d7/a0-a6

	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

dec_hertz
	subq.w	#1,hertz_delay
	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#199,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte

new_120	clr.b	$fffffa1b.w
	move.w	d0,-(sp)
	REPT	50
	nop
	ENDR
	moveq	#0,d0
.loop	cmp.b	$ffff8209.w,d0
	bne.s	.loop

	clr.b	$ffff820a.w	;60 hertz
	REPT	22
	nop
	ENDR
	move.b	#2,$ffff820a.w	;back to 50 hertz
	move.w	pattern+2,$ffff8240.w
	move.w	(sp)+,d0
	clr.l	$ffff8240+2.w
	clr.l	$ffff8240+6.w
	clr.l	$ffff8240+10.w
	move.l	pattern+16,$ffff8240+14.w
	move.l	pattern+20,$ffff8240+18.w
	move.l	pattern+24,$ffff8240+22.w
	move.l	pattern+28,$ffff8240+26.w
	rte


new_118		move.l	d0,-(sp)		;new keyboard routine
		move.b	$fffffc02.w,d0
		cmp.b	#$1d,d0
		bne.s	.k1
		bset	#2,key
.k1		cmp.b	#$9d,d0
		bne.s	.k2
		bclr	#2,key
.k2		cmp.b	#$38,d0
		bne.s	.k3
		bset	#3,key
.k3		cmp.b	#$b8,d0
		bne.s	.k4
		bclr	#3,key
.k4		move.b	d0,key+1
		bclr	#6,$fffffa11.w
		move.l	(sp)+,d0
		rte



;*******************************************************
; New clear_stars routine
; coded by MAC SYS DATA 'cos the old one was shit slow
;*******************************************************
clear_stars	lea	old_stars,a0
		moveq	#0,d0
		REPT	STARS
		move.l	scr_last,d2
		move.l	(a0)+,a1
		move.l	d0,(a1,d2.l)
		move.l	d0,4(a1,d2.l)
		ENDR
		rts





************************************************************
			SECTION DATA
************************************************************

xi		ds.w		1
yi		ds.w		1
zi		ds.w		1
FRAME		ds.w		1
STARDIR		ds.w		1
STARTIME	dc.w		200
XRAND		incbin	rnd_x.dat
YRAND		incbin	rnd_y.dat
ZRAND		incbin	rnd_z.dat

DIR_TAB		dc.w	00,00,10	; lists of x,y and z directions for stars
		dc.w	00,-2,10
		dc.w	00,-3,00
		dc.w	00,03,-10
		dc.w	-3,03,00
		dc.w	03,03,10
		dc.w	00,03,00
		dc.w	-3,-3,-10
		dc.w	03,00,10
		dc.w	00,-3,00
		dc.w	00,00,10
		dc.w	01,01,00
		dc.w	-2,01,00
		dc.w	-2,01,10
		dc.w	00,00,10
		dc.w	03,00,00
		dc.w	-3,03,10
		dc.w	00,00,-10
		dc.w	03,03,10
		dc.w	-3,00,00
		dc.w	-3,-3,00

		dc.w	00,00,-10
		dc.w	00,00,10
		dc.w	00,03,10
		dc.w	-3,03,00
		dc.w	00,03,-10
		dc.w	00,00,-10
		dc.w	-3,-3,-10
		dc.w	03,-3,00
		dc.w	00,-3,10
		dc.w	00,00,10
		dc.w	00,00,-20

*-------------------------------------------------------------------------*
; Another MSD adaption!
;this table will appear to give some randomness to the stars movement
;as the stars will not move in the same direction for the same length
;of time.
star_time_table_pos	dc.l	star_time_table
star_time_table		dc.w	127,127,127,64,64,64,64,64,64,64,64,64,64
			dc.w	32,16,127,127,64,127,127,127
			dc.w	-1		;end of table
;-----------------------------------------------------------------


music	incbin	kidney5.thk

pic	incbin	logo.pi1

ripple_table_pos	dc.l	init_ripple_table
init_ripple_table
	dcb.w	200,$0701
ripple_table
	incbin	sine1.dat
	incbin	sine3.dat
	incbin	sine5.dat
	incbin	sine3.dat
	incbin	sine7.dat
reset_ripple_flag
	incbin	sine1.dat

	even

pattern	incbin	pattern.pi1


scroll_pointer	dc.l	scroll_text
scroll_text
 DC.B "                   "
 dc.b "MAC SYS DATA IS PROUD TO PRESENT PERSISTENCE OF VISION "
 dc.b "DEMO COMPILATION 118.          MENU CODED BY "
 DC.B "MAC SYS DATA OF P.O.V.,      "
 DC.B "LOGO BY MAC SYS DATA BASED ON AN ORIGINAL BY OZ.      "
 DC.B "MUSIC FROM THE KIDNEY BEAN DEMO.          RELEASE DATE: 28TH JUNE 1992.       "
 DC.B "                                                 "
 DC.B "P.O.V.,        P.O. BOX 40,        THORNTON-CLEVELEYS,        "
 DC.B "BLACKPOOL,        LANCS.,         FY5 3PH.        ENGLAND.        "
 DC.B "                                                 "
 DC.B "                                                 "
 DC.B "                                                 "
 DC.B "                                                 "
 DC.B "                                                 "
 dc.b "                                                 "
 dc.b "                                                 "
 dc.b "                                                 "
 dc.b "                                                 "
 dc.b "                                                 "
 dc.b $ff
 DC.B "   HELLO HACKER WHAT THE FUCK DO YOU WANT?   "
	even
char_offset	dc.w	0
font	dcb.b	14*4,0
	incbin	"1plane.fnt"
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,00,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,00,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,41,00,42,00,42,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;	 v  w  x  y  z
 dc.b	22,23,24,25,26


	even


demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"DENTRO",0
	even
exec2	dc.b	"GALTAN09.DMC",0
	even
exec3	dc.b	"DEAD",0
	even
exec4	dc.b	"PHF",0
	even
exec5	dc.b	"ST_CNX",0
	even
exec6	dc.b	"M_CODER",0
	even
exec7	dc.b	"POWER",0
	even
exec8	dc.b	"copier.pov",0
	even



old_stars_pos	dc.l	old_stars
*-------------------------------------------------------------------------*

	SECTION BSS

*-------------------------------------------------------------------------*

bss_start


old70			ds.l	1
old120			ds.l	1
old118			ds.l	1
olda07			ds.b	1
olda09			ds.b	1
olda1b			ds.b	1
olda21			ds.b	1

org_physical		ds.l	1
org_logical		ds.l	1

key			ds.w	1
hertz_delay		ds.w	1
hertz_toggle		ds.w	1
vsync_flag		ds.w	1
old_pal			ds.w	16
old_stack		ds.l	1
org_rez			ds.w	1

Y_PLOT		ds.w		200

old_stars	REPT	STARS
		ds.l	1
		ENDR

scr_last	ds.l	1
scr_now		ds.l	1
scr_xor		ds.l	1

		ds.b	1024
screens		ds.b	39936		;new screen memory
		ds.b	39936

ripple_data		ds.b	(RIPPLER_WIDTH*4*RIPPLER_DEPTH)*16
ripple_end

	even

bss_end