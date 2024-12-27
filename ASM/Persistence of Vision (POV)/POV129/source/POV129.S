*************************************************************************
*			PERSISTENCE OF VISION 129			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music by:	BASS (AMIGA)						*
*									*
*									*
* Grafix by: 	BASS and Machine System Data				*
*									*
*			½ Persistence Of Vision 1993			*
*************************************************************************
*
* STE/STFM tracker menu
*
*	If you use this menu code then please credit me for my work
*	and don't claim you coded it - ta MSD 3/2/93.
*

* Protracker replay code, slightly optimised by MSD/POV
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
PARTS_STE	EQU 5-1			; 25.035
LEN_STE	EQU 100
INC_STE	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ_STE-3
PARTS_STE	EQU 5-1			; 50.072
LEN_STE	EQU 200
INC_STE	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC


;****** STFM BITS ***********
* Uses registers D5-D7/A6.
MVOL	EQU	$60			; >= $40 ($60 recommended)
FREQ	EQU	2			; 0=6.144, 1=8.192, 2=12.288
					; 3=16.384
	IFEQ FREQ
A_DATA	EQU 40				; 6.144
D_DATA	EQU 164
PARTS	EQU 3-1
LEN	EQU 41
INC	EQU $02469BC0			; 3579546/6144*65536
	ELSEIF
	IFEQ FREQ-1
A_DATA	EQU 30				; 8.192
D_DATA	EQU 123
PARTS	EQU 4-1
LEN	EQU 41
INC	EQU $01B4F4D0			; 3579546/8192*65536
	ELSEIF
	IFEQ FREQ-2
A_DATA	EQU 20				; 12.288
D_DATA	EQU 82
PARTS	EQU 6-1
LEN	EQU 41
INC	EQU $01234DE0			; 3579546/12288*65536
	ELSEIF
	IFEQ FREQ-3
A_DATA	EQU 15				; 16.384
D_DATA	EQU 123
PARTS	EQU 4-1
LEN	EQU 82
INC	EQU $00DA7A68			; 3579546/16384*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC
;***********************************************************************




YES=1
yes=YES
NO=0
no=NO


AUTORUN4=NO	;YES to use POV AUTORUN 4 (poke filename at $200 and exit)
		;NO to run program from here

FINAL=no	;YES to remove escape to assembler code
		;NO to keep it on


******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
DOWNLOAD	equ	no

	ifne	DOWNLOAD
	include	sttx1.s
	org	$1000

Code_Start
Exec_Addr
	ENDC
************************************************************************

B_DATA		equ	198
TBCR		equ	$fffffa1b	;TimerB Control Register
TBDR		equ	$fffffa21	;TimerB Data Register


	opt	o+,w-


	ifeq	DOWNLOAD
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
	endc

	jsr	clear_bss
	ifeq	DOWNLOAD
	jsr	set_super
	endc

	jsr	test_4_ste
	or.b	#%00000010,$ffff820a.w		;50Hz
	jsr	get_screen_base
	jsr	get_old_palette
	jsr	get_original_rez
	jsr	black_out
	move.l	screen_base,a0
	jsr	set_low_rez
	jsr	show_picture

	tst.w	ste_flag
	bne.s	init_ste
	bsr	muson_stfm			; Install music


	bra.s	main_loop
init_ste
	bsr	muson_ste

main_loop
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	colour_cycle
	bsr	scroll
	bsr	do_vus
;	clr.w	$ffff8240.w


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


exit	tst.w	ste_flag
	bne.s	.shut_down_ste
	bsr	musoff_stfm	; Restore system completely
	bra.s	.co
.shut_down_ste
	bsr	musoff_ste
.co	jsr	set_old_palette
	move.l	old_scr_base,a0
	jsr	set_org_rez

	ifeq	DOWNLOAD
	jsr	set_user
	endc

	ifne	DOWNLOAD
	move.l	4.w,-(sp)
	rts
	endc

	ifeq	DOWNLOAD
	ifeq	AUTORUN4
	bra	exec
	endc
	ELSE
	clr.w	-(sp)
	trap	#1
	ENDC

	ifeq	FINAL
assem	tst.w	ste_flag
	bne.s	.shut_down_ste
	bsr	musoff_stfm	; Restore system completely
	bra.s	.co
.shut_down_ste
	bsr	musoff_ste
.co	jsr	set_old_palette
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	old_scr_base,a0
	jsr	set_med_rez
	jsr	set_user
	clr.w	-(sp)
	trap	#1
	ENDC


zero	;flip hertz indicator...
	tst.w	hertz_delay
	bne	main_loop
	eor.w	#$002,pic+2
	eor.w	#-1,hertz_toggle
	move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
	bra	main_loop


reset	move.l	4.w,-(sp)
	rts





colour_cycle	move.w	colour_no,d0
		bpl.s	.ok
		move.w	#colours_end-colours-28,d0
		move.w	d0,colour_no
.ok		lea	colours,a0
		movem.l	0(a0,d0.w),d1/d2/d3/d4
		movem.l	d1/d2/d3/d4,$ffff8244.w
		movem.l	$10(a0,d0.w),d1/d2/d3
		movem.l	d1/d2/d3,$ffff8244+$10.w
		sub.w	#2,colour_no
		rts


*********** SCROLLER **********************
*
* NOTE: I used some old code dating back to POV 1 which uses ROXL
*	the next version will probably have a new 4 bit scroller.
*
*******************************************
DEPTH		EQU	16
WIDTH		EQU	16
BUFFER_SIZE	EQU	DEPTH*(WIDTH*2)

scroll	bsr	.here	;yes a shit scroll rout so I do it 3 times
	bsr	.here
.here	move.l	line_ptr,a5
	tst.b	(a5)
	bpl	loop3
	lea	scroll_text,a5	;restart message
	move.l	a5,line_ptr
loop3	tst.w	scroll_number
	bne	loop2
	move.w	#WIDTH,scroll_number
	moveq	#0,d0
	move.b	(a5)+,d0
	move.l	a5,line_ptr
	sub.w	#32,d0
	mulu	#(DEPTH*2),d0
	lea	font,a5
	add.l	d0,a5	;letter address is in a5
;transfer letter into buffer
	lea	sbuffer,a1
	REPT	DEPTH
	move.w	(a5)+,(a1)+
	ENDR

loop2	move.l	screen_base,a5
	add.l	#160*209+4,a5
	move.l	a5,a2
	add.w	#152,a2

	lea	sbuffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#(DEPTH-1),d1
aloop	roxl.w	(a1)+			;shift buffer
	move.w	sr,d0			;get the status register
	and.w	#1,d0			;mask off all but carry flag
	or.w	d0,(a2)			;poke right pixel to screen
	lea	160(a2),a2		;down a line on screen
	dbf	d1,aloop


	move.w	#(DEPTH)-1,d0
loopy	and.w	#%1111111111101111,SR		;clear X flag
	roxl.w	152(a5)
	roxl.w	144(a5)
	roxl.w	136(a5)
	roxl.w	128(a5)
	roxl.w	120(a5)
	roxl.w	112(a5)
	roxl.w	104(a5)
	roxl.w	96(a5)
	roxl.w	88(a5)
	roxl.w	80(a5)
	roxl.w	72(a5)
	roxl.w	64(a5)
	roxl.w	56(a5)
	roxl.w	48(a5)
	roxl.w	40(a5)
	roxl.w	32(a5)
	roxl.w	24(a5)
	roxl.w	16(a5)
	roxl.w	8(a5)
	roxl.w	(a5)
	lea	160(a5),a5
	dbf	d0,loopy
	sub.w	#1,scroll_number
	rts



do_vus	move.l	screen_base,a0
	add.l	#(160*231),a0
	move.l	a0,a4
	moveq	#0,d2
	moveq	#-1,d3

	lea	voice1,a1
	lea	vus+0,a3
	bsr	vu
	lea	40(a4),a0

	lea	voice4,a1
	lea	vus+2,a3
	bsr	vu
	lea	48+40(a4),a0

	lea	voice2,a1
	lea	vus+4,a3
	bsr	vu
	lea	40+48+40(a4),a0

	lea	voice3,a1
	lea	vus+6,a3

vu	move.w	(a1),d0		;get chan data from tracker
	beq.s	.lower		;if no sample has been played this is 0 so
				;value is not higher than last

	move.w	#30,(a3)	;a sample has been played so make vu hit top
	bra.s	.over		;max value of vu then skip smaller check

.lower	tst.w	(a3)		;is value 0?
	beq.s	.over		;yes so don't decrease are vu height value

	subq.w	#2,(a3)		;decrease vu height

.over	move.w	(a3),d0		;get vu height
	and.w	#31,d0		;mask off so max 32 lines high
	move.w	#30,d1
	sub.w	d0,d1
	tst.w	d0		;if fill value is 0 then skip to clear rout
	ble.s	.clear
.loop	move.w	d3,(a0)	;fill in
	move.w	d3,8(a0)
	move.w	d3,16(a0)
	move.w	d3,24(a0)
	lea	-160(a0),a0
	sub.w	#1,d0
	bne.s	.loop
.clear	move.w	d2,(a0)		;clear above vu level (wipes old vu grafix)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	move.w	d2,24(a0)
	lea	-160(a0),a0
	dbra	d1,.clear
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

	clr.b	TBCR.w		;stop timerb
	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	$70.w,oldvbl
	move.l	$118.w,oldkbd
	move.l	$120.w,old_timerb
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#timerb_ste,$120.w
	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#B_DATA,TBDR.w	;timer B data
	move.b	#8,TBCR.w		;ei timber B

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


musoff_ste	bsr	vsync
		move	#$2700,sr

		clr.b	$FFFFFA19.w	; Stop timer A
		clr.b	$FFFFFA1F.w	; timer A data
		clr.b	TBCR.w		; Stop timer B

		move.l	oldvbl,$70.w
		move.l	oldkbd,$118.w
		move.l	old_timerb,$120.w
		lea	store,a0
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0),$fffffa13.w

		move.l	oldtima,$134.w	; Restore everything

		clr.b	$FFFF8901.w		; Stop DMA
		bset	#3,$fffffa17.w
		lea	yesmouse,a0
		jsr	send_2_ik

		move	#$2300,sr
		rts


;--------------------------------------------------------- Volume table --
vol_ste	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL_STE,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop
	rts

vtab	DS.B 65*256
vtabend

incrcal_ste
	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC_STE,d2

recalc_ste
	swap	d2
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
stereo	move	#$2500,sr
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

.nomus	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v1_ste	movea.l	wiz2lc(pc),a0

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

.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc

	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v2_ste	movea.l	wiz1lc(pc),a0

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

.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4	move.w	d4,wiz4pos
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

;---------------------------------------------------- Interrupts on/off --
muson_stfm
	lea	nomouse,a0
	jsr	send_2_ik

	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables
	bsr	clearym			; Clear soundchip registers

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp

	move	#$2700,sr

	lea	store,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)
	move.l	$fffffa06.w,s06		; Save MFP registers
	move.l	$fffffa12.w,s12
	move.b	$fffffa1d.w,s1d

	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	$120.w,old_timerb
	move.l	$118.w,oldkbd
	move.l	$70.w,oldvbl
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#timerb_stfm,$120.w
	bclr	#3,$fffffa17.w		; Autovectors

	move.b	#$21,$fffffa07.w	0 0 1 0 0 0 0 1
				;           |         +---- Timer B $120 ena
				;           +-------------- Timer A $134
	move.b	#%01010000,$fffffa09.w	0 1 0 1 0 0 0 0
				;         |   +------------ $110 ena
				;         +---------------- MC6850 $118 ena
	move.b	#%01010000,$fffffa15.w	0 1 0 1 0 0 0 0
				;         |   +------------ $110 mask
				;         +---------------- MC6850 $118 mask
	move.b	#$21,$fffffa13.w	0 0 1 0 0 0 0 1
				;           |         +---- Timer B $120 mask
				;           +-------------- Timer A $134 mask

	clr.b	$fffffa1d.w		;stop timer C & D
	clr.b	$fffffa19.w		;stop timer A
	clr.b	TBCR.w			;stop timer B
	move.b	#A_DATA,$FFFFFA1F.w	;set timer A data
	move.b	#B_DATA,TBDR.w	;timer B data
	move.b	#D_DATA,$FFFFFA25.w	;set timer D data
	move.b	#8,TBCR.w		;ei timber B

	move.b	#2,$FFFFFA19.w		;start timer A
	move.b	#6,$FFFFFA1D.w		;timer C & D control

	move.l	$110.w,oldtimd
	move.l	$134.w,oldtima
	move.l	#timerd,$110.w
	move.l	#playvec,$134.w

	lea	sample1(pc),a6
	move	#$2300,sr
	rts

newvbl		move.w	pic+4,$ffff8242.w
		clr.w	vsyncflag
		move.l	pic+2,$ffff8240.w
		clr.b	TBCR.w
		move.b	#B_DATA,TBDR.w	;set init timerb data
		move.b	#8,TBCR.w		;ei timer b
		tst.w	hertz_delay
		bne.s	.dec_hertz
		rte
.dec_hertz	sub.w	#1,hertz_delay
		rte

timerb_stfm	clr.b	TBCR.w		;DI all other interrupts
		move.b	#1,TBDR.w
		move.l	#border_stfm,$120.w

		clr.b	$fffffa1d.w		;stop timer C & D
		clr.b	$fffffa19.w		;stop timer A

		move.b	#8,TBCR.w
		rte

border_stfm		clr.b	TBCR.w
		REPT 60				;wait for 1/2 a screen width
		nop
		ENDR
.loop		tst.b	$ffff8209.w		;check low video pos
		bne.s	.loop
		clr.b	$ffff820a.w		;60Hz
		REPT	22
		nop
		ENDR
		MOVE.B	#2,$FFFF820A.W
		move.b	#2,$FFFFFA19.w		;start timer A
		move.b	#6,$FFFFFA1D.w		;timer C & D control
		move.w	#$0004,$ffff8242.w
		move.l	#$0fff0fff,$ffff8248.w
		rte

timerb_ste	clr.b	TBCR.w		;DI all other interrupts
		move.b	#1,TBDR.w
		move.l	#border_ste,$120.w
		move.b	#8,TBCR.w
		rte

border_ste	clr.b	TBCR.w
		REPT 60				;wait for 1/2 a screen width
		nop
		ENDR
.loop		tst.b	$ffff8209.w		;check low video pos
		bne.s	.loop
		clr.b	$ffff820a.w		;60Hz
		REPT	22
		nop
		ENDR
		MOVE.B	#2,$FFFF820A.W
		move.w	#$0004,$ffff8242.w
		move.l	#$0fff0fff,$ffff8248.w
		rte


musoff_stfm	move	#$2700,sr
		move.l	oldkbd,$118.w
		move.l	oldvbl,$70.w
		move.l	oldtimd,$110.w	; Restore vectors
		move.l	old_timerb,$120.w
		move.l	oldtima,$134.w

		move.l	s06,$FFFFFA06.w
		move.l	s12,$FFFFFA12.w
		move.b	s1d,$FFFFFA1D.w

		bset	#3,$FFFFFA17.w		; Softvectors

		lea	yesmouse,a0
		jsr	send_2_ik

		move	#$2300,sr
		rts



;-------------------------------------------- Clear soundchip registers --
clearym	move	#$2700,sr

	moveq	#$0A,d0
._1	move.b	d0,$FFFF8800.w
	clr.b	$FFFF8802.w
	dbra	d0,._1			; Clear soundchip registers
	clr.b	$FFFF8800.w
	clr.b	$FFFF8802.w
	move.b	#7,$FFFF8800.w
	move.b	#$FF,$FFFF8802.w

	rts

;----------------------------------------------- Calculate volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	add.b	#$80,d2
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop
	rts



;-------------------------------------------- Calculate increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
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
	dbra	d0,recalc
	rts

itab	DS.L	$30
stab	DS.L	$3A0-$30

;---------------------------------------------------- Samplecalculating --
timerd	;move.w	#$070,$ffff8240.w
	movea.l	samp1(pc),a6

	move	#$2300,sr
	movem.l	d0-d4/a0-a4,-(sp)

	subq.w	#1,count
	bpl.s	.nomus

	move.w	#PARTS,count
	bsr	music

.nomus	move.l	samp2(pc),d0
	move.l	samp1(pc),samp2
	move.l	d0,samp1

	lea	itab(pc),a2
	lea	vtab(pc),a4
	moveq	#0,d1

v1	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d1
	move.w	wiz1frc(pc),d0

	move.w	aud1per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud1vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	REPT LEN
	add.w	d2,d0
	addx.w	d3,d1
	move.b	0(a0,d1.l),d4
	move.b	0(a1,d4.w),d4
	move.w	d4,(a3)+
	ENDR

	cmp.l	wiz1len(pc),d1
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d1

.ok1	move.w	d1,wiz1pos
	move.w	d0,wiz1frc


v2	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d1
	move.w	wiz2frc(pc),d0

	move.w	aud2per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud2vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr	v234

	cmp.l	wiz2len(pc),d1
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d1

.ok2	move.w	d1,wiz2pos
	move.w	d0,wiz2frc


v3	movea.l	wiz3lc(pc),a0

	move.w	wiz3pos(pc),d1
	move.w	wiz3frc(pc),d0

	move.w	aud3per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud3vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr.s	v234

	cmp.l	wiz3len(pc),d1
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d1

.ok3	move.w	d1,wiz3pos
	move.w	d0,wiz3frc


v4	movea.l	wiz4lc(pc),a0

	move.w	wiz4pos(pc),d1
	move.w	wiz4frc(pc),d0

	move.w	aud4per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud4vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr.s	v234

	cmp.l	wiz4len(pc),d1
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d1

.ok4	move.w	d1,wiz4pos
	move.w	d0,wiz4frc

	movem.l	(sp)+,d0-d4/a0-a4
	rte

v234	REPT LEN
	add.w	d2,d0
	addx.w	d3,d1
	move.b	0(a0,d1.l),d4
	move.b	0(a1,d4.w),d4
	add.w	d4,(a3)+
	ENDR

	rts

;-------------------------------------------- Hardware-registers & data --
count	DC.W PARTS

samp1	DC.L sample1
samp2	DC.L sample2

sample1	REPT	LEN
	DC.W	$200
	ENDR

sample2	REPT	LEN
	DC.W	$200
	ENDR

;--------------------------------------------------- Playback-interrupt --
playvec	move.w	(a6)+,d7
	lsl.w	#4,d7
	movem.l	snd_tab(pc,d7.w),d5-d7
	movem.l	d5-d7,$FFFF8800.w
	rte

;--------------------------------------------- Sound data for soundchip --
snd_tab	REPT 384
	DC.L $08000F00,$09000A00,$0A000000,0
	ENDR

	DC.L $08000F00,$09000A00,$0A000000,0
	DC.L $08000F00,$09000A00,$0A000000,0
	DC.L $08000F00,$09000900,$0A000900,0
	DC.L $08000F00,$09000900,$0A000900,0
	DC.L $08000F00,$09000900,$0A000800,0
	DC.L $08000F00,$09000900,$0A000800,0
	DC.L $08000F00,$09000800,$0A000700,0
	DC.L $08000F00,$09000800,$0A000700,0
	DC.L $08000E00,$09000B00,$0A000D00,0
	DC.L $08000E00,$09000B00,$0A000D00,0
	DC.L $08000E00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000A00,$0A000D00,0
	DC.L $08000E00,$09000A00,$0A000D00,0
	DC.L $08000E00,$09000C00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000C00,0
	DC.L $08000E00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000D00,$0A000800,0
	DC.L $08000E00,$09000D00,$0A000800,0
	DC.L $08000E00,$09000D00,$0A000700,0
	DC.L $08000E00,$09000D00,$0A000700,0
	DC.L $08000E00,$09000D00,$0A000000,0
	DC.L $08000E00,$09000D00,$0A000000,0
	DC.L $08000B00,$09000E00,$0A000C00,0
	DC.L $08000B00,$09000E00,$0A000C00,0
	DC.L $08000E00,$09000B00,$0A000C00,0
	DC.L $08000E00,$09000B00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000B00,0
	DC.L $08000E00,$09000C00,$0A000B00,0
	DC.L $08000A00,$09000E00,$0A000C00,0
	DC.L $08000A00,$09000E00,$0A000C00,0
	DC.L $08000E00,$09000A00,$0A000C00,0
	DC.L $08000E00,$09000A00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000A00,0
	DC.L $08000E00,$09000C00,$0A000A00,0
	DC.L $08000E00,$09000900,$0A000C00,0
	DC.L $08000E00,$09000900,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000900,0
	DC.L $08000E00,$09000C00,$0A000900,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000700,0
	DC.L $08000E00,$09000C00,$0A000700,0
	DC.L $08000E00,$09000C00,$0A000600,0
	DC.L $08000E00,$09000C00,$0A000300,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000B00,$0A000A00,0
	DC.L $08000E00,$09000B00,$0A000A00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000D00,$0A000A00,0
	DC.L $08000D00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000D00,$09000D00,$0A000900,0
	DC.L $08000D00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000A00,$0A000900,0
	DC.L $08000E00,$09000A00,$0A000900,0
	DC.L $08000D00,$09000D00,$0A000800,0
	DC.L $08000D00,$09000D00,$0A000700,0
	DC.L $08000D00,$09000D00,$0A000600,0
	DC.L $08000D00,$09000D00,$0A000600,0
	DC.L $08000E00,$09000900,$0A000900,0
	DC.L $08000E00,$09000900,$0A000900,0
	DC.L $08000E00,$09000800,$0A000900,0
	DC.L $08000E00,$09000800,$0A000900,0
	DC.L $08000E00,$09000900,$0A000800,0
	DC.L $08000E00,$09000900,$0A000800,0
	DC.L $08000E00,$09000700,$0A000900,0
	DC.L $08000E00,$09000900,$0A000700,0
	DC.L $08000E00,$09000900,$0A000700,0
	DC.L $08000E00,$09000900,$0A000600,0
	DC.L $08000E00,$09000900,$0A000600,0
	DC.L $08000E00,$09000800,$0A000700,0
	DC.L $08000E00,$09000800,$0A000700,0
	DC.L $08000E00,$09000800,$0A000600,0
	DC.L $08000E00,$09000800,$0A000600,0
	DC.L $08000E00,$09000800,$0A000400,0
	DC.L $08000E00,$09000800,$0A000400,0
	DC.L $08000E00,$09000700,$0A000500,0
	DC.L $08000E00,$09000700,$0A000400,0
	DC.L $08000E00,$09000700,$0A000300,0
	DC.L $08000E00,$09000600,$0A000400,0
	DC.L $08000E00,$09000600,$0A000300,0
	DC.L $08000E00,$09000500,$0A000400,0
	DC.L $08000E00,$09000500,$0A000200,0
	DC.L $08000E00,$09000400,$0A000200,0
	DC.L $08000E00,$09000300,$0A000200,0
	DC.L $08000E00,$09000000,$0A000000,0
	DC.L $08000D00,$09000B00,$0A000A00,0
	DC.L $08000D00,$09000B00,$0A000A00,0
	DC.L $08000A00,$09000C00,$0A000C00,0
	DC.L $08000A00,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000A00,$0A000C00,0
	DC.L $08000D00,$09000900,$0A000B00,0
	DC.L $08000D00,$09000900,$0A000B00,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000A00,$0A000A00,0
	DC.L $08000D00,$09000A00,$0A000A00,0
	DC.L $08000900,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000800,$09000C00,$0A000C00,0
	DC.L $08000800,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000C00,$0A000800,0
	DC.L $08000C00,$09000C00,$0A000800,0
	DC.L $08000D00,$09000B00,$0A000400,0
	DC.L $08000D00,$09000B00,$0A000400,0
	DC.L $08000C00,$09000C00,$0A000700,0
	DC.L $08000C00,$09000C00,$0A000600,0
	DC.L $08000C00,$09000C00,$0A000600,0
	DC.L $08000C00,$09000C00,$0A000500,0
	DC.L $08000D00,$09000A00,$0A000700,0
	DC.L $08000D00,$09000A00,$0A000600,0
	DC.L $08000D00,$09000A00,$0A000600,0
	DC.L $08000D00,$09000A00,$0A000500,0
	DC.L $08000D00,$09000900,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000900,0
	DC.L $08000B00,$09000B00,$0A000B00,0
	DC.L $08000D00,$09000800,$0A000800,0
	DC.L $08000D00,$09000800,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000800,0
	DC.L $08000D00,$09000900,$0A000500,0
	DC.L $08000D00,$09000900,$0A000400,0
	DC.L $08000D00,$09000800,$0A000600,0
	DC.L $08000C00,$09000B00,$0A000700,0
	DC.L $08000D00,$09000700,$0A000700,0
	DC.L $08000C00,$09000B00,$0A000600,0
	DC.L $08000B00,$09000B00,$0A000A00,0
	DC.L $08000800,$09000A00,$0A000C00,0
	DC.L $08000C00,$09000B00,$0A000200,0
	DC.L $08000C00,$09000A00,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000000,0
	DC.L $08000D00,$09000600,$0A000400,0
	DC.L $08000D00,$09000500,$0A000500,0
	DC.L $08000C00,$09000900,$0A000900,0
	DC.L $08000D00,$09000500,$0A000400,0
	DC.L $08000B00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000400,$0A000300,0
	DC.L $08000B00,$09000A00,$0A000A00,0
	DC.L $08000C00,$09000A00,$0A000500,0
	DC.L $08000C00,$09000900,$0A000800,0
	DC.L $08000B00,$09000B00,$0A000800,0
	DC.L $08000C00,$09000A00,$0A000000,0
	DC.L $08000C00,$09000A00,$0A000000,0
	DC.L $08000C00,$09000900,$0A000700,0
	DC.L $08000B00,$09000B00,$0A000700,0
	DC.L $08000C00,$09000900,$0A000600,0
	DC.L $08000B00,$09000A00,$0A000900,0
	DC.L $08000B00,$09000B00,$0A000600,0
	DC.L $08000A00,$09000A00,$0A000A00,0
	DC.L $08000B00,$09000B00,$0A000500,0
	DC.L $08000B00,$09000A00,$0A000800,0
	DC.L $08000B00,$09000B00,$0A000200,0
	DC.L $08000C00,$09000700,$0A000700,0
	DC.L $08000C00,$09000800,$0A000400,0
	DC.L $08000C00,$09000700,$0A000600,0
	DC.L $08000B00,$09000900,$0A000900,0
	DC.L $08000A00,$09000A00,$0A000900,0
	DC.L $08000C00,$09000600,$0A000600,0
	DC.L $08000C00,$09000700,$0A000300,0
	DC.L $08000B00,$09000A00,$0A000500,0
	DC.L $08000B00,$09000900,$0A000800,0
	DC.L $08000B00,$09000A00,$0A000300,0
	DC.L $08000A00,$09000A00,$0A000800,0
	DC.L $08000B00,$09000A00,$0A000000,0
	DC.L $08000B00,$09000900,$0A000700,0
	DC.L $08000B00,$09000800,$0A000800,0
	DC.L $08000A00,$09000900,$0A000900,0
	DC.L $08000A00,$09000A00,$0A000700,0
	DC.L $08000C00,$09000100,$0A000100,0
	DC.L $08000A00,$09000A00,$0A000600,0
	DC.L $08000B00,$09000800,$0A000700,0
	DC.L $08000A00,$09000A00,$0A000500,0
	DC.L $08000A00,$09000900,$0A000800,0
	DC.L $08000A00,$09000A00,$0A000400,0
	DC.L $08000A00,$09000A00,$0A000300,0
	DC.L $08000A00,$09000A00,$0A000200,0
	DC.L $08000900,$09000900,$0A000900,0
	DC.L $08000A00,$09000800,$0A000800,0
	DC.L $08000B00,$09000800,$0A000100,0
	DC.L $08000A00,$09000900,$0A000600,0
	DC.L $08000B00,$09000700,$0A000400,0
	DC.L $08000A00,$09000900,$0A000500,0
	DC.L $08000900,$09000900,$0A000800,0
	DC.L $08000A00,$09000900,$0A000300,0
	DC.L $08000A00,$09000800,$0A000600,0
	DC.L $08000900,$09000900,$0A000700,0
	DC.L $08000A00,$09000900,$0A000000,0
	DC.L $08000900,$09000800,$0A000800,0
	DC.L $08000A00,$09000800,$0A000400,0
	DC.L $08000900,$09000900,$0A000600,0
	DC.L $08000A00,$09000800,$0A000100,0
	DC.L $08000900,$09000900,$0A000500,0
	DC.L $08000900,$09000800,$0A000700,0
	DC.L $08000800,$09000800,$0A000800,0
	DC.L $08000900,$09000800,$0A000600,0
	DC.L $08000900,$09000900,$0A000200,0
	DC.L $08000900,$09000700,$0A000700,0
	DC.L $08000900,$09000900,$0A000000,0
	DC.L $08000800,$09000800,$0A000700,0
	DC.L $08000900,$09000700,$0A000600,0
	DC.L $08000800,$09000800,$0A000600,0
	DC.L $08000900,$09000800,$0A000200,0
	DC.L $08000900,$09000600,$0A000600,0
	DC.L $08000800,$09000700,$0A000700,0
	DC.L $08000800,$09000800,$0A000400,0
	DC.L $08000800,$09000700,$0A000600,0
	DC.L $08000800,$09000800,$0A000200,0
	DC.L $08000700,$09000700,$0A000700,0
	DC.L $08000800,$09000600,$0A000600,0
	DC.L $08000800,$09000700,$0A000400,0
	DC.L $08000700,$09000700,$0A000600,0
	DC.L $08000800,$09000600,$0A000500,0
	DC.L $08000800,$09000600,$0A000400,0
	DC.L $08000700,$09000600,$0A000600,0
	DC.L $08000700,$09000700,$0A000400,0
	DC.L $08000800,$09000500,$0A000400,0
	DC.L $08000600,$09000600,$0A000600,0
	DC.L $08000700,$09000600,$0A000400,0
	DC.L $08000700,$09000500,$0A000500,0
	DC.L $08000600,$09000600,$0A000500,0
	DC.L $08000600,$09000600,$0A000400,0
	DC.L $08000600,$09000500,$0A000500,0
	DC.L $08000600,$09000600,$0A000200,0
	DC.L $08000600,$09000500,$0A000400,0
	DC.L $08000500,$09000500,$0A000500,0
	DC.L $08000600,$09000500,$0A000200,0
	DC.L $08000500,$09000500,$0A000400,0
	DC.L $08000500,$09000400,$0A000400,0
	DC.L $08000500,$09000500,$0A000200,0
	DC.L $08000400,$09000400,$0A000400,0
	DC.L $08000400,$09000400,$0A000300,0
	DC.L $08000400,$09000400,$0A000200,0
	DC.L $08000400,$09000300,$0A000300,0
	DC.L $08000300,$09000300,$0A000300,0
	DC.L $08000300,$09000300,$0A000200,0
	DC.L $08000300,$09000200,$0A000200,0
	DC.L $08000200,$09000200,$0A000200,0
	DC.L $08000200,$09000200,$0A000100,0
	DC.L $08000100,$09000100,$0A000100,0
	DC.L $08000200,$09000100,$0A000000,0
	DC.L $08000100,$09000100,$0A000000,0
	DC.L $08000100,$09000000,$0A000000,0
	DC.L $08000000,$09000000,$0A000000,0

	REPT 384
	DC.L $08000000,$09000000,$0A000000,0
	ENDR

;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

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

end_of_samples	DC.L 0

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

set_super	clr.l	-(sp)		;Set super stack equal
		move.w	#$20,-(sp)	; to user stack before call
		trap	#1
		addq.l	#6,sp		;correct stack
		move.l	d0,stack_save	;save old supervisor stack value
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1		;back to user
		addq.l	#6,sp		;correct stack
		rts

get_old_palette	lea	$ffff8240.w,a0
		lea	old_palette,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

set_new_palette	lea	pic+2,a0
		bra	set_pal
set_old_palette	lea	old_palette,a0
set_pal		lea	$ffff8240.w,a1
		REPT	8
		move.l 	(a0)+,(a1)+
		ENDR
		rts

get_screen_base	move.l	$44e.w,old_scr_base
		move.l	#screen,d0
		clr.b	d0
		move.l	d0,screen_base
		rts

set_org_rez	move.b	original_rez,$ffff8260.w
		bra.s	set_screen
set_med_rez	move.b	#1,$ffff8260.w
		bra.s	set_screen
set_low_rez	clr.b	$ffff8260.w
set_screen	move.l	a0,d0
		lsr.l	#8,d0
		lea	$ffff8201.w,a5
		movep.w	d0,(a5)
		rts


get_original_rez
		move.b	$ffff8260.w,original_rez
		rts


show_picture	lea	pic+34,a0
		move.l	screen_base,a1
		move.w	#32000/4-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop
		rts


black_out	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

clear_bss	lea	bssstart,a0		;clear BSS 'cause most packers don't
.clear		clr.b	(a0)+
		cmp.l	#eobss,a0
		bne.s	.clear
		rts

send_2_ik	move.l	a0,-(sp)
		move.w	#2-1,-(sp)
		move.w	#$19,-(sp)
		trap	#14
		addq.l	#8,sp
		rts

; Ste Test Routine - Sets 'ste_flg' true if the machine is STE and inits.
test_4_ste	move.w	#$2300,sr
		lea	$ffff8205.w,a5
		move.b	(a5),d7
		move.b	#'M',(a5)	;poke new value
		cmp.b	(a5),d7		;get value again, is it same?
		beq	.notSTE	;yes same so not ste
		move.b	d7,(a5)
		move.w	#-1,ste_flag
.notSTE		rts


	ifeq	DOWNLOAD
****************
	SECTION DATA
****************
	endc

mod_data	INCBIN	bass.mod

	DS.B	50000			; Workspace
workspc	DS.W	1

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
;	dc.b	7, $09		;key 8
;	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
;	dc.b	7, $68		;keypad 8
;	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8
exec1	dc.b	"BIG_ALEC.512",0
	even
exec2	dc.b	"TFMX.512",0
	even
exec3	dc.b	"REPLAY4.512",0
	even
exec4	dc.b	"CARTOON.512",0
	even
exec5	dc.b	"TSC49.512",0
	even
exec6	dc.b	"DEMO2.512",0
	even
exec7	dc.b	"COPIER.POV",0
	even
exec8	dc.b	"filename.ext",0
	even


pic	incbin	pov129.pi1

nomouse		dc.b	$12,$1a
yesmouse	dc.b	$14,$08
line_ptr	dc.l	scroll_text

scroll_text
 dc.b "          ````` WELCOME TO PERSISTENCE OF VISION DISC 129. ````` "
 dc.b "RELEASE DATE: 8TH FEB 1993.           MSD HERE AGAIN WITH A NEW TRACKER MENU,    "
 DC.B "ART AND MOD STOLEN FROM THE AMIGA.              "
 dc.b "   ONCE AGAIN IF YOU HAVE AN STE THEN THE MOD WILL SOUND EXCELLENT BUT "
 DC.B "IF YOU ONLY HAVE AN STFM IT WILL SOUND CRAP, IF YOU HAVE A FALCON "
 DC.B "THEN IT'LL SOUND REALLY BAD! (IF SOMEONE WILL TELL ME HOW TO DETECT "
 DC.B "THE FALCON I'LL INCLUDE THE NEW MOD REPLAY).        THIS DISC CONTAINS "
 DC.B "SOME OLD STUFF, THE REPLAY 4 DEMO HAS BEEN LYING AROUND FOR AGES "
 DC.B "BUT IT FITTED WELL ON THE DISC SO I RELEASED IT. I STILL HAVE LOADS "
 DC.B "OF SAMPLE SOUND DEMOS ALL PACKED AND WAITING BUT THEY ARE CRAP "
 DC.B "SO I AM PURPOSELY HOLDNG ONTO THEM. I'LL TRY TO GET RID OF THE DEMOS "
 DC.B "ONE AT A TIME BUT OUR DISC CONTENTS WILL GO DOWN IN QUALITY WHICH "
 DC.B "WE DON'T WANT (BUT WE WILL SAVE YOU DISC SPACE BY RELEASING THEM).   "
 DC.B "  ON THE CARDS IS A RUBBISH DISNEY PICTURE SHOW THAT IS PRESENTLY "
 DC.B "LEANING AGAINST MY DISC DRIVE, I MAY MAKE IT INTO A TRACKER SLIDESHOW "
 DC.B "LIKE THE VAXEL ONE I WROTE ABOUT A YEAR AGO (OR I COULD JUST PACK IT AS IT IS!). "
 DC.B "     THIS MENU WAS ORIGINALLY GOING ON OUR OFFICIAL SOURCE CODE "
 DC.B "DISC BUT IT LOOKED TOO GOOD SO I MADE IT INTO A MENU, I'LL "
 DC.B "RELEASE THE SOURCE CODE DISC NEXT AS SOON AS I'VE FINISHED WORK "
 DC.B "ON THE LINK FILER (NOW 100 PERCENT BUG FREE AND FULL OF FEATURES). "
 DC.B "      MY AMIGA A500 IS NOW WORKING!    THE ORIGINAL SHOP I WENT TO "
 DC.B "HAD THE WRONG CIA CHIPS "
 DC.B "AND THE ONLY WAY I COULD PROVE IT WAS TO TAKE MY A500 TO THE SHOP "
 DC.B "IN PIECES AND SHOW THEM THE CHIP WAS A 8520A.  I PHONED THE SHOP "
 DC.B "NEXT DAY AND THEY ADMITTED THEY TRIED TO SELL ME THE WRONG ONE BUT "
 DC.B "BLAMED THEIR SUPPLIER FOR SENDING THE WRONG ONES!  IN THE AMIGA THERE "
 DC.B "ARE 2 CIA CHIPS FOR CONTROLLING THE SERIAL/KEYBOARD AND PARALLEL/DISC DRIVE. "
 DC.B "  IN MY AMIGA THEY ARE BOTH 8520A CHIPS AND ARE EXACTLY THE SAME. ONE "
 DC.B "BLOKE AT ELM COMPUTING IN CLEVELEYS (ENGLAND) ARGUED THEY WERE "
 DC.B "DEFINITELY DIFFERENT AND VIRTUALLY CALLED ME A LIAR WHEN I "
 DC.B "SAID THEY WERE NOT IN MY A500. I WENT TO THE OTHER BRANCH (ELM COMPUTING "
 DC.B "IN BLACKPOOL) AND THE ASSISTANT SAID 'OH THEY ARE BOTH THE SAME' WHICH "
 DC.B "I PROVED WHEN I SHOWED HIM MY A500. SO ELM, GO SACK THE DICK HEAD AT "
 DC.B "CLEVELEYS, HE SAID HE WAS A REPAIR ENGINEER BUT SEEMS TO KNOW LESS "
 DC.B "THAN MY 12 YEAR OLD NEPHEW.   I DON'T THINK HE REALISED THAT I WAS "
 DC.B "NOT ONE THE USUAL 'DUMB' CUSTOMERS WHO HE COULD BAFFLE WITH BULLSHIT AS "
 DC.B "I AM EDUCATED TO LEVEL 5 ELECTRONICS AT HNC LEVEL PLUS I AM A "
 DC.B "CRAFTSMAN IN INSTRUMENTATION (4 YEARS APPRENTICESHIP) AND CAN "
 DC.B "FAULT FIND ON PCB'S AT COMPONENT LEVEL.    ELM AT BLACKPOOL "
 DC.B "SAID THEY WOULD GET THE NEW SUPPLY OF 8520A CHIPS IN THE FOLLOWING "
 DC.B "WEEK BUT I WAS FED UP OF THE SHOP AND BOUGHT AN AMIGA MAG FOR THE "
 DC.B "ADVERTISEMENTS.  I FOUND A SUPPLIER WHO UNDERCUT THE SHOP PRICE "
 DC.B "BY 4 POUNDS STERLING (10 DM) SO I ORDERED ONE AND IT ARRIVED NEXT DAY (WHICH "
 DC.B "WAS YESTERDAY) SO I THREW IT IN AND ALL THE PORTS NOW WORK (BUT THE "
 DC.B "MOUSE STILL LOCKS UP NOW AND AGAIN SO I MAY HAVE TO REPLACE THE "
 DC.B "OTHER CIA!).   WELL ENOUGH OF THIS CRAP TALK, HERE ARE THE GREETINGS.......      "
 DC.B "   POV SENDS ITS SMALL GREETINGS TO:  "
 DC.B "   ADRENALIN UK,   ANIMAL MINE,   "
 DC.B "CYNIX (QUATTRO),   DEL,   DR SYNE,   "
 DC.B "GEORGE (BART),   "
 DC.B "INSOMNIA (ANGEL GET IN TOUCH AS THE BELGIUM MAIL "
 DC.B "SERVICE SENT MY LAST PACKAGE BACK SAYING ADDRESS UNKNOWN),    "
 DC.B "KGB (ARE YOU DEAD?),   MUG UK,   "
 DC.B "PAL PD,   POMPEY PIRATES (RIP OR WOT?),   "
 DC.B "PURE ENERGY,   RIPPED OFF,   "
 DC.B "STRANGER    AND   TNC PD.         THE GREETS ARE SHORT AS "
 DC.B "THERE SEEMS TO BE NOBODY ON THE ST AT THE MOMENT, IF YOU "
 DC.B "ARE ACTIVE OR ARE IN CONTACT WITH ANY MEMBER OF POV THEN WRITE "
 DC.B "TO US AT THE USUAL PO BOX.     IF YOU ARE NOT IN CONTACT WITH "
 DC.B "POV BUT WOULD LIKE TO BE YOU SHOULD GO GET A PEN AND PAPER AS "
 DC.B "ADDRESS WILL BE SCROLLING PAST LATER.               "
 DC.B "WHAT ARE ATARI CORP. UPTO?     THEY PROMISE THE EARTH THEN "
 DC.B "DON'T DELIVER THE GOODS.    FALCON?        SHIT!       IT WAS "
 DC.B "PROMISED FOR THE UK AGES AGO AND IT'S NOT HERE.  AS USUAL "
 DC.B "ATARI IS FULL OF DREAMS, THEY TELL YOU OF NEW PRODUCTS AND HOW "
 DC.B "THEY ARE AVAILABLE TOMORROW BUT WHEN TOMORROW COMES THE NEW "
 DC.B "STUFF DOESN'T APPEAR.   IF ATARI DO NOT KEEP THEIR PROMISE "
 DC.B "OF THE NEW CASED FALCON AND MASS UK AVAILABILITY BY APRIL "
 DC.B "I AM GONNA SELL MY ST'S AND WORK MORE ON THE AMIGA (THIS IS NO "
 DC.B "LIE).      I'VE ALREADY GOT 2 BUYERS FOR MY 2 DEVELOPMENT STFM'S. "
 DC.B "I WAS GONNA SELL THEM ANYWAY AND GET A FALCON BUT AT THIS RATE "
 DC.B "A NEW 1400 AMIGA WILL BE OUT AND THE FALCON WILL LOOK SHIT. "
 DC.B "   I WILL KEEP MY 4 MEG STE FOR DEVELOPMENT PURPOSES (I WRITE ON "
 DC.B "THE STE AND DOWNLOAD IT TO MY AMIGA LIKE PDS FOR PC'S).    "
 DC.B "  I AM EXTREMELY LIKELY TO BUY A SNES AND DISC DRIVE THEN WRITE "
 DC.B "SOME STUFF ON THAT, I WAS EVEN THINKING OF GETTING ANOTHER MACHINE "
 DC.B "LIKE A 486 PC.    THE COMPUTER MARKET IS TURNING CRAP, NO GOOD "
 DC.B "HARDWARE AT RESONABLE PRICES AND BUGGER ALL SUPPORT.     THE ONLY WAY I'D "
 DC.B "GET A FALCON NOW IS IF IT CAME OUT IN MARCH AND WAS FULLY SUPPORTED "
 dc.b "WITH LOTS OF THIRD PARTY GOODIES. WHAT I WANT TO "
 DC.B "GET IS A 1 MEG VERSION THEN BUY A THIRD MARKET 14 MEG MEMORY BOARD AND "
 DC.B "HARD DISC CONTROLLER BUT I BET I CAN'T.  WHY CAN'T WE BUY THE "
 DC.B "HD CONTROLLER SEPERATELY AND SPECIFY WHAT SIZE HD WE WANT. WHO "
 DC.B "CAN WORK WITH ONLY 20 OR 52 MEG HARD DISCS?  I PRESENTLY USE A "
 DC.B "210 MEG HARD DISCS MADE UP OF 2 MECHANISMS AND IT'S STILL TOO "
 DC.B "SMALL!  I WANT QUALITY SOFTWARE LIKE THE PC HAS, JUST THROW "
 DC.B "THE DISC IN THE DRIVE AND THE SOFTWARE WILL SELF CONFIGURE ITSELF "
 DC.B "TO MY SETUP, THE SOFTWARE DOESN'T CRASH AND HAS A GOOD FRONT END. "
 DC.B "   I HOPE WE CAN GET A GOOD 'WINDOWS' LOOKING GUI RATHER THAN "
 DC.B "THE CRAP LOOKING AND OUT DATED GEM.   I AM WORKING ON A BETTER "
 DC.B "GUI AT THE MOMENT BUT IT'S QUITE HARD TO GET IT TO PERFORM ALL "
 DC.B "THE GEM CALLS AND IT'S NOW GETTING ON MY TITS.  I MAY RE-WRITE IT "
 DC.B "SO IT IS A GENERAL GUI AND SITS BELOW MY 68000 WITH EXTENDED "
 DC.B "SYSTEM TRAPS SO I CAN USE IT TO CALL NEW WINDOW ROUTINES "
 DC.B "AND SUCH LIKE. I PROGRAMMED SOMETHING SIMILAR ON THE ZX SPECTRUM "
 DC.B "THAT ALLOWED ME TO CALL NEW ROUTS FROM BASIC BUT THEN I BOUGHT MY ST!"
 DC.B "      OKAY ENOUGH OF THIS, I HOPE YOU'VE GOT A PEN AND PAPER......   "
 DC.B "         YOU CAN CONTACT P.O.V. AT [[[[[[[[[        MAC SYS DATA,        "
 DC.B "P.O. BOX 40,              THORNTON-CLEVELEYS,              LANCASHIRE,              "
 DC.B "FY5 3PH,              ENGLAND.                      "
 DC.B "                         WRAP      "
 dc.b "                        ````````````````````````````````````    "
 DC.B "                                                                "
 DC.B "                                                                "
 DC.B "                                                                "
 DC.B "                                                                "
 DC.B "                                                                "
 DC.B "                                                                "
 dc.b "          ````` WELCOME TO PERSISTENCE OF VISION DISC 129. ````` "
 DC.B "             ?EREH NIAGA  "
 DC.B "                                   WELL JENNY AND I ARE "
 DC.B "TOGETHER AGAIN AND ALL IS HUNKY DOREY (OKAY DEL?)...........  THAT'S ALL I HAVE TO "
 DC.B "SAY.   WRAP (FOR REAL)                                 "
 dc.b $ff
	even

font	incbin	oz_font.dat
	even



* colours for background
colours
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$001,$001,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$002,$002,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$003,$003,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$004,$004,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$001,$005,$005,$001,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$002,$006,$006,$002,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$003,$007,$007,$003,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$004,$00f,$00f,$004,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$005,$00f,$00f,$005,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$006,$00f,$00f,$006,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$007,$00f,$00f,$007,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$00f,$00f,$00f,$00f,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$00f,$00f,$00f,$00f,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$00f,$00f,$00f,$00f,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$001,$00f,$00f,$00f,$00f,$001,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$002,$00f,$00f,$00f,$00f,$002,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$003,$00f,$00f,$00f,$00f,$003,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$004,$00f,$00f,$00f,$00f,$004,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$005,$00f,$00f,$00f,$00f,$005,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$006,$00f,$00f,$00f,$00f,$006,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$007,$00f,$00f,$00f,$00f,$007,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$00f,$00f,$00f,$00f,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$00f,$00f,$00f,$00f,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$00f,$00f,$00f,$00f,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$007,$007,$007,$007,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$006,$006,$006,$006,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$005,$005,$005,$005,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$004,$004,$004,$004,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$003,$003,$003,$003,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$002,$002,$002,$002,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$002,$002,$002,$002,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$002,$002,$002,$002,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$002,$002,$002,$002,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$002,$002,$002,$002,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$002,$002,$002,$002,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$002,$002,$002,$002,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$002,$002,$002,$002,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$002,$002,$002,$002,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$002,$002,$002,$002,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$001,$001,$001,$001,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$000,$000,$000,$000,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$00f,$000,$000,$000,$000,$00f,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$007,$000,$000,$000,$000,$007,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$006,$000,$000,$000,$000,$006,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$005,$000,$000,$000,$000,$005,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$004,$000,$000,$000,$000,$004,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$003,$000,$000,$000,$000,$003,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$002,$000,$000,$000,$000,$002,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$001,$000,$000,$000,$000,$001,$000,$000,$000,$000,$000

 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$020,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$030,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$010,$000,$000,$040,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$020,$000,$000,$050,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$030,$000,$000,$060,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$040,$000,$000,$070,$000,$000,$000,$000
 dc.w	$000,$000,$000,$010,$000,$000,$050,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$000,$000,$000,$020,$000,$000,$060,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$000,$000,$000,$030,$000,$000,$070,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$010,$000,$000,$040,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$020,$000,$000,$050,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$030,$000,$000,$060,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$040,$000,$000,$070,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$050,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$060,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$070,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$0f0,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$0f0,$000,$000,$000,$000
 dc.w	$1f0,$000,$000,$1f0,$000,$000,$1f0,$000,$000,$1f0,$000,$000,$000,$000
 dc.w	$2f0,$000,$000,$2f0,$000,$000,$2f0,$000,$000,$2f0,$000,$000,$000,$000
 dc.w	$3f0,$000,$000,$3f0,$000,$000,$3f0,$000,$000,$3f0,$000,$000,$000,$000
 dc.w	$4f0,$000,$000,$4f0,$000,$000,$4f0,$000,$000,$4f0,$000,$000,$000,$000
 dc.w	$5f0,$000,$000,$5f0,$000,$000,$5f0,$000,$000,$5f0,$000,$000,$000,$000
 dc.w	$6f0,$000,$000,$6f0,$000,$000,$6f0,$000,$000,$6f0,$000,$000,$000,$000
 dc.w	$7f0,$000,$000,$7f0,$000,$000,$7f0,$000,$000,$7f0,$000,$000,$000,$000
 dc.w	$ff0,$000,$000,$ff0,$000,$000,$ff0,$000,$000,$ff0,$000,$000,$000,$000
 dc.w	$ff1,$000,$000,$ff1,$000,$000,$ff1,$000,$000,$ff1,$000,$000,$000,$000
 dc.w	$ff2,$000,$000,$ff2,$000,$000,$ff2,$000,$000,$ff2,$000,$000,$000,$000
 dc.w	$ff3,$000,$000,$ff3,$000,$000,$ff3,$000,$000,$ff3,$000,$000,$000,$000
 dc.w	$ff4,$000,$000,$ff4,$000,$000,$ff4,$000,$000,$ff4,$000,$000,$000,$000
 dc.w	$ff5,$000,$000,$ff5,$000,$000,$ff5,$000,$000,$ff5,$000,$000,$000,$000
 dc.w	$ff6,$000,$000,$ff6,$000,$000,$ff6,$000,$000,$ff6,$000,$000,$000,$000
 dc.w	$ff7,$000,$000,$ff7,$000,$000,$ff7,$000,$000,$ff7,$000,$000,$000,$000
 dc.w	$fff,$000,$000,$fff,$000,$000,$fff,$000,$000,$fff,$000,$000,$000,$000
 dc.w	$7ff,$000,$000,$7ff,$000,$000,$7ff,$000,$000,$7ff,$000,$000,$000,$000
 dc.w	$67f,$000,$000,$67f,$000,$000,$67f,$000,$000,$67f,$000,$000,$000,$000
 dc.w	$567,$000,$000,$567,$000,$000,$567,$000,$000,$567,$000,$000,$000,$000
 dc.w	$456,$000,$000,$456,$000,$000,$456,$000,$000,$456,$000,$000,$000,$000
 dc.w	$345,$000,$000,$345,$000,$000,$345,$000,$000,$345,$000,$000,$000,$000
 dc.w	$234,$000,$000,$234,$000,$000,$234,$000,$000,$234,$000,$000,$000,$000

 dc.w	$123,$000,$000,$123,$000,$000,$123,$000,$000,$123,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$123,$000,$000,$123,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$123,$000,$000,$123,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$123,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$123,$000,$000,$123,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$123,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$123,$000,$000,$012,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$123,$000,$000,$001,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$123,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$123,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$012,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$001,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$023,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$012,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$001,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$123,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$012,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$001,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$110,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$220,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$330,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$440,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$550,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$660,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$770,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$ff0,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$770,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$660,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$550,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$440,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$330,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$220,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$110,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111
 dc.w	$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222
 dc.w	$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333
 dc.w	$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444
 dc.w	$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555
 dc.w	$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666
 dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
 dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff
 dc.w	$f7f,$f7f,$f7f,$f7f,$f7f,$f7f,$f7f,$f7f,$f7f,$f7f,$f7f,$f7f,$f7f,$f7f
 dc.w	$f6f,$f6f,$f6f,$f6f,$f6f,$f6f,$f6f,$f6f,$f6f,$f6f,$f6f,$f6f,$f6f,$f6f
 dc.w	$f5f,$f5f,$f5f,$f5f,$f5f,$f5f,$f5f,$f5f,$f5f,$f5f,$f5f,$f5f,$f5f,$f5f
 dc.w	$f4f,$f4f,$f4f,$f4f,$f4f,$f4f,$f4f,$f4f,$f4f,$f4f,$f4f,$f4f,$f4f,$f4f
 dc.w	$f3f,$f3f,$f3f,$f3f,$f3f,$f3f,$f3f,$f3f,$f3f,$f3f,$f3f,$f3f,$f3f,$f3f
 dc.w	$f2f,$f2f,$f2f,$f2f,$f2f,$f2f,$f2f,$f2f,$f2f,$f2f,$f2f,$f2f,$f2f,$f2f
 dc.w	$f1f,$f1f,$f1f,$f1f,$f1f,$f1f,$f1f,$f1f,$f1f,$f1f,$f1f,$f1f,$f1f,$f1f
 dc.w	$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f,$f0f
 dc.w	$707,$707,$707,$707,$707,$707,$707,$707,$707,$707,$707,$707,$707,$707
 dc.w	$606,$606,$606,$606,$606,$606,$606,$606,$606,$606,$606,$606,$606,$606
 dc.w	$505,$505,$505,$505,$505,$505,$505,$505,$505,$505,$505,$505,$505,$505
 dc.w	$404,$404,$404,$404,$404,$404,$404,$404,$404,$404,$404,$404,$404,$404
 dc.w	$303,$303,$303,$303,$303,$303,$303,$303,$303,$303,$303,$303,$303,$303
 dc.w	$202,$202,$202,$202,$202,$202,$202,$202,$202,$202,$202,$202,$202,$202
 dc.w	$101,$101,$101,$101,$101,$101,$101,$101,$101,$101,$101,$101,$101,$101
 dc.w	$100,$100,$100,$100,$100,$100,$100,$100,$100,$100,$100,$100,$100,$100
 dc.w	$200,$200,$200,$200,$200,$200,$200,$200,$200,$200,$200,$200,$200,$200
 dc.w	$300,$300,$300,$300,$300,$300,$300,$300,$300,$300,$300,$300,$300,$300
 dc.w	$400,$400,$400,$400,$400,$400,$400,$400,$400,$400,$400,$400,$400,$400
 dc.w	$500,$500,$500,$500,$500,$500,$500,$500,$500,$500,$500,$500,$500,$500
 dc.w	$600,$600,$600,$600,$600,$600,$600,$600,$600,$600,$600,$600,$600,$600
 dc.w	$700,$700,$700,$700,$700,$700,$700,$700,$700,$700,$700,$700,$700,$700


 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$700
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$600
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$500
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$400
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$700,$300
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$600,$200
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$500,$100
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$400,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$700,$300,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$600,$200,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$500,$100,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$400,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$700,$300,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$600,$200,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$500,$100,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$400,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$700,$300,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$600,$200,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$500,$100,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$400,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$700,$300,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$600,$200,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$500,$100,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$f00,$400,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$700,$300,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$600,$200,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$500,$100,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$f00,$400,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$700,$300,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$600,$200,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$500,$100,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$f00,$400,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$700,$300,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$600,$200,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$500,$100,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$f00,$400,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$700,$300,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$600,$200,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$500,$100,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$f00,$400,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$700,$300,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$600,$200,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$500,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$f00,$400,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$700,$300,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$600,$200,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$500,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$f00,$400,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$700,$300,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$600,$200,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$500,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$f00,$400,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$700,$300,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$600,$200,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$500,$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$400,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$300,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$200,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$100,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$100,$000,$000,$000,$000,$000,$000,$200,$000,$000,$000,$000,$000,$000
 dc.w	$300,$000,$000,$000,$000,$000,$000,$400,$000,$000,$000,$000,$000,$000
 dc.w	$500,$000,$000,$000,$000,$000,$000,$600,$000,$000,$000,$000,$000,$000
 dc.w	$700,$000,$000,$000,$000,$000,$000,$701,$000,$000,$000,$000,$000,$000
 dc.w	$702,$000,$000,$000,$000,$000,$000,$703,$000,$000,$000,$000,$000,$000
 dc.w	$704,$000,$000,$000,$000,$000,$000,$705,$000,$000,$000,$000,$000,$000
 dc.w	$706,$000,$000,$000,$000,$000,$000,$707,$000,$000,$000,$000,$000,$000
 dc.w	$707,$000,$000,$000,$000,$000,$000,$707,$000,$000,$000,$000,$000,$000
 dc.w	$707,$000,$000,$000,$000,$000,$000,$707,$000,$000,$000,$000,$000,$000
 dc.w	$707,$000,$000,$000,$000,$000,$000,$707,$000,$000,$000,$000,$000,$000
 dc.w	$707,$000,$000,$000,$000,$000,$000,$707,$000,$000,$000,$000,$000,$000
 dc.w	$707,$000,$000,$000,$000,$000,$000,$707,$000,$000,$000,$000,$000,$000
 dc.w	$707,$000,$000,$000,$000,$000,$000,$707,$000,$000,$000,$000,$000,$000
 dc.w	$606,$000,$000,$000,$000,$000,$000,$606,$000,$000,$000,$000,$000,$000
 dc.w	$505,$000,$000,$000,$000,$000,$000,$505,$000,$000,$000,$000,$000,$000
 dc.w	$404,$000,$000,$000,$000,$000,$000,$404,$000,$000,$000,$000,$000,$000
 dc.w	$303,$000,$000,$000,$000,$000,$000,$303,$000,$000,$000,$000,$000,$000
 dc.w	$202,$000,$000,$000,$000,$000,$000,$202,$000,$000,$000,$000,$000,$000
 dc.w	$101,$000,$000,$000,$000,$000,$000,$101,$000,$000,$000,$000,$000,$000

 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$101,$000,$000,$101,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$202,$000,$000,$202,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$303,$000,$000,$303,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$404,$000,$000,$404,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$505,$000,$000,$505,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$606,$000,$000,$606,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$707,$000,$000,$707,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$607,$000,$000,$607,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$507,$000,$000,$507,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$407,$000,$000,$407,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$307,$000,$000,$307,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$207,$000,$000,$207,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$107,$000,$000,$107,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$017,$010,$010,$017,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$027,$020,$020,$027,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$037,$030,$030,$037,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$047,$040,$040,$047,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$057,$050,$050,$057,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$067,$060,$060,$067,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$077,$070,$070,$077,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$076,$070,$070,$076,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$075,$070,$070,$075,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$074,$070,$070,$074,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$073,$070,$070,$073,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$072,$070,$070,$072,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$071,$070,$070,$071,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$070,$070,$070,$070,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$070,$070,$070,$070,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$070,$070,$070,$070,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$070,$070,$070,$070,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$070,$070,$070,$070,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$060,$060,$060,$060,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$050,$050,$050,$050,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$040,$040,$040,$040,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$030,$030,$030,$030,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$020,$020,$020,$020,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$010,$010,$010,$010,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	rept	3
 dc.w	$100,$f00,$700,$e00,$600,$d00,$500,$c00,$400,$b00,$300,$a00,$200,$900
 dc.w	$100,$f00,$700,$e00,$600,$d00,$500,$c00,$400,$b00,$300,$a00,$200
 dc.w	$900,$100,$f00,$700,$e00,$600,$d00,$500,$c00,$400,$b00,$300,$a00
 dc.w	$200,$900,$100,$f00,$700,$e00,$600,$d00,$500,$c00,$400,$b00,$300
 dc.w	$a00,$200,$900,$100,$f00,$700,$e00,$600,$d00,$500,$c00,$400,$b00
 dc.w	$300,$a00,$200,$900,$100,$f00,$700,$e00,$600,$d00,$500,$c00,$400
 dc.w	$b00,$300,$a00,$200,$900,$100,$f00,$700,$e00,$600,$d00,$500,$c00
 dc.w	$400,$b00,$300,$a00,$200,$900,$100,$f00,$700,$e00,$600,$d00,$500
 dc.w	$c00,$400,$b00,$300,$a00,$200,$900,$100,$f00,$700,$e00,$600,$d00
 dc.w	$500,$c00,$400,$b00,$300,$a00,$200,$900,$100,$f00,$700,$e00,$600
 dc.w	$d00,$500,$c00,$400,$b00,$300,$a00,$200,$900,$100,$f00,$700,$e00
 dc.w	$600,$d00,$500,$c00,$400,$b00,$300,$a00,$200,$900,$100,$f00,$700
 dc.w	$e00,$600,$d00,$500,$c00,$400,$b00,$300,$a00,$200,$900,$100,$f00
 dc.w	$700,$e00,$600,$d00,$500,$c00,$400,$b00,$300,$a00,$200,$900
	endr

 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$001,$002,$003,$004,$005,$006
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$007,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00e,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$006,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00d,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$005,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00c,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$004,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00b,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$003,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$00a,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$002,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$009,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$001,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$008,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
 dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
colours_end




	ifeq	DOWNLOAD
	SECTION BSS
	endc
bssstart


sbuffer		ds.b	BUFFER_SIZE

colour_no	ds.w	1
black		ds.b	32
old_timerb	ds.l	1
oldtima		ds.l	1
oldtimd		ds.l	1
store		ds.l	1
scroll_number	ds.w	1
oldkbd		ds.l	1
key		ds.w	1
ste_flag	ds.w	1
hertz_delay	ds.w	1
hertz_toggle	ds.w	1
oldvbl		ds.l	1
old_palette	ds.w	16
stack_save	ds.l	1
old_scr_base	ds.l	1
screen_base	ds.l	1
original_rez	ds.b	1
s06		ds.l	1
s12		ds.l	1
s1d		ds.b	1

	even

vus	ds.w	1		;last recorded level of VUs
	ds.w	1
	ds.w	1
	ds.w	1



buffer		ds.w	128
vsyncflag	ds.w	1

	ds.b	256
screen	ds.b	160*248
eobss


	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
