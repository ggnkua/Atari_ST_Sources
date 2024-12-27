*************************************************************************
*		PERSISTENCE OF VISION FILLER SCREEN FOR POV 150		*
*		-----------------------------------------------		*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* 									*
*									*
*									*
*									*
*************************************************************************
*
* FALCON/STE/STFM tracker menu
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

; Uses registers D5-D7/A6.						;
;****** STFM BITS ***********
MVOL	EQU	$60			; >= $40 ($60 recommended)
FREQ	EQU	3			; 0=6.144, 1=8.192, 2=12.288
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

FINAL=NO	;YES to remove escape to assembler code
		;NO to keep it on

DOWNLOAD=yes	;yes to use WIDGET downloader


******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
	ifne	DOWNLOAD
	include	transmit.s
	org	$20000
Code_Start
Exec_Addr
	ENDC


	opt	o+,w-

	jsr	clear_bss
	jsr	set_super
	jsr	depack_mod
	jsr	test_4_ste
	jsr	test_4_falcon
	jsr	get_screen_base
	jsr	get_old_palette
	jsr	get_original_rez


	tst.w	falcon_flag
	bne.s	init_falcon

	jsr	black_out
	jsr	set_low_rez
	jsr	show_picture

	tst.w	ste_flag
	bne.s	init_ste
	jsr	muson_stfm			; Install music
	jsr	set_new_palette
	bra	main_loop
init_ste
	bsr	muson_ste
	jsr	set_new_palette
	bra.s	main_loop
init_falcon

	move.l	#$3919,d0
	movec	d0,cacr

		move.w	#-1,-(sp)
		move.w	#$58,-(sp)	;get_original_rez
		trap	#14
		addq.l	#4,sp
		move.w	d0,org_falcon_rez

		move.w	$ffff82aa.w,org_overscanbtm	;bottom overscan

		move.w	#4,d7		;new Falcon video mode (256 colours)
		move.w	d7,-(sp)
		move.w	#$5b,-(sp)
		trap	#14
		addq.w	#4,sp
		move.l	d0,screen_bytes	;number of bytes used by screen mode

		move.w	d7,d0
;		or.w	#32,d0		;set for TV 50 Hz
		and.w	#%1111111111110111,d0		;40 coloumn

		move.w	d0,-(sp)	;falcon rez
		move.w	#3,-(sp)	;rez 3!
		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#14,sp


;This bit will automatically set the falcon video res but it will
;preserve the RGB/VGA mode.
;			  fedcba9876543210
;Octet de poids faible :    S O P V 8 N N N
		move.w	d0,d1
		and.w	#%00110000,d1	;keep RGB/VGA flag
		move.l	#%000110100010,d0
		or.w	d1,d0
		move.w	d0,-(sp)
		move.w	#$58,-(sp)
;		trap	#14
		addq.l	#4,sp

;Octet de poids faible :    S O P V 8 N N N
;	N  Bits par pixels :	4 -> 16 bits	65536 colours
;				3 -> 8  bits	256 colours
;				2 -> 4  bits	16 colours
;				1 -> 2  bits	1 colours
;				0 -> 1  bit
;	8 Flag 80 colonnes :	1 -> mode 80 colonnes
;				0 -> mode 40 colonnes
;	V Flag VGA         :	1 -> mode moniteur VGA
;				0 -> mode TV
;	P Flag PAL         :	1 -> mode PAL
;				0 -> mode NTSC
;	O Flag Overscan    :	1 -> Overscan ON (impossible en VGA)
;				0 -> Overscan OFF

;Where 'mode' looks like this:-
;    bits            meaning
;    0-2             These bits form a value so that 2^X represents the 
;                    number of bits/pixel
;    3               80 coloun flag (if set, 80 columns, otherwise 40)
;    4               VGA Flag (if set, VGA mode, if not TV/RGB mode) 
;    5               PAL Flag (if set, PAL mode, otherwise NTSC)
;    6               Overscan Flag (not valid with VGA)
;    7               ST compatibility flag
;    8               Vertical flag (if set, enables interlace mode on a         
;                    colour monitor or double line mode on a VGA monitor)
;    9-15            Reserved (set 0)



;	jsr	show_picture

	bsr	init_falcon_mod
;	jsr	set_new_palette



main_loop
	bsr	vsync
;	move.w	#$123,$ffff8240.w

		bsr	text_printer
		bsr	show_position	;ste/stfm only!

;	clr.w	$ffff8240.w


	move.w	key,d0

	cmp.w	#1,d0		;ESC
	beq	exit

	bra	main_loop

error
exit
	tst.w	falcon_flag
	bne.s	.shut_down_falcon
	tst.w	ste_flag
	bne.s	.shut_down_ste
	jsr	musoff_stfm	; Restore system completely
	bra.s	.co
.shut_down_ste
	bsr	musoff_ste
	bra.s	.co
.shut_down_falcon
	move	#$2700,sr
	bsr	stop_falcon_mod
	clr.b	$FFFFFA1b.w		; Stop timer B
	move.l	old_timerb,$120.w
	move.l	oldvbl,$70.w
	move.l	oldkbd,$118.w

	lea	store,a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0),$fffffa13.w

	lea	yesmouse,a0
	jsr	send_2_ik
	move	#$2300,sr

		move.w	org_falcon_rez,-(sp)
		move.w	#$58,-(sp)	;set_original_rez
		trap	#14
		addq.l	#4,sp

		move.w	org_overscanbtm,$ffff82aa.w	;bottom overscan
	bra.s	.fas


.co	jsr	set_old_palette
	jsr	set_low_rez
.fas	jsr	set_user

	clr.w	-(sp)
	trap	#1




offset_down_scr	equ	160*56
depth		equ	8
plane		equ	0		;0,1,2,3
text_printer	eor.w	#1,cursor
		bne	.do_cursor_only

		cmp.b	#1,enable_text
		blt	.do
		beq.s	.nearly
		sub.b	#1,enable_text
		rts
.nearly		clr.w	xpos
		sub.b	#1,enable_text
		move.l	screen_base,a0

		lea	plane*2+offset_down_scr(a0),a0
		moveq	#0,d0		;clear area of last text
		move.w	#16-1,d1	;number of lines of text
.clear		rept	depth
		move.w	d0,(a0)
		move.w	d0,8(a0)
		move.w	d0,16(a0)
		move.w	d0,24(a0)
		move.w	d0,32(a0)
		move.w	d0,40(a0)
		move.w	d0,48(a0)
		move.w	d0,56(a0)
		move.w	d0,64(a0)
		move.w	d0,72(a0)
		move.w	d0,80(a0)
		move.w	d0,88(a0)
		move.w	d0,96(a0)
		move.w	d0,104(a0)
		move.w	d0,112(a0)
		move.w	d0,120(a0)
		move.w	d0,128(a0)
		move.w	d0,136(a0)
		move.w	d0,144(a0)
		move.w	d0,152(a0)
		lea	160(a0),a0
		endr
		lea	160(a0),a0
		dbf	d1,.clear
		move.w	#1,cursor
		clr.l	ypos
		rts

.do		tst.w	delay_timer
		beq.s	.no_delay
		sub.w	#1,delay_timer
		rts
.no_delay	move.l	ascii_pos,a0
		moveq	#0,d0
		move.b	(a0)+,d0
		cmp.b	#-1,d0
		bne.s	.no_restart
		clr.w	xpos
		clr.l	ypos
		lea	ascii,a0
		move.b	(a0)+,d0
.no_restart	cmp.b	#13,d0
		bne.s	.notcr
		move.l	a0,ascii_pos
		move.w	#1,cursor
		bsr	.do_cursor_only
		add.l	#(depth+1)*160,ypos
		clr.w	xpos
		rts

.notcr		cmp.b	#15,d0
		bne.s	.not_end
		move.b	(a0)+,enable_text
		move.l	a0,ascii_pos
		rts

.not_end	cmp.b	#11,d0		;delay
		bne.s	.no_set_delay
		move.l	a0,ascii_pos
		move.w	#20,delay_timer
		rts

.no_set_delay	cmp.b	#12,d0		;del
		bne	.ok
		move.l	a0,ascii_pos
		move.l	screen_base,a1
		add.l	ypos,a1
		move.w	xpos,d0		;clear char to right of cursor
		and.w	#$ff,d0
		move.w	d0,d1
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		and.w	#1,d1
		add.w	d1,d0
		add.w	d0,a1
		moveq	#0,d0
offset		set	(plane*2)+offset_down_scr
		rept	depth
		move.b	d0,offset(a1)
offset		set	offset+160
		endr
		sub.w	#1,xpos
		rts

;BUG IN TAB SOMEWHERE!!!
.ok		move.l	a0,ascii_pos
		cmp.b	#9,d0		;tab
		bne.s	.no_tab
		move.w	xpos,d2
		add.w	#8,d2
		and.w	#$fff8,d2
		sub.w	xpos,d2
		sub.w	#1,d2
.loop		move.w	#' ',d0
		bsr	.no_tab
		dbf	d2,.loop
		bra	.no_delay

.no_tab		sub.w	#' ',d0
		mulu	#depth,d0
		lea	font,a0
		add.w	d0,a0
		move.w	xpos,d0
		and.w	#$ff,d0
		move.w	d0,d1
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8 for words across screen
		and.w	#1,d1
		add.w	d1,d0
.no_add		move.l	screen_base,a1
		add.l	ypos,a1
		add.w	d0,a1
offset	set	(plane*2)+offset_down_scr
		rept	depth
		move.b	(a0)+,offset(a1)
offset	set	offset+160
		endr
		add.w	#1,xpos
		rts

.do_cursor_only	move.w	xpos,d0
		move.w	d0,d1
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		beq.s	.no_curs	;prevent cursor on top line when CR is met as 1st char
		and.w	#1,d1
		add.w	d1,d0
		move.l	screen_base,a1
		add.l	ypos,a1
		add.w	d0,a1
		eor.b	#-1,plane*2+offset_down_scr+((depth-2)*160)(a1)
		eor.b	#-1,plane*2+offset_down_scr+((depth-1)*160)(a1)
.no_curs	rts




;STFM uses registers D5-D7/A6 so do not use here
;this shows the position in the mod so the user can see how far to go.
show_position
		moveq	#0,d0
		move.b	songpos,d0
		move.w	d0,d1
		and.w	#%1111,d1	;lower nibble
		lsr.w	#4,d0
		and.w	#%1111,d0	;upper nibble

		lea	font,a1
		move.l	a1,a2
		add.w	#$10,d0
		cmp.w	#$1a,d0
		blt.s	.noad0
		add.w	#7,d0
.noad0		mulu	#8,d0
	add.w	d0,a1
		move.l	screen_base,a0
		add.w	#160*4,a0
		move.l	a0,a3
		move.b	(a1)+,16+2(a0)
		move.b	(a1)+,16+162(a0)
		move.b	(a1)+,16+322(a0)
		move.b	(a1)+,16+482(a0)
		move.b	(a1)+,16+642(a0)
		move.b	(a1)+,16+802(a0)
		move.b	(a1)+,16+962(a0)
		move.b	(a1)+,16+1122(a0)

		add.w	#$10,d1
		cmp.w	#$1a,d1
		blt.s	.noad1
		add.w	#7,d1
.noad1		mulu	#8,d1
		add.w	d1,a2
		move.b	(a2)+,16+3(a3)
		move.b	(a2)+,16+163(a3)
		move.b	(a2)+,16+323(a3)
		move.b	(a2)+,16+483(a3)
		move.b	(a2)+,16+643(a3)
		move.b	(a2)+,16+803(a3)
		move.b	(a2)+,16+963(a3)
		move.b	(a2)+,16+1123(a3)





;pat pos
		moveq	#0,d0
		move.b	pattpos,d0
		move.w	d0,d1
		and.w	#%1111,d1	;lower nibble

		lea	font,a1
		move.l	a1,a2
		move.l	screen_base,a0
		add.w	#160*22,a0
		move.l	a0,a3
		add.w	#$10,d1
		cmp.w	#$1a,d1
		blt.s	.noad15
		add.w	#7,d1
.noad15		mulu	#8,d1
		add.w	d1,a2
		move.b	(a2)+,16+2(a3)
		move.b	(a2)+,16+162(a3)
		move.b	(a2)+,16+322(a3)
		move.b	(a2)+,16+482(a3)
		move.b	(a2)+,16+642(a3)
		move.b	(a2)+,16+802(a3)
		move.b	(a2)+,16+962(a3)
		move.b	(a2)+,16+1122(a3)

aa
		moveq	#0,d0
		move.b	pattpos+1,d0
		lsr.w	#4,d0
		and.w	#%1111,d0	;upper nibble

		lea	font,a1
		move.l	a1,a2
		add.w	#$10,d0
		cmp.w	#$1a,d0
		blt.s	.noad04
		add.w	#7,d0
.noad04		mulu	#8,d0
	add.w	d0,a1
		move.b	(a1)+,16+3(a0)
		move.b	(a1)+,16+163(a0)
		move.b	(a1)+,16+323(a0)
		move.b	(a1)+,16+483(a0)
		move.b	(a1)+,16+643(a0)
		move.b	(a1)+,16+803(a0)
		move.b	(a1)+,16+963(a0)
		move.b	(a1)+,16+1123(a0)
		rts



; #############################################################################
; depack routine for module packer
; In :
; a0 = Pointer on module
depack_mod
		lea	mod,a0
		bsr	analyse_module		; find sample start/end
		bsr	init_depack
		movea.l	sample_start(PC),A0	; packed sample
		move.l	sample_end(PC),D0
		sub.l	A0,D0			; unpacked length
 		move.l	d0,-(sp)
		bsr	depack_sample        ; depack over source
		move.l	(sp)+,d0
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
		movea.l	(sp)+,a0
		rts

; a0=packed sample (also destination)
; d0=unpacked length
depack_sample
		lea	depack_hi(PC),A2
		lea	depack_lo(PC),A3

		addq.l	#1,D0
		and.b	#-2,D0		 ; round length up
		move.l	D0,D7
		lsr.l	#1,D7		; sample length in words

		lea	0(A0,D0.l),A1        ; destination end
		adda.l	D7,A0		; source end

		move.w	#128,D0		; last byte
		moveq	#0,D1		; clear temp

depack_loop	move.b	-(A0),D1		; get 2 distances
		add.b	0(A2,D1.w),D0
		move.b	D0,-(A1)
		add.b	0(A3,D1.w),D0
		move.b	D0,-(A1)

		subq.l	#1,D7
		bne.s	depack_loop
		rts

init_depack
		lea	depack_lo(PC),A1
		move.w	#15,D7
init1		lea	power_bytes(PC),A0
		move.w	#15,D6
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

power_bytes	DC.B	-128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64
sample_start	DC.L	0
sample_end	DC.L	0

depack_lo	DS.B	256
depack_hi	DS.B	256
; DEPACK END





***********************************************************************
***********										***********
***********										***********
***********  Sample of Use of my DSP SoundTracker Replay	***********
***********										***********
***********	   Runs with most 4/6/8 Voices .MOD		***********
***********										***********
***********	Simplet / ABSTRACT						***********
***********	LESAGE St‚phane - Rue des Monts Jura		***********
***********	01200 Chƒtillon-en-Michaille - FRANCE		***********
***********										***********
***********										***********
***********************************************************************

; 0 for VBL Rout in RVB 50 Hz Only
; 1 for universal Timer A Rout with CIA-Tempos

VBL_Timer	EQU	1

*******************************************************************
***********			Inits			***********
*******************************************************************

init_falcon_mod
	bsr	Init_Music
	bmi	error
	lea	store,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)
	move	#$2700,sr
	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	$120.w,old_timerb
	move.l	$70.w,oldvbl
	move.l	$118.w,oldkbd
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#timerb,$120.w
	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
;	move.b	#188,$fffffa21.w		;timer B data
;	move.b	#8,$fffffa1b.w		;ei timber B
	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w

		bsr.s	Init_Music_IT
		move.w	#$2300,sr
		rts

stop_falcon_mod

*******************************************************************
***********	   Restore Interrupts and Cut DSP Sound	***********
*******************************************************************

		bsr.s	Stop_Music_IT
		bsr.s	Stop_Music
		rts








***********************************************************************
***********			SoundTracker Rout				***********
***********************************************************************

***********************************************************************
***********							*******
***********							*******
***********		   DSP SoundTracker Replay		*******
***********							*******
***********	   Runs with most 4/6/8 Voices .MOD		*******
***********							*******
***********		    by Simplet / ABSTRACT		*******
***********							*******
***********							*******
***********************************************************************

		RsReset

Amiga_Name		rs.b	22
Amiga_Length		rs.w	1	* Taille cod‚e en words
Amiga_Fine_Tune		rs.b	1	* de 0 … 15  =  0 … 7 et -8 … -1
Amiga_Volume		rs.b	1	* de 0 … 64
Amiga_Repeat_Start	rs.w	1
Amiga_Repeat_Length	rs.w	1

Amiga_Size		rs.b	1	* 30 octets

		RsReset

Voice_Sample_Start		rs.l	1
Voice_Sample_Offset		rs.l	1
Voice_Sample_Position		rs.l	1
Voice_Sample_Length		rs.l	1
Voice_Sample_Repeat_Length	rs.l	1
Voice_Sample_Volume		rs.w	1
Voice_Sample_Period		rs.w	1
Voice_Sample_Fine_Tune		rs.w	1

Voice_Start			rs.l	1
Voice_Length			rs.l	1
Voice_Repeat_Length		rs.l	1
Voice_Volume			rs.w	1
Voice_Period			rs.w	1
Voice_Wanted_Period		rs.w	1

Voice_Note			rs.w	1
Voice_Sample			rs.b	1
Voice_Command			rs.b	1
Voice_Parameters		rs.b	1

Voice_Tone_Port_Direction	rs.b	1
Voice_Tone_Port_Speed		rs.b	1
Voice_Glissando_Control		rs.b	1
Voice_Vibrato_Command		rs.b	1
Voice_Vibrato_Position		rs.b	1
Voice_Vibrato_Control		rs.b	1
Voice_Tremolo_Command		rs.b	1
Voice_Tremolo_Position		rs.b	1
Voice_Tremolo_Control		rs.b	1
Voice_Funk_Speed		rs.b	1
Voice_Funk_Offset		rs.b	1
Voice_Funk_Position		rs.l	1
Voice_Funk_Start		rs.l	1

Voice_Size			rs.b	1

***********************************************************************
***********			Initialisations			*******
***********************************************************************

		ifeq	DOWNLOAD
		Section	TEXT
		endc

Init_Music
		bsr	Init_Module
		bra	Init_Sound

Init_Music_IT
		clr.b	$fffffa19.w		; Coupe Timer
		move.l	#SndTrack_Timer,$134.w	; Installe Vecteur
		bset.b	#5,$fffffa07.w		; Autorise Timer
		bset.b	#5,$fffffa13.w		; D‚Maske Timer
		move.b	Simplet_IT_Timer_Data(pc),$fffffa1f.w
		move.b	Simplet_IT_Timer_Control(pc),$fffffa19.w
		rts

Stop_Music_IT
		clr.b	$fffffa19.w		; Coupe Timer
		bclr.b	#5,$fffffa07.w		; Autorise Timer
		bclr.b	#5,$fffffa13.w		; D‚Maske Timer
		rts

Stop_Music
		move.b	#$80+$28/2,$ffffa201.w	; Host User 1, vecteur $28
		rts

***********************************************************************
***********	   Interruptions du Replay Soundtracker		***********
***********************************************************************

SndTrack_Timer
		bclr.b	#5,$fffffa0f.w		; … Cause du mode SEI
		move.w	#$2300,sr		; Ne bloque pas tout le monde

		ror.w	SndTrack_Timer_Cmpt
		bcc.s	SndTrack_Timer_Ret

		move.b	Simplet_IT_Timer_Data(pc),$fffffa1f.w
		move.b	Simplet_IT_Timer_Control(pc),$fffffa19.w
		move.w	Simplet_IT_Sample_Length(pc),Code_Sample_Length
		bsr.s	SndTrack_IT

SndTrack_Timer_Ret
		rte

SndTrack_Timer_Cmpt
		dc.w		%0001000100010001


SndTrack_IT
		move.l	$ffff9800.w,-(sp)
		move.l	#$ff000000,$ffff9800.w

		movem.l	d0-d7/a0-a6,-(sp)

; Signale au DSP qu'on veut causer … la routine Soundtracker
		move.b	#$80+$26/2,$ffffa201.w	; Host User 0, vecteur $26

; Port Host
		lea.l	$ffffa204.w,a6

; On balance le nombre de samples … calculer (code automodifi‚)
SplLen	move.l	#984,(a6)

Code_Sample_Length	equ	SplLen+4


		moveq.l	#0,d7
		move.w	Simplet_Voices_Nb(pc),d7
		subq.w	#2,d7
		lsr.w	d7
		move.l	d7,(a6)	; Nombre de paires de voies suppl‚mentaires

; Envoie les samples au DSP

		lea.l	Simplet_Voices(pc),a5		; Gauche
		bsr.s	Play_Voice
		lea.l	Voice_Size(a5),a5		; Droite
		bsr.s	Play_Voice

		subq.w	#1,d7

Play_All_Voices
		adda.w	Increment_Voice_1(pc),a5
		bsr.s	Play_Voice
		adda.w	Increment_Voice_2(pc),a5
		bsr.s	Play_Voice

		subq.w	#1,d7
		bmi.s	No_More_Voices

		adda.w	Increment_Voice_3(pc),a5
		bsr.s	Play_Voice
		adda.w	Increment_Voice_4(pc),a5
		bsr.s	Play_Voice

		subq.w	#1,d7
		bpl.s	Play_All_Voices


; S'occupe de la partition

No_More_Voices
		bsr		Simplet_Play_Patterns

		movem.l	(sp)+,d0-d7/a0-a6

		move.l	(sp)+,$ffff9800.w
		rts

; S'occupe d'une voie : envoie volume, fr‚quence et les samples

Play_Voice
; Envoie volume
		moveq.l	#0,d0
		move.w	Voice_Sample_Volume(a5),d0
		mulu.l	#$7fffff/64*2,d0
		moveq.l	#0,d1
		move.w	Simplet_Voices_Nb(pc),d1
		divu.l	d1,d0
		move.l	d0,(a6)

; Envoie fr‚quence relative
		move.l	#$800000/49169*428*8363,d0
		moveq.l	#0,d1
		move.w	Voice_Sample_Period(a5),d1
		divu.l	d1,d0
		move.l	d0,(a6)

; Explication du calcul :
; Fr‚quence de replay d'une note =
; Periode de la Note * Base du DO-2 / Periode du DO-2
; Nous on veut le rapport avec la fr‚quence de Replay donc / 49169
; et r‚sultat … virgule pr‚multipli‚ par $800000 pour le DSP

; Recoie longueur du sample … envoyer
WaitDSP		btst.b	#0,$ffffa202.w
		beq.s	WaitDSP
		move.l	(a6),d0

		movea.l	Voice_Sample_Start(a5),a0
		move.l	Voice_Sample_Position(a5),d2
		adda.l	d2,a0				; Adresse courante
		add.l	d0,d2				; Nouvelle position d'arriv‚e

		cmp.l	Voice_Sample_Length(a5),d2	; A-t'on d‚pass‚ la fin ?
		blt.s	No_Repeat					; Si Non pas de probleme

		sub.l	Voice_Sample_Repeat_Length(a5),d2	; Si Oui, boucle

No_Repeat	move.l	d2,Voice_Sample_Position(a5)	; Nouvelle position

		ext.l	d0
		divu.l	#6,d0			; Envoi par paquet de 6 un
		addq.w	#1,d0			; de + car on tombe pas pile
		move.l	d0,(a6)			; Nombre de paquets

		subq.w	#1,d0			; pour le dbra
		subq.l	#1,a0			; Cale les samples

Send_Samples
		move.l	(a0),(a6)
		move.l	3(a0),(a6)
		addq.l	#6,a0
		dbra	d0,Send_Samples
		rts

***********************************************************************
***********		   Initialisations Son et DSP		*******
***********************************************************************

Init_Sound
* Stoppe la lecture DMA au cas o—...
		clr.b	$ffff8901.w

* DAC sur piste 0 (quartet fort)
		move.b	#$0f,$ffff8920.w

* Source DSP-Xmit sur Horloge Interne 25.175 MHz, DSP connect‚ (Enable)
* Source DMA-Play sur Horloge Interne 25.175 MHz
		move.w	#%10010001,$ffff8930.w

* Destinations DAC, DMA-Record et External OutPut
* connect‚es … Source DSP-Xmit, Handshaking On
* Destination DSP-Rec connect‚e sur DMA-Play, DSP connect‚ (Enable)
		move.w	#%0010001000010011,$ffff8932.w

* Fr‚quence 49169 Hz
		move.b	#1,$ffff8935.w

* Seulement Matrice et pas le PSG-Yamaha
		move.b	#%10,$ffff8937.w

* Programme DSP
		move.w	#113,-(sp)		; DSP_RequestUniqueAbility
		trap	#14			; XBios
		addq.l	#2,sp

		move.w	d0,-(sp)			; No Ability
		move.l	#(DSP_End-DSP_Code)/3,-(sp)	; Longueur en Mots DSP
		pea.l	DSP_Code(pc)			; Adresse du code binaire
		move.w	#109,-(sp)			; Dsp_ExecProg
		trap	#14				; XBios
		lea.l	12(sp),sp


Connect	move.l	#87654321,$ffffa204.w
		moveq.l	#0,d0

Conct_Get	btst.b	#0,$ffffa202.w
		bne.s	DSP_Test
		addq.l	#1,d0
		cmp.l	#100000,d0
		beq.s	DSP_Error
		bra.s	Conct_Get

DSP_Test	move.l	$ffffa204.w,d0
		cmp.l	#12345678,d0
		beq.s	DSP_Ok

DSP_Error	moveq.l	#-1,d0
DSP_Ok	rts

***********************************************************************
***********		Initialisations du Module		*******
***********************************************************************

Init_Module
		lea	mod,a0

		lea.l	20+31*30+2(a0),a1		; Par d‚faut
		lea.l	4+128(a1),a2			; Type
		moveq.l	#31,d0				; 31 instruments
		moveq.l	#64,d2				; 64 lignes par pattern
		sf	Simplet_Old_Module

		move.b	#125,Simplet_Tempo		; Tempo par d‚faut
		move.b	#6,Simplet_Speed		; Vitesse par d‚faut
		move.b	#5,Simplet_IT_Timer_Control
		move.b	#192,Simplet_IT_Timer_Data
		move.w	#984,Simplet_IT_Sample_Length

		move.l	$438(a0),d3			; ModFile Chunk

; Formats 4 voies
		moveq.l	#4,d1

		cmp.l	#"M.K.",d3
		beq.s	Format_Ok
		cmp.l	#"M!K!",d3
		beq.s	Format_Ok
		cmp.l	#"M&K&",d3
		beq.s	Format_Ok
		cmp.l	#"FA04",d3
		beq.s	Format_Digital
		cmp.l	#"FLT4",d3
		beq.s	Format_Ok

; Formats 6 voies
		moveq.l	#6,d1

		cmp.l	#"FA06",d3
		beq.s	Format_Digital
		cmp.l	#"6CHN",d3
		beq.s	Format_Ok
		cmp.l	#"FLT6",d3
		beq.s	Format_Ok

; Formats 8 voies
		moveq.l	#8,d1

		cmp.l	#"FA08",d3
		beq.s	Format_Digital
		cmp.l	#"8CHN",d3
		beq.s	Format_Ok
		cmp.l	#"FLT8",d3
		beq.s	Format_Ok
		cmp.l	#"OCTA",d3
		beq.s	Format_Ok

; Si rien de sp‚cial alors c'est un ancien module 15 instruments
		lea.l	20+15*30+2(a0),a1
		lea.l	128(a1),a2
		moveq.l	#15,d0
		moveq.l	#4,d1
		st	Simplet_Old_Module
		bra.s	Format_Ok

Format_Digital
		move.w	(a2)+,d2
		addq.l	#2,a2

Format_Ok	move.l	a1,Simplet_Sequence_Adr	; Adresse de la s‚quence
		move.l	a2,Simplet_Patterns_Adr	; Adresse des patterns
		move.w	d0,Simplet_Samples_Nb	; Nombre d'instruments
		move.w	d1,Simplet_Voices_Nb	; Nombre de voies
		move.w	d2,Simplet_Pattern_Length

		lsl.w	#2,d1
		move.w	d1,Simplet_Line_Size	; Taille d'une 'ligne'
		mulu.w	d2,d1
		move.w	d1,Simplet_Pattern_Size	; Taille d'un pattern

		move.b	-2(a1),d0
		move.w	d0,Simplet_Song_Length	; Longueur du module
		move.b	-1(a1),d2
		cmp.b	d0,d2				; le Restart
		blo.s	Simplet_Restart_Ok		; est-il coh‚rent ?
		moveq.l	#0,d2				; si non, Restart = 0
Simplet_Restart_Ok
		move.w	d2,Simplet_Song_Restart

		subq.w	#1,d0				; Parcours la s‚quence
		moveq.l	#0,d1				; jusqu'… la derniŠre
Simplet_Sequence_Loop					; position
		move.b	(a1)+,d2				; No Pattern
		cmp.b	d1,d2				; Plus grand
		blo.s	Simplet_Seq_No_Max		; que le maximum ?
		move.b	d2,d1				; alors Nouveau maximum
Simplet_Seq_No_Max
		dbra	d0,Simplet_Sequence_Loop


		addq.w	#1,d1				; Nombre de patterns
		mulu.w	Simplet_Pattern_Size(pc),d1	; Taille totale

		move.l	Simplet_Patterns_Adr(pc),a1	; Adresse du d‚but
		lea.l	(a1,d1.l),a1			; Des samples

		lea.l	20(a0),a2			; Pointe sur Sample 1
		moveq.l	#0,d2
		move.w	Simplet_Samples_Nb(pc),d0
		subq.w	#1,d0

Simplet_Total_Length
		move.w	Amiga_Length(a2),d3		; Longueur
		ext.l	d3				; du sample
		add.l	d3,d3				; * 2 car stock‚ en words
		add.l	d3,d2				; Ajoute au total
		lea.l	Amiga_Size(a2),a2		; Instrument suivant
		dbra		d0,Simplet_Total_Length	; Calcule longueur totale


; Recopie les samples … la fin de la zone de travail temporaire
; pour justement pouvoir travailler dessus, les pr‚parer au bouclage
		lea.l	workspc,a2

		move.l	a1,a3
		add.l	d2,a1

Simplet_Move_Samples
		move.l	-(a1),-(a2)
		move.l	-(a1),-(a2)
		subq.l	#8,d2
		bpl.s	Simplet_Move_Samples


; Maintenant, on bosse sur les samples
		lea.l	20(a0),a0			; Pointe sur 1er Sample
		lea.l	Simplet_Samples_Adr(pc),a1	; Adresse des samples

		move.w	Simplet_Samples_Nb(pc),d0
		subq.w	#1,d0

Simplet_Next_Sample
		move.l	a3,(a1)+			; Note Adresse

		move.w	Amiga_Length(a0),d3		; Longueur Nulle ?
		beq	Simplet_NextSample		; Alors pas d'instrument

		move.w	Amiga_Repeat_Length(a0),d4	; Longueur de Boucle
		cmp.w	#1,d4				; sup‚rieure … 1 ?
		bhi.s	Simplet_Repeat_Length		; Alors il y a bouclage


Simplet_No_Repeat_Length
		move.w	d3,d1				; Longueur
		subq.w	#1,d1
Simplet_Copy_1
		move.w	(a2)+,(a3)+			; Recopie simplement
		dbra	d1,Simplet_Copy_1		; le sample

		move.w	#1400-1,d2
Simplet_Copy_2
		clr.w	(a3)+				; et met du vide aprŠs
		dbra	d2,Simplet_Copy_2		; car ne boucle pas

		move.w	#1400,d1			; Repeat Length pour
		bra.s	Simplet_Sample_Ok		; boucler dans le vide


Simplet_Repeat_Length
		tst.w	Amiga_Repeat_Start(a0)	; Y'a t'il un d‚but de boucle?
		bne.s	Simplet_Repeat_Start	; Oui


		move.l	a3,a4			; Note le d‚but du sample

		move.w	d3,d1			; Longueur
		subq.w	#1,d1
Simplet_Copy_3
		move.w	(a2)+,(a3)+		; Recopie le sample jusqu'…
		dbra	d1,Simplet_Copy_3	; La fin de la boucle
		bra.s	Simplet_No_Repeat_Start


Simplet_Repeat_Start
		move.w	Amiga_Repeat_Start(a0),d1	; On prend le sample
		move.w	d1,d3				; jusqu'au d‚but de la
		move.l	a2,a4				; boucle

		subq.w	#1,d1
Simplet_Copy_4
		move.w	(a4)+,(a3)+
		dbra	d1,Simplet_Copy_4

		add.w	Amiga_Length(a0),a2
		add.w	Amiga_Length(a0),a2

Simplet_No_Repeat_Start
		move.l	a3,a5
		moveq.l	#0,d1

Simplet_Too_Small
		move.l	a4,a6
		move.w	d4,d2
		subq.w	#1,d2

Simplet_Copy_5
		move.w	(a6)+,(a3)+
		addq.w	#2,d1
		dbra	d2,Simplet_Copy_5

		cmp.w	#1400,d1
		blo.s	Simplet_Too_Small

		move.w	#1400/2-1,d2
Simplet_Copy_6
		move.w	(a5)+,(a3)+
		dbra	d2,Simplet_Copy_6


Simplet_Sample_Ok
		lsl.w	d3
		move.w	d3,Amiga_Length(a0)
		move.w	d1,Amiga_Repeat_Length(a0)
		clr.w	Amiga_Repeat_Start(a0)

Simplet_NextSample
		lea.l	Amiga_Size(a0),a0
		dbra	d0,Simplet_Next_Sample


		move.b	Simplet_Speed(pc),Simplet_Counter
		move.w	#-1,Simplet_Pattern_Position
		clr.w	Simplet_Song_Position
		clr.w	Simplet_Pattern_Break_Position
		sf	Simplet_Pattern_Break_Flag
		sf	Simplet_Position_Jump_Flag
		sf	Simplet_Pattern_Loop_Flag
		clr.b	Simplet_Pattern_Delay_Time


		lea.l	workspc,a0
		move.l	#1000,d1
		move.l	#500,d2
		move.w	#2345,d4
		moveq.l	#0,d5

		lea.l	Simplet_Voices(pc),a6
		moveq.l	#8-1,d7

Init_A_Voice
		clr.l	Voice_Sample_Offset(a6)
		clr.l	Voice_Sample_Position(a6)
		move.l	a0,Voice_Sample_Start(a6)
		move.l	d1,Voice_Sample_Length(a6)
		move.l	d2,Voice_Sample_Repeat_Length(a6)
		move.w	d4,Voice_Sample_Period(a6)
		move.w	d5,Voice_Sample_Volume(a6)
		move.l	a0,Voice_Start(a6)
		move.l	d1,Voice_Length(a6)
		move.l	d2,Voice_Repeat_Length(a6)
		move.w	d4,Voice_Period(a6)
		move.w	d5,Voice_Volume(a6)
		move.l	a0,Voice_Funk_Start(a6)

		clr.l	Voice_Tone_Port_Direction(a6)
		clr.l	Voice_Vibrato_Position(a6)
		clr.b	Voice_Tremolo_Control(a6)
		clr.w	Voice_Funk_Speed(a6)
		clr.l	Voice_Funk_Position(a6)

		lea.l	Voice_Size(a6),a6
		dbra	d7,Init_A_Voice
		rts

***********************************************************************
***********		Remet les voies … z‚ro			*******
***********************************************************************

Clear_Voices
		lea.l	workspc,a0
		move.l	#1000,d1
		move.l	#500,d2
		move.w	#2345,d4
		moveq.l	#0,d5

		lea.l	Simplet_Voices(pc),a6
		moveq.l	#8-1,d7

Clear_A_Voice
		clr.l	Voice_Sample_Offset(a6)
		clr.l	Voice_Sample_Position(a6)
		move.l	a0,Voice_Sample_Start(a6)
		move.l	d1,Voice_Sample_Length(a6)
		move.l	d2,Voice_Sample_Repeat_Length(a6)
		move.w	d4,Voice_Sample_Period(a6)
		move.w	d5,Voice_Sample_Volume(a6)
		move.l	a0,Voice_Start(a6)
		move.l	d1,Voice_Length(a6)
		move.l	d2,Voice_Repeat_Length(a6)
		move.w	d4,Voice_Period(a6)
		move.w	d5,Voice_Volume(a6)

		lea.l	Voice_Size(a6),a6
		dbra	d7,Clear_A_Voice
		rts

***********************************************************************
***********		Gestion du Soundtrack			*******
***********************************************************************

Simplet_Play_Patterns
		addq.b	#1,Simplet_Counter
		move.b	Simplet_Counter(pc),d0
		cmp.b	Simplet_Speed(pc),d0
		blo	Simplet_No_New_Note

		clr.b	Simplet_Counter

		tst.b	Simplet_Pattern_Break_Flag(pc)
		bne.s	Simplet_New_Pattern

		tst.b	Simplet_Pattern_Delay_Time(pc)
		beq.s	Simplet_No_Delay

		subq.b	#1,Simplet_Pattern_Delay_Time
		bra	Simplet_No_New_Note

Simplet_No_Delay
		tst.b	Simplet_Pattern_Loop_Flag(pc)
		beq.s	Simplet_No_Pattern_Loop

		move.w	Simplet_Pattern_Loop_Position(pc),Simplet_Pattern_Position
		sf	Simplet_Pattern_Loop_Flag
		bra.s	Simplet_New_Notes

Simplet_No_Pattern_Loop
		tst.b	Simplet_Position_Jump_Flag(pc)
		beq.s	Simplet_New_Line

		move.w	Simplet_Position_Jump_Pos(pc),d0
		sf	Simplet_Position_Jump_Flag
		bra.s	Simplet_New_Position

Simplet_New_Line
		addq.w	#1,Simplet_Pattern_Position
		move.w	Simplet_Pattern_Position(pc),d0
		cmp.w	Simplet_Pattern_Length(pc),d0
		blo.s	Simplet_New_Notes

Simplet_New_Pattern
		move.w	Simplet_Song_Position(pc),d0
		addq.w	#1,d0

Simplet_New_Position
		move.w	Simplet_Pattern_Break_Position(pc),Simplet_Pattern_Position
		clr.w	Simplet_Pattern_Break_Position
		sf	Simplet_Pattern_Break_Flag

		cmp.w	Simplet_Song_Length(pc),d0
		blo.s	Simplet_No_Restart
		move.w	Simplet_Song_Restart(pc),d0
		bne.s	Simplet_No_Restart

		move.b	#125,Simplet_Tempo
		move.b	#6,Simplet_Speed
		move.b	#5,Simplet_IT_Timer_Control
		move.b	#192,Simplet_IT_Timer_Data
		move.w	#984,Simplet_IT_Sample_Length

Simplet_No_Restart
		move.w	d0,Simplet_Song_Position


Simplet_New_Notes
		lea.l	mod+20,a5		; Pointe sur infos samples
		movea.l	Simplet_Sequence_Adr(pc),a0
		move.w	Simplet_Song_Position(pc),d1
		moveq.l	#0,d0
		move.b	(a0,d1.w),d0
		mulu.w	Simplet_Pattern_Size(pc),d0
		movea.l	Simplet_Patterns_Adr(pc),a4
		adda.l	d0,a4				; Pointe sur le Pattern
		move.w	Simplet_Pattern_Position(pc),d0
		mulu.w	Simplet_Line_Size(pc),d0
		adda.w	d0,a4				; Pointe sur la Bonne Ligne


		lea.l	Simplet_Voices(pc),a6
		move.w	Simplet_Voices_Nb(pc),d7
		subq.w	#1,d7
Simplet_New_Notes_Loop
		bsr.s	Simplet_Play_Voice

		lea.l	Voice_Size(a6),a6
		dbra	d7,Simplet_New_Notes_Loop
		rts


Simplet_No_New_Note
		lea.l	Simplet_Voices(pc),a6
		move.w	Simplet_Voices_Nb(pc),d7
		subq.w	#1,d7
Simplet_No_New_Note_Loop
		bsr	Simplet_Check_Efx_2

		lea.l	Voice_Size(a6),a6
		dbra	d7,Simplet_No_New_Note_Loop
		rts


Simplet_Play_Voice
		move.w	(a4)+,d1
		move.b	(a4)+,d2
		move.b	(a4)+,Voice_Parameters(a6)

		move.w	d1,d0
		and.w	#$0fff,d0
		move.w	d0,Voice_Note(a6)
		and.w	#$f000,d1
		lsr.w	#8,d1
		move.b	d2,d0
		lsr.b	#4,d0
		add.b	d1,d0
		move.b	d0,Voice_Sample(a6)
		and.b	#$0f,d2
		move.b	d2,Voice_Command(a6)

		moveq.l	#0,d2
		move.b	Voice_Sample(a6),d2
		beq.s	Simplet_No_New_Sample

		subq.w	#1,d2
		lea.l	Simplet_Samples_Adr(pc),a1
		move.l	(a1,d2.w*4),Voice_Start(a6)
		clr.l	Voice_Sample_Offset(a6)
		mulu.w	#Amiga_Size,d2
		moveq.l	#0,d0
		move.w	Amiga_Length(a5,d2.w),d0
		move.l	d0,Voice_Length(a6)
		move.w	Amiga_Repeat_Length(a5,d2.w),d0
		move.l	d0,Voice_Repeat_Length(a6)
		moveq.l	#0,d0
		move.b	Amiga_Volume(a5,d2.w),d0
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		move.b	Amiga_Fine_Tune(a5,d2.w),d0
		mulu.w	#12*3*2,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)

		move.w	Amiga_Repeat_Start(a5,d2.w),d0
		add.l	Voice_Start(a6),d0
		move.l	d0,Voice_Funk_Start(a6)

Simplet_No_New_Sample
		tst.w	Voice_Note(a6)
		beq	Simplet_Check_Efx_1

		move.w	Voice_Command(a6),d0
		and.w	#$0ff0,d0
		cmp.w	#$0e50,d0
		beq.s	Simplet_Do_Set_Fine_Tune

		move.b	Voice_Command(a6),d0
		subq.b	#3,d0				; 3 = Tone Portamento
		beq	Simplet_Set_Tone_Portamento
		subq.b	#2,d0				; 5 = Tone Porta + Vol Slide
		beq	Simplet_Set_Tone_Portamento
		subq.b	#4,d0				; 9 = Sample Offset
		bne.s	Simplet_Set_Period

		bsr	Simplet_Sample_Offset
		bra.s	Simplet_Set_Period

Simplet_Do_Set_Fine_Tune
		bsr	Simplet_Set_Fine_Tune

Simplet_Set_Period
		lea.l	Simplet_Period_Table(pc),a0
		move.w	Voice_Note(a6),d0
		bsr	Simplet_Find_Period
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	(a0),Voice_Period(a6)


		move.w	Voice_Command(a6),d0
		and.w	#$0ff0,d0
		cmp.w	#$0ed0,d0
		bne.s	Simplet_No_Note_Delay
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		beq.s	Simplet_No_Note_Delay
		rts

Simplet_No_Note_Delay
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
		move.l	Voice_Length(a6),d0
		move.l	Voice_Repeat_Length(a6),d1
		add.l	d1,d0
		move.l	d0,Voice_Sample_Length(a6)
		move.l	d1,Voice_Sample_Repeat_Length(a6)


		btst.b	#2,Voice_Vibrato_Control(a6)
		bne.s	Simplet_Vibrato_No_Reset
		clr.b	Voice_Vibrato_Position(a6)
Simplet_Vibrato_No_Reset

		btst.b	#2,Voice_Tremolo_Control(a6)
		bne.s	Simplet_Tremolo_No_Reset
		clr.b	Voice_Tremolo_Position(a6)
Simplet_Tremolo_No_Reset


Simplet_Check_Efx_1
		bsr	Simplet_Funk_Update
		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jmp	([Jump_Table_1,d0.w*4])

Jump_Table_1
		dc.l	Simplet_Period_Nop,Simplet_Period_Nop
		dc.l	Simplet_Period_Nop,Simplet_Period_Nop
		dc.l	Simplet_Period_Nop,Simplet_Period_Nop
		dc.l	Simplet_Period_Nop,Simplet_Period_Nop
		dc.l	Simplet_Period_Nop,Simplet_Period_Nop
		dc.l	Simplet_Period_Nop,Simplet_Position_Jump
		dc.l	Simplet_Volume_Change,Simplet_Pattern_Break
		dc.l	Simplet_E_Commands_1,Simplet_Set_Speed

Simplet_E_Commands_1
		move.b	Voice_Parameters(a6),d0
		and.w	#$f0,d0
		lsr.w	#4,d0
		jmp	([Jump_Table_E1,d0.w*4])

Jump_Table_E1
		dc.l	Simplet_Return,Simplet_Fine_Portamento_Up
		dc.l	Simplet_Fine_Portamento_Down,Simplet_Set_Glissando_Control
		dc.l	Simplet_Set_Vibrato_Control,Simplet_Return
		dc.l	Simplet_Pattern_Loop,Simplet_Set_Tremolo_Control
		dc.l	Simplet_Return,Simplet_Retrig_Note
		dc.l	Simplet_Volume_Fine_Up,Simplet_Volume_Slide_Down
		dc.l	Simplet_Note_Cut,Simplet_Return
		dc.l	Simplet_Pattern_Delay,Simplet_Funk_It


Simplet_Check_Efx_2
		bsr	Simplet_Funk_Update
		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jmp	([Jump_Table_2,d0.w*4])

Jump_Table_2
		dc.l	Simplet_Arpeggio,Simplet_Portamento_Up
		dc.l	Simplet_Portamento_Down,Simplet_Tone_Portamento
		dc.l	Mt_Vibrato,Simplet_Tone_Portamento_Plus_Volume_Slide
		dc.l	Simplet_Vibrato_Plus_Volume_Slide,Mt_Tremolo
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Volume_Slide,Simplet_Return
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_E_Commands_2,Simplet_Return

Simplet_E_Commands_2
		move.b	Voice_Parameters(a6),d0
		and.w	#$f0,d0
		lsr.w	#4,d0
		jmp	([Jump_Table_E2,d0.w*4])

Jump_Table_E2
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Return,Simplet_Retrig_Note
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Note_Cut,Simplet_Note_Delay
		dc.l	Simplet_Return,Simplet_Return


Simplet_Find_Period
		cmp.w	12*2(a0),d0
		bhs.s	Simplet_Do_Find_Period
		lea.l	12*2(a0),a0
		cmp.w	12*2(a0),d0
		bhs.s	Simplet_Do_Find_Period
		lea.l	12*2(a0),a0

Simplet_Do_Find_Period
		moveq.l	#12-1,d3
Simplet_Find_Period_Loop
		cmp.w	(a0)+,d0
		dbhs	d3,Simplet_Find_Period_Loop
		blo.s	Simplet_Period_Found
		subq.l	#2,a0
Simplet_Period_Found
		rts


Simplet_Period_Nop
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)

Simplet_Return
		rts

Simplet_Arpeggio_Table
		dc.b	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
		dc.b	1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

Simplet_Arpeggio
		move.b	Voice_Parameters(a6),d1
		beq.s	Simplet_Period_Nop

		moveq.l	#0,d0
		move.b	Simplet_Counter(pc),d0
		move.b	Simplet_Arpeggio_Table(pc,d0.w),d0
		beq.s	Simplet_Period_Nop
		subq.b	#2,d0
		beq.s	Simplet_Arpeggio_2

Simplet_Arpeggio_1
		lsr.w	#4,d1
Simplet_Arpeggio_2
		and.w	#$f,d1

		lea.l	Simplet_Period_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	Voice_Period(a6),d0
		bsr.s	Simplet_Find_Period
		move.w	(a0,d1.w*2),Voice_Sample_Period(a6)
		rts


Simplet_Portamento_Up
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0

Simplet_Portamento_Up2
		sub.w	d0,Voice_Period(a6)
		move.w	Voice_Period(a6),d0
		cmp.w	#113,d0
		bhi.s	Simplet_Portamento_Up_Ok
		move.w	#113,Voice_Period(a6)

Simplet_Portamento_Up_Ok
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		rts

 
Simplet_Portamento_Down
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
Simplet_Portamento_Down2
		add.w	d0,Voice_Period(a6)
		move.w	Voice_Period(a6),d0
		cmp.w	#856,d0
		blo.s	Simplet_Portamento_Down_Ok
		move.w	#856,Voice_Period(a6)

Simplet_Portamento_Down_Ok
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		rts


Simplet_Set_Tone_Portamento
		lea.l	Simplet_Period_Table(pc),a0
		move.w	Voice_Note(a6),d0
		bsr	Simplet_Find_Period
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	(a0),d0

		move.w	d0,Voice_Wanted_Period(a6)
		move.w	Voice_Period(a6),d1
		sf	Voice_Tone_Port_Direction(a6)
		cmp.w	d1,d0
		beq.s	Simplet_Clear_Tone_Portamento
		bge	Simplet_Period_Nop
		st	Voice_Tone_Port_Direction(a6)
		rts

Simplet_Clear_Tone_Portamento
		clr.w	Voice_Wanted_Period(a6)
		rts

Simplet_Tone_Portamento
		move.b	Voice_Parameters(a6),d0
		beq.s	Simplet_Tone_Portamento_No_Change
		move.b	d0,Voice_Tone_Port_Speed(a6)
		clr.b	Voice_Parameters(a6)

Simplet_Tone_Portamento_No_Change
		tst.w	Voice_Wanted_Period(a6)
		beq	Simplet_Period_Nop
		moveq.l	#0,d0
		move.b	Voice_Tone_Port_Speed(a6),d0
		tst.b	Voice_Tone_Port_Direction(a6)
		bne.s	Simplet_Tone_Portamento_Up

Simplet_Tone_Portamento_Down
		add.w	d0,Voice_Period(a6)
		move.w	Voice_Wanted_Period(a6),d0
		cmp.w	Voice_Period(a6),d0
		bgt.s	Simplet_Tone_Portamento_Set_Period
		move.w	Voice_Wanted_Period(a6),Voice_Period(a6)
		clr.w	Voice_Wanted_Period(a6)
		bra.s	Simplet_Tone_Portamento_Set_Period

Simplet_Tone_Portamento_Up
		sub.w	d0,Voice_Period(a6)
		move.w	Voice_Wanted_Period(a6),d0
		cmp.w	Voice_Period(a6),d0
		blt.s	Simplet_Tone_Portamento_Set_Period
		move.w	Voice_Wanted_Period(a6),Voice_Period(a6)
		clr.w	Voice_Wanted_Period(a6)


Simplet_Tone_Portamento_Set_Period
		move.w	Voice_Period(a6),d0
		tst.b	Voice_Glissando_Control(a6)
		beq.s	Simplet_Glissando_Skip

		lea.l	Simplet_Period_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		bsr	Simplet_Find_Period
		move.w	(a0),d0

Simplet_Glissando_Skip
		move.w	d0,Voice_Sample_Period(a6)
		rts


Mt_Vibrato
		move.b	Voice_Parameters(a6),d0
		beq.s	Mt_Vibrato2
		move.b	Voice_Vibrato_Command(a6),d2
		and.b	#$0f,d0
		beq.s	Mt_VibSkip
		and.b	#$f0,d2
		or.b	d0,d2
Mt_VibSkip
		move.b	Voice_Parameters(a6),d0
		and.b	#$f0,d0
		beq.s	Mt_vibskip2
		and.b	#$0f,d2
		or.b	d0,d2
Mt_vibskip2
		move.b	d2,Voice_Vibrato_Command(a6)
Mt_Vibrato2
		move.b	Voice_Vibrato_Position(a6),d0
		lea.l	Simplet_Sinus_Table(pc),a3
		lsr.w	#2,d0
		and.w	#$001f,d0
		moveq.l	#0,d2
		move.b	Voice_Vibrato_Control(a6),d2
		and.b	#$3,d2
		beq.s	Mt_Vib_Sine
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	Mt_Vib_RampDown
		move.b	#255,d2
		bra.s	Mt_Vib_Set
Mt_Vib_RampDown
		tst.b	Voice_Vibrato_Position(a6)
		bpl.s	Mt_Vib_RampDown2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	Mt_Vib_Set
Mt_Vib_RampDown2
		move.b	d0,d2
		bra.s	Mt_Vib_Set
Mt_Vib_Sine
		move.b	(a3,d0.w),d2
Mt_Vib_Set
		move.b	Voice_Vibrato_Command(a6),d0
		and.w	#15,d0
		mulu.w	d0,d2
		lsr.w	#7,d2
		move.w	Voice_Period(a6),d0
		tst.b	Voice_Vibrato_Position(a6)
		bmi.s	Mt_VibratoNeg
		add.w	d2,d0
		bra.s	Mt_Vibrato3
Mt_VibratoNeg
		sub.w	d2,d0
Mt_Vibrato3
		move.w	d0,Voice_Sample_Period(a6)
		move.b	Voice_Vibrato_Command(a6),d0
		lsr.w	#2,d0
		and.w	#$003c,d0
		add.b	d0,Voice_Vibrato_Position(a6)
		rts

Simplet_Tone_Portamento_Plus_Volume_Slide
		bsr	Simplet_Tone_Portamento_No_Change
		bra	Simplet_Volume_Slide


Simplet_Vibrato_Plus_Volume_Slide
		bsr.s	Mt_Vibrato2
		bra	Simplet_Volume_Slide

Mt_Tremolo
		move.b	Voice_Parameters(a6),d0
		beq.s	Mt_Tremolo2
		move.b	Voice_Tremolo_Command(a6),d2
		and.b	#$0f,d0
		beq.s	Mt_treskip
		and.b	#$f0,d2
		or.b	d0,d2
Mt_treskip
		move.b	Voice_Parameters(a6),d0
		and.b	#$f0,d0
		beq.s	Mt_treskip2
		and.b	#$0f,d2
		or.b	d0,d2
Mt_treskip2
		move.b	d2,Voice_Tremolo_Command(a6)
Mt_Tremolo2
		move.b	Voice_Tremolo_Position(a6),d0
		lea.l	Simplet_Sinus_Table(pc),a3
		lsr.w	#2,d0
		and.w	#$001f,d0
		moveq.l	#0,d2
		move.b	Voice_Tremolo_Control(a6),d2
		and.b	#$3,d2
		beq.s	Mt_tre_sine
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	Mt_tre_rampdown
		move.b	#255,d2
		bra.s	Mt_tre_set
Mt_tre_rampdown
		tst.b	Voice_Tremolo_Position(a6)
		bpl.s	Mt_tre_rampdown2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	Mt_tre_set
Mt_tre_rampdown2
		move.b	d0,d2
		bra.s	Mt_tre_set
Mt_tre_sine
		move.b	(a3,d0.w),d2
Mt_tre_set
		move.b	Voice_Tremolo_Command(a6),d0
		and.w	#15,d0
		mulu.w	d0,d2
		lsr.w	#6,d2
		moveq.l	#0,d0
		move.w	Voice_Volume(a6),d0
		tst.b	Voice_Tremolo_Position(a6)
		bmi.s	Mt_TremoloNeg
		add.w	d2,d0
		bra.s	Mt_Tremolo3
Mt_TremoloNeg
		sub.w	d2,d0
Mt_Tremolo3
		bpl.s	Mt_TremoloSkip
		clr.w	d0
Mt_TremoloSkip
		cmp.w	#$40,d0
		bls.s	Mt_TremoloOk
		move.w	#$40,d0
Mt_TremoloOk
		move.w	d0,Voice_Sample_Volume(a6)
		move.b	Voice_Tremolo_Command(a6),d0
		lsr.w	#2,d0
		and.w	#$003c,d0
		add.b	d0,Voice_Tremolo_Position(a6)
		bra	Simplet_Period_Nop


Simplet_Sample_Offset
		move.l	Voice_Sample_Offset(a6),d1
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		beq.s	Simplet_Sample_Offset_No_New

		lsl.w	#8,d0
		move.l	d0,d1
Simplet_Sample_Offset_No_New

		move.l	Voice_Sample_Offset(a6),d0
		add.l	d1,d0
		cmp.l	Voice_Length(a6),d0
		ble.s	Simplet_Sample_Offset_Ok
		move.l	Voice_Length(a6),d0
Simplet_Sample_Offset_Ok
		move.l	d0,Voice_Sample_Offset(a6)
		move.l	d0,Voice_Sample_Position(a6)
		rts


Simplet_Volume_Slide
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		lsr.w	#4,d0
		beq.s	Simplet_Volume_Slide_Down

Simplet_Volume_Slide_Up
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$40,Voice_Volume(a6)
		ble.s	Simplet_Volume_Slide_Up_Ok
		move.w	#$40,Voice_Volume(a6)

Simplet_Volume_Slide_Up_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra	Simplet_Period_Nop


Simplet_Volume_Slide_Down
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0

Simplet_Volume_Slide_Down2
		sub.w	d0,Voice_Volume(a6)
		bpl.s	Simplet_Volume_Slide_Down_Ok
		clr.w	Voice_Volume(a6)

Simplet_Volume_Slide_Down_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra	Simplet_Period_Nop


Simplet_Position_Jump
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0

		move.w	d0,Simplet_Position_Jump_Pos
		st	Simplet_Position_Jump_Flag
		rts


Simplet_Volume_Change
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		cmp.b	#$40,d0
		ble.s	Simplet_Volume_Change_Ok
		moveq.l	#$40,d0

Simplet_Volume_Change_Ok
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		rts


Simplet_Pattern_Break
		moveq.l	#0,d0

		tst.b	Simplet_Old_Module(pc)
		bne.s	Simplet_Pattern_Break_Ok

		move.b	Voice_Parameters(a6),d0

		move.w	d0,d2			; Codage en BCD
		lsr.w	#4,d0			; premier chiffre
		mulu.w	#10,d0			; les dizaines
		and.w	#$0f,d2			; deuxiŠme chiffre
		add.w	d2,d0			; les unit‚s

		cmp.w	Simplet_Pattern_Length(pc),d0
		blo.s	Simplet_Pattern_Break_Ok
		moveq.l	#0,d0
	
Simplet_Pattern_Break_Ok
		move.w	d0,Simplet_Pattern_Break_Position
		st	Simplet_Pattern_Break_Flag
		rts


Simplet_Set_Speed
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		beq.s	Simplet_End
		cmp.b	#32,d0
		bhi.s	Simplet_Set_Tempo
		move.b	d0,Simplet_Speed
Simplet_End
		rts

Simplet_Set_Tempo
		move.b	d0,Simplet_Tempo
		sub.b	#32,d0
		lea.l	Simplet_Tempo_Table(pc),a2
		move.w	(a2,d0.w*4),Simplet_IT_Sample_Length
		move.b	2(a2,d0.w*4),Simplet_IT_Timer_Control
		move.b	3(a2,d0.w*4),Simplet_IT_Timer_Data
		rts


Simplet_Fine_Portamento_Up
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra	Simplet_Portamento_Up2
 
Simplet_Fine_Portamento_Down
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra	Simplet_Portamento_Down2


Simplet_Set_Glissando_Control
		move.b	Voice_Parameters(a6),Voice_Glissando_Control(a6)
		rts

Simplet_Set_Vibrato_Control
		move.b	Voice_Parameters(a6),Voice_Vibrato_Control(a6)
		rts

Simplet_Set_Fine_Tune
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		mulu.w	#12*3*2,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)
		rts

Simplet_Pattern_Loop
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		beq.s	Simplet_Set_Loop_Position

		tst.w	Simplet_Pattern_Loop_Counter(pc)
		beq.s	Simplet_Set_Loop_Counter

		subq.w	#1,Simplet_Pattern_Loop_Counter
		beq	Simplet_Return

Simplet_Do_Loop	
		st	Simplet_Pattern_Loop_Flag
		rts
Simplet_Set_Loop_Counter
		move.w	d0,Simplet_Pattern_Loop_Counter
		bra.s	Simplet_Do_Loop
Simplet_Set_Loop_Position
		move.w	Simplet_Pattern_Position(pc),Simplet_Pattern_Loop_Position
		rts


Simplet_Set_Tremolo_Control
		move.b	Voice_Parameters(a6),Voice_Tremolo_Control(a6)
		rts


Simplet_Retrig_Note
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		beq.s	Simplet_No_Retrig_Note

		moveq.l	#0,d1
		move.b	Simplet_Counter(pc),d1
		bne.s	Simplet_Retrig_Note_Skip

		tst.w	Voice_Note(a6)
		bne.s	Simplet_No_Retrig_Note

Simplet_Retrig_Note_Skip
		divu.w	d0,d1
		swap.w	d1
		tst.w	d1
		bne.s	Simplet_No_Retrig_Note

		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)

Simplet_No_Retrig_Note
		rts


Simplet_Volume_Fine_Up
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra	Simplet_Volume_Slide_Up


Simplet_Note_Cut
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		cmp.b	Simplet_Counter(pc),d0
		bne	Simplet_Return
		clr.w	Voice_Volume(a6)
		clr.w	Voice_Sample_Volume(a6)
		rts

Simplet_Note_Delay
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		cmp.b	Simplet_Counter(pc),d0
		bne	Simplet_Return
		tst.w	Voice_Note(a6)
		beq	Simplet_Return

		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
		move.l	Voice_Length(a6),d0
		move.l	Voice_Repeat_Length(a6),d1
		add.l	d1,d0
		move.l	d0,Voice_Sample_Length(a6)
		move.l	d1,Voice_Sample_Repeat_Length(a6)
		rts


Simplet_Pattern_Delay
		tst.b	Simplet_Pattern_Delay_Time(pc)
		bne	Simplet_Return
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		move.b	d0,Simplet_Pattern_Delay_Time
		rts


Simplet_Funk_It
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		move.b	d0,Voice_Funk_Speed(a6)
		beq	Simplet_Return

Simplet_Funk_Update
		moveq.l	#0,d0
		move.b	Voice_Funk_Speed(a6),d0
		beq	Simplet_Return

		lea.l	Simplet_Funk_Table(pc),a0
		move.b	(a0,d0.w),d0
		add.b	d0,Voice_Funk_Offset(a6)
		btst.b	#7,Voice_Funk_Offset(a6)
		beq	Simplet_Return

		clr.b	Voice_Funk_Offset(a6)

		movea.l	Voice_Funk_Position(a6),a0
		addq.w	#1,a0
		cmpa.l	Voice_Repeat_Length(a6),a0
		blo.s	Simplet_Funk_Ok
		movea.w	#0,a0
Simplet_Funk_Ok
		move.l	a0,Voice_Funk_Position(a6)
		add.l	Voice_Funk_Start(a6),a0
		moveq.l	#-1,d0
		sub.b	(a0),d0
		move.b	d0,(a0)
		rts		


Simplet_Sinus_Table	
		dc.b	0,24,49,74,97,120,141,161,180,197,212,224
		dc.b	235,244,250,253,255,253,250,244,235,224
		dc.b	212,197,180,161,141,120,97,74,49,24

Simplet_Funk_Table
		dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128


Simplet_Period_Table
; Tuning 0, Normal
		dc.w 856,808,762,720,678,640,604,570,538,508,480,453
		dc.w 428,404,381,360,339,320,302,285,269,254,240,226
		dc.w 214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
		dc.w 850,802,757,715,674,637,601,567,535,505,477,450
		dc.w 425,401,379,357,337,318,300,284,268,253,239,225
		dc.w 213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
		dc.w 844,796,752,709,670,632,597,563,532,502,474,447
		dc.w 422,398,376,355,335,316,298,282,266,251,237,224
		dc.w 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
		dc.w 838,791,746,704,665,628,592,559,528,498,470,444
		dc.w 419,395,373,352,332,314,296,280,264,249,235,222
		dc.w 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
		dc.w 832,785,741,699,660,623,588,555,524,495,467,441
		dc.w 416,392,370,350,330,312,294,278,262,247,233,220
		dc.w 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
		dc.w 826,779,736,694,655,619,584,551,520,491,463,437
		dc.w 413,390,368,347,328,309,292,276,260,245,232,219
		dc.w 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
		dc.w 820,774,730,689,651,614,580,547,516,487,460,434
		dc.w 410,387,365,345,325,307,290,274,258,244,230,217
		dc.w 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
		dc.w 814,768,725,684,646,610,575,543,513,484,457,431
		dc.w 407,384,363,342,323,305,288,272,256,242,228,216
		dc.w 204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
		dc.w 907,856,808,762,720,678,640,604,570,538,508,480
		dc.w 453,428,404,381,360,339,320,302,285,269,254,240
		dc.w 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
		dc.w 900,850,802,757,715,675,636,601,567,535,505,477
		dc.w 450,425,401,379,357,337,318,300,284,268,253,238
		dc.w 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
		dc.w 894,844,796,752,709,670,632,597,563,532,502,474
		dc.w 447,422,398,376,355,335,316,298,282,266,251,237
		dc.w 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
		dc.w 887,838,791,746,704,665,628,592,559,528,498,470
		dc.w 444,419,395,373,352,332,314,296,280,264,249,235
		dc.w 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
		dc.w 881,832,785,741,699,660,623,588,555,524,494,467
		dc.w 441,416,392,370,350,330,312,294,278,262,247,233
		dc.w 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
		dc.w 875,826,779,736,694,655,619,584,551,520,491,463
		dc.w 437,413,390,368,347,328,309,292,276,260,245,232
		dc.w 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
		dc.w 868,820,774,730,689,651,614,580,547,516,487,460
		dc.w 434,410,387,365,345,325,307,290,274,258,244,230
		dc.w 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
		dc.w 862,814,768,725,684,646,610,575,543,513,484,457
		dc.w 431,407,384,363,342,323,305,288,272,256,242,228
		dc.w 216,203,192,181,171,161,152,144,136,128,121,114


; Table qui contient les paramŠtres pour l'interruption Timer
; et le nombre de samples … calculer en fonction du Tempo

Simplet_Tempo_Table	IncBin	'TEMPODSP.TAB'

; Variables de gestion

			ds.b	1
Simplet_Old_Module	ds.b	1
Simplet_Sequence_Adr	ds.l	1
Simplet_Patterns_Adr	ds.l	1
Simplet_Line_Size	ds.w	1
Simplet_Pattern_Size	ds.w	1
Simplet_Samples_Adr	ds.l	31

Simplet_Voices_Nb	ds.w	1
Simplet_Samples_Nb	ds.w	1

Simplet_Song_Position	ds.w	1
Simplet_Song_Length	ds.w	1
Simplet_Song_Restart	ds.w	1

Simplet_Pattern_Position	ds.w	1
Simplet_Pattern_Length		ds.w	1

Simplet_Pattern_Loop_Counter	ds.w	1
Simplet_Pattern_Loop_Position	ds.w	1
Simplet_Pattern_Break_Position	ds.w	1
Simplet_Position_Jump_Pos	ds.w	1
Simplet_Pattern_Loop_Flag	ds.b	1
Simplet_Pattern_Break_Flag	ds.b	1
Simplet_Position_Jump_Flag	ds.b	1
Simplet_Pattern_Delay_Time	ds.b	1
Simplet_Tempo			ds.b	1
Simplet_Speed			ds.b	1
Simplet_Counter			ds.b	1

Simplet_IT_In_Service		ds.b	1
Simplet_IT_Timer_Control	ds.b	1
Simplet_IT_Timer_Data		ds.b	1
Simplet_IT_Sample_Length	ds.w	1

Simplet_Voices			ds.b	8*Voice_Size

; Pour un enchainement st‚r‚o Amiga  L R R L L R R L
Increment_Voice_1		dc.w	2*Voice_Size
Increment_Voice_2		dc.w	-Voice_Size
Increment_Voice_3		dc.w	2*Voice_Size
Increment_Voice_4		dc.w	Voice_Size

; Pour un enchainement st‚r‚o simple L R L R L R L R
*Increment_Voice_1		dc.w	Voice_Size
*Increment_Voice_2		dc.w	Voice_Size
*Increment_Voice_3		dc.w	Voice_Size
*Increment_Voice_4		dc.w	Voice_Size

*******************************************************************
***********			Routine DSP		***********
*******************************************************************

DSP_Code	IncBin	'TRACKER.P56'
DSP_End		Even




new_kbd
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

	clr.b	$fffffa1b.w
	move.l	#timerb,$120.w
	move.b	#55,$fffffa21.w		;reset timerb data
	clr.w	colour_offset
	move.b	#8,$fffffa1b.w		;ei timer b
	rts



************** TIMER B (RASTER ISR) **************

timerb		clr.b	$fffffa1b.w		;stop timer B
		move.b	#9,$fffffa21.w
	move.l	a0,-(sp)
	lea	colours,a0
	add.w	colour_offset,a0
	move.w	(a0),$ffff8242.w
	add.w	#2,colour_offset
	move.l	(sp)+,a0
		move.b	#8,$fffffa1b.w
		rte				;continue

**************************************************
































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
	move.l	#timerb,$120.w
	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#188,$fffffa21.w		;timer B data
	move.b	#8,$fffffa1b.w		;ei timber B

	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w

	clr.b	$FFFFFA19.w		;stop timer A
	move.b	#1,$FFFFFA1F.w		;timer A data

	move.l	$134.w,oldtima
	move.l	#stereo,$0134.w
	move.b	#8,$FFFFFA19.w		;stop timer A

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
	dc.w	%0000010001001100	*bass    (+12 dB)
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
	move.l	#timerb,$120.w
	bclr	#3,$fffffa17.w		; Autovectors
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#188,$fffffa21.w	;timer B data
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

newvbl	move.w	pic+2,$ffff8240.w
	clr.w	vsyncflag
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
	lea	mod,a1		; Module
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
init	lea	mod,a0
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

music	lea	mod,a0
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

getnew	lea	mod+$043C,a0
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
	cmp.b	mod+$03B6,d1
	bne.s	endr
	move.b	mod+$03B7,songpos
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

set_super
		ifeq	DOWNLOAD
		clr.l	-(sp)		;Set super stack equal
		move.w	#$20,-(sp)	; to user stack before call
		trap	#1
		addq.l	#6,sp		;correct stack
		move.l	d0,stack_save	;save old supervisor stack value
		endc
		rts

set_user
		ifeq	DOWNLOAD
		move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1		;back to user
		addq.l	#6,sp		;correct stack
		endc
		rts

get_old_palette	lea	$ffff8240.w,a0
		lea	old_palette,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

set_new_palette:
	lea	pic+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	$ffff8240.w,a1
	REPT	16
	move.w	(a0)+,(a1)+
	ENDR
	rts

get_screen_base	move.w	#3,-(sp)
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

set_low_rez:
	clr.w	-(sp)
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez	move.l	screen_base,-(sp)
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
		clr.b	(a5)
		move.b	(a5),d0	;get original value
		move.b	#-1,(a5)	;poke new value
		move.b	(a5),d1
		cmp.b	d1,d0		;get value again, is it same?
		beq	.notSTE	;yes same so not ste
		move.b	d7,(a5)
.ste_found	move.w	#-1,ste_flag
		lea	preset,a0
		lea	model,a1
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
.notSTE		rts


test_4_falcon
*** Detect Falcon computer code...
***
*** Written by MAC SYS DATA of PERSISTENCE OF VISION
***
***

; Execute in Supervisor mode

	move.l	$5a0,a0
	cmp.l	#0,a0
	beq.s	.nocookiejar
	move.l	$14(a0),d0	;get video shifter type?
	tst.l	d0
	beq.s	.notdma
	cmp.l	#$30000,d0
	beq.s	.yesfalcon
.notdma
.nocookiejar
	rts
.yesfalcon
	move.w	#-1,falcon_flag
		lea	preset+6,a0
		lea	model,a1
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)+

	rts


	ifeq	DOWNLOAD
****************
 SECTION DATA
****************
	endc

mod	INCBIN	95-rave.npk
modend
	ds.b	710110-(modend-mod)

	DS.B	34000			; Workspace
workspc	DS.W	1

pic	incbin	pic.pi1


; 13=next line
; 15=end of line, time delay text is on screen (max 126)
; 12=del char
; 11=delay

;NOTE:   THE ROUTINE SUPPORTS TAB!!!
ascii_pos	dc.l	ascii
;                123456789012345678901234567890123456789	39 CHARS ONLY
ascii
	dc.b	13,13,13,13,13,13,13
	dc.b	"		PRESENTING",13,15,70

	dc.b	13,13,13,13
	dc.b	"---------------------------------------",13
	dc.b	" bbbb   bbb  b   b	 b  bbbbb  bbb ",13
	dc.b	" b   b b   b b   b	bb  b     b  bb",13
	dc.b	" bbbb  b   b b   b	 b  bbbb  b b b",13
	dc.b	" b     b   b  b b 	 b      b bb  b",13
	dc.b	" b      bbb    b  	bbb bbbb   bbb ",13
	dc.b	"---------------------------------------",13
	dc.b	"		DISK FILLER!",13
	dc.b	15,100

	dc.b	13,13,13
	dc.b	"		CALLED....",13,13
	dc.b	"	  bbbb   bbb  b   b bbbbb",13
	dc.b	"	  b   b b   b b   b b",13
	dc.b	"	  bbbb  b   b b   b bbbb",13
	dc.b	"	  b  b  bbbbb  b b  b",13
	dc.b	"	  b   b b   b   b   bbbbb",13
	dc.b	13
	dc.b	"          PLAYING ON AN ATARI "
model	dc.b	"STFM  "
	dc.b	15,80

	dc.b	"",13
	dc.b	"",13
	dc.b	"",13
	dc.b	"",13
	dc.b	"   STICKING WITH HISTORICAL EVENTS OF",13
	dc.b	"  PERSISTENCE OF VISION, THIS DISK WAS",13
	dc.b	"     CODED ENTIRELY BY POV MEMBERS.",13
	dc.b	"",13,11,11,11,11
	dc.b	" TO BE MORE ACCURATE, THIS DISK IS THE",13
	dc.b	"  PRODUCT OF ONE PERSON IN POV WITH A",13
	dc.b	"   FEW BITS OF ART FROM AN EX MEMBER",13
	dc.b	"   DATING BACK SOME 4 YEARS WITH THE",13
	dc.b	" EXCEPTION OF THE ABOVE LOGO DRAWN",13
	dc.b	"	         BY GONZO.",13
	dc.b	15,126

	dc.b	"",13
	dc.b	"",13
	dc.b	"",13
	dc.b	" THIS DISK IS THE PRODUCT OF TWO YEARS",13
	dc.b	"WORK. I KNOW IT DOES NOT LOOK MUCH AND",13
	dc.b	" IS VERY DATED BY MODERN DEMOS BUT YOU",13
	dc.b	"      ARE LUCKY TO SEE IT AT ALL.",13
	dc.b	"",13,11,11,11
	dc.b	"   ONCE I HAD COMPLETED THE SCREENS I",13
	dc.b	"   BUILT A TEST VERSION AND REALISED",13
	dc.b	"  THERE WAS A SHED FULL OF DISK SPACE",13
	dc.b	" AVAILABLE SO I DECIDED TO WRITE A DISK",13
	dc.b	"		 FILLER.",13
	dc.b	"",13
	dc.b	"",13
	dc.b	15,126

	dc.b	"",13
	dc.b	"",13
	dc.b	"",13
	dc.b	"  THIS SCREEN IS NAMED RAVE AFTER THE",13
	dc.b	"  MOD WHICH IS CALLED 95-RAVE AND WAS",13
	DC.B	" WRITTEN BY DAX OF RAVEBUSTERS IN 1995.",13
	DC.B	13
	DC.B	"  THE MOD IS OVER 10 MINUTES LONG AND",13
	DC.B	"  IS SUPERB SO MAKE SURE YOU LISTEN TO",13
	DC.B	"		IT ALL.",13,13
	DC.B	"   UNFORTUNATELY THE MOD IS OVER 750K",13
	DC.B	"    AND SO IS TOO LARGE FOR HALF MEG",13
	DC.B	"		 OWNERS.",13
	dc.b	15,126

;                123456789012345678901234567890123456789	39 CHARS ONLY
	dc.b	"",13
	dc.b	"",13
	dc.b	"",13
	dc.b	"IF YOU HAVE A PC AND WOULD LIKE TO SEE",13
	dc.b	"  A COOL EMULATOR THEN GET A COPY OF",13
	dc.b	"		PACIFIST.",13
	dc.b	"",13
	dc.b	"",13
	dc.b	" THIS EMULATOR IS VIRTUALLY 100 PERCENT",13
	dc.b	"  ATARI COMPATIBLE AND RUNS NEARLY ALL",13
	dc.b	"		POV MENUS.",13
	dc.b	15,126

	dc.b	13
	dc.b	"PACIFIST DOES NOT PRESENTLY SUPPORT THE",13
	DC.B	"  HARDWARE FEATURES OF THE STE SO SOME",13
	DC.B	"   DEMOS AND MENUS DO NOT WORK AT ALL.",13
	DC.B	13
	dc.b	" FUTURE POV MENUS DETECT WHEN THEY ARE",13
	DC.B	"        RUNNING UNDER PACIFIST.",13,13
	DC.B	"  IF PACIFIST CANNOT FULLY SUPPORT THE",13
	DC.B	"  MENU THEN ONE OF TWO THINGS HAPPEN;",13,13,11,11
	DC.B	"   1) THE MENU WILL AUTOMATICALLY RUN",13
	DC.B	"      ALTERNATIVE CODE",13,13,11,11
	DC.B	" 2) INFORM YOU IT CANNOT RUN CORRECTLY",13
	DC.B	"    VIA A BASIC INTRO.",13,11,11
	DC.B	15,126

	DC.B	13,13,13,13,13
	DC.B	" IF YOU WOULD LIKE TO CONTACT POV THEN",13
	DC.B	"	       E-MAIL ME AT",13,13
	DC.B	"	  POV@FATAL-DESIGN.COM",13,13,11
	DC.B	15,126

	DC.B	13,13,13,13
	DC.B	"   YOU CAN VISIT THE POV WEB SITE AT",13,13
	DC.B	"WWW.GEOCITIES.COM/SILICONVALLEY/LAB/1436",13,13,13,11,11,11,11,11
	DC.B	"          AND NOW IT'S TIME FOR",13,13,11,11
	dc.b	"            WARP............",12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,11,"WRAP........"
	dc.b	11,11,11,11,11,11,11
	dc.b	15,126

	dc.b	-1		;end of text in pages....
		even

font	incbin	8X8_comp.FNT
preset	dc.b	"STE   "
	dc.b	"FALCON"

nomouse		dc.b	$12,$1a
yesmouse	dc.b	$14,$08

l0042	dc.w	62391
l0053	dc.w	0
l0054	dc.w	0
l0055	dc.w	0
l0056	dc.w	0
screen_bytes	dc.l	0

colour_offset	dc.w	0
colours	dc.w	$200,$300,$400,$510,$620,$730,$640,$550
	dc.w	$460,$371,$272,$173,$074,$075,$076,$077

	ifeq	DOWNLOAD
	SECTION BSS
	endc
bssstart
stack_save	ds.l	1
black		ds.b	32
old_timerb	ds.l	1
store		ds.l	1
oldkbd		ds.l	1
key		ds.w	1
ste_flag	ds.w	1
falcon_flag	ds.w	1
org_falcon_rez	ds.w	1
org_overscanbtm	ds.w	1
oldvbl		ds.l	1
old_palette	ds.w	16
screen_base	ds.l	1
original_rez	ds.w	1

xpos		ds.w	1
ypos		ds.l	1
cursor		ds.w	1
delay_timer	ds.w	1
	even
enable_text	ds.b	1
	even


eobss

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
