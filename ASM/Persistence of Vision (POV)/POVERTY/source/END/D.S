*************************************************************************
*			POVerty demo END part				*
*			~~~~~~~~~~~~~~~~~~~~~				*
*									*
*									*
* Written by:	MAC SYS DATA of Persistence Of Vision			*
*									*
*									*
* Date:		December 1994						*
*									*
*									*
*									*
*									*
*									*
*									*
*				STE VERSION				*
*									*
*************************************************************************
no=0
yes=1

FINAL		equ	yes

DOWNLOAD	equ	no

; The following line is only used for debugging code.
TRACKER		equ	yes

		opt	w-,o+


		ifne	DOWNLOAD
		include	"g:\down\parallel.v4\transmit.s"
		org	$20000

Code_Start
Exec_Addr
		endc

		IFNE	TRACKER
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

		endc
start

		ifne	FINAL
		org	$10000
		endc

		bsr	set_up

main_loop	bsr	vsync

		jsr	do_rout

		cmp.w	#$39,key
		bne	main_loop

;stop mod
exit
		IFNE	TRACKER
		jsr	musoff
		endc

		move.b	#$8,$fffffc02.w
		move.w	#$2700,sr
		move.l	old_timerb,$120.w
		move.l	old_kbd,$118.w
		move.l	old_vbl,$70.w
		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.b	a09,$fffffa09.w
		move.b	a07,$fffffa07.w
		move.b	a13,$fffffa13.w
		move.w	#$2300,sr

		movem.l	oldpal,d0-d7
		movem.l	d0-d7,$ffff8240.l

;		move.w	org_overscanbtm,$ffff82aa.w
;		move.b	#%1110,$ffff8800.w		;i/o port A select
;		move.b	old_falcon_speaker,$ffff8802.w

;		move.w	original_rez,-(sp)	;$29
;		move.w	#$58,-(sp)
;		trap	#14
;		addq.l	#4,sp
		move.b	original_rez,$ffff8260.w

		move.l	screen_base,d0
		bsr	set_screen
		bsr	v_sync

		ifne	FINAL
		move.l	4.w,a0
		jmp	(a0)
		elseif
		dc.w	$a009

		ifeq	DOWNLOAD
		bsr	set_user
		endc
		endc

		ifne	DOWNLOAD
		move.l	4.w,-(sp)
		rts
		endc
		clr.w	-(sp)
		trap	#1


do_rout		sub.l	#1,rout_timer
		bne.s	.do_rout
		move.l	present_rout_pos,a0
		ifeq	FINAL
		tst.l	(a0)
		beq	exit
		endc
		move.l	(a0)+,present_rout
		move.l	(a0)+,rout_timer
		move.l	a0,present_rout_pos
.do_rout	move.l	present_rout,a0
		jmp	(a0)

null		nop
		rts



make_gid_pal	movem.l	oz_gid,d0-d7
		movem.l	d0-d7,changing_pal
		rts

make_poverty_pal
		movem.l	poverty,d0-d7
		movem.l	d0-d7,changing_pal
		rts

make_pacman_pal
		movem.l	pacman,d0-d7
		movem.l	d0-d7,changing_pal
		rts

make_credits_pal
		movem.l	credits,d0-d7
		movem.l	d0-d7,changing_pal
		rts

move_scrn_up	move.l	scr_now,a1
		add.l	#160*79,a1
		lea	160(a1),a2
		move.w	#240-79-1+48,d0		;+48 for length of logos
.loop
OFFSET		set	0
		rept	7
		move.l	OFFSET(a2),OFFSET(a1)
		move.l	OFFSET+4(a2),OFFSET+4(a1)
OFFSET		set	OFFSET+8
		endr
		lea	160(a1),a1
		lea	160(a2),a2
		dbf	d0,.loop
		rts

put_end		movem.l	theend,d0-d7
		movem.l	d0-d7,changing_pal
;put the end logo
		lea	theend+32,a0
		add.w	theendlogooffset,a0
		move.l	scr_now,a1
		add.l	#160*100+32,a1
		add.w	theendoffset,a1
.loop		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,28(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,36(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,44(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,52(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,60(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,68(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,76(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,84(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,92(a1)
		add.w	#160,theendoffset
		add.w	#96,theendlogooffset
		rts


put_gid_below	lea	oz_gid+32,a0
		bra.s	gid_size
put_pac_below	lea	pacman+32,a0
		bra.s	gid_size
put_credits_below
		lea	credits+32,a0
gid_size	move.l	scr_now,a1
		add.l	#160*240+8,a1
		move.w	#43-1,d0
.loop		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,28(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,36(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,44(a1)
		lea	160(a1),a1
		dbf	d0,.loop
		rts


put_pov_below	lea	poverty+32,a0
		move.l	scr_now,a1
		add.l	#160*240,a1
		move.w	#47-1,d0
.loop		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,28(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,36(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,44(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,52(a1)
		lea	160(a1),a1
		dbf	d0,.loop
		rts



start_dots	move.l	#move_dots,active_vbl_rout
		rts
stop_dots	clr.l	active_vbl_rout
		move.l	scr_now,a1
		add.l	#160*107,a1
		clr.w	(a1)
		rts

do_diddle	sub.w	#1,diddle_dots
		rts
move_dots	lea	dot_offset,a6
diddle_dots	equ	*+2
		move.w	#18-1,d7
.dot_loop	move.w	(a6),d0
		add.w	#4,(a6)
		lea	gid_dot_table,a0
		move.w	(a0,d0.w),d1	;bit pattern data
		move.w	2(a0,d0.w),d2	;screen offset
		move.w	-2(a0,d0.w),d3	;bit pattern data
		move.l	scr_now,a1
		add.l	#160*107,a1
		clr.w	(a1,d3.w)
		or.w	d1,(a1,d2.w)
		cmp.w	#(gid_dot_table_end-gid_dot_table),(a6)
		blt.s	.ok
		clr.w	(a6)
.ok		add.w	#2,a6
		dbf	d7,.dot_loop
		rts


enable_text	clr.w	text_enabled
		rts

offset_down_scr	equ	160*79+56
depth		equ	8
plane		equ	0		;0,1,2,3
text_printer	eor.w	#1,cursor
		bne	.do_cursor_only
		tst.w	text_enabled
		beq.s	.enabled
		rts
.enabled	move.l	ascii_pos,a0
		moveq	#0,d0
		move.b	(a0)+,d0
		cmp.b	#-1,d0
		bne.s	.no_restart
		clr.w	xpos
		clr.l	ypos
		lea	ascii,a0
		move.l	a0,ascii_pos
		clr.w	text_enabled
		rts
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
		move.l	a0,ascii_pos
		move.w	#-1,text_enabled
		clr.w	xpos
		clr.l	ypos
		rts

.not_end	cmp.b	#12,d0		;del
		bne	.ok
		move.l	a0,ascii_pos
		move.l	scr_now,a1
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
		move.l	a1,-(sp)
		add.l	#offset_down_scr,a1
offset		set	(plane*2)
		rept	depth
		move.b	d0,offset(a1)
offset		set	offset+160
		endr
		sub.w	#1,xpos
		move.l	(sp)+,a1
		rts

;BUG IN TAB SOMEWHERE!!!
.ok		move.l	a0,ascii_pos
		cmp.b	#9,d0		;tab
		bne.s	.no_tab
		move.w	xpos,d7
		add.w	#8,d7
		and.w	#$fff8,d7
		sub.w	xpos,d7
		sub.w	#1,d7
.loop		move.w	#' ',d0
		bsr	.no_tab
		dbf	d7,.loop
		bra	.not_end

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
.no_add		move.l	scr_now,a1
		add.l	ypos,a1
		add.w	d0,a1
		move.l	a1,-(sp)
		add.l	#offset_down_scr,a1
offset	set	(plane*2)
		rept	depth
		move.b	(a0),offset(a1)
		move.b	(a0),2+offset(a1)
		move.b	(a0)+,4+offset(a1)
offset	set	offset+160
		endr
		move.l	(sp)+,a1
		add.w	#1,xpos
		rts

.do_cursor_only	move.w	xpos,d0
		move.w	d0,d1
		lsr.w	#1,d0	;\2
		lsl.w	#3,d0	;*8	;bytes across screen
		beq.s	.no_curs	;prevent cursor on top line when CR is met as 1st char
		and.w	#1,d1
		add.w	d1,d0
		move.l	scr_now,a1
		add.l	ypos,a1
		add.w	d0,a1
		add.l	#offset_down_scr,a1
		eor.b	#-1,plane*2+((depth-2)*160)(a1)
		eor.b	#-1,plane*2+((depth-1)*160)(a1)
.no_curs	rts

clear_text	clr.w	xpos
		move.l	scr_now,a0
		add.l	#plane*2+offset_down_scr,a0
		moveq	#0,d0		;clear area of last text
		move.w	#16-1,d1	;number of lines of text
.clear		rept	depth
		move.l	d0,(a0)
		move.w	d0,4(a0)
		move.l	d0,8(a0)
		move.w	d0,12(a0)
		move.l	d0,16(a0)
		move.w	d0,20(a0)
		move.l	d0,24(a0)
		move.w	d0,28(a0)
		move.l	d0,32(a0)
		move.w	d0,36(a0)
		move.l	d0,40(a0)
		move.w	d0,44(a0)
		move.l	d0,48(a0)
		move.w	d0,52(a0)
		move.l	d0,56(a0)
		move.w	d0,60(a0)
		move.l	d0,64(a0)
		move.w	d0,68(a0)
		move.l	d0,72(a0)
		move.w	d0,76(a0)
		move.l	d0,80(a0)
		move.w	d0,84(a0)
		move.l	d0,88(a0)
		move.w	d0,92(a0)
		move.l	d0,96(a0)
		move.w	d0,100(a0)
		lea	160(a0),a0
		endr
		lea	160(a0),a0
		dbf	d1,.clear
		move.w	#1,cursor
		clr.l	ypos
		rts









 
timerb		clr.b	$fffffa1b.w
		move.w	#$f00,$ffff8240.w
		move.l	#timerbpart2,$120.w
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte

timerbpart2	clr.w	$ffff8240.w
		clr.b	$fffffa1b.w	
		movem.l	d0-d7,-(sp)
		movem.l	changing_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	(sp)+,d0-d7
		move.l	#timerbpart3,$120.w
		move.b	#2,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte

timerbpart3	movem.l	d0/a0,-(sp)
		clr.b	$fffffa1b.w
		move.l	raster_offset,d0
		and.w	#255,d0
		lea	raster_cols,a0
		move.w	0(a0,d0.w),$ffff824e.w
		add.l	#2,raster_offset
		move.b	#8,$fffffa1b.w
		movem.l	(sp)+,d0/a0
		rte

vbl		clr.w	vsync_flag
		clr.b	$fffffa1b.w
		movem.l	d0-d7/a0-a6,-(sp)
		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		add.l	#2,raster_offset+4
		move.l	raster_offset+4,raster_offset

		tst.l	active_vbl_rout
		beq.s	.no_rout
		move.l	active_vbl_rout,a0
		jsr	(a0)
.no_rout
		movem.l	(sp)+,d0-d7/a0-a6
		move.l	#timerb,$120.w
		move.b	#77,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte


new_kbd		movem.l	d0,-(sp)
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
		movem.l	(sp)+,d0
		rte

vsync		move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		rts



		ifeq	FINAL
set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts
		endc

set_up
**** First clear BSS as most packers don't
		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
.clear_bss	clr.b	(a0)+
		sub.l	#1,d0
		bne.s	.clear_bss

		ifeq	DOWNLOAD
		ifeq	FINAL
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc
		endc

		lea	colours,a0
		move.w	#$110,d0
		move.w	#50-1,d1
.fill_colours	move.w	d0,(a0)+
		add.w	#$010,d0
		dbf	d1,.fill_colours

		move.l	$44e.w,screen_base

		move.b	$ffff8260.w,original_rez

		ifeq	FINAL
		movem.l	$ffff8240.l,d0-d7
		movem.l	d0-d7,oldpal
		endc

		clr.b	$ffff8260.w

		move.w	#1,cursor
		clr.w	text_enabled

		move.b	#$12,$fffffc02.w

*** Calcualate a screen area of our own
		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		bsr	set_screen

		lea	pic+34,a0
		move.l	scr_now,a1
		move.w	#200-1,d0
.show_pic	rept	20
		move.l	(a0)+,(a1)+
		endr
		dbf	d0,.show_pic


		move.w	#$2700,sr

		IFNE	TRACKER
		jsr	muson
		endc

; Store original vector slots
		move.l	$120.w,old_timerb
		move.l	$118.w,old_kbd
		move.l	$70.w,old_vbl
		move.b	$fffffa09.w,a09
		move.b	$fffffa07.w,a07
		move.b	$fffffa13.w,a13


		and.b	#$df,$fffffa09.w
		and.b	#$fe,$fffffa07.w
		move.l	#new_kbd,$118.w
		move.l	#vbl,$70.w
		move.l	#timerb,$120.w
		move.b	#77,$fffffa21.w
		move.b	#8,$fffffa1b.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w
		move.w	#$2300,sr
		rts


set_screen	lsr.l	#8,d0
		lea	$fffff8201.w,a0
		movep.w	d0,(a0)
		rts
v_sync		move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		rts


		IFNE	TRACKER
;---------------------------------------------------- Interrupts on/off --
muson	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples
	move.w	#$f00,$ffff8240.w

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

	rts

musoff	move	#$2700,sr

	clr.b	$FFFFFA19.w		; Stop timers

	move.l	oldtima(pc),$0134.w	; Restore everything

	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w

	clr.b	$FFFF8901.w		; Stop DMA

	move	#$2300,sr
	rts

oldtima	DC.L 0

;--------------------------------------------------------- Volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab	DS.B 65*256
vtabend

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
	lea	vtab(pc),a3
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
	lea	vtab(pc),a3
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
	cmp.b	mod+$03B6,d1
	bne.s	endr
	move.b	mod+$03B7,songpos
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
		ds.l	2
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





	ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
	endc

	endc

pic		incbin	pov_big1.pi1


oz_gid		incbin	oz_gid.dat
poverty		incbin	poverty.dat
pacman		incbin	pacman.dat
credits		incbin	credits.dat
theend		incbin	theend.dat
rout_timer	dc.l	10


		IFNE	TRACKER
mod		incbin	spacedeb.mod
		endc

	DS.B	120000		; Workspace
workspc	DS.W	1



dot_offset	dc.w	0
		dc.w	4*(16*1)
		dc.w	4*(16*2)
		dc.w	4*(16*3)
		dc.w	4*(16*4)
		dc.w	4*(16*5)
		dc.w	4*(16*6)
		dc.w	4*(16*7)
		dc.w	4*(16*8)
		dc.w	4*(16*9)
		dc.w	4*(16*10)
		dc.w	4*(16*11)
		dc.w	4*(16*12)
		dc.w	4*(16*13)
		dc.w	4*(16*14)
		dc.w	4*(16*15)
		dc.w	4*(16*16)
		dc.w	4*(16*17)
		dc.w	4*(16*18)
		dc.w	4*(16*18)


		dc.w	$0008,160
gid_dot_table
		dc.w	$0008,0,$0004,0,$0002,0,$0001,0

		dc.w	$8000,8,$4000,8,$2000,8,$1000,8
		dc.w	$0800,8,$0400,8,$0200,8,$0100,8
		dc.w	$0080,8,$0040,8,$0020,8,$0010,8
		dc.w	$0008,8,$0004,8,$0002,8,$0001,8

		dc.w	$8000,16,$4000,16,$2000,16,$1000,16
		dc.w	$0800,16,$0400,16,$0200,16,$0100,16
		dc.w	$0080,16,$0040,16,$0020,16,$0010,16
		dc.w	$0008,16,$0004,16,$0002,16,$0001,16

		dc.w	$8000,24,$4000,24,$2000,24,$1000,24
		dc.w	$0800,24,$0400,24,$0200,24,$0100,24
		dc.w	$0080,24,$0040,24,$0020,24,$0010,24
		dc.w	$0008,24,$0004,24,$0002,24,$0001,24

		dc.w	$8000,32,$4000,32,$2000,32,$1000,32
		dc.w	$0800,32,$0400,32,$0200,32,$0100,32
		dc.w	$0080,32,$0040,32,$0020,32,$0010,32
		dc.w	$0008,32,$0004,32,$0002,32,$0001,32

		dc.w	$8000,40,$4000,40,$2000,40,$1000,40
		dc.w	$0800,40,$0400,40,$0200,40,$0100,40
		dc.w	$0080,40,$0040,40,$0020,40,$0010,40
		dc.w	$0008,40,$0004,40,$0002,40,$0001,40

		dc.w	$8000,48,$4000,48,$2000,48,$1000,48
		dc.w	$0800,48,$0400,48,$0200,48,$0100,48
		dc.w	$0080,48,$0040,48,$0020,48,$0010,48
		dc.w	$0008,48,$0004,48,$0002,48,$0001,48

		dc.w	$8000,56+(1*160)
		dc.w	$8000,56+(2*160)
		dc.w	$8000,56+(3*160)
		dc.w	$8000,56+(4*160)
		dc.w	$8000,56+(5*160)
		dc.w	$8000,56+(6*160)
		dc.w	$8000,56+(7*160)
		dc.w	$8000,56+(8*160)
		dc.w	$8000,56+(9*160)
		dc.w	$8000,56+(10*160)
		dc.w	$8000,56+(11*160)
		dc.w	$8000,56+(12*160)
		dc.w	$8000,56+(13*160)
		dc.w	$8000,56+(14*160)
		dc.w	$8000,56+(15*160)
		dc.w	$8000,56+(16*160)
		dc.w	$8000,56+(17*160)
		dc.w	$8000,56+(18*160)
		dc.w	$8000,56+(19*160)
		dc.w	$8000,56+(20*160)
		dc.w	$8000,56+(21*160)
		dc.w	$8000,56+(22*160)
		dc.w	$8000,56+(23*160)
		dc.w	$8000,56+(24*160)
		dc.w	$8000,56+(25*160)
		dc.w	$8000,56+(26*160)
		dc.w	$8000,56+(27*160)
		dc.w	$8000,56+(28*160)
		dc.w	$8000,56+(29*160)
		dc.w	$8000,56+(30*160)
		dc.w	$8000,56+(31*160)
		dc.w	$8000,56+(32*160)
		dc.w	$8000,56+(33*160)
		dc.w	$8000,56+(34*160)
		dc.w	$8000,56+(35*160)
		dc.w	$8000,56+(36*160)
		dc.w	$8000,56+(37*160)
		dc.w	$8000,56+(38*160)
		dc.w	$8000,56+(39*160)
		dc.w	$8000,56+(40*160)
		dc.w	$8000,56+(41*160)
		dc.w	$8000,56+(42*160)
		dc.w	$8000,56+(43*160)
		dc.w	$8000,56+(44*160)
		dc.w	$8000,56+(45*160)


		dc.w	$0001,48+(46*160),$0002,48+(46*160),$0004,48+(46*160),$0008,48+(46*160)
		dc.w	$0010,48+(46*160),$0020,48+(46*160),$0040,48+(46*160),$0080,48+(46*160)
		dc.w	$0100,48+(46*160),$0200,48+(46*160),$0400,48+(46*160),$0800,48+(46*160)
		dc.w	$1000,48+(46*160),$2000,48+(46*160),$4000,48+(46*160),$8000,48+(46*160)

		dc.w	$0001,40+(46*160),$0002,40+(46*160),$0004,40+(46*160),$0008,40+(46*160)
		dc.w	$0010,40+(46*160),$0020,40+(46*160),$0040,40+(46*160),$0080,40+(46*160)
		dc.w	$0100,40+(46*160),$0200,40+(46*160),$0400,40+(46*160),$0800,40+(46*160)
		dc.w	$1000,40+(46*160),$2000,40+(46*160),$4000,40+(46*160),$8000,40+(46*160)

		dc.w	$0001,32+(46*160),$0002,32+(46*160),$0004,32+(46*160),$0008,32+(46*160)
		dc.w	$0010,32+(46*160),$0020,32+(46*160),$0040,32+(46*160),$0080,32+(46*160)
		dc.w	$0100,32+(46*160),$0200,32+(46*160),$0400,32+(46*160),$0800,32+(46*160)
		dc.w	$1000,32+(46*160),$2000,32+(46*160),$4000,32+(46*160),$8000,32+(46*160)

		dc.w	$0001,24+(46*160),$0002,24+(46*160),$0004,24+(46*160),$0008,24+(46*160)
		dc.w	$0010,24+(46*160),$0020,24+(46*160),$0040,24+(46*160),$0080,24+(46*160)
		dc.w	$0100,24+(46*160),$0200,24+(46*160),$0400,24+(46*160),$0800,24+(46*160)
		dc.w	$1000,24+(46*160),$2000,24+(46*160),$4000,24+(46*160),$8000,24+(46*160)

		dc.w	$0001,16+(46*160),$0002,16+(46*160),$0004,16+(46*160),$0008,16+(46*160)
		dc.w	$0010,16+(46*160),$0020,16+(46*160),$0040,16+(46*160),$0080,16+(46*160)
		dc.w	$0100,16+(46*160),$0200,16+(46*160),$0400,16+(46*160),$0800,16+(46*160)
		dc.w	$1000,16+(46*160),$2000,16+(46*160),$4000,16+(46*160),$8000,16+(46*160)

		dc.w	$0001,8+(46*160),$0002,8+(46*160),$0004,8+(46*160),$0008,8+(46*160)
		dc.w	$0010,8+(46*160),$0020,8+(46*160),$0040,8+(46*160),$0080,8+(46*160)
		dc.w	$0100,8+(46*160),$0200,8+(46*160),$0400,8+(46*160),$0800,8+(46*160)
		dc.w	$1000,8+(46*160),$2000,8+(46*160),$4000,8+(46*160),$8000,8+(46*160)

		dc.w	$0001,0+(46*160),$0002,0+(46*160),$0004,0+(46*160),$0008,0+(46*160)

		dc.w	$10,(45*160)
		dc.w	$10,(44*160)
		dc.w	$10,(43*160)
		dc.w	$10,(42*160)
		dc.w	$10,(41*160)
		dc.w	$10,(40*160)
		dc.w	$10,(39*160)
		dc.w	$10,(38*160)
		dc.w	$10,(37*160)
		dc.w	$10,(36*160)
		dc.w	$10,(35*160)
		dc.w	$10,(34*160)
		dc.w	$10,(33*160)
		dc.w	$10,(32*160)
		dc.w	$10,(31*160)
		dc.w	$10,(30*160)
		dc.w	$10,(29*160)
		dc.w	$10,(28*160)
		dc.w	$10,(27*160)
		dc.w	$10,(26*160)
		dc.w	$10,(25*160)
		dc.w	$10,(24*160)
		dc.w	$10,(23*160)
		dc.w	$10,(22*160)
		dc.w	$10,(21*160)
		dc.w	$10,(20*160)
		dc.w	$10,(19*160)
		dc.w	$10,(18*160)
		dc.w	$10,(17*160)
		dc.w	$10,(16*160)
		dc.w	$10,(15*160)
		dc.w	$10,(14*160)
		dc.w	$10,(13*160)
		dc.w	$10,(12*160)
		dc.w	$10,(11*160)
		dc.w	$10,(10*160)
		dc.w	$10,(9*160)
		dc.w	$10,(8*160)
		dc.w	$10,(7*160)
		dc.w	$10,(6*160)
		dc.w	$10,(5*160)
		dc.w	$10,(4*160)
		dc.w	$10,(3*160)
		dc.w	$10,(2*160)
		dc.w	$10,(160)
gid_dot_table_end



present_rout	dc.l	null
present_rout_pos	dc.l	rout1
rout1		dc.l	null,20
		dc.l	make_poverty_pal,1
		dc.l	enable_text,1
		dc.l	text_printer,210
		dc.l	put_pov_below,1
		dc.l	move_scrn_up,250-79-40
		dc.l	clear_text,1
		dc.l	enable_text,1
		dc.l	text_printer,212
		dc.l	null,300
		dc.l	move_scrn_up,80
		dc.l	clear_text,1
		dc.l	make_gid_pal,1
		dc.l	put_gid_below,1
		dc.l	move_scrn_up,250-79-40
		dc.l	start_dots,1
		dc.l	enable_text,1
		dc.l	text_printer,192	;text part 2
		dc.l	null,406
		rept	17
		dc.l	do_diddle,1
		dc.l	null,15
		endr
		dc.l	stop_dots,1
		dc.l	move_scrn_up,80
		dc.l	clear_text,1
		dc.l	put_credits_below,1
		dc.l	make_credits_pal,1
		dc.l	move_scrn_up,250-79-40
		dc.l	enable_text,1
		dc.l	text_printer,210
		dc.l	null,400
		dc.l	move_scrn_up,80
		dc.l	clear_text,1
		dc.l	put_pac_below,1
		dc.l	make_pacman_pal,1
		dc.l	move_scrn_up,250-79-40
		dc.l	enable_text,1
		dc.l	text_printer,400
		dc.l	null,400
		dc.l	clear_text,1
		dc.l	enable_text,1
		dc.l	text_printer,400
		dc.l	null,400
		dc.l	move_scrn_up,80
		dc.l	clear_text,1
		dc.l	put_end,84
		dc.l	null,200000
		dc.l	0,0




;NOTE:   THE ROUTINE SUPPORTS TAB!!!
ascii_pos	dc.l	ascii
;                12345678901234567890123456	;26 chars wide
ascii	dc.b	13,13
	dc.b	"        'POVERTY'",13,13
	dc.b	"          ALIAS",13,13
	dc.b	"      OZ SLIDESHOW 3",13,13,13,13
	dc.b	"         CREDITS",13
	dc.b	15

	dc.b	13,13,13
	dc.b	"          PART 1",13,13
	dc.b	"  CODED BY MAC SYS DATA",13,13
	dc.b	"      ART BY OZ/MSD",13,13
	dc.b	" MUSIC RIPPED FROM AMIGA",13
	dc.b	15

;                12345678901234567890123456
	dc.b	13,13,13
	dc.b	"          PART 2",13,13
	dc.b	"  CODED BY MAC SYS DATA",13,13
	dc.b	"        ART BY OZ",13,13
	dc.b	"       MUSIC BY OZ",13
	dc.b	15

;                12345678901234567890123456
	dc.b	13,13,13
	dc.b	"     PART 3 (CREDITS)",13,13
	dc.b	"  CODED BY MAC SYS DATA",13,13
	dc.b	"        ART BY OZ",13,13
	dc.b	"     MUSIC BY UNKNOWN",13
	dc.b	15

;                12345678901234567890123456
	dc.b	13,13,13
	DC.B	"    QUICK GREETS TO...",13,13
	DC.B	"           DEL",13
	DC.B	"         DR SYNE",13
	DC.B	"      GEORGE (BART)",13
	DC.B	"       MARKO (TBB)",13
	DC.B	"     FELICE OF MAGGIE",13,13
	dc.b	"   ALL WHO KNOW ME VIA",13
	dc.b	"     INTERNET E-MAIL",13
	dc.b	15

	dc.b	13,13,13
	dc.b	"  PERSISTENCE OF VISION",13,13
	dc.b	" WILL RETURN LATER IN THE",13
	dc.b	"       YEAR OF 1995",13
	dc.b	" WITH MORE COMPILATIONS.",13,13,13
	dc.b	"      RELEASE DATE:",13,13
	dc.b	"       1-JUNE-1995",13
	dc.b	15

	dc.b	-1		;end of text in pages....
		even

font	incbin	8X8_comp.FNT

raster_cols
	dc.w	$000,$008,$001,$009,$002,$00a,$003,$00b
	dc.w	$004,$00c,$005,$00d,$006,$00e,$007,$00f
	dc.w	$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f
	dc.w	$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff,$0f7
	dc.w	$0fe,$0f5,$0fd,$0f4,$0fc,$0f3,$0fb,$0f2
	dc.w	$0fa,$0f1,$0f8,$0f0,$8f0,$1f0,$9f0,$2f0
	dc.w	$af0,$3f0,$bf0,$4f0,$cf0,$5f0,$df0,$6f0
	dc.w	$ef0,$7f0,$ff0,$f70,$fe0,$f60,$fd0,$f50
	dc.w	$fc0,$f40,$fb0,$f30,$fa0,$f20,$f90,$f10

	dc.w	$f80,$f00,$f08,$f01,$f09,$f02,$f0a,$f03
	dc.w	$f0b,$f04,$f0c,$f05,$f0d,$f06,$f0e,$f07
	dc.w	$f0f

	dc.w	$f07
	dc.w	$f0e,$f06,$f0d,$f05,$f0c,$f04,$f0b,$f03

	dc.w	$78a,$e12,$699,$d21,$5a8,$c30,$4b0,$b40
	dc.w	$3c0,$a50,$2d0,$960,$1e0,$870,$0f0

	dc.w	$0f0,$070,$0e0,$060,$0d0,$050,$0c0,$040
	dc.w	$0b0,$030,$0a0,$030,$090,$010,$080,$000




	ifeq	DOWNLOAD
*******************
   SECTION BSS
*******************
	endc
bssstart
pic_pos		ds.l	1

		ifeq	FINAL
stack_save	ds.l	1
		
		endc

screen_base	ds.l	1
original_rez	ds.w	1
old_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1

changing_pal	ds.l	16

		even
oldpal		ds.w	16
old_timerb	ds.l	1
old_vbl		ds.l	1
a09		ds.b	1
a07		ds.b	1
a13		ds.b	1
		even
key		ds.w	1
old_kbd		ds.l	1
vsync_flag	ds.w	1
active_vbl_rout	ds.l	1

xpos		ds.w	1
ypos		ds.l	1
cursor		ds.w	1
text_enabled	ds.w	1
raster_offset	ds.l	2
theendoffset	ds.w	1
theendlogooffset	ds.w	1

colours		ds.l	50

		ds.b	256

screens		ds.b	160*240
		ds.b	160*60

bssend
stop

		ifne	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
		endc
	end


