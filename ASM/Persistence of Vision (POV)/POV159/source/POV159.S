*************************************************************************
*			PERSISTENCE OF VISION 159			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Music by: 	Unknown, file taken from Aminet				*
*									*
*									*
* Grafix by: 	OZYMANDIAS and Machine System Data			*
*									*
*************************************************************************
*
* STE/STFM tracker menu
*
*		If you use this code then give me credit.
*		Don't be a lamer and claim you use it.
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


;****** STFM BITS ***********
;Uses registers D5-D7/A6
MVOL	EQU	$60			; >= $40 ($60 recommended)
FREQ	EQU	1			; 0=6.144, 1=8.192, 2=12.288
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

FINAL=yes	;YES to remove escape to assembler code
		;NO to keep it on


******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
DOWNLOAD	equ	no

	ifne	DOWNLOAD
	include	transmit.s
	org	$20000

Code_Start
Exec_Addr
	ENDC


	OPT	o+,ow+,ow2-,ow3-,ow4-,w-

	include	"SYSTEMEQ.S"

MAX_DOTS	equ	104

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

	jsr	clear_bss
	ifeq	DOWNLOAD
	jsr	set_super
	endc
	move.w	#$2300,sr

	jsr	test_4_pacifist_emulator

	tst.w	pacifist_flag
	bne	facifist_stop

	jsr	test_4_ste
	or.b	#%00000010,$ffff820a.w		;50Hz
	jsr	get_screen_base
	jsr	get_old_palette
	jsr	get_original_rez
	jsr	black_out
	jsr	set_low_rez

	bsr	set_screen
	jsr	show_picture

	move.w	#$2300,sr
	tst.w	ste_flag
	bne.s	init_ste
	jsr	muson_stfm			; Install music
	jsr	set_new_palette
	bra.s	msd
init_ste
	jsr	muson_ste
	jsr	set_new_palette
msd
	move.w	#4,bump_one
	move.w	#8,bump_two
	move.w	#12,bump_three

main_loop
	bsr	vsync
	lea	pic+2,a0
	lea	Palette0,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr


;	move.w	#$123,Palette0.w
	bsr	flip_screens
	bsr	scroller
	eor.w	#(MAX_DOTS*2),dot_off
	bsr	erase_dots
	bsr	show_dots
	bsr	move_dots
	bsr	change_dots

;	clr.w	Palette0.w


	move.w	key,d0

	ifeq	FINAL
	cmp.w	#1,d0		;ESC
	beq.s	assem
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
	jsr	musoff_stfm	; Restore system completely
	bra.s	.co
.shut_down_ste
	jsr	musoff_ste
.co	jsr	set_old_palette
	jsr	set_low_rez
	ifeq	DOWNLOAD
	jsr	set_user
	endc

	ifeq	AUTORUN4
	bra	exec

	ELSE
	clr.w	-(sp)
	trap	#1
	ENDC

	ifeq	FINAL
assem
	ifne	DOWNLOAD
	move.l	4.w,-(sp)
	rts
	endc

	tst.w	ste_flag
	bne.s	.shut_down_ste
	bsr	musoff_stfm	; Restore system completely
	bra.s	.co
.shut_down_ste
	bsr	musoff_ste
.co	jsr	set_old_palette
	jsr	set_med_rez
	jsr	set_user
	clr.w	-(sp)
	trap	#1
	ENDC


zero	;flip hertz indicator...
	tst.w	hertz_delay
	bne	main_loop
	eor.w	#$009,pic+2
	eor.w	#-1,hertz_toggle
	move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
	bra	main_loop


reset	move.l	4.w,-(sp)
	rts

set_screen
	move.l	#screens,d0
	clr.b	d0
	move.l	d0,first_scr
	move.l	d0,scr_now
	clr.l	scr_add
	rts


flip_screens
	move.l	first_scr,d0
	add.l	scr_add,d0
	move.l	d0,scr_now
	lsr.l	#8,d0
	lea	VidBaseHi,a0
	movep.w	d0,(a0)
	eor.l	#(160*248),scr_add
	rts



change_dots
	addq.w	#2,clip_ptr
	and.w	#(2*255),clip_ptr
	cmp.w	#(2*216),clip_ptr
	bne.s	.end

	bsr.s	random1
	move.w	d0,bump_one
	bsr.s	random1
	move.w	d0,bump_two
	bsr.s	random1
	move.w	d0,bump_three

	bsr.s	random2
	move.w	d0,add_one
	bsr.s	random2
	move.w	d0,add_two
	bsr.s	random2
	move.w	d0,add_three
.end
	rts


random1
	move.l	seed,d0
	mulu	#$1afb,d0
	add.l	#$1fccd,d0
	move.l	d0,seed
	moveq	#11,d1
	asr.w	d1,d0
	and.w	#$fffc,d0
	bne.s	.no_fix
	addq.w	#4,d0
.no_fix
	rts

random2
	move.l	seed,d0
	mulu	#$1afb,d0
	add.l	#$1fccd,d0
	move.l	d0,seed
	moveq	#12,d1
	asr.w	d1,d0
	and.w	#$fffc,d0
	bne.s	.no_fix
	addq.w	#4,d0
.no_fix
	rts


erase_dots
	move.l	scr_now,a0
	lea	160*64+8*11+4(a0),a0
	lea	dot_addrs,a2
	add.w	dot_off,a2
	moveq	#0,d0
	REPT	MAX_DOTS
	move.w	(a2)+,d1
	move.w	d0,(a0,d1)
	ENDR
	rts


move_dots
	move.w	add_one,d0
	add.w	d0,ptr_one
	and.w	#(4*255),ptr_one
	move.w	add_two,d0
	add.w	d0,ptr_two
	and.w	#(4*255),ptr_two
	move.w	add_three,d0
	add.w	d0,ptr_three
	and.w	#(4*255),ptr_three
	rts











********************************************************
;a0=screen address
;a1=



;do not use registers D5-D7/A6
show_dots
	move.l	scr_now,a0
	lea	160*64+8*11+4(a0),a0
	lea	path_one,a2
	lea	path_two,a3
	lea	path_three,a4
	move.w	ptr_one,d2
	move.w	ptr_two,d3
	move.w	ptr_three,d4
	lea	dot_addrs,a1
	add.w	dot_off,a1
	lea	clip_path,a5
	add.w	clip_ptr,a5
	move.w	(a5),tempd6
	moveq	#(MAX_DOTS-1),d0
.loop	move.w	d0,tempd0
	move.w	2(a2,d2),d1
	add.w	2(a3,d3),d1
	add.w	2(a4,d4),d1
	move.w	(a2,d2),d0
	add.w	(a3,d3),d0
	add.w	(a4,d4),d0
	add.w	tempd6,d0
	add.w	dot_data(pc,d0),d1
	move.w	dot_data+2(pc,d0),d0
	or.w	d0,(a0,d1)
	move.w	d1,(a1)+

bump_one	equ	*+2
	add.w	#0,d2
	and.w	#(4*255),d2
bump_two	equ	*+2
	add.w	#0,d3
	and.w	#(4*255),d3
bump_three	equ	*+2
	add.w	#0,d4
	and.w	#(4*255),d4
	move.w	tempd0,d0
	dbf	d0,.loop
	rts

tempd0	dc.w	0
tempd6	dc.w	0



********************************************************










dot_data
X	set	0
	REPT	144
	dc.w	(X/16)*8
	dc.w	$8000>>(X&15)
X	set	X+1
	ENDR
	dcb.l	144,0

;do not use registers D5-D7/A6
scroller
	lea	font,a5
	move.l	scr_now,a2
	lea	160*201+6(a2),a2
	move.l	text_ptr,a4
	move.l	a4,a3
	move.w	char_off,d3
	moveq	#0,d2
	moveq	#40-1,d1
.loop
	move.w	(a3),d0
	bpl.s	.cont
	lea	text_start,a3
	move.w	(a3),d0
.cont
	move.l	a5,a0
	add.w	d3,d0
	add.w	d0,a0
.column
OFF	set	0
	REPT	16
	move.b	(a0)+,OFF(a2)
OFF	set	OFF+160
	ENDR
	dbf	d1,.not_end
	add.w	#16,char_off
	and.w	#(16*3),char_off
	bne.s	.end
	addq.w	#2,a4
	tst.w	(a4)
	bpl.s	.end
	lea	text_start,a4
.end
	move.l	a4,text_ptr
	rts
.not_end
	addq.w	#1,a2
	tst.w	d2
	beq.s	.next
	addq.w	#6,a2
.next
	not.w	d2
	add.w	#16,d3
	and.w	#(16*3),d3
	bne.s	.column
	addq.w	#2,a3
	bra	.loop

border_isr
	or.w	#$700,sr
	clr.b	TBCR
	move.l	d0,-(sp)
	move.l	a0,-(sp)
.wait
	cmp.b	#$60,VidAddrLo
	blo.s	.wait
	dbt	d0,*
	dbt	d0,*
	lea	.nops(pc),a0
	moveq	#0,d0
	move.b	VidAddrLo,d0
	sub.b	#$60,d0
	add.w	d0,a0
	jmp	(a0)
.nops
	REPT	89
	nop
	ENDR
	dbt	d0,*
	dbt	d0,*
	clr.b	SyncMode
	nop
	move.b	#2,SyncMode

	move.w	pic+2,Palette0
	move.w	pic+2,d0
	swap	d0
	move.w	pic+2,d0
	lea	Palette1,a0
	move.w	d0,(a0)+
	REPT	3
	move.l	d0,(a0)+
	ENDR
	move.l	#$0310041,(a0)+
	move.l	#$0510062,(a0)+
	move.l	#$0730074,(a0)+
	move.l	#$0750276,(a0)
	move.l	(sp)+,a0
	move.l	(sp)+,d0
	rte



new_kbd	;new keyboard handler - returns GEM VDI low byte in key.w
	movem.l	d0,-(sp)
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

facifist_stop
	incbin	pacifist.dat
;	pea	nopacifist		;print text
;	move.w	#9,-(sp)
;	trap	#1
;	add.w	#6,sp
;	move.w	#7,-(sp)		;wait on key
;	trap	#1
;	add.w	#2,sp
;	move.w	4.w,-(sp)
;	rts



muson_ste
	bsr	vol_ste			; Calculate volume tables
	bsr	incrcal_ste			; Calculate tonetables

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
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#border_isr,$120.w
	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#199,$fffffa21.w	;timer B data
	move.b	#8,$fffffa1b.w		;ei timber B

	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w

	clr.b	$FFFFFA19.w		;stop timer A
	move.b	#1,$FFFFFA1F.w		;timer A data
	move.b	#8,$FFFFFA19.w		;start timer A


	move.l	$134.w,oldtima
	move.l	#stereo,$0134.w

	move.b	#FREQ_STE,$FFFF8921.w	; Frequency

	lea	$FFFF8907.w,a0

	move.l	#sample1_ste,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	#sample1_ste+LEN_STE*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)




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
		move.w	#3-1,d0
mwwrite		move.w	#$07ff,$ffff8924.w	;MICROWIRE mask register
mwwrite2	cmp.w	#$07ff,$ffff8924.w	;wait for write state
		bne.s	mwwrite2
		move.w	(a0)+,$ffff8922.w	;MICROWIRE data register - make new values...
		dbra	d0,mwwrite
*------------------------------------------------------------------

	move.b	#3,$FFFF8901.w		; Start DMA

	move	#$2300,sr
	rts


setsam_dat
;this is complex but I'll try to make it simple....
;
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;The VOLUME bit is already taken care of by the rest of the code
; but I've left it in for reference only... (MSD)
;
;                     dd = always 10 cos that's the device output for GI tone chip
;                     ||xxx=master volume (%011 or can be left %101 or right %100)
;                     |||||yyyyyy=volume setting 000000 -80dB (sound off)
;                     |||||||||||                010100 -40dB
;                     |||||||||||                101???   0dB (??? doesn't matter)
;	dc.w	%0000010011101000


;base + treble
;       z zzz
;	0 000 -12 dB
;	0 110   0 dB
;	1 100 +12 dB
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


musoff_ste
	move	#$2700,sr

	clr.b	$FFFFFA19.w		; Stop timer A
	clr.b	$FFFFFA1b.w		; Stop timer B

	move.l	old_timerb,$120.w
	move.l	oldvbl,$70.w
	move.l	oldkbd,$118.w
	lea	store,a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0),$fffffa13.w

	move.l	oldtima(pc),$0134.w	; Restore everything

	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w

	clr.b	$FFFF8901.w		; Stop DMA

	lea	yesmouse,a0
	jsr	send_2_ik

	move	#$2300,sr
	rts

oldtima	DC.L 0

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
aud1vol	DC.W 0
	DS.W 3

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

	move	#$2700,sr

	lea	store,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)
	move.l	$FFFFFA06.w,s06		; Save MFP registers
	move.l	$FFFFFA12.w,s12
	move.b	$FFFFFA1D.w,s1d

	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	$120.w,old_timerb
	move.l	$118.w,oldkbd
	move.l	$70.w,oldvbl
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#border_isr,$120.w
	bclr	#3,$fffffa17.w		; Autovectors
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#199,$fffffa21.w	;timer B data
	move.b	#8,$fffffa1b.w		;ei timber B

	move.b	#$21,$fffffa07.w	0 0 0 0 0 0 0 0
				;		      +---- Timer B $120 ena

	move.b	#%01010000,$fffffa09.w	0 1 0 1 0 0 0 0
				;	  |   +------------ $110 ena
				;	  +---------------- MC6850 $118 ena
	move.b	#%01010000,$fffffa15.w	0 1 0 1 0 0 0 0
				;         |   +------------ $110 mask
				;         +---------------- MC6850 $118 mask
	move.b	#$21,$fffffa13.w	0 0 0 0 0 0 0 0
				;		      +---- Timer B $120 mask

	clr.b	$FFFFFA1D.w		;stop timer C & D
	clr.b	$FFFFFA19.w		;stop timer A
	move.b	#A_DATA,$FFFFFA1F.w	;set timer A data
	move.b	#D_DATA,$FFFFFA25.w	;set timer D data
	move.b	#2,$FFFFFA19.w		;start timer A
	move.b	#6,$FFFFFA1D.w		;timer C & D control

	move.l	$0110.w,oldtimd
	move.l	$0134.w,oldtima
	move.l	#timerd,$0110.w
	move.l	#playvec,$0134.w

	lea	sample1(pc),a6
	move	#$2300,sr
	rts

newvbl	move.w	pic+2,Palette0.w

	clr.b	$fffffa1b.w		;disable timerb
	move.l	#border_isr,$120.w	;reset timerb to initial one
	move.b	#199,$fffffa21.w	;reset timerb data
	move.b	#8,$fffffa1b.w		;ei timer b

	clr.w	vsyncflag
	tst.w	hertz_delay
	bne.s	.dec_hertz
	rte
.dec_hertz
	sub.w	#1,hertz_delay
	rte


musoff_stfm
	move	#$2700,sr

	move.l	oldkbd,$118.w
	move.l	oldvbl,$70.w
	move.l	oldtimd(pc),$0110.w	; Restore vectors
	move.l	oldtima(pc),$0134.w

	move.l	s06(pc),$FFFFFA06.w
	move.l	s12(pc),$FFFFFA12.w
	move.b	s1d(pc),$FFFFFA1D.w

	bset	#3,$FFFFFA17.w		; Softvectors

	lea	yesmouse,a0
	jsr	send_2_ik

	move	#$2300,sr
	rts

s06	DC.L 0
s12	DC.L 0
s1d	DC.B 0
	EVEN

oldtimd	DC.L 0

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

itab	DS.L $30
stab	DS.L $03A0-$30

;---------------------------------------------------- Samplecalculating --
timerd	movea.l	samp1(pc),a6

	move	#$2500,sr
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

sample1	REPT LEN
	DC.W $0200
	ENDR

sample2	REPT LEN
	DC.W $0200
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
	lea	data,a1		; Module
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

.nospac	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	data,a0
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

music	lea	data,a0
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

getnew	lea	data+$043C,a0
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
	clr.w	wiz3pos			;

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
	cmp.b	data+$03B6,d1
	bne.s	endr
	move.b	data+$03B7,songpos
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

vib	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
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
	cmp.b	#$04,d0
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
	move.b	$03(a4),d0
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

speed	DC.W $06
counter	DC.W $00
songpos	DC.B $00
break	DC.B $00
pattpos	DC.W $00

dmacon		DC.W $00
samplestarts	DS.L $1F

voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3

buffer	ds.w	128
vsyncflag	ds.w	1

tst_key		move.w	#11,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

get_key		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		rts

set_super	clr.l	-(sp)		;Set super stack equal
		move.w	#$20,-(sp)	; to user stack before call
		trap	#1
		addq.l	#6,sp		;correct stack
		move.l	d0,pstacksave	;save old supervisor stack value
		rts

set_user	move.l	pstacksave,-(sp)
		move.w	#$20,-(sp)
		trap	#1		;back to user
		addq.l	#6,sp		;correct stack
		rts

get_old_palette	lea	Palette0.w,a0
		lea	old_palette,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

set_new_palette
	lea	pic+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	Palette0.w,a1
	REPT	16
	move.w	(a0)+,(a1)+
	ENDR
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

get_original_rez:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_org_rez	move.w	original_rez,-(sp)
		bra.s	set_rez
set_low_rez	clr.w	-(sp)
		bra	set_rez
set_med_rez	move.w	#1,-(sp)
set_rez		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts


show_picture	lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#(160*248),a2
		move.w	#32000/4-1,d0
.loop		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.loop

		lea	pattern,a0
		move.w	#42*160/4-1,d0
.border		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.border
		rts


black_out	movem.l	black,d0-d7
		movem.l	d0-d7,Palette0.w
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
		clr.b	(a5)
		move.b	(a5),d0	;get original value
		move.b	#-1,(a5)	;poke new value
		move.b	(a5),d1
		cmp.b	d1,d0		;get value again, is it same?
		beq	.notSTE	;yes same so not ste
		move.b	d7,(a5)
.ste_found	move.w	#-1,ste_flag
.notSTE		rts



****************************************************************
test_4_pacifist_emulator
; FOR ST Programmers - How to detect PaCifiST (0.46 of greater)
;
; When Vsync is called with D6=D7='Emu?' and those registers are
; altered, you can assume you're running under an Emulator.
;
; If D6='PaCi' & D7='fiST', then it's under PaCifiST and A0 points out
; some extra hardware registers:
;
; 0     BYTE    major version (BCD)
; 1     BYTE    minor version (BCD)
;
; Special registers will be added with each version
        move.l  #'Emu?',d5
        move.l  d5,d7
        move.l  d5,d6
        move    #$25,-(a7)
        trap    #$e
        addq.l  #2,a7

        cmp.l   d5,d6
        bne.s   under_emu
	rts
under_emu
        cmp.l  #'PaCi',d6
        bne.s  not
        cmp.l  #'fiST',d7
        bne.s  not
	move.w	#-1,pacifist_flag
not	rts




****************
* DATA SECTION *
****************

data	INCBIN	absolute.MOD

	DS.B	6700			; Workspace
workspc	DS.W	1


nopacifist
	dc.b	27,'E'
	dc.b	13,10,10,10	
	dc.b	"                             PERSISTENCE OF VISION",13,10,10,10
	dc.b	"              Sorry POV 159 does now work on the Pacifist emulator",13,10
	dc.b	"                            due to the use of Timer A.",13,10,0
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
	dc.b	8, $0a		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6c		;keypad 6
	dc.b	6, $67		;keypad 7
	dc.b	7, $68		;keypad 8
	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"romeo.prg",0
	even
exec2	dc.b	"ovrplasm.prg",0
	even
exec3	dc.b	"ovr_adso.prg",0
	even
exec4	dc.b	"p_fullsc.prg",0
	even
exec5	dc.b	"p_mdist.prg",0
	even
exec6	dc.b	"p_shadow.prg",0
	even
exec7	dc.b	"p_silent.prg",0
	even
exec8	dc.b	"tribal_f.prg",0
	even
exec9	dc.b	"copier.pov",0
	even

pic	incbin	grn_man.pi1

nomouse		dc.b	$12,$1a
yesmouse	dc.b	$14,$08

picture		incbin	grn_man.PI1
pattern		incbin	"PATTERN.DAT"

font		incbin	"BORIS.FNT"

seed		dc.l	53

char_off	dc.w	0
text_ptr	dc.l	text_start
text_start	incbin	"SCROLLER.TXT"

add_one		dc.w	-12
add_two		dc.w	-8
add_three	dc.w	4
ptr_one		dc.w	0
ptr_two		dc.w	0
ptr_three	dc.w	0
path_one	incbin	"ONE.PTH"
path_two	incbin	"TWO.PTH"
path_three	incbin	"THREE.PTH"

clip_ptr	dc.w	0
clip_path
	dcb.w	176,0

ADD	set	1
X	set	0
TOG	set	0
	REPT	(8*4)
	IFGT	(X-144)
	dc.w	(144*4)
	ELSEIF
	dc.w	(X*4)
	ENDC
X	set	X+ADD
TOG	set	(TOG+1)&3
	IFEQ	TOG
ADD	set	ADD+1
	ENDC
	ENDR

CLIP	set	(72*2)
	dcb.w	16,(144*4)

SUB	set	8
X	set	144
TOG	set	0
	REPT	(8*4)
X	set	X-SUB
TOG	set	(TOG+1)&3
	IFEQ	TOG
SUB	set	SUB-1
	ENDC
	dc.w	(X*4)
	ENDR



	ifeq	DOWNLOAD
	SECTION BSS
	endc
bssstart

black		ds.b	32
old_timerb	ds.l	1
store		ds.l	1

oldkbd		ds.l	1
key		ds.w	1
ste_flag	ds.w	1
hertz_delay	ds.w	1
hertz_toggle	ds.w	1
oldvbl		ds.l	1
old_palette	ds.w	16
pstacksave	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1

clock		ds.w	1
vsync_flag	ds.w	1
pacifist_flag	ds.w	1

save_stk	ds.l	1
usp_bak		ds.l	1

first_scr	ds.l	1
scr_now		ds.l	1
scr_add		ds.l	1

dot_off		ds.w	1
dot_addrs	ds.w	(MAX_DOTS*2)

		ds.b	256
screens		ds.b	(160*248*2)

finish	even



eobss

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
