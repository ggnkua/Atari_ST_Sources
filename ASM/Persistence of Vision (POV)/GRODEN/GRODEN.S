*************************************************************************
*			Groden and Kvack Kvack type demo		*
*			--------------------------------		*
*									*
*									*
* Written by:	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Date:		April 1996 -  May 1997 					*
*									*
*									*
*									*
* Inspired by the TCB version in SO WATT DEMO				*
*									*
*************************************************************************


yes=1
YES=yes
no=0
NO=no

FINAL		equ	yes
TEST		equ	no	;yes turns off tracker to hopefully prevent total bomb out
DEVELOP		equ	no	;yes for development to include 9 PI1s
DISASSEM	equ	no	;yes to check using MONST, no for hard scroll
DOWNLOAD	equ	no


******************************************************************************
* DOWNLOAD is the widget downloader written by POV. Using a special parallel
* lead you can code on one machine and run the executable on a slave machine.
* This saves you time rebooting your main machine plus you can code for the
* Falcon from an STE or code for an STE on your Falcon. A PC version is
* available that allows you to code on PC, download to ST/STE/FALCON.
		ifne	DOWNLOAD
		include	TRANSMIT.S
		org	$20000
Code_Start
Exec_Addr
		endc


LINEWID		equ	80


******************************************************************************

******************************************************************************


;-----------------------------------------------------------------------;
; 	Replay STe							;
; 	by WizzCat the 21st of May 1991					;
;-----------------------------------------------------------------------;
; Uses no registers							;
;									;
; Replay is started by calling MUSON in supervisor mode. Returns with	;
; timer A running. Calling MUSOFF will stop music.			;
;									;
; This routine needs some workspace after the module to work properly.	;
; We've set it to 16k, some modules needs more, some need less. If the	;
; workspace is too small, initialization will hang on an ILLEGAL	;
; instruction. Adjust workspace size to fit the specific module.	;
;									;
; MVOL = Main volume	  (Unnecessary to adjust. $80 default)		;
; FREQ = replay frequency (See below)					;
;-----------------------------------------------------------------------;

MVOL	EQU $80
FREQ	EQU 1				; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)

	IFEQ FREQ
PARTS	EQU 5-1				; 6.259
LEN	EQU 25
INC	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ-1
PARTS	EQU 5-1				; 12.517
LEN	EQU 50
INC	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ-2
PARTS	EQU 5-1				; 25.035
LEN	EQU 100
INC	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ-3
PARTS	EQU 5-1				; 50.072
LEN	EQU 200
INC	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC


	opt	o+,w-

		bsr	set_up
		tst.w	ste_flag
		beq.s	finish
		move.w	#$2300,sr


		move.w	pic1+6,$ffff8246.w	;prevent colour overlap
;	move.w	#007,$ffff8246.w

****** REMEMBER:
******          FROM HERE ONWARDS THE SCREEN IS 320 BYTES LONG
******


main_loop
		ifeq	DISASSEM
	bsr	vsync
		elseif
		movem.l	d0/d1/d2/a0/a1/a2,-(sp)
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		movem.l	(sp)+,d0/d1/d2/a0/a1/a2
		endc


;	move.w	#$123,$ffff8240.w

		bsr	hardware_scroll
		bsr	software_scroll

	bsr	scroller

;	clr.w	$ffff8240.w


		cmp.b	#$39,$fffffc02.w
		bne.s	main_loop


		clr.b	$ffff8264.w		;bit offset

* $ffff820e is byte on STE ($ffff820f)
* $ffff820e is word on Falcon
		move.b	#0,$ffff820f.w		;offset to next word of screen
		move.w	#0,$ffff8264.w

		move.l	old_vbl,$70.w

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


*******************
* CUSTOM ROUTINES *
*******************

scroller
	rts










hardware_scroll	move.l	offset_pointer,a0
.get		move.l	(a0)+,d0
		bpl.s	.no_reset
		lea	table1,a0
		move.l	(a0)+,d0
*here we go to do hardware scroll
.no_reset	move.l	a0,offset_pointer
		move.w	d0,d1
		move.w	d0,d2
		move.l	d0,d4
		swap	d4
		move.w	d0,screen2_pixel_offset	;0-15 shift number

		and.l	#$f0,d1		;shift = /8
		lsr.w	#1,d1

		move.l	scr_now,d6
		and.l	#$ff00,d2	;256 boundary
		lsr.l	#1,d2
		add.w	d1,d2
		add.l	d2,d6

		; Y offset
		move.l	d4,d5	;*320	4 cycles
		lsl.l	#8,d4	;	24
		lsl.l	#6,d5	;	20
		add.l	d5,d4	;	8

		add.l	d4,d6
		move.l	d6,hard_addr
* screen 2
		add.l	d4,d2
		move.l	d2,screen2_address	;address to print screen 2
*

		and.w	#15,d0		;bit shift
		bne.s	.extra_fetch

		ifeq	DISASSEM
		move.b	#LINEWID,$ffff820f.w	;offset to next line
		move.b	d0,$ffff8265.w		;pixel shift
		endc
		move.b	hard_addr+1,$ffff8205.w
		move.b	hard_addr+2,$ffff8207.w
		move.b	hard_addr+3,$ffff8209.w
		rts
.extra_fetch
		ifeq	DISASSEM
		move.b	#LINEWID-4,$ffff820f.w	;offset to next line
		move.b	d0,$ffff8265.w		;pixel shift
		endc
		move.b	hard_addr+1,$ffff8205.w
		move.b	hard_addr+2,$ffff8207.w
		move.b	hard_addr+3,$ffff8209.w
		rts









*Software scroll routine will get offset from table and lookup correct
* preshifted picture, add screen word offset and display.
software_scroll
		lea	pic2_data,a0		;pre shifted data start
		move.w	screen2_pixel_offset,d0	;pixel shift of hard scroll rout
		and.w	#$f,d0			;mask off for 16 bits
		mulu	#80*200,d0		;multiply screen data size

;	add.w	#20,d0	;for testing...

		add.l	d0,a0		;A0 now points to pre-scrolled picture


**now get the word offset from our table + Y offset
		move.l	table2_pointer,a2	;get offset into table
.get		move.l	(a2)+,d0		;get data
		bpl.s	.no_reset		;if positive (not -1) then continue
		lea	table2,a2		;get start of table
		move.l	(a2)+,d0		;get data
.no_reset	move.l	a2,table2_pointer	;save position in table

		move.l	d0,d1
		swap	d0
		and.w	#$ff,d0
		and.w	#255,d1

		move.w	d1,d2	;mulu #160,d1
		lsl.w	#7,d1
		lsl.w	#5,d2
		add.w	d2,d1


** now d0.w = word offset
** and d1.w = Y offset

		add.w	d1,d0
		add.w	d0,a0

		move.l	scr_now,a1	;screen that hardware is showing
		add.l	screen2_address,a1
		add.w	#2,a1	;A1 now points to position we want to draw new screen

destin	set	0
		rept	200
		move.w	(a0)+,(a1)		;12
		move.w	(a0)+,destin+8(a1)	;16
		move.w	(a0)+,destin+16(a1)	;16
		move.w	(a0)+,destin+24(a1)	;16
		move.w	(a0)+,destin+32(a1)	;16
		move.w	(a0)+,destin+40(a1)	;16
		move.w	(a0)+,destin+48(a1)	;16
		move.w	(a0)+,destin+56(a1)	;16
		move.w	(a0)+,destin+64(a1)	;16
		move.w	(a0)+,destin+72(a1)	;16
		move.w	(a0)+,destin+80(a1)	;16
		move.w	(a0)+,destin+88(a1)	;16
		move.w	(a0)+,destin+96(a1)	;16
		move.w	(a0)+,destin+104(a1)	;16
		move.w	(a0)+,destin+112(a1)	;16
		move.w	(a0)+,destin+120(a1)	;16
		move.w	(a0)+,destin+128(a1)	;16
		move.w	(a0)+,destin+136(a1)	;16
		move.w	(a0)+,destin+144(a1)	;16
		move.w	(a0)+,destin+152(a1)	;16
		move.w	(a0)+,destin+160(a1)	;16  needed cos hardware scroll displays an extra word
		lea	38(a0),a0		;8 cycles
		lea	320(a1),a1		;8 cycles
		endr
		rts






*make a picture of a 2 wide pi1
shift_pic2	lea	screens,a6
		lea	pic2+34+2,a0
		move.w	#200-1,d0
.move
offset	set	0
		rept	160/4
		move.l	offset(a0),(a6)+
offset	set	offset+4
		endr


offset	set	0
		rept	160/4
		move.l	offset(a0),(a6)+
offset	set	offset+4
		endr

		lea	160(a0),a0
		add.w	#8,a6

		dbf	d0,.move




**now make a picture for the software scroll
		lea	pic2_data,a6
* Save the screen then shift it
		move.w	#16-1,d1
.times16
		lea	screens,a0
		move.w	#200-1,d0
.loop
		move.w	(a0),(a6)+
		move.w	8(a0),(a6)+
		move.w	16(a0),(a6)+
		move.w	24(a0),(a6)+
		move.w	32(a0),(a6)+
		move.w	40(a0),(a6)+
		move.w	48(a0),(a6)+
		move.w	56(a0),(a6)+
		move.w	64(a0),(a6)+
		move.w	72(a0),(a6)+
		move.w	80(a0),(a6)+
		move.w	88(a0),(a6)+
		move.w	96(a0),(a6)+
		move.w	104(a0),(a6)+
		move.w	112(a0),(a6)+
		move.w	120(a0),(a6)+
		move.w	128(a0),(a6)+
		move.w	136(a0),(a6)+
		move.w	144(a0),(a6)+
		move.w	152(a0),(a6)+

		move.w	160(a0),(a6)+
		move.w	160+8(a0),(a6)+
		move.w	160+16(a0),(a6)+
		move.w	160+24(a0),(a6)+
		move.w	160+32(a0),(a6)+
		move.w	160+40(a0),(a6)+
		move.w	160+48(a0),(a6)+
		move.w	160+56(a0),(a6)+
		move.w	160+64(a0),(a6)+
		move.w	160+72(a0),(a6)+
		move.w	160+80(a0),(a6)+
		move.w	160+88(a0),(a6)+
		move.w	160+96(a0),(a6)+
		move.w	160+104(a0),(a6)+
		move.w	160+112(a0),(a6)+
		move.w	160+120(a0),(a6)+
		move.w	160+128(a0),(a6)+
		move.w	160+136(a0),(a6)+
		move.w	160+144(a0),(a6)+
		move.w	160+152(a0),(a6)+

		lea	328(a0),a0
		dbf	d0,.loop

		lea	screens,a0
		move.w	#200-1,d0
.shift
		roxr	(a0)
		roxr	8(a0)
		roxr	16(a0)
		roxr	24(a0)
		roxr	32(a0)
		roxr	40(a0)
		roxr	48(a0)
		roxr	56(a0)
		roxr	64(a0)
		roxr	72(a0)
		roxr	80(a0)
		roxr	88(a0)
		roxr	96(a0)
		roxr	104(a0)
		roxr	112(a0)
		roxr	120(a0)
		roxr	128(a0)
		roxr	136(a0)
		roxr	144(a0)
		roxr	152(a0)

		roxr	160+0(a0)
		roxr	160+8(a0)
		roxr	160+16(a0)
		roxr	160+24(a0)
		roxr	160+32(a0)
		roxr	160+40(a0)
		roxr	160+48(a0)
		roxr	160+56(a0)
		roxr	160+64(a0)
		roxr	160+72(a0)
		roxr	160+80(a0)
		roxr	160+88(a0)
		roxr	160+96(a0)
		roxr	160+104(a0)
		roxr	160+112(a0)
		roxr	160+120(a0)
		roxr	160+128(a0)
		roxr	160+136(a0)
		roxr	160+144(a0)
		roxr	160+152(a0)

		lea	328(a0),a0
		dbf	d0,.shift

		dbf	d1,.times16
		rts








vsync
		move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		rts





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

		move.w	#$2700,sr
		move.l	$70.w,old_vbl
		bclr	#3,$fffffa17.w

		bsr	test_for_ste

		move.w	#4,-(sp)	;get_original_rez
		trap	#14
		addq.l	#2,sp
		move.w	d0,original_rez

	ifeq	DEVELOP
		movem.l	pic1+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
	endc

		clr.w	-(sp)
		move.l	#-1,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now

		bsr	text_on

		bsr	shift_pic2

		clr.b	$484.w
***development code...
		ifne	DEVELOP
		movem.l	pic1+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea	pic1+34,a0
		move.l	scr_now,a1
		move.w	#200-1,d0
.loop
offset	set	0
		rept	40
		move.l	(a0)+,offset(a1)
offset	set	offset+4
		endr
		lea	320(a1),a1
		dbf	d0,.loop


*set up pic 2
		lea	pic2+34,a0
		move.l	scr_now,a1
		lea	160(a1),a1
		move.w	#200-1,d0
.loop2
offset	set	0
		rept	40
		move.l	(a0)+,offset(a1)
offset	set	offset+4
		endr
		lea	320(a1),a1
		dbf	d0,.loop2


*set up pic 3
		lea	pic3+34,a0
		move.l	scr_now,a1
		add.l	#320*200,a1
		move.w	#200-1,d0
.loop3
offset	set	0
		rept	40
		move.l	(a0)+,offset(a1)
offset	set	offset+4
		endr
		lea	320(a1),a1
		dbf	d0,.loop3

*set up pic 4
		lea	pic4+34,a0
		move.l	scr_now,a1
		add.l	#320*200+160,a1
		move.w	#200-1,d0
.loop4
offset	set	0
		rept	40
		move.l	(a0)+,offset(a1)
offset	set	offset+4
		endr
		lea	320(a1),a1
		dbf	d0,.loop4
		endc
****end of development code




*This bit will make the main backdrop into a 2*2 matrix (hardware scrolled screens)
		ifeq	DEVELOP		;only do this if development is set to NO
		lea	pic1+34,a5
		move.l	scr_now,a4


		move.l	a5,a0
		move.l	a4,a1
		move.w	#200-1,d0
.loop
offset	set	0
		rept	40
		move.l	(a0),offset(a1)		;pic1
		move.l	(a0)+,offset+160(a1)	;pic2
offset	set	offset+4
		endr
		lea	320(a1),a1
		dbf	d0,.loop


*set up pic 3
		move.l	a5,a0
		move.l	a4,a1
		add.l	#320*200,a1
		move.w	#200-1,d0
.loop3
offset	set	0
		rept	40
		move.l	(a0),offset(a1)		;pic 3
		move.l	(a0)+,offset+160(a1)	;set up pic 4
offset	set	offset+4
		endr
		lea	320(a1),a1
		dbf	d0,.loop3
		endc


*start of mod setup
;---------------------------------------------------- Interrupts on/off --
muson	jsr	vol			; Calculate volume tables
	jsr	incrcal			; Calculate tonetables

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move	#$2700,sr

	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w

	clr.b	$FFFFFA19.w
	move.b	#1,$FFFFFA1F.w
	move.b	#8,$FFFFFA19.w

	move.l	$0134.w,oldtima
	move.l	#stereo,$0134.w

	move.b	#FREQ,$FFFF8921.w		; Frequency

	lea	$FFFF8907.w,a0

	move.l	#sample1,d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	#sample1+LEN*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	move.b	#3,$FFFF8901.w		; Start DMA
**end of mod setup

		ifeq	DEVELOP		;only do this if development is set to NO
		movem.l	pic1+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		endc

		move.b	#80,$ffff820f.w	;word offset to next line +160
		move.l	#newvbl,$70.w
		move.w	#$2300,sr
		rts



test_for_ste	lea	$ffff8205.w,a5
		move.b	(a5),d0		;get original value
		move.b	#-1,(a5)	;poke new value
		cmp.b	(a5),d0		;get value again, is it same?
		bne	.notSTE		;yes same so not ste
		move.b	d0,(a5)		;yes so poke original value back
.ste_found	move.w	#-1,ste_flag
.notSTE		rts



*** ISRs
newvbl		clr.w	vsync_flag
		rte


text_on		bsr	set_screen
		move.l	scr_now,a1
		lea	ascii,a2
	move.w	#$777,$ffff8242.w
		move.l	a1,a6
.loop		moveq	#0,d7
		move.b	(a2)+,d7
		beq	aquit
		cmp.b	#10,d7
		bne.s	.nocrlf
		add.w	#160*16,a1
		move.l	a1,a6
		bra.s	.loop
.nocrlf		sub.w	#32,d7
		mulu	#32,d7
		lea	font,a3
		add.w	d7,a3
offset		set	0
		rept	16
		bsr	pause
		move.w	(a3)+,offset(a6)
offset		set	offset+160
		endr
		add.w	#8,a6
		bra	.loop
aquit		move.w	#$2300,sr
		move.w	#800,d7
.wait		move.w	#$25,-(sp)
		trap	#14
		add.w	#2,sp
		cmp.b	#$39,$fffffc02.w
		beq.s	.yes
		dbf	d7,.wait
.yes		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts


set_screen	move.l	scr_now,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts


pause		move.w	#500,d5
.nop		nop
		dbf	d5,.nop
		rts







;--------------------------------------------------------- Volume table --
vol	moveq	#64,d0
	lea	vtabend,a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts


;------------------------------------------------------ Increment-table --
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

;-------------------------------------------------------- DMA interrupt --
stereo	move	#$2500,sr
	bclr	#5,$FFFFFA0F.w
	movem.l	d0-a6,-(sp)

	move.l	samp1(pc),d0
	move.l	samp2(pc),samp1
	move.l	d0,samp2

	lea	$FFFF8907.w,a0

	move.l	samp1(pc),d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	samp1(pc),d0
	add.l	#LEN*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	subq.w	#1,count
	bpl.s	.nomus

	move.w	#PARTS,count
	bsr	music

.nomus	lea	itab(pc),a5
	lea	vtab,a3
	moveq	#0,d0
	moveq	#0,d4

v1	movea.l	wiz2lc(pc),a0

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

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
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
	lea	vtab,a3
	moveq	#0,d0
	moveq	#0,d4

v2	movea.l	wiz1lc(pc),a0

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

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
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
count	DC.W PARTS

wiz1lc	DC.L sample1
wiz1len	DC.L 0
wiz1rpt	DC.W 0
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1
wiz2len	DC.L 0
wiz2rpt	DC.W 0
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1
wiz3len	DC.L 0
wiz3rpt	DC.W 0
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1
wiz4len	DC.L 0
wiz4rpt	DC.W 0
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

samp1	DC.L sample1
samp2	DC.L sample2

sample1	DS.W LEN
sample2	DS.W LEN

;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	mod(pc),a1		; Module
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
init	lea	mod(pc),a0
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

music	lea	mod(pc),a0
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

getnew	lea	mod+$043C(pc),a0
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
	clr.w	wiz1pos			;

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
	clr.w	wiz2pos			;

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
	clr.w	wiz4pos			;-------------------

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	mod+$03B6(pc),d1
	bne.s	endr
	move.b	mod+$03B7(pc),songpos
endr:	tst.b	break
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

nop:	move.w	$10(a4),$06(a3)
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




		ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
		endc



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

mod	INCBIN ronken.MOD

	DS.B	16384			; Workspace
workspc	DS.W	1

***mod bits end


	even




	ifne	DEVELOP
pic1		incbin	"develop\1.pi1"
pic2		incbin	"develop\2.pi1"
pic3		incbin	"develop\3.pi1"
pic4		incbin	"develop\4.pi1"
		endc


offset_pointer	dc.l	table1

table1		incbin	sine1.dat
		dc.l	-1

** table 2 is made up of word offsets (.w) then Y offset (.w)
table2_pointer	dc.l	table2
table2

;table two is made up of 2 words for each screen update.
; The first word is the X offset (0,2,4,6,8..38)
; The second word is the Y offset in lines where 100 is a whole screen
		dc.w	0,1,0,2,0,3,0,4,0,5,0,6
		dc.w	0,7,0,8,0,9,0,10,0,11,0,12,0,13,0,14,0,15,0,16,0,17,0,18,0,19
		dc.w	0,20,0,21,0,22,0,23,0,24,0,25,0,26,0,27,0,28
		dc.w	0,29,0,30,0,31,0,32,0,33,0,34,0,35,0,36,0,37
		dc.w	0,38,0,39,0,40,0,41,0,42,0,43,0,44,0,45,0,46
		dc.l	047,48,49,50,51,52,53,54,55,56,57,58,59
		dc.l	60,61,62,63,64,65,66,67,68,69
		dc.l	70,71,72,73,74,75,76,77,78,79
		dc.l	80,81,82,83,84,85,86,87,88,89
		dc.l	90,91,92,93,94,95,96,97,98,99
	;	dc.l	100
		dc.w	0,99,2,99,4,99,6,99,8,99,10,99,12,99,14,99,16,99,18,99
;move screen to left
	dc.w	20,99,22,99,24,99,26,99,28,99,30,99,32,99,34,99,36,99,38,99

;move screen down
	dc.w	38,98,00,97,00,96,00,95,00,94,00,93,00,92,00,91
	dc.w	00,90,00,89,00,88,00,87,00,86,00,85,00,84,00,83,00,82,00,81
	dc.w	00,80,00,79,00,78,00,77,00,76,00,75,00,74,00,73,00,72,00,71
	dc.w	00,70,00,69,00,68,00,67,00,66,00,65,00,64,00,63,00,62,00,61
	dc.w	00,60,00,59,00,58,00,57,00,56,00,55,00,54,00,53,00,52,00,51
	dc.w	00,50,00,49,00,48,00,47,00,46,00,45,00,44,00,43,00,42,00,41

	dc.w	38,40,36,40,34,40,32,40,30,40,28,40,26,40,24,40,22,40,20,40
	dc.w	18,40,16,40,14,40,12,40,10,40,08,40,06,40,04,40,02,40

	dc.w	02,40,04,39,06,38,08,37,10,36,12,35,14,34,16,33,18,32,20,31
	dc.w	22,30,24,29,26,28,28,27,30,26,32,25,34,24,36,23,38,22,00,21
	dc.w	02,20,04,19,06,18,08,17,10,16,12,15,14,14,16,13,18,12,20,11
	dc.w	22,10,24,09,26,08,28,07,30,06,32,05,34,04,36,03,38,02,00,01


	dc.l	-1

font	incbin	med_font.dat

		;12345678901234567890
ascii	dc.b	"   TCB DID IT WITH",10
	dc.b	" JUST SOFTWARE MANY",10
	dc.b	"      YEARS AGO",10,10
	dc.b	"I STARTED TO RUN OUT",10
	dc.b	"OF MEMORY AND I USE",10
	dc.b	"    HARDWARE AND",10
	dc.b	"  SOFTWARE SCROLL.",10,10
	dc.b	"NO RIPPED CODE, JUST",10
	dc.b	"    RIPPED GRAFIX.",10
	dc.b	"             RESPECT"
	dc.b	0
	even


	ifeq	DEVELOP
pic1		incbin	tcb1.pi1
pic2		incbin	tcb2.pi1
	endc













		ifeq	DOWNLOAD
*******************
   SECTION BSS
*******************
		endc
stack_save	ds.l	1

ste_flag	ds.w	1
screen_base	ds.l	1
original_rez	ds.w	1
old_st_palette	ds.w	16
scr_now		ds.l	1


vsync_flag		ds.w	1
old_vbl			ds.l	1
hard_addr		ds.l	1
offset_into_tables	ds.w	1

screen2_address		ds.l	1
screen2_pixel_offset	ds.w	1

pic2_data
;The following line is the official space needed for the demo
	;	ds.b	16*8*22*200	;22 words by 200 lines (20 words for screen then 1 word each side)
;but... you can get away with the following space due to the shift tables in this code
; if you change the code, you may have to use the above line
	ds.b	16*8*16*200



black		ds.w	16



**mod bits

oldtima		ds.L 1

vtab		DS.B 65*256
vtabend



**mod bits end



* screens are    1 2
*                3 4
		ds.b	256
screens		ds.b	32000
		ds.b	32000
		ds.b	32000
		ds.b	32000



		ifne	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
		endc
