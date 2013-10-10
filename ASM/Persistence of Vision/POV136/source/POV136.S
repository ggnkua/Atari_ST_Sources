*************************************************************************
*			PERSISTENCE OF VISION 136			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music by:								*
*									*
*									*
* Grafix by: 	OZYMANDIAS and Machine System Data			*
*									*
*************************************************************************
*
* STE tracker menu with VUs, rasters and Hardware scroll
* STFM chip tune, text printer, rasters, 3D starfield
*
* To whom it may concern:
*	This code took hours to complete so don't be a lamer and claim
*	you wrote it. Just because you can change the scrolltext does
*	not mean you can take the credit. My code is so obvious that
*	virtually ANY ST user will recognise it anyway. MSD 17/7/93
*

MVOL_STE	EQU	$80
FREQ_STE	EQU	2		; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)
	IFEQ FREQ_STE
PARTS_STE	EQU 5-1			; 6.259
LEN_STE	EQU 25
INC_STE	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ_STE-1
PARTS_STE	EQU 5-1			; 12.517
LEN_STE	EQU 50
INC_STE	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ_STE-2
PARTS_STE	EQU 5-1				; 25.035
LEN_STE	EQU 100
INC_STE	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ_STE-3
PARTS_STE	EQU 5-1				; 50.072
LEN_STE	EQU 200
INC_STE	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC


;***********************************************************************

TIMERB_LINE	equ	5	;make timerb trigger ever 5 horiz lines


YES=1
yes=YES
NO=0
no=NO


AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

FINAL=no	;YES to remove escape to assembler code
		;NO to keep it on


	opt	o+,w-


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

	jsr	startup

	tst.w	ste_flag
	bne.s	init_ste
	bra	stfm


init_ste	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		clr.b	$ffff8260.w		;go low rez
		move.l	#screens,d0
		clr.b	d0
		move.l	d0,screen_base
		move.l	d0,a0
		bsr	set_screen
		lea	pic+34,a0		;show pic
		move.l	screen_base,a1
		move.l	a1,a2
		add.l	#64000,a2
		move.w	#179*160/4-1,d0
.loop		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.loop
		lea	32000(a1),a1
		lea	32000(a2),a2
		move.w	#(200-179)*160/4-1,d0	;move '* POV WILL EAT' to bottom of 2nd screen
.loop2		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.loop2

		bsr	muson_ste
		jsr	set_new_palette
main_loop	bsr	vsync
;		move.w	#$123,$ffff8240.w
		bsr	move_screen
		bsr	do_vus
		bsr	scroll
;		clr.w	$ffff8240.w

	move.w	key,d0

	ifeq	FINAL
	cmp.w	#1,d0		;ESC
	beq	assem
	ENDC

	cmp.w	#11,d0		;0 keyboard
	beq	zero

	cmp.w	#$70,d0		;0 keypad
	beq	zero

	cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
	beq	reset

	cmp.w	#$62,d0		;HELP
	beq	toggle_vus

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


exit		bsr	musoff_ste
		jsr	set_old_palette
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		clr.b	$ffff8260.w
		move.l	old_base,a0
		jsr	set_screen
		jsr	set_user

		ifeq	AUTORUN4
		bra	exec

		ELSE
		clr.w	-(sp)
		trap	#1
		ENDC

		ifeq	FINAL
assem		bsr	musoff_ste
		jsr	set_old_palette
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		move.b	#1,$ffff8260.w
		move.l	old_base,a0
		jsr	set_screen
		jsr	set_user
		clr.w	-(sp)
		trap	#1
		ENDC


zero		tst.w	hertz_delay
		bne	main_loop
		eor.w	#$002,$ffff8240.w
		eor.w	#-1,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key fast repeat
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts

toggle_vus	tst.w	vucontrol_delay
		bne	main_loop
		eor.w	#-1,vucontrol
		move.w	#10,vucontrol_delay
		bra	main_loop


move_screen	move.w	screen_offsets,d0
		and.w	#511,d0
		lea	sine,a0
		add.w	d0,a0
		move.w	(a0),d0
		move.l	screen_base,a0
		add.w	d0,a0
		tst.l	screen_no
		beq.s	.okay
		add.l	#64000,a0
.okay		move.l	a0,hard_addr
		move.b	hard_addr+1,$ffff8205.w
		move.b	hard_addr+2,$ffff8207.w
		move.b	hard_addr+3,$ffff8209.w
		add.w	#2,screen_offsets
		eor.l	#64000,screen_no
		rts

;voice+16=instrument????
do_vus		move.l	screen_base,a0
		add.l	#32000+(160*176),a0
		add.l	screen_no,a0
		moveq	#0,d2
		moveq	#-1,d3

		lea	voice1,a1
		lea	vus+0,a3
		bsr	vu
		add.w	#(160*130)+40,a0

		lea	voice4,a1
		lea	vus+2,a3
		bsr	vu
		add.w	#(160*130)+48,a0

		lea	voice2,a1
		lea	vus+4,a3
		bsr	vu
		add.w	#(160*130)+40,a0

		lea	voice3,a1
		lea	vus+6,a3

vu		tst.w	vucontrol
		beq.s	.vu_on
		moveq	#0,d0
		bra.s	.lower


.vu_on		move.w	(a1),d0		;get chan data from tracker
		beq.s	.lower
		move.w	#62,(a3)
		bra.s	.over

.lower		tst.w	(a3)		;is last value bigger than ours?
		beq.s	.over		;no!

		subq.w	#2,(a3)		;decrease data

.over		move.w	(a3),d0
		and.w	#63,d0
		move.w	#63,d1
		sub.w	d0,d1
.loop		move.w	d3,(a0)	;fill in
		move.w	d3,8(a0)
		move.w	d3,16(a0)
		move.w	d3,24(a0)
		lea	-320(a0),a0
		dbf	d0,.loop
.clear		move.w	d2,(a0)		;clear above
		move.w	d2,8(a0)
		move.w	d2,16(a0)
		move.w	d2,24(a0)
		lea	-320(a0),a0
		dbf	d1,.clear
		rts


scroll	move.l	screen_base,a1
	add.w	#160*196,a1
	add.l	screen_no,a1
	lea	font_offsets,a2
	lea	font,a3
	move.l	line_ptr,a4
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
	mulu	#32*4,d0	;;font height * 4 planes
	add.w	d0,a0
	move.w	d6,d0
	mulu	#32,d0		;font height
	add.w	d0,a0

.column
OFF	set	0
	REPT	31
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR
	add.w	#1,a0

	subq.w	#1,d5
	beq.s	.finish

	add.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	add.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,line_ptr
	rts




new_kbd	movem.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$1d,d0
	bne.s	.k1
	bset	#2,key
.k1	cmp.b	#$9d,d0
	bne.s	.k2
	bclr	#2,key
.k2	cmp.b	#$38,d0
	bne.s	.k3
	bset	#3,key
.k3	cmp.b	#$b8,d0
	bne.s	.k4
	bclr	#3,key
.k4	move.b	d0,key+1
	bclr	#6,$fffffa11.w
	movem.l	(sp)+,d0
	rte

vsync	move.w	#-1,vsyncflag
.ss	tst.w	vsyncflag
	bne.s	.ss
	rts




************** STE TIMER B (RASTER ISR) **************
ste_timerb	move.w	#0,$ffff8242.w		;change colour ASAP to prevent flicker
rast_col	equ *-4				;this means PC-4
		clr.b	$fffffa1b.w		;stop timerb
		move.l	a0,-(sp)		;stash these
		move.l	d0,-(sp)		;regs
		move.w	rast_offset,d0		;get position in colour table
		and.w	#255,d0
		lea	raster_colours,a0
		add.w	d0,a0
		move.w	(a0),rast_col		;get colour
		add.w	#2,rast_offset
		move.l	(sp)+,d0		;put back these
		move.l	(sp)+,a0		;regs
		move.b	#TIMERB_LINE,$fffffa21.w	;make timerB occur every xx lines
		move.b	#8,$fffffa1b.w		;reenable timer B
		rte				;get outta here



muson_ste
	bsr	vol_ste			; Calculate volume tables
	bsr	incrcal_ste		; Calculate tonetables

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	lea	nomouse,a0
	jsr	send_2_ik

	move	#$2700,sr
	lea	store,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)

	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	$120.w,old_timerb
	move.l	$70.w,oldvbl
	move.l	$118.w,oldkbd
	move.l	#ste_timerb,$120.w
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#ste_timerb,$120.w
	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#TIMERB_LINE,$fffffa21.w	;timer B data
	move.b	#8,$fffffa1b.w		;ei timber B

	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w



;*****************************************************
;* Okay all you STE freaks here is the important bit...
;*
;* I've put loads of comments in to help you change the settings
;* The BASS and TREBLE bit has a FULL breakdown of what bits do what
;* so you have no excuse for not changing them.
;*
;* MAC SYS DATA 18/7/92
;*
;*****************************************************

		lea	setsam_dat(pc),a0
		move.w	#6-1,d0
mwwrite		move.w	#$07ff,$ffff8924.w	;MICROWIRE mask register
mwwrite2	cmp.w	#$07ff,$ffff8924.w	;wait for write state
		bne.s	mwwrite2
		move.w	(a0)+,$ffff8922.w	;MICROWIRE data register - make new values...
		dbf	d0,mwwrite
*------------------------------------------------------------------



		clr.b	$FFFFFA19.w		;stop timer A
		move.b	#1,$FFFFFA1F.w		;timer A data
		move.b	#8,$FFFFFA19.w		;start timer A

		move.l	$134.w,oldtima
		move.l	#stereo,$134.w

		move.b	#FREQ_STE,$FFFF8921.w	; Frequency

		lea	$ffff8907.w,a0

		move.l	#sample1_ste,d0
		move.b	d0,(a0)
		lsr.w	#8,d0
		move.l	d0,-5(a0)

		move.l	#sample1_ste+LEN_STE*2,d0
		move.b	d0,12(a0)
		lsr.w	#8,d0
		move.l	d0,7(a0)

		move.b	#3,$ffff8901.w		; Start DMA/repeat 4 ever

		move	#$2300,sr		; Start isr's
		rts


setsam_dat
;this is complex but I'll try to make it simple....
;
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;The VOLUME bit is already taken care of by the rest of the code
; but I've set it anyway... (MSD)
;
;Volume/Tone data values:
;
;Master Volume:      0 - 40 (0 = -80dB, 40 = 0dB)
;Left/Right Volume:  0 - 20 (0 = -80dB, 20 = 0dB)
;Treble/Bass:        0 - 12 (0 = -12dB, 6 = 0dB, 12 = +12dB)
;
;
;                     dd = always 10 cos that's the device output for GI tone chip
;                     ||xxx=master volume (%011 or can be left %101 or right %100)
;                     |||||yyyyyy=volume setting 000000 -80dB (sound off)
;                     |||||||||||                010100 -40dB
;                     |||||||||||                101???   0dB (??? doesn't matter but it don't seem to work if 000)
	dc.w	%0000010011101111		;master


;			   yyyyyy=volume setting 000000 -40dB
;			   ||||||                001010 -20dB
;			   ||||||                0101??   0dB (??? doesn't matter but it don't seem to work if 000)
	dc.w	%0000010101010111		;left
	dc.w	%0000010100010111		;right


;base + treble
;       zzzz
;	0000 -12 dB
;	0110   0 dB
;	1100 +12 dB
;                     xx = always 10 cos that's the device output for GI tone chip
;                     ||yyy = define BASS (001) or TREBLE (010)
;                     |||||@@=don't matter
;                     |||||||zzzz=+12,0,-12Db (see table above)
;                     |||||||||||
	dc.w	%0000010010001100	*treble  (+12 dB) 
	dc.w	%0000010001000110	*bass    (  0 dB)
	dc.w	%0000000000000010	*mixer	01=mix sound chip
					*       10=do not mix
					*       11=reserved


musoff_ste	move	#$2700,sr

		clr.b	$FFFFFA19.w		; Stop timer A
		clr.b	$FFFFFA1b.w		; Stop timer B

		move.l	oldtima,$134.w		; Restore everything
		move.l	old_timerb,$120.w
		move.l	oldkbd,$118.w
		move.l	oldvbl,$70.w
		lea	store,a0
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0),$fffffa13.w


		bclr	#5,$FFFFFA07.w
		bclr	#5,$FFFFFA13.w

		clr.b	$ffff8901.w		; Stop DMA

		lea	yesmouse,a0
		jsr	send_2_ik

		move	#$2300,sr
		rts


;--------------------------------------------------------- Volume table --
vol_ste		moveq	#64,d0
		lea	vtabend,a0

.ploop		move.w	#255,d1
.mloop		move.w	d1,d2
		ext.w	d2
		muls	d0,d2
		divs	#MVOL_STE,d2		; <---- Master volume
		move.b	d2,-(a0)
		dbra	d1,.mloop
		dbra	d0,.ploop
		rts

incrcal_ste	lea	stab,a0
		move.w	#$30,d1
		move.w	#$039F-$30,d0
		move.l	#INC_STE,d2

recalc_ste	swap	d2
		moveq	#0,d3
		move.w	d2,d3
		divu	d1,d3
		move.w	d3,d4
		swap	d4

		swap	d2
		move.w	d2,d3
		divu	d1,d3
		move.w	d3,d4
		move.l	d4,(a0)+

		addq.w	#1,d1
		dbra	d0,recalc_ste
		rts


;-------------------------------------------------------- DMA interrupt --
stereo		move	#$2500,sr
		bclr	#5,$FFFFFA0F.w
		movem.l	d0-a6,-(sp)

		move.l	samp1_ste(pc),d0
		move.l	samp2_ste(pc),samp1_ste
		move.l	d0,samp2_ste

		lea	$FFFF8907.w,a0

		move.l	samp1_ste(pc),d0
		move.b	d0,(a0)
		lsr.w	#8,d0
		move.l	d0,-5(a0)

		move.l	samp1_ste(pc),d0
		add.l	#LEN_STE*2,d0
		move.b	d0,12(a0)
		lsr.w	#8,d0
		move.l	d0,7(a0)

		subq.w	#1,count_ste
		bpl.s	.nomus

		move.w	#PARTS_STE,count_ste
		bsr	music

.nomus		lea	itab,a5
		lea	vtab,a3
		moveq	#0,d0
		moveq	#0,d4

v1_ste		movea.l	wiz2lc(pc),a0

		move.w	wiz2pos(pc),d0
		move.w	wiz2frc(pc),d1

		move.w	aud2per(pc),d7
		add.w	d7,d7
		add.w	d7,d7
		move.w	0(a5,d7.w),d2

		movea.w	2(a5,d7.w),a4

		move.w	aud2vol(pc),d7
		asl.w	#8,d7
		lea	0(a3,d7.w),a2

		movea.l	wiz3lc(pc),a1
		move.w	wiz3pos(pc),d4
		move.w	wiz3frc(pc),d5

		move.w	aud3per(pc),d7
		add.w	d7,d7
		add.w	d7,d7
		move.w	0(a5,d7.w),d6
		movea.w	2(a5,d7.w),a5

		move.w	aud3vol(pc),d7
		asl.w	#8,d7
		lea	0(a3,d7.w),a3

		movea.l	samp1_ste(pc),a6
		moveq	#0,d3

		REPT LEN_STE
		add.w	a4,d1
		addx.w	d2,d0
		add.w	a5,d5
		addx.w	d6,d4
		move.b	0(a0,d0.l),d3
		move.b	0(a2,d3.w),d7
		move.b	0(a1,d4.l),d3
		add.b	0(a3,d3.w),d7
		move.w	d7,(a6)+
		ENDR

		cmp.l	wiz2len(pc),d0
		blt.s	.ok2
		sub.w	wiz2rpt(pc),d0

.ok2		move.w	d0,wiz2pos
		move.w	d1,wiz2frc

		cmp.l	wiz3len(pc),d4
		blt.s	.ok3
		sub.w	wiz3rpt(pc),d4

.ok3		move.w	d4,wiz3pos
		move.w	d5,wiz3frc

		lea	itab,a5
		lea	vtab,a3
		moveq	#0,d0
		moveq	#0,d4

v2_ste		movea.l	wiz1lc(pc),a0

		move.w	wiz1pos(pc),d0
		move.w	wiz1frc(pc),d1

		move.w	aud1per(pc),d7
		add.w	d7,d7
		add.w	d7,d7
		move.w	0(a5,d7.w),d2
		movea.w	2(a5,d7.w),a4

		move.w	aud1vol(pc),d7
		asl.w	#8,d7
		lea	0(a3,d7.w),a2

		movea.l	wiz4lc(pc),a1

		move.w	wiz4pos(pc),d4
		move.w	wiz4frc(pc),d5

		move.w	aud4per(pc),d7
		add.w	d7,d7
		add.w	d7,d7
		move.w	0(a5,d7.w),d6
		movea.w	2(a5,d7.w),a5

		move.w	aud4vol(pc),d7
		asl.w	#8,d7
		lea	0(a3,d7.w),a3

		movea.l	samp1_ste(pc),a6
		moveq	#0,d3

		REPT LEN_STE
		add.w	a4,d1
		addx.w	d2,d0
		add.w	a5,d5
		addx.w	d6,d4
		move.b	0(a0,d0.l),d3
		move.b	0(a2,d3.w),d7
		move.b	0(a1,d4.l),d3
		add.b	0(a3,d3.w),d7
		move.b	d7,(a6)
		addq.w	#2,a6
		ENDR

		cmp.l	wiz1len(pc),d0
		blt.s	.ok1
		sub.w	wiz1rpt(pc),d0

.ok1		move.w	d0,wiz1pos
		move.w	d1,wiz1frc

		cmp.l	wiz4len(pc),d4
		blt.s	.ok4
		sub.w	wiz4rpt(pc),d4

.ok4		move.w	d4,wiz4pos
		move.w	d5,wiz4frc

		movem.l	(sp)+,d0-a6
		rte

;-------------------------------------------- Hardware-registers & data --
count_ste	DC.W PARTS_STE

wiz1lc	DC.L sample1_ste
wiz1len	DC.L 320
wiz1rpt	DC.W 320
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1_ste
wiz2len	DC.L 320
wiz2rpt	DC.W 320
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1_ste
wiz3len	DC.L 320
wiz3rpt	DC.W 320
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1_ste
wiz4len	DC.L 320
wiz4rpt	DC.W 320
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W	0
	DS.W	3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dmactrl	DC.W 0
dummy	DC.L 0

samp1_ste	DC.L sample1_ste
samp2_ste	DC.L sample2_ste

sample1_ste	DS.W LEN_STE
sample2_ste	DS.W LEN_STE


newvbl		clr.w	vsyncflag
		movem.l	d0/a0,-(sp)
		lea	raster_colours,a0
		move.w	vbl_rast_offset,d0
		and.w	#255,d0
		add.w	d0,a0
		move.w	(a0),rast_col
		move.w	(a0),$ffff8242.w
		movem.l	(sp)+,d0/a0
		add.w	#2,vbl_rast_offset
		move.w	vbl_rast_offset,rast_offset
		tst.w	hertz_delay
		bne.s	.dec_hertz
		tst.w	vucontrol_delay
		bne.s	.dec_vucontrol
		rte
.dec_vucontrol	sub.w	#1,vucontrol_delay
		rte
.dec_hertz	sub.w	#1,hertz_delay
		tst.w	vucontrol_delay
		bne.s	.dec_vucontrol
		rte


;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples,a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	mod_data,a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7
roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep


repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6


rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	move.w	#$700,$ffff8240.w
	illegal


;------------------------------------------------------ Main replayrout --
init	lea	mod_data,a0
	lea	$03B8(a0),a1

	moveq	#$7F,d0
	moveq	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music	lea	mod_data,a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2	move.w	$10(a4),d2
	bra.s	arp4

arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	mod_data+$043C,a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	moveq	#0,d3		;speed increase by MSD of POV

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	move.w	d3,wiz1pos	;;speed increase

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	move.w	d3,wiz2pos	;;speed increase

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	move.w	d3,wiz3pos	;;speed increase


wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	move.w	d3,wiz4pos	;;speed increase

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	mod_data+$03B6,d1
	bne.s	endr
	move.b	mod_data+$03B7,songpos
endr	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	3(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#2,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$F,d0
	mulu	d0,d2
	lsr.w	#6,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,6(a3)
	move.b	$1A(a4),d0
	lsr.w	#2,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#4,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W	6
counter	DC.W	0
songpos	DC.B	0
break	DC.B	0
pattpos	DC.W	0

dmacon		DC.W	0
samplestarts	DS.L	$1F

voice1	DS.W	10
	DC.W	1
	DS.W	3
voice2	DS.W	10
	DC.W	2
	DS.W	3
voice3	DS.W	10
	DC.W	4
	DS.W	3
voice4	DS.W	10
	DC.W	8
	DS.W	3


set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1		;back to user
		addq.l	#6,sp		;correct stack
		rts


set_new_palette	lea	pic+2,a0
		bra	set_pal
set_old_palette	lea	old_palette,a0
set_pal		lea	$ffff8240.w,a1
		REPT	8
		move.l 	(a0)+,(a1)+
		ENDR
		rts


set_screen	move.l	a0,d0
		lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		rts


startup		lea	bssstart,a0	;clear BSS 'cause most packers don't
		move.l	#bss_end-bssstart,d0
		lsr.w	#2,d0		;\2
.clear		clr.l	(a0)+
		sub.l	#1,d0
		bne.s	.clear

		clr.l	-(sp)		;Set super stack equal
		move.w	#$20,-(sp)	; to user stack before call
		trap	#1
		addq.l	#6,sp		;correct stack
		move.l	d0,stack_save	;save old supervisor stack value

********************************************************
		jsr	depack_module	;NPACKER 0.3
********************************************************


; Ste Test Routine - Sets 'ste_flg' true if the machine is STE and inits.
		move.w	sr,-(sp)
		move.w	#$2300,sr
		lea	$ffff8205.w,a5
		move.b	(a5),d7
		move.b	#'M',(a5)	;poke new value
		cmp.b	(a5),d7		;get value again, is it same?
		beq	.notSTE	;yes same so not ste
		move.b	d7,(a5)
		move.w	#-1,ste_flag
.notSTE		move.w	(sp)+,sr
		or.b	#%00000010,$ffff820a.w		;50Hz

		move.l	$44e.w,old_base
		move.b	$ffff8260.w,old_rez

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette

		rts






send_2_ik	move.l	a0,-(sp)
		move.w	#2-1,-(sp)
		move.w	#$19,-(sp)
		trap	#14
		addq.l	#8,sp
		rts





; #############################################################################
; depack routine for module packer
; In :
; a0 = Pointer on module

depack_module	lea	mod_data,a0
		bsr	analyse_module	; find sample start/end
		bsr	init_depack
		movea.l	sample_start(PC),A0	; packed sample
		move.l  sample_end(PC),D0
		sub.l   A0,D0			; unpacked length
		move.l	D0,-(A7)
		bsr	depack_sample        ; depack over source
		move.l	(A7)+,D0
                rts
; a0=module address
analyse_module	move.l	A0,-(A7)
		lea	$03b8(A0),A1
		moveq	#$7f,D0
		moveq	#0,D4
mt_loop		move.l	D4,D2
		subq.w	#1,D0
mt_lop2		move.b	(A1)+,D4
		cmp.b	D2,D4
		bgt.s	mt_loop
		dbra	D0,mt_lop2
		addq.b	#1,D2

		asl.l	#8,D2
		asl.l	#2,D2
		add.l	#$043c,D2
		move.l	D2,D1
		add.l	A0,D2
		movea.l	D2,A2
		move.l	A2,sample_start

		moveq	#$1e,D0
mt_lop3		moveq	#0,D4
		move.w	42(A0),D4
		add.l	D4,D4
		adda.l	D4,A2
		adda.l	#$1e,A0
		dbra	D0,mt_lop3
		move.l	A2,sample_end
		movea.l	(A7)+,A0
		rts

; a0=packed sample (also destination)
; d0=unpacked length
depack_sample	lea	depack_hi(PC),A2
		lea	depack_lo(PC),A3
		addq.l	#1,D0
		and.b	#-2,D0		;round length up
		move.l	D0,D7
		lsr.l	#1,D7		;sample length in words
		lea	0(A0,D0.l),A1	; destination end
		adda.l	D7,A0		; source end
		move.w	#128,D0		; last byte
		moveq	#0,D1		; clear temp
depack_loop	move.b	-(A0),D1	; get 2 distances
		add.b	0(A2,D1.w),D0
		move.b	D0,-(A1)
		add.b	0(A3,D1.w),D0
		move.b	D0,-(A1)
		subq.l	#1,D7
		bne.s	depack_loop
		rts

init_depack	lea	depack_lo(PC),A1
		move.w	#15,D7
init1		lea	power_bytes(PC),A0
		move.w  #15,D6
init2		move.b	(A0)+,(A1)+
		dbra	D6,init2
		dbra	D7,init1
		lea	power_bytes(PC),A0
		lea	depack_hi(PC),A1
		move.w	#15,D7
init3		move.w	#15,D6
		move.b	(A0)+,D0
init4		move.b	D0,(A1)+
		dbra	D6,init4
		dbra	D7,init3
		rts
power_bytes	DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64
sample_start	DC.L 0
sample_end	DC.L 0
depack_lo	DS.B 256
depack_hi:      DS.B 256

************** END OF DEPACKER **************************************









*************************************************************************
*									*
*			STFM PART OF POV 136				*
*			--------------------				*
*									*
*************************************************************************

RASTER_COLOUR	equ	$ffff8242	;colour coloured by rasters

DISPLAY_TIME	equ	200		;time text is held on screen
					;Increase this to allow user
					;to read text

STARS		equ	130		;number of stars to stick on screen
					;you can INCREASE this until it goes
					;into 2 frames if you want!

stfm		bsr	stfm_sort_text
		bsr	stfm_make_yp_tab	; make up a table of Y coordinates
		bsr	stfm_setup

stfm_main_loop	bsr	stfm_flip_screen
		bsr	stfm_vsync
;		move.w	#$123,$ffff8240.w
		bsr	stfm_clear_stars	;clear the star field
		bsr	stfm_starfield		; move, calculate and print starfield.
		bsr	stfm_print_text
		jsr	chip_music+8
;		move.w	stfm_pic+2,$ffff8240.w

		moveq	#0,d0
		move.b	stfm_key,d0

		cmp.b	#1,d0
		beq.s	stfm_stop

		bra	stfm_main_loop

stfm_stop	bsr	stfm_reset_isr

		move.b	#8,$fffffc02.w

		IFNE	FINAL
		bra	exec
		ENDC

		clr.w	-(sp)
		trap	#1



*-----------------------------------------------------------------------*
*				    3D STARFIELD PRINT			*
*-----------------------------------------------------------------------*

stfm_starfield

.move_stars			; this moves the stars around!
	lea	XRAND,a0	; get bank of random x-coords
	lea	YRAND,a1	;  "   "   "    "    y-coords
	lea	ZRAND,a2	;  "   "   "    "    z-coords
	move.w	xi,d0	; xi = X increment, in d0
	move.w	yi,d1	; yi = Y increment, in d1
	move.w	zi,d2	; zi = Z increment, in d2
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
	lea	stfm_y_plot,a5	; get list of y-coords on screen
	lea	.plot(pc),a6	; list of plot routs. (colours)
	lea	XRAND,a1	; get coords of stars
	lea	YRAND,a2
	lea	ZRAND,a3
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

.log	move.l	stfm_present_base,a4	;get present screen address
	lea	60*160(a4),a4
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
	movem.l	a4/a5,-(sp)	;bit for new clear stars routine by MAC SYS DATA
	move.l	stfm_old_stars_pos,a5
	sub.l	stfm_present_base,a4
	move.l	a4,(a5)+
	move.l	a5,stfm_old_stars_pos
	movem.l	(sp)+,a4/a5
**************

	jmp	(a0)

.end	dbra	d0,.loop
	bra.s	.control_stars

.P0	dbra	d0,.loop	; these routines plot pixels
	bra.s	.control_stars
.P2	or.w	d6,4(a4)	
	dbra	d0,.loop

*-------------------------------*

.control_stars		; this makes the stars change direction
	subq.w	#1,STARTIME
	bne.s	.ok

	move.l	stfm_star_time_table_pos,a0
	tst.w	(a0)
	bpl.s	.yes
	lea	stfm_star_time_table,a0
.yes	move.w	(a0)+,STARTIME
	move.l	a0,stfm_star_time_table_pos

	addq	#1,STARDIR
	and.w	#$1F,STARDIR
.ok	addq	#1,FRAME
	and.w	#7,FRAME
	bne.s	.n3	
	lea	DIR_TAB,a0
	move.w	STARDIR,d0
	mulu	#6,d0
	move.w	0(a0,d0),d1
	move.w	2(a0,d0),d2
	move.w	4(a0,d0),d3
	cmp.w	xi,d1
	beq.s	.n1
	bgt.s	.g1
	subq	#1,xi
	bra.s	.n1
.g1	addq	#1,xi
.n1	cmp.w	yi,d2
	beq.s	.n2
	bgt.s	.g2
	subq	#1,yi
	bra.s	.n2
.g2	addq	#1,yi
.n2	cmp.w	zi,d3
	beq.s	.n3
	bgt.s	.g3
	subq	#2,zi
	bra.s	.n3
.g3	addq	#2,zi
.n3	rts

.plot	dc.l	.P2,.P2,.P2,.P2,.P2,.P2,.P2,.P2,.P2,.P2	; list of colour
	dc.l	.P2,.P2,.P2,.P2,.P2,.P0			; plot routs.

*-------------------------------*

stfm_make_yp_tab	; make Y-POS > SCREEN conversion table
		lea	stfm_y_plot+400,a0
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
stfm_clear_stars
		lea	stfm_old_stars,a0
		moveq	#0,d0
		REPT	STARS
		move.l	stfm_last_base,d2
		lea	60*160(a2),a2
		move.l	(a0)+,a1
		move.l	d0,4(a1,d2.l)
		ENDR
		rts

stfm_print_text	tst.w	stfm_disc_clear_enable
		bne	.do_clear
		tst.w	stfm_disc_enable
		beq.s	.do_stuff
		rts
.do_stuff	move.l	stfm_text_pos,a1
		move.l	stfm_present_base,a0
		move.l	stfm_last_base,a3

		lea	60*160(a0),a0
		lea	60*160(a3),a3
.restart	moveq	#0,d1
		move.b	(a1)+,d1
		move.l	a1,stfm_text_pos
		cmp.b	#-1,d1
		bne.s	.no_reset
		move.l	#stfm_middle_text,a1
		bra.s	.restart
.no_reset	cmp.b	#"^",d1		;termintor
		bne.s	.do_text
		cmp.b	#13,(a1)
		bne.s	.notcr_here	;if CR is here then take for granted CR,LF
		add.l	#2,stfm_text_pos
.notcr_here	move.w	#-1,stfm_disc_clear_enable
		move.w	#-1,stfm_disc_enable
		move.w	#29*7,stfm_lines_to_do
		move.w	#DISPLAY_TIME,stfm_do_clear_delay
		clr.b	stfm_xpos
		clr.b	stfm_ypos
		clr.w	stfm_byte_offset
		rts
.do_text	cmp.b	#13,d1
		bne.s	.notcr
		clr.b	stfm_xpos
		clr.w	stfm_byte_offset
		bra	.restart
.notcr		cmp.b	#10,d1
		bne.s	.notlf
		addq.b	#1,stfm_ypos
		bra	.restart
.notlf		cmp.b	#9,d1		;HORIZONTAL TAB
		bne.s	.notab		;routine added 11/2/92 for print speed
;calc TAB by getting MOD 8 then testing for odd/even position and altering byte_offset.
		moveq	#0,d5
		move.b	stfm_xpos,d5
		and.b	#%111,d5	;mod 8
		move.b	#8,d4
		sub.b	d5,d4		;sub MOD 8
		add.b	d4,stfm_xpos	;add to XPOS so now we are in correct word
		clr.w	stfm_byte_offset
		bra	.restart
.notab		sub.w	#32,d1
		mulu	#7,d1	;each char is 7 bytes long
		lea	stfm_minifont,a2
		add.w	d1,a2

		moveq	#0,d0
		move.b	stfm_ypos,d0
		mulu	#160*7,d0	;drop down 7 pixels...
		add.w	d0,a0
		add.w	d0,a3
		move.b	stfm_xpos,d0
		and.w	#$ff,d0
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		add.w	d0,a0
		add.w	d0,a3
		addq.b	#1,stfm_xpos
		add.w	stfm_byte_offset,a0
		add.w	stfm_byte_offset,a3
		move.b	(a2),(a0)
		move.b	(a2)+,(a3)
		move.b	(a2),160(a0)
		move.b	(a2)+,160(a3)
		move.b	(a2),320(a0)
		move.b	(a2)+,320(a3)
		move.b	(a2),480(a0)
		move.b	(a2)+,480(a3)
		move.b	(a2),640(a0)
		move.b	(a2)+,640(a3)
		move.b	(a2),800(a0)
		move.b	(a2)+,800(a3)
		move.b	(a2),960(a0)
		move.b	(a2)+,960(a3)	;chars are 7 pixels high
		eor.w	#1,stfm_byte_offset
		rts

.do_clear	tst.w	stfm_do_clear_delay
		beq.s	.yeah
		sub.w	#1,stfm_do_clear_delay
		rts
.yeah		tst.w	stfm_lines_to_do
		beq	.stop
		sub.w	#1,stfm_lines_to_do

		move.l	stfm_present_base,a0
		move.l	stfm_last_base,a3
		lea	60*160(a0),a0
		lea	60*160(a3),a3
		add.w	stfm_clear_line_offset,a0
		add.w	stfm_clear_line_offset,a3
		moveq	#0,d0
OFF	set	0
		rept	40
		move.w	d0,OFF(a0)
		move.w	d0,OFF(a3)
OFF	set	OFF+8
		endr
		add.w	#160,stfm_clear_line_offset
		rts
.stop		clr.w	stfm_disc_clear_enable
		move.w	#1,stfm_disc_enable
		clr.w	stfm_clear_line_offset
		rts

stfm_sort_text	lea	stfm_middle_text,a0
		lea	stfm_disc_start_table,a1
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



stfm_setup	move.b	#$12,$fffffc02.w	;no mouse

		move.l	$44e.w,old_base

		movem.l	$ffff8240.w,d0-d7	;save old pal
		movem.l	d0-d7,old_palette

		move.b	$ffff8260.w,old_rez	;save rez

		movem.l	stfm_pic+2,d0-d7		;set new pal
		movem.l	d0-d7,$ffff8240.w

		clr.b	$ffff8260.w		;low rez

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,stfm_present_base
		move.l	d0,stfm_screen_1
		add.l	#49152,d0
		move.l	d0,stfm_screen_2

		move.l	stfm_screen_1,a0		;new screen base
		bsr	stfm_set_screen
		bsr	stfm_flip_screen

		lea	stfm_pic+34,a0
		move.l	stfm_screen_1,a1
		move.l	stfm_screen_2,a2
		move.w	#(160*60)/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show
		
		lea	stfm_storage,a0		;store old MFP
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

		moveq	#1,d0
		jsr	chip_music

		move.w	#$2700,sr
		clr.b	$fffffa1d.w
		andi.b	#$df,$fffffa09.w
		andi.b	#$fe,$fffffa07.w
		move.l	#border_timerb,$120.w
		move.l	#stfm_new70,$70.w
		move.l	#new118,$118.w
		ori.b	#1,$fffffa07.w
		ori.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w		;auto isr ena
		move.w	#$2300,sr
		rts





stfm_reset_isr	move.w	#$2700,sr
		lea	stfm_storage,a0		;store old MFP
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
		lea	$ffff8800.w,a0
		move.l	#$8080000,(a0)
		move.l	#$9090000,(a0)
		move.l	#$a0a0000,(a0)
		move.w	#$2300,sr

		movem.l	old_palette,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	old_base,a0
		bsr	stfm_set_screen

		move.b	old_rez,$ffff8260.w
		rts

;******* timerb code ****************************************************
stfm_timerb_part1
		clr.b	$fffffa1b.w
		cmp.w	#29,stfm_colour_count	;logo depth
		beq.s	.setup_border_timerb
		move.l	a0,-(sp)
		move.l	stfm_colour_pos,a0
		move.w	(a0)+,RASTER_COLOUR.w
		move.l	a0,stfm_colour_pos
		move.l	(sp)+,a0
		add.w	#1,stfm_colour_count
		move.b	#2,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte
.setup_border_timerb
		move.w	stfm_colours,RASTER_COLOUR.w
		move.b	#7,$fffffa21.w
		move.w	#23,stfm_raster_counter
		move.l	#stfm_raster_timerb,$120.w
		move.l	#stfm_colours+2,stfm_colour_pos
		move.b	#8,$fffffa1b.w
		rte

stfm_raster_timerb	move.l	a0,-(sp)
		move.l	stfm_colour_pos,a0
		move.w	(a0)+,RASTER_COLOUR.w
		move.l	a0,stfm_colour_pos
		move.l	(sp)+,a0
		sub.w	#1,stfm_raster_counter
		beq.s	.setup_border
		rte
.setup_border	clr.b	$fffffa1b.w
		move.b	#7,$fffffa21.w
		move.w	#23,stfm_raster_counter
		move.l	#go_border_timerb,$120.w
		move.l	#stfm_colours+2,stfm_colour_pos
		move.b	#8,$fffffa1b.w
		rte
go_border_timerb
		clr.b	$fffffa1b.w
		move.l	#border_timerb,$120.w
		move.b	#1,$fffffa21.w
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
		rte

;********* new vbl ******************************************************
stfm_new70	move.w	#$2700,sr
		movem.l	d0-d7,-(sp)
		movem.l	stfm_pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(sp)+,d0-d7
		move.w	d0,-(sp)
		move.w	#$57e,d0
.aaa		dbf	d0,.aaa
		clr.b	$ffff820a.w
		moveq	#1,d0
.bbb		dbf	d0,.bbb
		move.b	#2,$ffff820a.w
		move.w	stfm_colours,RASTER_COLOUR.w
		move.w	(sp)+,d0
		movem.l	d0-d7/a0-a6,-(sp)
		move.l	#stfm_old_stars,stfm_old_stars_pos
		move.l	#stfm_colours,stfm_colour_pos
		clr.w	stfm_colour_count
		clr.w	stfm_vsync_flag
		clr.b	$fffffa1b.w
		move.l	#stfm_timerb_part1,$120.w
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		movem.l	(sp)+,d0-d7/a0-a6
		tst.w	stfm_disc_enable
		bne.s	.dec
		rte
.dec		sub.w	#1,stfm_disc_enable
		rte

new118		move.w	#$2500,sr
		move.b	$fffffc02.w,stfm_key
		bclr	#6,$fffffa11.w
		rte



***********************
* SUBROUTINES SECTION *
***********************


stfm_vsync	move.w	#-1,stfm_vsync_flag	;custom routine to wait
.vs		tst.w	stfm_vsync_flag		;for screen refresh
		bne.s	.vs
		rts

stfm_flip_screen	;flip between 2 screens to stop flickering
		move.l	stfm_present_base,stfm_last_base
		move.l	stfm_screen_1,a0
		move.w	stfm_screen_number,d0
		beq	.1
		move.l	stfm_screen_2,a0
.1		move.l	a0,stfm_present_base
		eor.w	#-1,stfm_screen_number

stfm_set_screen	move.l	a0,d0
		lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		rts









*****************************
	SECTION DATA
*****************************

char_offset	dc.w	0
font		dcb.b	32*4,0
		incbin	"1plane.fnt"
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,00,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,00,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,48,49,50,00,00,00,01,02,03

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21

;        v  w  x  y  z  {  |  }  ~
 dc.b	22,23,24,25,26,44,41,45,00



mod_data	INCBIN	pakgallo.mod
mod_data_end
	ds.b	101014-(mod_data_end-mod_data)



	ds.b	2230*2		;calculated by WIZZ_WRK.PRG by Boris/POV
workspc	ds.w	1

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
;	dc.b	4, $06		;key 5
;	dc.b	5, $07		;key 6
;	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
;	dc.b	4, $6b		;keypad 5
;	dc.b	5, $6c		;keypad 6
;	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"turn_off.meg",0
	even
exec2	dc.b	"sinful.meg",0
	even
exec3	dc.b	"impact.512",0
	even
exec4	dc.b	"copier.pov",0
	even
exec5	dc.b	"filename.ext",0
	even
exec6	dc.b	"filename.ext",0
	even
exec7	dc.b	"filename.ext",0
	even
exec8	dc.b	"filename.ext",0
	even


pic	incbin	pic.pi1

nomouse		dc.b	$12,$1a
yesmouse	dc.b	$14,$08
line_ptr	dc.l	scroll_text

scroll_text
 dc.b "                 MAC SYS DATA WELCOMES YOU TO A SPECIAL "
 DC.B "PERSISTENCE OF VISION DISC, THIS TIME IT IS AN STE ONLY DISC.  YES "
 DC.B "ALL THE DEMOS ON THIS DISC ARE FOR THE STE ONLY. IF YOU TRY THIS "
 DC.B "DISC ON AN STFM YOU WILL NOT GET THIS EXCELLENT MENU BUT INSTEAD "
 DC.B "GET A 3D STARFIELD, TEXT PRINTER AND A NASTY CHIP TUNE.           "
 DC.B "HERE'S THE CREDITS:      "
 DC.B "MENU CODED BY MAC SYS DATA,   GRAFIX BY OZYMANDIAS,   THE MOD "
 DC.B "WAS RIPPED FROM SOME INTRO BUT I CAN'T REMEMBER WHICH ONE "
 DC.B "ANYWAY IT IS PLAYING AT 25MHZ.       "
 DC.B "RELEASE DATE 18TH JULY 1993.        "
 DC.B "I SHOULD BE RELEASING A COUPLE OF DISCS WITH RE-CYCLED MENUS ON AS "
 DC.B "MY HARD DISC IS STILL VERY FULL. I'LL TART THE MENUS UP SO YOU "
 DC.B "PROBABLY WON'T RECOGNISE THEM.      OZ HAS NOW FINISHED COLLEGE FOR "
 DC.B "THE SUMMER AND HAS BEEN BUSY ON HIS NEW APPLE MAC. HE HAS DRAWN SEVERAL "
 DC.B "NEW PICS INCLUDING A NEW LOGO, I SHALL USE ONE OF THE NEW PICTURES "
 DC.B "SOON BUT I STILL HAVE 130 PICTURE DATING BACK 3 YEARS TO USE!     "
 DC.B "            POV SENDS ITS GREETINGS TO:  "
 DC.B "   ADRENALIN,   ANIMAL MINE,   BLIND BASTARD,   "
 DC.B "CYNIX,   D-BUG,   DEL,   DELTA FORCE,   DR SYNE,   ERIK PLANKTON,   "
 DC.B "EQUINOX,   FUSION,   GEORGE (BART),   "
 DC.B "INNER CIRCLE,   MAD VISION,   MUG UK,   NEXT,   "
 DC.B "PAL PD,   PIXEL TWINS,   POMPEY PIRATES,   "
 DC.B "PURE ENERGY,   REPLICANTS,   RIPPED OFF   AND   "
 DC.B "THE SYNDICATE (CONTACT ME)!            "
 DC.B "TO CONTACT ANY MEMBER OF P.O.V. SIMPLY WRITE TO.......          "
 DC.B "P.O. BOX 40,              THORNTON-CLEVELEYS,              LANCASHIRE,              "
 DC.B "FY5 3PH,              ENGLAND.                GOT THAT?       "
 dc.b "                          GOTO WRAP IT HERE AS DISC SPACE IS SHORT... "
 DC.B "                       WRAP.             "
 dc.b $ff
	even



vbl_rast_offset	dc.w	0
rast_offset	dc.w	0
raster_colours	dc.w	$800,$100,$900,$200,$a00,$300,$b00,$400
		dc.w	$c00,$500,$d00,$600,$e00,$700,$f00,$f80
		dc.w	$f10,$f90,$f20,$fa0,$f30,$fb0,$f40,$fc0
		dc.w	$f50,$fd0,$f60,$fe0,$f70,$ff0,$7f0,$ef0
		dc.w	$6f0,$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0
		dc.w	$2f0,$9f0,$1f8,$8f1,$0f9,$0f2,$0fa,$0f3
		dc.w	$0fb,$0f4,$0fc,$0f5,$0fd,$0f6,$0fe,$0f7
		dc.w	$0ff,$07f,$0ef,$06f,$0df,$05f,$0cf,$04f
		dc.w	$0bf,$03f,$0af,$02f,$09f,$01f,$08f,$00f
		dc.w	$80f,$10f,$90f,$20f,$a0f,$30f,$b0f,$40f
		dc.w	$c0f,$50f,$d0f,$60f,$e0f,$70f,$f0f,$f07
		dc.w	$f0e,$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03
		dc.w	$f0a,$f02,$f09,$f01,$f08,$f00,$f88,$f11
		dc.w	$f99,$f22,$faa,$f33,$fbb,$f43,$fca,$f52
		dc.w	$fd9,$f61,$fe8,$770,$ee0,$660,$dd0,$550
		dc.w	$cc0,$440,$bb0,$330,$aa0,$220,$990,$110


sine		incbin	sine1.dat



*********************** STFM DATA PARTS *********************************
stfm_colours	dc.w	$300,$400,$500,$600,$700,$710,$720,$730,$740,$750,$760
		dc.w	$770,$671,$572,$473,$374,$275,$176,$077,$067,$057,$047
		dc.w	$037,$027,$017,$007,$006,$005,$004

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
stfm_star_time_table_pos	dc.l	stfm_star_time_table
stfm_star_time_table		dc.w	127,127,127,64,64,64,64,64,64,64,64,64,64
			dc.w	32,16,127,127,64,127,127,127
			dc.w	-1		;end of table
;-----------------------------------------------------------------


stfm_old_stars_pos	dc.l	stfm_old_stars

******************* isr details *******
stfm_key		dc.w	0

stfm_pic	incbin	stfm_pic.pi1
chip_music	incbin	dns_thk.mus

stfm_text_pos		dc.l	stfm_middle_text
stfm_middle_text	incbin	ascii.s
			dc.b	$ff
			even
stfm_minifont		incbin	6x6_font.dat	font.dat
			even


*************************************************************************





	SECTION BSS
bssstart

vus	ds.w	1		;last recorded level of VUs
	ds.w	1
	ds.w	1
	ds.w	1


end_of_samples	ds.l	1
oldtima		ds.l	1
hard_addr	ds.l	1
black		ds.b	32
old_timerb	ds.l	1
store		ds.l	1
vucontrol	ds.w	1
vucontrol_delay	ds.w	1
oldkbd		ds.l	1
key		ds.w	1
ste_flag	ds.w	1
hertz_delay	ds.w	1
hertz_toggle	ds.w	1
oldvbl		ds.l	1
old_palette	ds.w	16
stack_save	ds.l	1
screen_base	ds.l	1
old_base	ds.l	1
old_rez		ds.w	1
screen_offsets	ds.w	1
screen_no	ds.l	1
vsyncflag	ds.w	1

itab		DS.L	$30
stab		DS.L	$3A0-$30

vtab		DS.B	65*256
vtabend



*********************** STFM BSS PARTS **********************************
stfm_colour_pos		ds.l	1
stfm_colour_count	ds.w	1
stfm_raster_counter	ds.w	1
stfm_present_base	ds.l	1
stfm_last_base		ds.l	1
stfm_screen_1		ds.l	1
stfm_screen_2		ds.l	1
stfm_screen_number	ds.w	1
stfm_vsync_flag		ds.w	1
stfm_storage		ds.b	20
stfm_xpos		ds.b	1
stfm_ypos		ds.b	1
		even
stfm_byte_offset	ds.w	1
stfm_lines_to_do	ds.w	1
stfm_clear_line_offset	ds.w	1
stfm_do_clear_delay	ds.w	1
stfm_disc_clear_enable	ds.w	1
stfm_disc_enable	ds.w	1
stfm_disc_start_table	ds.l	30	;1 long word for each page
stfm_y_plot		ds.w		200
stfm_old_stars	REPT	STARS
		ds.l	1
		ENDR
*************************************************************************



		ds.b	256
screens		ds.b	32000
		ds.b	32000
		ds.b	32000
		ds.b	32000
bss_end
