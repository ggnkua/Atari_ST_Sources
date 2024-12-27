*************************************************************************
*		General startup shell code for ST/STE/FALCON		*
*		--------------------------------------------		*
*									*
*									*
* Written by:	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
*									*
*									*
*									*
*									*
*									*
*									*
*************************************************************************


yes=1
YES=yes
no=0
NO=no

DOWNLOAD	equ	no

		ifne	DOWNLOAD
		include	TRANSMIT.S
		org	$20000
Code_Start
Exec_Addr
		endc




		bsr	set_up

main_loop	bsr	v_sync
		bsr	set_screen	;screen flip
		move.w	#$123,$ffff8240.w

		move.w	pic+2,$ffff8240.w
		bsr	tst_key
		tst.l	d0
		beq.s	main_loop

		tst.w	falcon_flag
		bne	do_shutdown_falcon

		bsr	set_old_palette

		move.w	#1,-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

finish		move.b	#$8,$fffffc02.w

		ifeq	DOWNLOAD
		bsr	set_user
		endc

		ifne	DOWNLOAD
		move.l	4.w,-(sp)
		rts
		endc

		clr.w	-(sp)
		trap	#1

do_shutdown_falcon
		bsr	shutdown_falcon
		bra.s	finish

*******************
* CUSTOM ROUTINES *
*******************





***********************
* SUBROUTINES SECTION *
***********************
v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

tst_key	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts


set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


set_old_palette
	lea	old_st_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts




set_up
		ifeq	DOWNLOAD
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_st_palette

		bsr	test_for_ste
		bsr	test_for_falcon
		tst.w	falcon_flag
		bne	setup_falcon

		move.w	#4,-(sp)	;get_original_rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		clr.w	-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

set_screen	move.l	scr_now,d6
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

setup_falcon
		lea	falcon_store,a0
		lea	$ffff8200.w,a1		; Videobase.
		move.w	$60(a1),(a0)+
		move.w	$66(a1),(a0)+
		move.l  $C0(a1),(a0)+
		move.w  $0A(a1),(a0)+
		move.w  $0E(a1),(a0)+
		move.w  $10(a1),(a0)+
		move.l  $82(a1),(a0)+
		move.l  $86(a1),(a0)+
		move.l  $8A(a1),(a0)+
		move.l  $A2(a1),(a0)+
		move.l  $A6(a1),(a0)+
		move.l  $AA(a1),(a0)+

.savefv		lea	FVbuffer1298,a1
		move.l	#'FVD2',(a1)+	4 bytes header
		move.b	$ff8006,(a1)+	monitor type
		move.b	$ff820a,(a1)+	sync
		move.l	$ff820e,(a1)+	offset & vwrap
		move.w	$ff8266,(a1)+	spshift
		move.l	#$ff8282,a0	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a0
		bne	.loop1
		move.l	#$ff82a2,a0	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a0
		bne	.loop2
		move	$ff82c2,(a1)+	video control
		move	$ff82c0,(a1)+	video clock
		move.b	$ff8260,(a1)+	shifter resolution
		move.b	$ff820a,(a1)+	video sync mode

		move.w	#-1,-(sp)
		move.w	#$58,-(sp)	;get_original_rez
		trap	#14
		addq.l	#4,sp
		move.w	d0,org_falcon_rez

		move.w	$ffff82aa.w,org_overscanbtm	;bottom overscan

;Word is made up like so :  X X X X X X X V S O P M 8 N N N
;	N  Bits per pixels :	4 -> 16 bits	65536 colours
;				3 -> 8  bits	256 colours
;				2 -> 4  bits	16 colours
;				1 -> 2  bits	1 colours
;				0 -> 1  bit     0 colours?????
;	8 Flag 80 columns  :	1 -> mode 80 columns
;				0 -> mode 40 columns
;	M Flag VGA         :	1 -> mode monitor VGA
;				0 -> mode TV/RGB
;	P Flag PAL         :	1 -> mode PAL
;				0 -> mode NTSC
;	O Flag Overscan    :	1 -> Overscan ON (not valid on VGA)
;				0 -> Overscan OFF
;   S ST compatibility flag:    1 -> Yes
;                               0 -> No
;       V Vertical flag    :    1 -> enable interlace mode on colour
;                                    monitor or double line mode on VGA
;
;       X Reserved         :    Reserved (set 0)

;		move.w	#48,$ffff82aa.w	;overscan bottom by x number of lines

;This bit will automatically set the falcon video res but it will
;preserve the RGB/VGA mode.
		move.w	d0,d1
		and.w	#%00010000,d1	;keep vga/rgb-tv settings
		move.w	#%0000000010000010,d0
		or.w	d1,d0

		move.w	d0,-(sp)	;modecode
		move.w	#3,-(sp)	;mode
		move.l	#-1,-(sp)	;phys
		move.l	(sp),-(sp)	;log
		move.w	#5,-(sp)
		trap	#14
		add.l	#14,sp

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		bra	set_screen

shutdown_falcon	lea	falcon_store,a0
		lea	$ffff8200.w,a1	; Videobase.
		move.w	(a0)+,$60(A1)
		move.w	(a0)+,$66(A1)
		move.l  (a0)+,$C0(A1)
		move.w  (a0)+,$0A(A1)
		move.w  (a0)+,$0E(A1)
		move.w  (a0)+,$10(A1)
		move.l  (a0)+,$82(A1)
		move.l  (a0)+,$86(A1)
		move.l  (a0)+,$8A(A1)
		move.l  (a0)+,$A2(A1)
		move.l  (a0)+,$A6(A1)
		move.l  (a0)+,$AA(A1)

.restorefv	move.l	#FVbuffer1298,a0
		bsr	setfv

		move.w	org_falcon_rez,-(sp)	;mode
		move.w	#3,-(sp)		;modecode
		move.l	screen_base,-(sp)	;phys
		move.l	(sp),-(sp)		;log
		move.w	#5,-(sp)
		trap	#14
		add.l	#14,sp

		rts

setfv		cmp.l	#'FVD2',(a0)+	4 bytes header
		bne	.error
.ready		addq.l	#2,a0
		move.l	$70,-(sp)
		move	sr,-(sp)
		move.l	#.vbl,$70
		move	#$2300,sr
		
		move.l	$466,d0
.wait		cmp.l	$466,d0
		beq	.wait
		
		move.l	(a0)+,$ff820e	offset & vwrap
		move.w	(a0)+,$ff8266	spshift
		move.l	#$ff8282,a1	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a1
		bne	.loop1
		move.l	#$ff82a2,a1	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a1
		bne	.loop2
		move	(a0)+,$ff82c2	video control
		move	(a0)+,$ff82c0	video clock
		addq.l	#1,a0
		move.b	(a0)+,$ff820a	video sync mode
		move	(sp)+,sr
		move.l	(sp)+,$70
		moveq	#0,d0
		rts
.error		moveq	#-1,d0
		rts
.wrongmon	moveq	#-2,d0
		rts
.sm124		cmp.b	#0,(a0)
		bne	.wrongmon
		bra	.ready
.vga		cmp.b	#2,(a0)
		bne	.wrongmon
		bra	.ready
.vbl		addq.l	#1,$466
		rte
		



test_for_ste	lea	$ffff8205.w,a5
		move.b	(a5),d0		;get original value
		move.b	#-1,(a5)	;poke new value
		cmp.b	(a5),d0		;get value again, is it same?
		bne	.notSTE		;yes same so not ste
		move.b	d0,(a5)		;yes so poke original value back
.ste_found	move.w	#-1,ste_flag
.notSTE		rts

test_for_falcon
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
		rts
.yesfalcon	move.w	#-1,falcon_flag
		rts
.notdma
.nocookiejar	rts


		ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
		endc
pic		incbin	"h:\pics\oz\close.pi1"



		ifeq	DOWNLOAD
*******************
   SECTION BSS
*******************
		endc
stack_save	ds.l	1
falcon_flag	ds.w	1
ste_flag	ds.w	1
screen_base	ds.l	1
original_rez	ds.w	1
old_st_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1

falcon_store	ds.b	38
falcon030	ds.w	1
org_overscanbtm	ds.w	1
org_falcon_rez	ds.w	1
FVbuffer1298	ds.w	24

		ds.b	256
screens		ds.b	32000
		ds.b	32000

		ifne	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
		endc
