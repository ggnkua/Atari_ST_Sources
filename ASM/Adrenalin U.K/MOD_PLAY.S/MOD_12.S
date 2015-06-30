*************************************************************************
*			ADRENALIN UK MOD PLAYER				*
*			-----------------------				*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
* Grafix by: 	ANTHRAX							*
*									*
* Date:		14th March 1993						*
*									*
*									*
*									*
*									*
* This tracker player supports the following packers;-			*
*									*
*			ATOMIC 3.5					*
*			SPEEDPACKER 3					*
*									*
*************************************************************************
*
* Remember that this tracker can not play any modules which are over 260k
* Unpacked.
*
* When assembling for the final version set 'Final' to equ 'Yes'.
*
* Rem out any keys not used else a load error will occur.

; If you find certain mods don't play, try increasing the workspace (you'll
; have to increase it for 99.99% of OZYMANDIAS/BIOFEEDBACK mods).






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

atom_35	equ	NO	; Atomik v3.5 depack required ?
speed_3	equ	YES	; Speed Packer 3 depack required ?


FINAL=YES	;NO to remove escape to assembler code
		;NO to keep it on

TIMERB_LINE	equ	57

MAX_MOD_SIZE	equ	264000		; max mod size (unpacked)

	opt	o+,w-

	jsr	clear_bss
	jsr	set_super
	jsr	test_4_ste
	jsr	get_screen_base
	jsr	get_old_palette
	jsr	get_original_rez
	jsr	black_out
	jsr	set_low_rez
	jsr	print_titles
	jsr	show_picture

	lea	loadingpic,a1	;sort LOADING pic onto 256 byte boundary
	move.l	a1,d0
	clr.b	d0
	move.l	d0,a0
	move.l	a0,loadingpic_pos
	sub.w	#34,a0
	move.w	#32034/4-1,d1
movepic	move.l	(a1)+,(a0)+
	dbf	d1,movepic
	
	move.w	#-1,-(sp)
	move.l	loadingpic_pos,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	loadingpic_pos,a0
	sub.w	#32,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	bsr	load_mod1

	tst.w	ste_flag
	beq.s	no_ste
	bsr	vol_ste			; Calculate volume tables
	bsr	incrcal_ste		; Calculate tonetables
	move.l	#ste_timerb,sm_timerb
no_ste

	lea	nomouse,a0
	jsr	send_2_ik

	move.l	$120.w,old_timerb
	move.l	$70.w,oldvbl
	move.l	$118.w,oldkbd

restart_mod
	tst.w	ste_flag
	bne.s	init_ste
	move.w	#-1,-(sp)
	move.l	screen_base,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	bsr	muson_stfm			; Install music
	lea	pic+2,a0
	lea	$ffff8240.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
	bra.s	main_loop
init_ste
	bsr	vol_ste			; Calculate volume tables
	bsr	incrcal_ste		; Calculate tonetables
	bsr	muson_ste
	lea	pic+2,a0
	lea	$ffff8240.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
	move.w	#-1,-(sp)
	move.l	screen_base,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp


main_loop	
	bsr	vsync
;	move.w	#$123,$ffff8240.w
	bsr	scroll
	bsr	do_vus
;	clr.w	$ffff8240.w

	move.w	key,d0

	ifeq	FINAL
	cmp.w	#1,d0		;ESC
	beq	assem
	ENDC

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
	cmp.w	mod_number,d1
	beq	main_loop	;prevent loading present mod
	move.w	d1,mod_number
	lsl.w	#2,d1
	lea	filename_table,a0
	move.l	(a0,d1.w),a0
	lea	$200.w,a1
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR

exit	tst.w	ste_flag
	bne.s	.shut_down_ste
	bsr	musoff_stfm	; Restore system completely
	bra	.co
.shut_down_ste
	bsr	musoff_ste
;reset all bits to default to make mod start from beginning
	move.l	#sample1_ste,wiz1lc
	move.l	#sample1_ste,wiz2lc
	move.l	#sample1_ste,wiz3lc
	move.l	#sample1_ste,wiz4lc

	move.l	#sample1_ste,samp1_ste
	move.l	#sample2_ste,samp2_ste

	lea	$FFFF8907.w,a0
	move.l	#eobss,d0	;start of DMA play buffer
	move.l	d0,d1
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)
	move.b	d1,12(a0)	;end of DMA play buffer
	lsr.w	#8,d1
	move.l	d1,7(a0)


.co	move.l	#320,wiz1len
	move.w	#320,wiz1rpt
	clr.w	wiz1pos
	clr.w	wiz1frc
	move.l	#320,wiz2len
	move.w	#320,wiz2rpt
	clr.w	wiz2pos
	clr.w	wiz2frc
	move.l	#320,wiz3len
	move.w	#320,wiz3rpt
	clr.w	wiz3pos
	clr.w	wiz3frc
	move.l	#320,wiz4len
	move.w	#320,wiz4rpt
	clr.w	wiz4pos
	clr.w	wiz4frc
	move.l	#dummy,aud1lc
	clr.w	aud1len
	clr.w	aud1per
	clr.w	aud1vol
	clr.w	aud1vol+2
	clr.w	aud1vol+4
	clr.w	aud1vol+6
	move.l	#dummy,aud2lc
	clr.w	aud2len
	clr.w	aud2per
	clr.w	aud2vol
	clr.w	aud2vol+2
	clr.w	aud2vol+4
	clr.w	aud2vol+6
	move.l	#dummy,aud3lc
	clr.w	aud3len
	clr.w	aud3per
	clr.w	aud3vol
	clr.w	aud3vol+2
	clr.w	aud3vol+4
	clr.w	aud3vol+6
	move.l	#dummy,aud4lc
	clr.w	aud4len
	clr.w	aud4per
	clr.w	aud4vol
	clr.w	dmactrl
	clr.l	dummy

	move.w	#6,speed
	clr.w	counter
	clr.b	songpos
	clr.b	break
	clr.w	pattpos
	clr.w	dmacon

	lea	voice1,a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.w	#1,(a0)+
	clr.l	(a0)+
	clr.w	(a0)+

	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.w	#2,(a0)+
	clr.l	(a0)+
	clr.w	(a0)+

	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.w	#4,(a0)+
	clr.l	(a0)+
	clr.w	(a0)+

	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.w	#8,(a0)+
	clr.l	(a0)+
	clr.w	(a0)

	move.w	#-1,-(sp)
	move.l	loadingpic_pos,-(sp)
	move.l	(sp),-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	loadingpic_pos,a0
	sub.w	#32,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	bsr	load_mod

	bra	restart_mod


	ifeq	FINAL
assem	tst.w	ste_flag
	bne.s	.shut_down_ste
	move	#$2700,sr
	move.l	oldkbd,$118.w
	move.l	oldvbl,$70.w
	move.l	oldtimd(pc),$110.w	; Restore vectors
	move.l	oldtima(pc),$134.w
	move.l	s06(pc),$FFFFFA06.w
	move.l	s12(pc),$FFFFFA12.w
	move.b	s1d(pc),$FFFFFA1D.w
	bset	#3,$FFFFFA17.w		; Softvectors
	lea	yesmouse,a0
	jsr	send_2_ik
	move	#$2300,sr
	bra.s	.co
.shut_down_ste
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
	move.l	oldtima(pc),$134.w	; Restore everything
	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w
	clr.b	$FFFF8901.w		; Stop DMA
	bset	#3,$FFFFFA17.w		; Softvectors
	lea	yesmouse,a0
	jsr	send_2_ik
	move	#$2300,sr

.co	jsr	set_old_palette
	jsr	set_med_rez
	jsr	set_user
	clr.w	-(sp)
	trap	#1
	ENDC


reset	move.l	4.w,-(sp)
	rts





toggle_vus	tst.w	vucontrol_delay
		bne	main_loop
		eor.w	#-1,vucontrol
		move.w	#10,vucontrol_delay
		bra	main_loop




;voice+16=instrument????
do_vus	move.l	screen_base,a0
	add.w	#(160*182)+2,a0
	moveq	#0,d2
	moveq	#-1,d3

	lea	voice1,a1
	lea	vus+0,a3
	bsr	vu
	add.w	#(160*128)+40,a0

	lea	voice4,a1
	lea	vus+2,a3
	bsr	vu
	add.w	#(160*128)+48,a0

	lea	voice2,a1
	lea	vus+4,a3
	bsr	vu
	add.w	#(160*128)+40,a0

	lea	voice3,a1
	lea	vus+6,a3

vu	tst.w	vucontrol
	beq.s	.vu_on
	moveq	#0,d0
	bra.s	.lower


.vu_on	move.w	(a1),d0		;get chan data from tracker
	beq.s	.lower
	move.w	#62,(a3)
	bra.s	.over

.lower	tst.w	(a3)		;is last value bigger than ours?
	beq.s	.over		;no!

	subq.w	#2,(a3)		;decrease data

.over	move.w	(a3),d0
	and.w	#63,d0
	move.w	#63,d1
	sub.w	d0,d1
.loop	move.w	d3,(a0)	;fill in
	move.w	d3,8(a0)
	move.w	d3,16(a0)
	move.w	d3,24(a0)
	lea	-320(a0),a0
	dbf	d0,.loop
	sub.w	#1,d1
.clear	move.w	d2,(a0)		;clear above
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	move.w	d2,24(a0)
	lea	-320(a0),a0
	dbf	d1,.clear
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
	add.w	#160*(200-16),a5
	move.l	a5,a2
	add.w	#152,a2

	lea	sbuffer,a1
;scroll buffer into right pixel of screen ready for scrolling
	move.w	#(DEPTH-1),d1
aloop	roxl.w	(a1)+			;shift buffer
	move.w	sr,d0			;get the status regster
	and.w	#1,d0			;mask off all but carry flag
	or.w	d0,(a2)			;poke right pixel to screen
	lea	160(a2),a2		;down a line on screen
	dbf	d1,aloop

	and.w	#%1111111111101111,SR		;clear X flag

	move.w	#(DEPTH)-1,d0
loopy	roxl.w	152(a5)
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
	move.w	(a5),d3
	and.w	#$7fff,d3
	roxl.w	#1,d3
	move.w	d3,(a5)
	lea	160(a5),a5
	dbf	d0,loopy
	sub.w	#1,scroll_number
	rts


load_mod1	lea	fname1,a0	;setup mod 1 to load on startup
		lea	$200.w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+

load_mod	clr.w	-(sp)
		pea	$200
		move.w	#$3d,-(sp)
		trap	#1
		addq	#8,sp
		tst.l	d0
		bmi.s	error_open
		move.w	d0,d7
		pea	mod_data
		move.l	#MAX_MOD_SIZE,-(sp)		;max mod length
		move.w	d7,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp
		tst.l	d0
		bmi.s	error_read
		move.w	d7,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp

		lea	mod_data,a0
		bsr	depack

		rts
error_open	bsr	error_low
		pea	error_open_mess
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		bra.s	common_error
error_read	bsr	error_low
		pea	error_read_mess
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
common_error	move.l	#$07770777,d0
		lea	$ffff8242.w,a0
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.w	d0,(a0)
		move.w	#$2700,sr
stop		eor.w	#$700,$ffff8240.w
		bra.s	stop
error_low	clr.w	-(sp)
		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		rts


depack		
		ifne	atom_35
		bsr	depack_atm		;atomic 3.5
		endc

		ifne	speed_3
		bsr	depack_spv3		;speedpack 3 only if required
		endc
		rts


;----------------------------------------------------
	ifne	atom_35
;ATOMIK DECRUNCH SOURCE CODE v3.5 (non optimise, pas le temps. sorry...)

;ce depacker est indissociable du programme ATOMIK V3.5 tous les mecs
;qui garderons se source dans l'espoir de prendre de l'importance
;en se disant moi je l'ai et pas l'autre sont des lamers.

;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)

;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.

;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
             
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.

;call it by BSR DEPACK or JSR DEPACK but call it!

MODE		EQU	1
PIC_ALGO	EQU	0
DEC_SPACE	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE	EQU	0

depack_atm	movem.l	d0-a6,-(a7)
		cmp.l	#"ATM5",(a0)+
		bne	not_packed
		link	a2,#-28
		move.l	(a0)+,d0
		ifne	MODE
		lea	4(a0,d0.l),a5
		move.l	d0,-(a7)
		elseif
		move.l	a1,a5
		add.l	d0,a5
		endc
		move.l	a5,a4
		ifne	MODE
		ifne	DEC_SPACE
		lea	DEC_SPACE(a4),a5
		endc
		endc
		lea	-$c(a4),a4
		move.l	(a0)+,d0
		move.l	a0,a6
		add.l	d0,a6
		ifne	PIC_ALGO
		moveq	#0,d0
		move.b	-(a6),d0
		move	d0,-2(a2)
		ifne	RESTORE_SPACE
		lsl	#2,d0
		sub	d0,a4
		endc
		elseif
		ifne	RESTORE_SPACE
		clr	-2(a2)
		endc
		subq	#1,a6
		endc
		ifne	RESTORE_SPACE
		lea	buff_marg(pc),a3
		move	-2(a2),d0
		lsl	#2,d0
		add	#DEC_SPACE+$C,d0
		bra.s	.save
.save_m		move.b	(a4)+,(a3)+
		subq	#1,d0
.save		bne.s	.save_m
		movem.l	a3-a4,-(a7)
		endc
		ifne	PIC_ALGO
		pea	(a5)
		endc
		move.b	-(a6),d7
		bra	take_type
decrunch	move	d3,d5
take_lenght	add.b	d7,d7
.cont_take	dbcs	d5,take_lenght
		beq.s	.empty1
		bcc.s	.next_cod
		sub	d3,d5
		neg	d5
		bra.s	.do_copy1
.next_cod	moveq	#3,d6
		bsr.s	get_bit2
		beq.s	.next_cod1
		bra.s	.do_copy
.next_cod1	moveq	#7,d6
		bsr.s	get_bit2
		beq.s	.next_cod2
		add	#15,d5
		bra.s	.do_copy
.empty1		move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont_take
.next_cod2	moveq	#13,d6
		bsr.s	get_bit2
		add	#255+15,d5
.do_copy	add	d3,d5
.do_copy1	lea	decrun_table(pc),a4
		move	d5,d2
		bne.s	bigger
		add.b	d7,d7
		bne.s	.not_empty
		move.b	-(a6),d7
		addx.b	d7,d7
.not_empty	bcs.s	.ho_kesako
		moveq	#1,d6
		bra.s	word
.ho_kesako	moveq	#3,d6
		bsr.s	get_bit2
		tst.b	-28(a2)
		beq.s	.ho_kesako1
		move.b	10-28(a2,d5.w),-(a5)
		bra	tst_end
.ho_kesako1	move.b	(a5),d0
		btst	#3,d5
		bne.s	.ho_kesako2
		bra.s	.ho_kesako3
.ho_kesako2	add.b	#$f0,d5
.ho_kesako3	sub.b	d5,d0
		move.b	d0,-(a5)
		bra	tst_end
get_bit2	clr	d5
.get_bits	add.b	d7,d7
		beq.s	.empty
.cont		addx	d5,d5
		dbf	d6,.get_bits
		tst	d5
		rts
.empty		move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont
bigger		moveq	#2,d6
word		bsr.s	get_bit2
contus		move	d5,d4
		move.b	14(a4,d4.w),d6
		ext	d6
		tst.b	1-28(a2)
		bne.s	.spe_ofcod1
		addq	#4,d6
		bra.s	.nospe_ofcod1
.spe_ofcod1	bsr.s	get_bit2
		move	d5,d1
		lsl	#4,d1
		moveq	#2,d6
		bsr.s	get_bit2
		cmp.b	#7,d5
		blt.s	.take_orof
		moveq	#0,d6
		bsr.s	get_bit2
		beq.s	.its_little
		moveq	#2,d6
		bsr.s	get_bit2
		add	d5,d5
		or	d1,d5
		bra.s	.spe_ofcod2
.its_little	or.b	2-28(a2),d1
		bra.s	.spe_ofcod3
.take_orof	or.b	3-28(a2,d5.w),d1
.spe_ofcod3	move	d1,d5
		bra.s	.spe_ofcod2
.nospe_ofcod1	bsr.s	get_bit2
.spe_ofcod2	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty	bcs.s	string
	move.b	-(a6),-(a5)
tst_end	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod	sf	1-28(a2)
.spe_ofcod	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif	sf	-28(a2)
.freq	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string	bra	decrunch
work_done
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m	move.b	-(a3),-(a4)
	subq	#1,d0
.restore	bne.s	.restore_m
	endc
	unlk	a2
not_packed	movem.l	(a7)+,d0-a6
 	rts
decrun_table	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture	move	-2(a2),d7
.next_picture	dbf	d7,.decod_algo
	rts
.decod_algo	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd	lea	$7d00(a1),a2
.next_planes	moveq	#3,d6
.next_word	move	(a1)+,d0
	moveq	#3,d5
.next_bits	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
	ifne	MODE
copy_decrun	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc
	ifne	RESTORE_SPACE
buff_marg	dcb.b	$90+DEC_SPACE+$C
	endc

	endc
;------------------------------------------------------
	ifne	speed_3
* UNPACK source for SPACKERv3	(C)THE FIREHAWKS'92
* -------------------------------------------------
* in	a0: even address start packed block
* out	d0: original length or 0 if not SPv3 packed
* =================================================
* Use AUTO_SP3.PRG for multiblk packed files

depack_spv3
	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	sp3_53(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	sp3_02
	tst.w	(a1)
	bne.s	sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(sp),a1
	lea	sp3_58-sp3_53(a6),a3
	moveq	#128-1,d0
sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	sp3_03
	bsr	sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	sp3_58-sp3_53(a6),a2
	bsr	sp3_22
	bsr	sp3_15
sp3_02:	movem.l	(sp)+,d0-a6
	rts
sp3_03:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_04
	move.w	$FFFF8240.W,2(a6)
	btst	#1,$FFFF8260.W
	bne.s	sp3_04
	swap	d5
sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	sp3_54-sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
sp3_05:	cmp.b	d6,d3
	bne.s	sp3_06
	addq.w	#2,d3
sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	sp3_57-sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,sp3_07
	move.b	-(a0),-(a3)
	beq.s	sp3_08
	suba.w	d4,a0
sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
sp3_09:	bsr.s	sp3_10
	bsr.s	sp3_10
	dbf	d2,sp3_09
	rts
sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
sp3_11:	bcs.s	sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
sp3_12:	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	beq.s	sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
sp3_13:	moveq	#2,d1
	bsr	sp3_44
	move.w	sp3_55-sp3_53(a6),d1
	add.w	d0,d0
	beq.s	sp3_14
	move.w	sp3_55+2-sp3_53(a6),d1
sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
sp3_15:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_16
	move.w	2(a6),$FFFF8240.W
sp3_16:	tst.w	d6
	bpl.s	sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
sp3_17:	moveq	#3,d6
sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,sp3_19
	dbf	d6,sp3_18
	cmpa.l	a2,a3
	blt.s	sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	sp3_17
sp3_20:	rts
sp3_21:	move.b	-(a0),-(a1)
sp3_22:	swap	d5
	beq.s	sp3_23
	move.w	d5,$FFFF8240.W
sp3_23:	lea	sp3_56+2-sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	sp3_25
	rts
sp3_24:	adda.w	d3,a3
sp3_25:	add.b	d7,d7
	bcc.s	sp3_28
	beq.s	sp3_27
sp3_26:	move.w	(a3),d3
	bmi.s	sp3_24
	bra.s	sp3_29
sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	sp3_26
sp3_28:	move.w	-(a3),d3
	bmi.s	sp3_24
sp3_29:	ext.w	d3
	jmp	sp3_30(pc,d3.w)
sp3_30:	bra.s	sp3_30
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_37
	bra.s	sp3_36
	bra.s	sp3_32
	bra.s	sp3_33
	bra.s	sp3_31
	bra.s	sp3_34
	bra.s	sp3_21
sp3_31:	move.b	(a5),-(a1)
	bra.s	sp3_22
sp3_32:	bsr.s	sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_33:	bsr.s	sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_34:	moveq	#3,d1
	bsr.s	sp3_44
	lsr.w	#1,d0
	bcc.s	sp3_35
	not.w	d0
sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	sp3_22
sp3_36:	lea	sp3_52-2-sp3_53(a6),a4
	bsr.s	sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	sp3_22
sp3_37:	moveq	#3,d1
	bsr.s	sp3_44
	tst.w	d0
	beq.s	sp3_38
	addq.w	#5,d0
	bra.s	sp3_40
sp3_38:	move.b	-(a0),d0
	beq.s	sp3_39
	addi.w	#20,d0
	bra.s	sp3_40
sp3_39:	moveq	#13,d1
	bsr.s	sp3_44
	addi.w	#276,d0
sp3_40:	move.w	d0,d3
	add.w	d3,d3
sp3_41:	lea	sp3_52-sp3_53(a6),a4
	bsr.s	sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,sp3_42
	bra	sp3_22
sp3_43:	moveq	#0,d1
	move.b	(a3),d1
sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	sp3_47
sp3_45:	add.b	d7,d7
	beq.s	sp3_46
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	sp3_45
	rts
sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	sp3_44
	tst.b	d6
	beq.s	sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	sp3_50
	lsr.w	#1,d0
	beq.s	sp3_49
	roxr.b	#1,d7
	bcc.s	sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	sp3_50
sp3_49:	moveq	#2,d1
	bsr.s	sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	sp3_51
sp3_50:	lea	sp3_54-sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032

sp3_53:	DS.L	1
sp3_54:	DS.B	8
sp3_55:	DS.W	2*64
sp3_56:	DS.W	2
	DS.B	1
sp3_57:	DS.B	1
	DS.B	2*64
sp3_58:	DS.B	512

	endc
;---------------------------------------------



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



************** STFM TIMER B (RASTER ISR) **************

stfm_timerb
	move.w	#0,$ffff8244.w		;change colour ASAP to prevent flicker
stfm_raster	equ *-4			;this means PC-4 which changes the colour for FFFF8242
	clr.b	$fffffa1b.w		;stop
	move.l	a0,-(sp)		;stash these
	move.l	d0,-(sp)		;regs
	move.l	colour_pos,a0		;get position in colour table
	move.l	(a0)+,d0		;get colour
	move.l	a0,colour_pos		;store new pos
	tst.l	d0			;is it FFFFFFFF??
	bmi.s	.set_scroller_rast	;Yeah
	move.w	d0,stfm_raster		;redefine vu colour
	move.l	(sp)+,d0		;put back these
	move.l	(sp)+,a0		;regs
	move.b	#7,$fffffa21.w		;make timerB occur every xx lines
	move.b	#8,$fffffa1b.w		;reenable timer B
	rte				;get outta here
.set_scroller_rast
	move.l	#scroller_timerb,$120.w
	move.w	2(a0),sraster		;get colour
	move.l	(sp)+,d0		;regs
	move.l	(sp)+,a0		;regs
	move.b	#1,$fffffa21.w		;make timerB occur every line
	move.b	#8,$fffffa1b.w		;reenable timer B
	rte				;get outta here


************** STE TIMER B (RASTER ISR) **************
ste_timerb	move.l	#0,$ffff8244.w		;change colour ASAP to prevent flicker
vuraster	equ *-6			;this means PC-6 which changes the colour for VUs
	move.w	#0,$ffff8242.w
titleraster	equ	*-4
	clr.b	$fffffa1b.w		;stop
	move.l	a0,-(sp)		;stash these
	move.l	d0,-(sp)		;regs
	move.l	colour_pos,a0		;get position in colour table
	move.l	(a0)+,d0		;get colour
	move.l	a0,colour_pos		;store new pos
	tst.l	d0			;is it FFFFFFFF??
	bmi.s	.set_scroller_rast	;Yeah
	move.w	d0,vuraster		;redefine vu colour
	swap	d0
	move.w	d0,titleraster
	move.w	d0,vuraster+2
	move.l	(sp)+,d0		;put back these
	move.l	(sp)+,a0		;regs
	move.b	#7,$fffffa21.w		;make timerB occur every xx lines
	move.b	#8,$fffffa1b.w		;reenable timer B
	rte				;get outta here
.set_scroller_rast
	move.l	#scroller_timerb,$120.w
	move.w	(a0),sraster		;get colour
	move.l	(sp)+,d0
	move.l	(sp)+,a0
	move.b	#1,$fffffa21.w		;make timerB occur every line
	move.b	#8,$fffffa1b.w		;reenable timer B
	rte				;get outta here








scroller_timerb	move.w	#0,$ffff8242.w
sraster		equ *-4
		clr.b	$fffffa1b.w		;stop
		move.l	a0,-(sp)		;stash this
		move.l	colour_pos,a0		;get position in colour table
		move.w	(a0)+,sraster		;get colour
		move.l	a0,colour_pos		;store new pos
		move.l	(sp)+,a0		;unstash
		move.b	#1,$fffffa21.w		;make timerB occur every line
		move.b	#8,$fffffa1b.w		;reenable timer B
		rte				;get outta here






muson_ste
	bsr	vol_ste			; Calculate volume tables
	bsr	incrcal_ste		; Calculate tonetables

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move	#$2700,sr
	lea	store,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)

	clr.b	$fffffa1b.w		;stop timerb
	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	#new_kbd,$118.w
	move.l	#ste_timerb,$120.w
	move.l	#newvbl,$70.w
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


musoff_ste
	move	#$2700,sr

	clr.b	$FFFFFA19.w		; Stop timer A
	clr.b	$FFFFFA1b.w		; Stop timer B

;	move.l	old_timerb,$120.w
;	move.l	oldvbl,$70.w
;	move.l	oldkbd,$118.w
	lea	store,a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0),$fffffa13.w

;	move.l	oldtima(pc),$134.w	; Restore everything

	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w

	clr.b	$FFFF8901.w		; Stop DMA
	bset	#3,$FFFFFA17.w		; Softvectors

;	lea	yesmouse,a0
;	jsr	send_2_ik

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

	move.l	samp1_ste(pc),d0	;start of buffer for DMA
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	samp1_ste(pc),d0	;end of buffer for DMA
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
;	lea	nomouse,a0
;	jsr	send_2_ik

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
	move.l	#stfm_timerb,sm_timerb
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#stfm_timerb,$120.w
	bclr	#3,$fffffa17.w		; Autovectors
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#TIMERB_LINE,$fffffa21.w	;timer B data
	move.b	#8,$fffffa1b.w		;ei timber B

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
	move.b	#A_DATA,$FFFFFA1F.w	;set timer A data
	move.b	#D_DATA,$FFFFFA25.w	;set timer D data
	move.b	#2,$FFFFFA19.w		;start timer A
	move.b	#6,$FFFFFA1D.w		;timer C & D control

	move.l	$110.w,oldtimd
	move.l	$134.w,oldtima
	move.l	#timerd,$110.w
	move.l	#playvec,$134.w

	lea	sample1(pc),a6
	move	#$2300,sr
	rts

newvbl		clr.b	$fffffa1b.w
		move.w	pic+4,$ffff8242.w
		clr.w	vsyncflag
		tst.w	ste_flag
		beq.s	.stfm
		move.l	colours,vuraster
		bra.s	.over
.stfm		move.w	colours,stfm_raster
.over		move.w	srast,sraster
		move.l	pic+2,$ffff8240.w
		move.l	#colours+2,colour_pos
		move.l	#0,$120.w	;self modified timerb rout
sm_timerb	equ	*-6
		move.b	#TIMERB_LINE,$fffffa21.w	;set init timerb data

		movem.l	d0/a0-a1,-(sp)
		move.w	scrcoloff,d0
		and.w	#255,d0
		lea	scroller_colours,a0
		add.w	d0,a0
		lea	srast,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0),(a1)
		movem.l	(sp)+,d0/a0-a1
		add.w	#2,scrcoloff
		move.b	#8,$fffffa1b.w		;ei timer b
		tst.w	vucontrol_delay
		bne.s	.dec_vucontrol
		rte
.dec_vucontrol	sub.w	#1,vucontrol_delay
		rte




musoff_stfm	move	#$2700,sr

		move.l	oldkbd,$118.w
		move.l	oldvbl,$70.w
		move.l	oldtimd(pc),$110.w	; Restore vectors
		move.l	oldtima(pc),$134.w

		move.l	s06(pc),$FFFFFA06.w
		move.l	s12(pc),$FFFFFA12.w
		move.b	s1d(pc),$FFFFFA1D.w

		bset	#3,$FFFFFA17.w		; Softvectors

;		lea	yesmouse,a0
;		jsr	send_2_ik

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
	addq.w	#1,counter
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

get_screen_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base
		rts

get_original_rez
		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez
		rts

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



*************************************************************************
*		PRINT TITLES ROUT - NON MASKING	VERSION			*
*									*
* Revision:	1.2							*
* Date:		13/3/93							*
* By:		MSD 							*
*									*
*									*
*************************************************************************
*

TITLE_FONT_DEPTH	equ	6

print_titles	lea	pic+34,a0		;alter this to move the titles down the screen
		add.w	#160*64,a0
		move.l	a0,a6
		lea	screen_titles,a1
		lea	screen_titles_font,a2

		move.w	#12-1,d0	;max titles per menu
.loop		move.w	#20-1,d6	;40 across each line (I know it says 20 but it's 20 words)
.loop2		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#TITLE_FONT_DEPTH,d1		;chars are 9 bytes each

BYTE_OFF	set	0
LINE_OFF	set	0

		REPT	TITLE_FONT_DEPTH
		move.b	BYTE_OFF(a2,d1.w),d5	;get char

		move.b	d5,LINE_OFF+0(a0)	;poke data back to scrn


BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+160
		ENDR


BYTE_OFF	set	0
LINE_OFF	set	0
		moveq	#0,d1
		move.b	(a1)+,d1	;get ASCII char
		sub.w	#32,d1		;rid of ASCII
		mulu	#TITLE_FONT_DEPTH,d1		;chars are 9 bytes each

		REPT	TITLE_FONT_DEPTH
		move.b	BYTE_OFF(a2,d1.w),d5
		move.b	d5,LINE_OFF+1(a0)

BYTE_OFF	set	BYTE_OFF+1
LINE_OFF	set	LINE_OFF+160
		ENDR

		addq.w	#8,a0

		dbf	d6,.loop2
		lea	160*7(a6),a6
		move.l	a6,a0
		dbf	d0,.loop
		rts


****************
* DATA SECTION *
****************


screen_titles
;TITLES AS THEY WILL APPEAR ON THE MENU........ (MAX 40 CHARS)
;          ------1234567890123456789012345678901234567890------
	dc.b	"             ADRENALIN U.K.             "
	dc.b	"                                        "
	dc.b	"             MODULE DISK 10             "
	dc.b	"                                        "
	dc.b	"   F1: TRSI_CIV         F5: UTOPIA_4    "
	dc.b	"   F2: UTOPIA 1         F6: HUNTER      "
	dc.b	"   F3: UTOPIA 2         F7: AMBIENT     "
	dc.b	"   F4: UTOPIA 3         F8: GREGORIAN   "
	dc.b	"       F9: CRACKERS JOURNAL 26          "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"      DISK COMPILED BY: STRUCTURE       "
	even

screen_titles_font
	DC.L	0,$3C3C,$3C3C003C,$28280000,$127E,$2424FE48,$38545038
	dc.l	$14382474,$280A1712,$78C470C4,-$3387E7E8,0,$C181818
	dc.l	$180C3018,$18181830,$20A870,-$57DFFFF0,$107C1010,0
	dc.l	$10300000,$780000,0,$18180408,$8101020,$78CCCCCC
	dc.l	-$3387CF90,$30303030,$788C1830,$60FCFC18,$30388C78
	dc.l	$1C2C4C8C,-$1F30340,-$7F37388,$78C0F8CC,-$338703F4
	dc.l	$C183030,$78CC7878,-$33878734,-$3383F388,$1800,$18000000
	dc.l	$18001830,$183060,$30180000,$7E007E00,$180C06,$C18788C
	dc.l	$18300030,0,$78CC,-$33330334,-$7330704,-$33078734,-$3F3F3388
	dc.l	-$7333334,-$33070340,-$73F0304,-$33F3F08,-$3F3F873C
	dc.l	-$3F233388,-$33330304,-$3333CFD0,$30303030,$C0C0CCC
	dc.l	-$3873328,-$F1F0F28,-$3F3F3F40,-$3F033912,-$101293A
	dc.l	-$33130304,-$23338734,-$33333388,-$7333308,-$3F3F8734
	dc.l	-$33332794,-$7333308,-$33338340,$60301CF8,-$3CFCFD0
	dc.l	$3030CCCC,-$33333388,-$33333334,$4830B4B4,-$4B4B4B08 
	dc.l	-$33333388,-$33333334,-$3387CFD0,-$3F3E7D0,$60FC0000
	dc.l	0,0,0,0,0,0,0,0,$78,-$73833334,-$3F3F0734,-$3333FF90
	dc.l	-$373F3F38,$C0C7CCC,-$3333FF88,-$3333073C,$3860F060
	dc.l	$6060007C,-$33338374,$60607C66,$66663000,$30303030
	dc.l	$18001818,$1898CCD8,-$F1F0F28,$30303030,$303000FC
	dc.l	-$2929292A,$F8CCCC,-$3333FF88,-$33333334,$F8CCCC
	dc.l	-$73FFF84,-$333383F4,$D8E0C0,-$3F3FFF90,-$379FCF68
	dc.l	$60F06060,$606000CC,-$33333334,$CCCCCC,-$3337FF26
	dc.l	-$25252526,$CCCC78,-$3333FF34,-$33338374,$FC1830
	dc.l	$60C0FEFE,-$1010102,0,0,0,0,0,0,0,0,0,0,0,0 


mod_data	ds.b	MAX_MOD_SIZE

		DS.B	32768			; Workspace
workspc		DS.W	1


;Keys here are: function keys F1-F10, keys 1-3 and keypad 1-3
; 
;If you have 9 mods then I would suggest either using keys and keypad 1-9
;or functions keys F1-F9.
;If you have more then you could use keys A-Z or a combination of 
;function keys and numeric keys.
;
;This test version has 13 files so you have to detect 13 different keys. 
;
;
; Key Codes are as follow:
;
; 0=$0B  1=$02  2=$03  3=$04  4=$05  5=$06  6=$07  7=$08  8=$09  9=$0A
;
; F1=$3B  F2=$3C  F3=$3D  F4=$3E  F5=$3F  F6=$40  F7=$41  F8=$42  F9=$43
; F10=$44
;
; KEYPAD 0=$70  1=$6D  2=$6E  3=$6F  4=$6A  5=$6B  6=$6C  7=$67  8=$68
;
; KEYPAD 9=$69

demo_keys
	dc.b	0, $3b		;key F1
	dc.b	1, $3c		;key F2
	dc.b	2, $3d		;key F3
	dc.b	3, $3e		;key F4
	dc.b	4, $3f		;key F5
	dc.b	5, $40		;key F6
	dc.b	6, $41		;key F7
	dc.b	7, $42		;key F8
	dc.b	8, $43		;key F9
;	dc.b	9, $44		;key F10
	
;	dc.b	10, $02		;key 1
;	dc.b	11, $03		;key 2
;	dc.b	12, $04		;key 3

;	dc.b	10, $6d		;keypad 1
;	dc.b	11, $6e		;keypad 2
;	dc.b	12, $6f		;keypad 3
	dc.b	-1, -1

;Below is the filename look up table. There are 13 files, so we enter the
;different look up names up to 'fname13'. If there were only 10 files we'd
;only go to 'fname10' and delete the ones thereafter. 

filename_table	dc.l	fname1,fname2,fname3,fname4,fname5,fname6,fname7,fname8
		dc.l	fname9
;		dc.l	fname10,fname11,fname12,fname13

;As well as altering the filename look up table you also have to input all
;the filenames required to be loaded, see below.
 
fname1	dc.b	"trsi_civ.mod,0"
	even
fname2	dc.b	"utopia_1.mod",0
	even
fname3	dc.b	"utopia_2.mod",0
	even
fname4	dc.b	"utopia_3.mod",0
	even
fname5	dc.b	"utopia_4.mod",0
	even
fname6	dc.b	"hunter.mod",0
	even
fname7	dc.b	"ambient.mod",0
	even
fname8	dc.b	"gregoria.mod",0
	even
fname9	dc.b	"cj_26.mod",0
	even
;fname10	dc.b	"decathron.mod",0
;	even
;fname11	dc.b	".mod",0
;	even
;fname12	dc.b	".mod",0
;	even
;fname13	dc.b	".mod",0
;	even

;End of the filename look up table etc.

pic		incbin	pic3.pi1
		ds.b	34
		ds.b	256
loadingpic	incbin	loader2.pi1
loadingpic_pos	ds.l	1
nomouse		dc.b	$12,$1a
yesmouse	dc.b	$14,$08
line_ptr	dc.l	scroll_text

scroll_text
 dc.b "                                 "
 dc.b "ADRENALIN U.K. OF THE BRITISH ALLIANCE PROUDLY PRESENT COMPACT "
 DC.B "MODULE DISK TEN - YES, THE FIRST DECADE IS UPON US !!   RELEASE DATE 20/07/93.    "
 DC.B "AS USUAL, IT IS  STRUCTURE  (THE OLD MAN OF ADRENALIN) IS "
 DC.B "BACK WITH HIS TRUSTY GOLD PLATED PACEMAKER !!  FOR THOSE OF YOU WHO "
 DC.B "READ ABOUT MY BAD BACK ON THE SCROLLER FOR ADR MOD DISK EIGHT, IT IS 100% OK NOW !  A SIMPLE INJECTION "
 DC.B "AND I'M BACK ON MY FEET !  SO I THOUGHT I WOULD CELEBRATE AND RELEASE ANOTHER "
 DC.B "MODULE DISK FOR YOU LOT OUT THERE !  MAC ERROR WILL BE DOING THE NEXT WODGE OF DISKS AS HE HAS BEEN INUNDATED "
 DC.B "WITH TONNES OF THE LITTLE BLEEDERS.  ADR WILL BE EVEN MORE PRODUCTIVE THAN EVER BEFORE ..............     "

 DC.B "I SHALL NOW DESCRIBE THE CONTENTS OF THIS DISK FOR YOU.  "

 DC.B "FIRST UP IS A REALLY SMALL MODULE THAT I RIPPED FROM THE INTRO BY TRSI OFF THEIR "
 DC.B "CIVILIZATION HACK (THE INTRO WAS ON AN ANIMAL MINE DISK - I DON'T BOTHER PIRATING "
 DC.B "ST GAMES ANYMORE AS THE AMIGA VERSIONS ARE TEN TIMES BETTER !!).  APPARENTLY, MUG U.K. "
 DC.B "HAS KNOCKED UP ONE OF HIS INFAMOUS CHEAT ROUTINES FOR CIVILIZATION, SO LOOK OUT FOR THAT "
 DC.B "IN YOUR PD LIBRARIES/ADR DISKS SOON !!  NEXT WE HAVE SOME MORE AMIGA GOLDEN OLDIES IN THE "
 DC.B "SHAPE OF UTOPIA FROM BAZZA LEITCH (GAME BY GREMLIN GRAPHICS) OF IMAGITEC.  DEPACK THE FIRST "
 DC.B "MODULE AND SHOVE IT INTO A TRACKER PROGRAM AND READ WHAT BAZZA LEITCH HAS WRITTEN IN "
 DC.B "THE SAMPLE NAMES !!  HA! HA!  NEXT WE HAVE SOME TUNES THAT I RIPPED FROM SOME MORE "
 DC.B "ANIMAL MINE DISKS, BUT I CAN'T REMEMBER WHERE FROM EXACTLY BECAUSE MY YOUNGEST NIPPER "
 DC.B "HAS BORROWED MY NOTEPAD AND HASN'T RETURNED IT !!  IF MEMORY SERVES ME RIGHT, I THINK "
 DC.B "IT WAS AN AURA STE-ONLY DEMO ....... ?  THE ONE AFTER HUNTER WAS SENT TO ME BY GOOD OLD "
 DC.B "(WELL, HE SAYS HE IS OLD, BUT HIS AGE IS NOTHING COMPARED TO MINE!) MUG U.K. !!  CHEERS "
 DC.B "MATE !  FINALLY THE LAST TWO MODS WERE RIPPED BY ME FROM THE AMIGA AGES AGO.  I CANNOT "
 DC.B "REMEMBER WHERE I RIPPED GREGORIAN FROM, BUT THE CRACKERS JOURNAL 26 MODULE WAS RIPPED FROM ....... "
 DC.B "YEP, YOU GUESSED IT, CRACKERS JOURNAL 26.  CRACKERS JOURNAL IS A BIT LIKE THE AMAZINE "
 DC.B "DISK MAGS ON THE ST, BUT MORE (MUCH MORE!) PROFESSIONALLY DONE !  STILL NOT AS GOOD AS "
 DC.B "GRAPEVINE BY LSD, BUT I SUPPOSE YOU CAN'T HAVE EVERYTHING !  "


 DC.B "ALL CODING BY   MACHINE SYSTEM DATA OF PERSISTENCE OF VISION   GRAFIX "
 DC.B "BY OUR GOOD MATE   ANTHRAX   MODULES RIPPED AND DISK COMPILED "
 DC.B "BY   STRUCTURE.   NOW ITS TIME FOR THEM GREETINGS ME THINKS.      "
 DC.B "BEAR WITH ME, WHILST I SCRATCH MY GREY MATTER AND LOOK FOR THE KEY TO THE DOOR OF REMEMBERANCE ......   "
 DC.B "   "

 DC.B "GREETINGS TO THE FOLLOWING...     "
 DC.B "ADMIRABLES,     "
 DC.B "ADRENALINE (THE FRENCH GROUP - NOT ADRENALIN FRANCE !  NICE RIPPER GUYS !!),     "
 DC.B "ANIMAL MINE,     "
 DC.B "ANTHRAX,     "
 DC.B "APOLLO,     "
 DC.B "BREAKPOINT SOFTWARE,     "
 DC.B "ALL MEMBERS OF THE BRITISH ALLIANCE (WHO WE ARE NO LONGER PART OF, SO I AM TOLD!),    "
 DC.B "CHAOS (BEN AND TAT),     "
 DC.B "CHRIS H (YORK),     "
 DC.B "CHRIS H (MID GLAM),     "
 DC.B "CHRIS H (STAFFS),     "
 DC.B "C.I.D.,    "
 DC.B "CONCEPTORS (ESP. DEMON),      "
 DC.B "CRACKDOWN (ESP. INSPIRAL),     "
 DC.B "CYNIX (ESP. SUPERNOVA AND QUATTRO),     "
 DC.B "D-BUG,     "
 DC.B "DEVIANT DESIGNERS,     "
 DC.B "DIGI TALLIS (ESP. ORMOLU),     "
 DC.B "ELITE,     "
 DC.B "(E) TRIPPER,     "
 DC.B "FREESOFT,     "
 DC.B "FUZION,     "
 DC.B "I.C.S.,     "
 DC.B "INDIE HEAD,     "
 DC.B "INSANITY,     "
 DC.B "KGB,      "
 DC.B "LEMMINGS (PELE AND XENOCIDE),    "
 DC.B "MAD VISION,     "
 DC.B "MEGA 4 (ESP. POWA),    "
 DC.B "MICRO MANIAC,     "
 DC.B "MUG U.K. (THANKS FOR GETTING IN TOUCH AND SENDING ME ALL THEM MODS !!),     "
 DC.B "NEW AGE PDL,     "
 DC.B "OUTLAW PDL,    "
 DC.B "OUT OF ORDER (ESP. SONIC),     "
 DC.B "PERSISTENCE OF VISION (ESP. MAC SYS DATA AND BORIS),     "
 DC.B "PHF (ESP. GRAZEY)     "
 DC.B "POMPEY PIRATES (R.I.P. OR IS IT ??),     "
 DC.B "PURE ENERGY (ESP. FALCON AND ZAK),      "
 DC.B "PULSION,     "
 DC.B "REDLITE,     "
 DC.B "RIPPED OFF (ESP. STICK AND BILBO),     "
 DC.B "SAFARI (ESP. PANTHER AND RHINO),     "
 DC.B "SCANZ,     "
 DC.B "SECTION ONE (ESP. RED LICHTIE),     "
 DC.B "SPECIAL FX (R.I.P.),     "
 DC.B "SUPERIOR,     "
 DC.B "SUPREMACY,     "
 DC.B "SYNCRO SYSTEMS (ESP. RAZOR),     "
 DC.B "SYNDICATE,     "
 DC.B "THE EDGE,     "
 DC.B "THE JOKER,     "
 DC.B "THE REPLICANTS,     " 
 DC.B "TIM,     "
 DC.B "UNTOUCHABLES (ESP. MAT),    "
 DC.B "WILD! (ESP. SNAZ)    AND     "
 DC.B "X-STATIC (ESP. SIGNET).      "      
 DC.B "WELL, THATS ALL FROM ME FOR TODAY.   LOOK OUT FOR MODULE DISKS"
 DC.B " 11, 12, 13, 14 AND 15 COMING SOON.   THIS IS STRUCTURE FOR ADRENALIN U.K. SIGNING OFF...."
 DC.B "                                                   "
 DC.B "                                    "
 dc.b $ff
	even

font	incbin	oz_font.dat
	even


colour_pos	dc.l	colours
; colours are interlaced between VU rasters and TITLES rasters
colours		dc.w	$f00,$770
		dc.w	$f10,$760
		dc.w	$f20,$750
		dc.w	$f30,$740
		dc.w	$f40,$730
		dc.w	$f50,$720
		dc.w	$f60,$710
		dc.w	$f70,$700
		dc.w	$670,$600
		dc.w	$570,$500
		dc.w	$470,$400
		dc.w	$370,$300
		dc.w	$270,$200
		dc.w	$170,$100
		dc.w	$070,$006
		dc.w	$060,$007
		dc.w	$050,$007
		dc.w	$040,$0
		dc.w	-1,-1

;scroller rasters follow
srast		dcb.w	16,0
		dc.w	0

scroller_colours
		dc.w	$800,$100,$900,$200,$a00,$300,$b00,$400
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

;16 colour wrap over tail
		dc.w	$800,$100,$900,$200,$a00,$300,$b00,$400
		dc.w	$c00,$500,$d00,$600,$e00,$700,$f00,$f80

error_open_mess	dc.b	27,'E'
		dc.b	27,'Y',32+10,32+11,"ERROR OPENING FILE"
		dc.b	27,'Y',32+12,32+10,"COPY THIS DISC AGAIN",0
		even
error_read_mess	dc.b	27,'E'
		dc.b	27,'Y',32+10,32+11,"ERROR READING FILE"
		dc.b	27,'Y',32+12,32+10,"COPY THIS DISC AGAIN",0
		even


	SECTION BSS
bssstart

vus	ds.w	1		;last recorded level of VUs
	ds.w	1
	ds.w	1
	ds.w	1


sbuffer		ds.b	BUFFER_SIZE

black		ds.b	32
old_timerb	ds.l	1
store		ds.l	1
scroll_number	ds.w	1
vucontrol	ds.w	1
vucontrol_delay	ds.w	1
oldkbd		ds.l	1
key		ds.w	1
ste_flag	ds.w	1
oldvbl		ds.l	1
old_palette	ds.w	16
stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
scrcoloff	ds.w	1
mod_number	ds.w	1

buffer		ds.w	128
vsyncflag	ds.w	1

eobss

