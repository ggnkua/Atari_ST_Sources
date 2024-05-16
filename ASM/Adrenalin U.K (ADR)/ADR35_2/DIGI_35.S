*************************************************************************
*			ADRENALIN 35 version 2				*
*			----------------------				*
*									*
* Written by:	SPACEMAN SPIFF						*
*									*
* Date:		2/6/93							*
*									*
*									*
*									*
*									*
*									*
*************************************************************************
*
* I have used a DIGI-DRUM tune here BUT because I knock out the top
* border I had to disable the digi-drum tune in the lower border.
* The results is a slightly wavy digi-drum. If you have a keen ear you
* will notice it straight away otherwise it's ok.
*
* You can bolt a normal tune in if you wish or replace the present digi-drum
* tune with another digi one. The present tune uses timerd ($110) as it's
* drum driver and uses A6 all the time so don't use A6 in your program.
* Any mad max tunes should simply bolt in.
*
* SPACEMAN SPIFF 2/6/93
*
*

yes=1
YES=yes
no=0
NO=no

****** DOWNLOAD DEVELOPMENT SWITCHES *********************************
DOWNLOAD	equ	no

		ifne	DOWNLOAD		;version 1 download code
		include	sttx1.s
		org	$1000

Code_Start
Exec_Addr
		ENDC
*************************************************************************



FINAL		equ	no		;put to YES for disc version

RASTER_COLOUR	equ	$ffff8242	;colour coloured by rasters

DISPLAY_TIME	equ	200		;time text is held on screen
					;Increase this to allow user
					;to read text

STARS		equ	130		;number of stars to stick on screen
					;you can INCREASE this until it goes
					;into 2 frames if you want!
		ifeq	DOWNLOAD
begin		bra	start
		ds.l	100
ustack		ds.l	1

exec		pea	blank
		pea	blank
		pea	$200.w
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		pea	reset_me(pc)
		move.w	#$26,-(sp)
		trap	#14
reset_me	move.l	4.w,-(sp)
		rts

blank		dc.l	0

start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		endc

		lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
		lsr.w	#2,d0
clear_bss	clr.l	(a0)+
		sub.l	#1,d0
		bne.s	clear_bss

		bsr	sort_text
		bsr	make_yp_tab	; make up a table of Y coordinates

		bsr	setup

main_loop	bsr	flip_screen
		bsr	vsync
;		move.w	#$123,$ffff8240.w
		bsr	clear_stars	;clear the star field
		bsr	starfield	;move, calculate and print starfield.
		bsr	print_text
		jsr	music+4
;		move.w	hertz_toggle,$ffff8240.w

		moveq	#0,d0
		move.b	key,d0

		cmp.b	#1,d0
		beq.s	stop

		cmp.b	#11,d0		;0 keyboard
		beq	zero

		cmp.b	#$70,d0		;0 keypad
		beq	zero

		cmp.b	#$53,d0		;DEL=RESET!
		beq	reset

		lea	demo_keys,a0
.next		move.w	(a0)+,d1
		bmi	main_loop
		cmp.b	d1,d0
		beq.s	.run
		bra.s	.next
.run		lsr.w	#8,d1
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
stop
		IFNE	DOWNLOAD
		move.l	4.w,-(sp)
		rts
		ENDC

		bsr	reset_isr

		move.b	#8,$fffffc02.w

		ifeq	DOWNLOAD
		bsr	set_user
		endc

		ifeq	DOWNLOAD
		IFNE	FINAL
		bra	exec
		ENDC
		ENDC

		clr.w	-(sp)
		TRAP	#1


zero		;flip hertz indicator...
		tst.w	hertz_delay
		bne	main_loop
		eor.w	#$020,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts



*-----------------------------------------------------------------------*
*				3D STARFIELD PRINT			*
*-----------------------------------------------------------------------*

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
	move.l	a5,d7
	lea	.plot(pc),a5	; list of plot routs. (colours)
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
	cmp.w	#320-1,d5	; (limits of screen coordinates)
	bgt.s	.end		;	low res - 320*200
	cmp.w	#200-1,d6	;
	bgt.s	.end		;

.log	move.l	present_base,a4	;get present screen address
	add.w	#160*30,a4
	add.w	d6,d6		;add y coords to y coords
	move.l	a5,-(sp)
	move.l	d7,a5
	add.w	(a5,d6),a4	;add x to y and get real pos
	move.l	(sp)+,a5
	move.w	d5,d6
	and.w	#$FF0,d6
	lsr.w	d6  		;div 2
	add.w	d6,a4
	and.b	#$F,d5		;make on 16 byte boundary
	move.w	#%1000000000000000,d6
	lsr.w	d5,d6		;shift to star position
	lsr.w	#3,d3		;div colour by 8
	and.w	#%11111100,d3	;mask by 4
	move.l	(a5,d3),a0

***************
	movem.l	a4/a5,-(sp)	;bit for new clear_stars routine by MAC SYS DATA
	move.l	old_stars_pos,a5
	sub.l	present_base,a4
	move.l	a4,(a5)+
	move.l	a5,old_stars_pos
	movem.l	(sp)+,a4/a5
**************
	jmp	(a0)

.end	dbra	d0,.loop
	bra.s	.control_stars

.P0	dbra	d0,.loop	; these routines plot pixels in 7 colours
	bra.s	.control_stars
.P2	or.w	d6,4(a4)	
	dbra	d0,.loop

*-------------------------------*

.control_stars		; this makes the stars change direction
	subq.w	#1,STARTIME
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

.plot	dc.l	.P2,.P2,.P2,.P2,.P2,.P2,.P2,.P2,.P2,.P2	; list of colour
	dc.l	.P2,.P2,.P2,.P2,.P2,.P0			; plot routs.

*-------------------------------*

make_yp_tab	; make Y-POS > SCREEN conversion table
		lea	Y_PLOT+400,a0
		move.w	#200-1,d0
.lp		move.w	d0,d1
		mulu	#160,d1
		move.w	d1,-(a0)
		dbra	d0,.lp
		rts


;*******************************************************
; New clear_stars routine
; coded by MAC SYS DATA 'cos the old one was shit slow
;*******************************************************
clear_stars	lea	old_stars,a0
		moveq	#0,d0
	 	move.l	last_base,d2
		REPT	STARS
		move.l	(a0)+,a1
		move.w	d0,4(a1,d2.l)
		ENDR
		rts







print_text	tst.w	disc_clear_enable
		bne	.do_clear
		tst.w	disc_enable
		beq.s	.do_stuff
		rts
.do_stuff	move.l	text_pos,a1
		move.l	present_base,a0
		move.l	last_base,a3
.restart	moveq	#0,d1
		move.b	(a1)+,d1
		move.l	a1,text_pos
		cmp.b	#-1,d1
		bne.s	.no_reset
		move.l	#middle_text,a1
		bra.s	.restart
.no_reset	cmp.b	#"^",d1		;termintor
		bne.s	.do_text
		cmp.b	#13,(a1)
		bne.s	.notcr_here	;if CR is here then take for granted CR,LF
		add.l	#2,text_pos
.notcr_here	move.w	#-1,disc_clear_enable
		move.w	#-1,disc_enable
		move.w	#17*16,lines_to_do
		move.w	#DISPLAY_TIME,do_clear_delay
		clr.b	xpos
		clr.b	ypos
		rts
.do_text	cmp.b	#13,d1
		bne.s	.notcr
		clr.b	xpos
		bra	.restart
.notcr		cmp.b	#10,d1
		bne.s	.notlf
		addq.b	#1,ypos
		bra	.restart
.notlf		cmp.b	#9,d1		;HORIZONTAL TAB
		bne.s	.notab		;routine added 11/2/92 for print speed
;calc TAB by getting MOD 8.
		moveq	#0,d5
		move.b	xpos,d5
		and.w	#%111,d5	;mod 8
		move.w	#8,d4
		sub.w	d5,d4		;sub MOD 8
		add.b	d4,xpos		;add to XPOS so now we are in correct word
		bra	.restart
.notab		sub.b	#32,d1
		mulu	#32,d1
		lea	font,a2
		add.w	d1,a2
		moveq	#0,d0
		move.b	ypos,d0
		mulu	#160*16,d0	;drop down 16 pixels...
		add.l	d0,a0
		add.l	d0,a3
		move.b	xpos,d0
		and.l	#$ff,d0
		lsl.l	#3,d0	;*8	;bytes across screen
		add.l	d0,a0
		add.l	d0,a3
		addq.b	#1,xpos
LINE_OFFSET	set	0
		rept	16
		move.w	(a2),LINE_OFFSET(a0)
		move.w	(a2)+,LINE_OFFSET(a3)
LINE_OFFSET	set	LINE_OFFSET+160
		endr
		rts
.do_clear	tst.w	do_clear_delay
		beq.s	.yeah
		sub.w	#1,do_clear_delay
		rts
.yeah		tst.w	lines_to_do
		beq	.stop
		sub.w	#1,lines_to_do
		move.l	present_base,a0
		move.l	last_base,a3
		add.l	clear_line_offset,a0
		add.l	clear_line_offset,a3
		moveq	#0,d0
OFF	set	0
		rept	40
		move.w	d0,OFF(a0)
		move.w	d0,OFF(a3)
OFF	set	OFF+8
		endr
		add.l	#160,clear_line_offset
		rts
.stop		clr.w	disc_clear_enable
		move.w	#1,disc_enable
		clr.l	clear_line_offset
		rts

sort_text	lea	middle_text,a0
		lea	disc_start_table,a1
		move.l	a0,(a1)+	;poke start of disc into lookup table
.loop		cmp.b	#$ff,(a0)	;is end of list???
		beq.s	.quit
		move.b	(a0)+,d0
		cmp.b	#'^',d0
		bne.s	.loop
		move.b	(a0)+,d0	;cr
		move.b	(a0)+,d0	;lf
		move.l	a0,(a1)+
		bra.s	.loop
.quit		rts













setup
		ifeq	DOWNLOAD
		clr.l	-(sp)			;Set super
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc

		move.b	#$12,$fffffc02.w	;no mouse

		move.l	$44e.w,old_base

		movem.l	$ffff8240.w,d0-d7	;save old pal
		movem.l	d0-d7,old_pal

		move.b	$ffff8260.w,old_rez	;save rez

; IF USING A PICTURE THEN UNREMARK THE FOLLOWING 2 LINES
;;		movem.l	pic+2,d0-d7		;set new pal
;;		movem.l	d0-d7,$ffff8240.w

		clr.w	$ffff8240.w
		move.w	#-1,$ffff8248.w	;stars

		clr.b	$ffff8260.w		;low rez

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,present_base
		move.l	d0,screen_1
		add.l	#49152,d0
		move.l	d0,screen_2

		move.l	screen_1,a0		;new screen base
		bsr	set_screen
		bsr	flip_screen

;; IF USING A PICTURE UNREMARK THE FOLLOWING 2 LINES
;;		lea	pic+34,a0
;;		move.l	screen_1,a1
;;		move.l	screen_2,a2
;;		move.w	#(160*60)/4-1,d0
;;.show		move.l	(a0),(a1)+
;;		move.l	(a0)+,(a2)+
;;		dbf	d0,.show
		
		lea	storage,a0		;store old MFP
		move.l	$120.w,(a0)+
		move.l	$118.w,(a0)+
		move.l	$70.w,(a0)+
		move.b	$fffffa11.w,(a0)+
		move.b	$fffffa21.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa0f.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa1d.w,(a0)+
		move.b	$fffffa25.w,(a0)+

		move.w	#$2700,sr
		clr.b	$fffffa1d.w
		andi.b	#$df,$fffffa09.w
		andi.b	#$fe,$fffffa07.w
		move.l	#border_timerb,$120.w
		move.l	#new70,$70.w
		move.l	#new118,$118.w
		ori.b	#1,$fffffa07.w
		ori.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w		;auto isr ena

		moveq	#1,d0
		jsr	music

		move.w	#$2300,sr
		rts





reset_isr	moveq	#0,d0
		jsr	music

		move.w	#$2700,sr
		lea	storage,a0		;store old MFP
		move.l	(a0)+,$120.w
		move.l	(a0)+,$118.w
		move.l	(a0)+,$70.w
		move.b	(a0)+,$fffffa11.w
		move.b	(a0)+,$fffffa21.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa0f.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa1d.w
		move.b	(a0)+,$fffffa25.w
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		move.w	#$2300,sr

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	old_base,a0
		bsr	set_screen

		move.b	old_rez,$ffff8260.w
		rts

;******* timerb code ****************************************************


timerb_part1	clr.b	$fffffa1b.w
		move.l	a0,-(sp)
		move.l	colour_pos,a0
		move.w	(a0)+,RASTER_COLOUR.w
		move.l	a0,colour_pos
		move.l	(sp)+,a0
		sub.w	#1,raster_counter
		beq.s	.setup_border_timerb
		move.b	#16,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte
.setup_border_timerb
		move.l	#border_timerb,$120.w
		move.b	#3,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte

border_timerb	or.w	#$700,sr
		clr.b	$fffffa1b.w
		movem.l	d0/a0,-(sp)
.wait		cmp.b	#$80,$ffff8209.w
		blo.s	.wait
		dbt	d0,*
		dbt	d0,*
		lea	.nops(pc),a0
		moveq	#0,d0
		move.b	$ffff8209.w,d0
		sub.b	#$80,d0
		add.w	d0,a0
		jmp	(a0)
.nops		REPT	88
		nop
		ENDR
		dbt	d0,*
		dbt	d0,*
		clr.b	$ffff820a.w
		nop
		movem.l	(sp)+,d0/a0
		move.b	#2,$ffff820a.w

		bclr	#4,$fffffa15.w	;Disable digi-drum

		rte

;********* new vbl ******************************************************
new70		move.w	#$2700,sr

; IF YOU USE A PICTURE + RASTERS YOU WILL HAVE TO PUT THE PICTURE COLOURS
; BACK SO UN-REMARK THE FOLLOWING 4 LINES AND REMOVE THE +26 FROM THE
; LINE	move.w #$57e+26.d0
;
;		movem.l	d0-d7,-(sp)
;		movem.l	pic+2,d0-d7
;		movem.l	d0-d7,$ffff8240.w
;		movem.l	(sp)+,d0-d7

		move.w	d0,-(sp)
		move.w	#$57e+26,d0
.aaa		dbf	d0,.aaa
		clr.b	$ffff820a.w
		moveq	#1,d0
.bbb		dbf	d0,.bbb
		move.b	#2,$ffff820a.w

		bset	#4,$fffffa15.w		;enable digi-drum

		move.w	colours,RASTER_COLOUR.w
		move.w	(sp)+,d0
		move.w	hertz_toggle,$ffff8240.w
		move.l	#old_stars,old_stars_pos
		move.l	#colours,colour_pos
		clr.w	vsync_flag
		clr.b	$fffffa1b.w
		move.w	#15,raster_counter
		move.l	#timerb_part1,$120.w
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		tst.w	disc_enable
		bne.s	.dec
		tst.w	hertz_delay
		beq.s	.no_hz_dec
		sub.w	#1,hertz_delay
.no_hz_dec	rte
.dec		sub.w	#1,disc_enable
		tst.w	hertz_delay
		beq.s	.no_hz_dec
		sub.w	#1,hertz_delay
		rte

new118		move.w	#$2500,sr
		move.b	$fffffc02.w,key
		bclr	#6,$fffffa11.w
		rte



***********************
* SUBROUTINES SECTION *
***********************
set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1		;back to user
		addq.l	#6,sp
		rts



vsync		move.w	#-1,vsync_flag	;custom routine to wait
.vs		tst.w	vsync_flag		;for screen refresh
		bne.s	.vs
		rts

flip_screen	;flip between 2 screens to stop flickering
		move.l	present_base,last_base
		move.l	screen_1,a0
		move.w	screen_number,d0
		beq	.1
		move.l	screen_2,a0
.1		move.l	a0,present_base
		eor.w	#-1,screen_number

set_screen	move.l	a0,d0
		lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		rts


		ifeq	DOWNLOAD
***************************
	SECTION DATA
***************************
		endc
colours		dc.w	$300,$400,$500,$600,$700,$702,$703,$704,$705,$706
		dc.w	$707,$607,$507,$407,$307

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


old_stars_pos	dc.l	old_stars

******************* isr details *******
key	dc.w	0

;;NO PICTURE IN THIS MENU BUT YOU CAN USE ONE BY UNREMARKING THE FOLLOWING LINE
;;pic	incbin	pic.pi1


; Music by Donald Fakk Of S.O.T.E.
music	incbin	"sote.mus"	


text_pos		dc.l	middle_text
middle_text		incbin	ascii.s
			dc.b	$ff
			even
font			incbin	oz_font.dat
			even


demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
;	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
;	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"cuddly.ro",0
	even
exec2	dc.b	"fuzion.189",0
	even
exec3	dc.b	"F_A_L_L.prg",0
	even
exec4	dc.b	"UNT.13",0
	even
exec5	dc.b	"NIRVANA.U",0
	even
exec6	dc.b	"copier.pov",0
	even
exec7	dc.b	"filename.ext",0
	even
exec8	dc.b	"filename.ext",0
	even


		ifeq	DOWNLOAD
****************************
	SECTION BSS
****************************
		endc

bss_start

disc_start_table	ds.l	50	;1 long word for each page
colour_pos		ds.l	1
present_base		ds.l	1
last_base		ds.l	1
screen_1		ds.l	1
screen_2		ds.l	1
stack_save		ds.l	1
old_base		ds.l	1
clear_line_offset	ds.l	1
old_pal			ds.w	16
vsync_flag		ds.w	1
lines_to_do		ds.w	1
do_clear_delay		ds.w	1
disc_clear_enable	ds.w	1
disc_enable		ds.w	1
screen_number		ds.w	1
hertz_toggle		ds.w	1
hertz_delay		ds.w	1
raster_counter		ds.w	1
storage			ds.b	22
old_rez			ds.b	1
xpos			ds.b	1
ypos			ds.b	1
		even
Y_PLOT			ds.w	200

old_stars		REPT	STARS
			ds.l	1
			ENDR
			ds.b	256
screens			ds.b	49152*2
bss_end

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
