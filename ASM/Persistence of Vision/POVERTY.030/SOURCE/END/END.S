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
*				FALCON 030 VERSION			*
*									*
*************************************************************************
no=0
yes=1

FINAL		equ	yes

; The following line is only used for debugging code.
TRACKER		equ	yes

		opt	w-,o+


start
		ifne	FINAL
		org	$10000
		endc

		bsr	set_up

main_loop	bsr	vsync
;		move.l	#$7e000000,$ffff9800.w	;256 colour mode colour regs

		jsr	do_rout

;		clr.l	$ffff9800.w

		cmp.w	#$39,key
		bne	main_loop

;stop mod
exit
		IFNE	TRACKER
		jsr	stopmod
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

		move.w	org_overscanbtm,$ffff82aa.w
		move.b	#%1110,$ffff8800.w		;i/o port A select
		move.b	old_falcon_speaker,$ffff8802.w

		move.w	original_rez,-(sp)	;$29
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp

		move.l	screen_base,d0
		bsr	set_screen
		bsr	v_sync

		ifne	FINAL
		move.l	4.w,a0
		jmp	(a0)
		elseif
		dc.w	$a009
		bsr	set_user
		endc

		clr.w	-(sp)
		trap	#1


do_rout		sub.l	#1,rout_timer
		bne.s	.do_rout
		move.l	present_rout_pos,a0
		ifne	FINAL
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



make_gid_pal	lea	oz_gid_pal,a0
		lea	changing_pal,a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32(a1)
		rts

make_poverty_pal
		lea	poverty_pal,a0
		lea	changing_pal,a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32(a1)
		rts

make_pacman_pal
		lea	pacman_pal,a0
		lea	changing_pal,a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32(a1)
		rts

make_credits_pal
		lea	credits_pal,a0
		lea	changing_pal,a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32(a1)
		rts

move_scrn_up	move.l	scr_now,a1
		add.l	#384*96+(16*2),a1
		lea	384(a1),a2
		move.w	#240-96-1+48,d0
.loop
OFFSET		set	0
		rept	8
		move.l	OFFSET(a2),OFFSET(a1)
		move.l	OFFSET+4(a2),OFFSET+4(a1)
OFFSET		set	OFFSET+16
		endr
		lea	384(a1),a1
		lea	384(a2),a2
		dbf	d0,.loop
		rts

put_end		lea	theend_pal,a0
		lea	changing_pal,a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,32(a1)
;put the end logo
		lea	theend+32,a0
		add.w	theendlogooffset,a0
		move.l	scr_now,a1
		add.l	#384*114+(16*6),a1
		add.w	theendoffset,a1
.loop		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,36(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,52(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,68(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,84(a1)
		move.l	(a0)+,96(a1)
		move.l	(a0)+,100(a1)
		move.l	(a0)+,112(a1)
		move.l	(a0)+,116(a1)
		move.l	(a0)+,128(a1)
		move.l	(a0)+,132(a1)
		move.l	(a0)+,144(a1)
		move.l	(a0)+,148(a1)
		move.l	(a0)+,160(a1)
		move.l	(a0)+,164(a1)
		move.l	(a0)+,176(a1)
		move.l	(a0)+,180(a1)
		add.w	#384,theendoffset
		add.w	#96,theendlogooffset
		rts


put_gid_below	lea	oz_gid+32,a0
		bra.s	gid_size
put_pac_below	lea	pacman+32,a0
		bra.s	gid_size
put_credits_below
		lea	credits+32,a0
gid_size	move.l	scr_now,a1
		add.l	#384*240+(16*2),a1
		move.w	#43-1,d0
.loop		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,36(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,52(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,68(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,84(a1)
		lea	384(a1),a1
		dbf	d0,.loop
		rts


put_pov_below	lea	poverty+32,a0
		move.l	scr_now,a1
		add.l	#384*240+(16*2),a1
		move.w	#47-1,d0
.loop		move.l	(a0)+,(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,36(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,52(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,68(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,96(a1)
		move.l	(a0)+,100(a1)
		lea	384(a1),a1
		dbf	d0,.loop
		rts



start_dots	move.l	#move_dots,active_vbl_rout
		rts
stop_dots	clr.l	active_vbl_rout
		move.l	scr_now,a1
		add.l	#384*124+(16*1)+8,a1
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
		add.l	#384*124+(16*1)+8,a1
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

offset_down_scr	equ	384*96+16*8
depth		equ	8
plane		equ	4		;0,1,2,3
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
		add.l	#(depth+1)*384,ypos
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
		lsl.w	#4,d0	;*16	;bytes across screen
		and.w	#1,d1
		add.w	d1,d0
		add.w	d0,a1
		moveq	#0,d0
		move.l	a1,-(sp)
		add.l	#offset_down_scr,a1
offset		set	(plane*2)
		rept	depth
		move.b	d0,offset(a1)
offset		set	offset+384
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
		lsl.w	#4,d0	;*16 for words across screen
		and.w	#1,d1
		add.w	d1,d0
.no_add		move.l	scr_now,a1
		add.l	ypos,a1
		add.w	d0,a1
		move.l	a1,-(sp)
		add.l	#offset_down_scr,a1
offset	set	(plane*2)
		rept	depth
		move.b	(a0)+,offset(a1)
offset	set	offset+384
		endr
		move.l	(sp)+,a1
		add.w	#1,xpos
		rts

.do_cursor_only	move.w	xpos,d0
		move.w	d0,d1
		lsr.w	#1,d0	;\2
		lsl.w	#4,d0	;*16	;bytes across screen
		beq.s	.no_curs	;prevent cursor on top line when CR is met as 1st char
		and.w	#1,d1
		add.w	d1,d0
		move.l	scr_now,a1
		add.l	ypos,a1
		add.w	d0,a1
		add.l	#offset_down_scr,a1
		eor.b	#-1,plane*2+((depth-2)*384)(a1)
		eor.b	#-1,plane*2+((depth-1)*384)(a1)
.no_curs	rts

clear_text	clr.w	xpos
		move.l	scr_now,a0
		add.l	#plane*2+offset_down_scr,a0
		moveq	#0,d0		;clear area of last text
		move.w	#16-1,d1	;number of lines of text
.clear		rept	depth
		move.w	d0,(a0)
		move.w	d0,16(a0)
		move.w	d0,32(a0)
		move.w	d0,48(a0)
		move.w	d0,64(a0)
		move.w	d0,80(a0)
		move.w	d0,96(a0)
		move.w	d0,112(a0)
		move.w	d0,128(a0)
		move.w	d0,144(a0)
		move.w	d0,160(a0)
		move.w	d0,176(a0)
		move.w	d0,192(a0)
		move.w	d0,208(a0)
		move.w	d0,224(a0)
		lea	384(a0),a0
		endr
		lea	384(a0),a0
		dbf	d1,.clear
		move.w	#1,cursor
		clr.l	ypos
		rts









 
timerb		move.l	#$deadface,$ffff9800.w
col		equ	*-6
		clr.b	$fffffa1b.w
		movem.l	d0-d7/a0-a6,-(sp)
                moveq   #0,D0
		lea	colours,a1
		lea	$ffff8209.w,a0

		move.b	#8,d1
.waitsync	move.b	(a0),D0	; Screen-Low-Byte
		beq.s	.waitsync
		sub.b	d0,d1
		lsr.b	d1,d0

		move.l	(a1),col
		rept	23
		move.l	(a1)+,$ffff9800.w
		endr

		lea	changing_pal,a0
		lea	$ffff9800.w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	#timerbpart2,$120.w
		move.b	#1,$fffffa21.w
		move.b	#8,$fffffa1b.w

		lea	raster_cols,a0
		move.l	raster_offset,d0
		and.l	#511,d0
		move.l	(a0,d0.l),timerbpart2+34

		movem.l	(sp)+,d0-d7/a0-a6
		rte
timerbpart2	move.l	#$deadface,$ffff9800+20.w
		move.l	#$deadface,$ffff9800+24.w
		move.l	#$deadface,$ffff9800+28.w
		move.l	#$deadface,$ffff9800+32.w
		move.l	#$deadface,$ffff9840.w
		clr.b	$fffffa1b.w
		move.l	#timerbpart3,$120.w
		move.b	#8,$fffffa1b.w
		rte
timerbpart3	move.l	#$deadface,$ffff9800+36.w
		move.l	#$deadface,$ffff9800+40.w
		move.l	#$deadface,$ffff9800+44.w
		move.l	#$deadface,$ffff9800+48.w
		clr.b	$fffffa1b.w
		move.l	#timerbpart4,$120.w
		move.b	#8,$fffffa1b.w
		rte
timerbpart4	move.l	#$deadface,$ffff9800+52.w
		move.l	#$deadface,$ffff9800+56.w
		move.l	#$deadface,$ffff9800+60.w
		clr.b	$fffffa1b.w
		move.l	#timerbpart5,$120.w
		move.b	#3,$fffffa21.w
		move.b	#8,$fffffa1b.w
		rte
timerbpart5	move.l	a0,-(sp)
		move.l	d0,-(sp)
		lea	raster_cols,a0
		move.l	raster_offset,d0
		and.l	#511,d0
		move.l	(a0,d0.l),$ffff9840.w
		add.l	#4,raster_offset
		move.l	(sp)+,d0
		move.l	(sp)+,a0
		rte

vbl		clr.w	vsync_flag
		clr.l	$ffff9800.w
		clr.b	$fffffa1b.w
		movem.l	d0-d7/a0-a6,-(sp)
		lea	main_pal,a0
		lea	$ffff9800.w,a1
		move.w	#16-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop
		lea	changing_pal+20,a0
		move.l	(a0)+,timerbpart2+2
		move.l	(a0)+,timerbpart2+10
		move.l	(a0)+,timerbpart2+18
		move.l	(a0)+,timerbpart2+26
		move.l	(a0)+,timerbpart3+2
		move.l	(a0)+,timerbpart3+10
		move.l	(a0)+,timerbpart3+18
		move.l	(a0)+,timerbpart3+26
		move.l	(a0)+,timerbpart4+2
		move.l	(a0)+,timerbpart4+10
		move.l	(a0)+,timerbpart4+18
		IFNE	TRACKER
		bsr	play
		endc

		add.l	#4,raster_offset+4
		move.l	raster_offset+4,raster_offset

		tst.l	active_vbl_rout
		beq.s	.no_rout
		move.l	active_vbl_rout,a0
		jsr	(a0)
.no_rout
		movem.l	(sp)+,d0-d7/a0-a6
		move.l	#timerb,$120.w
		move.b	#92,$fffffa21.w
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

		ifeq	FINAL
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc

		lea	colours,a0
		move.l	#$d0000000,d0
		move.w	#50-1,d1
.fill_colours	move.l	d0,(a0)+
		add.l	#$00090000,d0
		dbf	d1,.fill_colours

		move.l	$44e.w,screen_base

		move.b	#%1110,$ffff8800.w	;i/o port A select
		move.b	$ffff8802.w,d0
		move.b	d0,old_falcon_speaker	;get value of reg
		or.b	#%10111111,d0
		move.b	d0,$ffff8802.w		;turn internal speaker off


		ifeq	FINAL
		move.w	#-1,-(sp)
		move.w	#$58,-(sp)	;get_original_rez
		trap	#14
		addq.l	#4,sp
		move.w	d0,original_rez
		endc

		ifeq	FINAL
		move.w	$ffff82aa.w,org_overscanbtm	;bottom overscan
		movem.l	$ffff8240.l,d0-d7
		movem.l	d0-d7,oldpal
		endc

;			  fedcba9876543210
		move.w	#%0000000001100011,-(sp)
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp

;Octet de poids faible :    S O P V 8 N N N
;	N  Bits par pixels :	4 -> 16 bits
;				3 -> 8  bits
;				2 -> 4  bits
;				1 -> 2  bits
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


		move.w	#1,cursor
		clr.w	text_enabled


** Sort the palette into a 256 colour mode palette
		lea	pic+2,a0	;source pal
		lea	main_pal,a1	;destination pal
		bsr	make_256_pal
		lea	main_pal,a0
		lea	$ffff9800.w,a1
		move.w	#16-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop

		lea	theend,a0	;source pal
		lea	theend_pal,a1	;destination pal
		bsr	make_256_pal

		lea	credits,a0	;source pal
		lea	credits_pal,a1	;destination pal
		bsr	make_256_pal

		lea	pacman,a0	;source pal
		lea	pacman_pal,a1	;destination pal
		bsr	make_256_pal

		lea	poverty,a0	;source pal
		lea	poverty_pal,a1	;destination pal
		bsr	make_256_pal

		lea	oz_gid,a0	;source pal
		lea	oz_gid_pal,a1	;destination pal
		bsr	make_256_pal

		move.b	#$12,$fffffc02.w

*** Calcualate a screen area of our own
		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		bsr	set_screen

		lea	pic+34,a0
		move.l	scr_now,a1
		add.w	#16,a1
		move.w	#200-1,d0
.show_pic	rept	13
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		add.w	#8,a1
		endr
		add.w	#8*7,a0
		add.w	#64+((8*7)*2),a1
		dbf	d0,.show_pic

		lea	pic2+34,a0
		move.l	scr_now,a1
		add.w	#16*11,a1
		move.w	#200-1,d0
.show_pic2	rept	14
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		add.w	#8,a1
		endr
		add.w	#8*6,a0
		add.w	#64+(8*6*2),a1
		dbf	d0,.show_pic2

		IFNE	TRACKER
		jsr	init_mod
		endc

		move.w	#$2700,sr
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
		move.b	#92,$fffffa21.w
		move.b	#8,$fffffa1b.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
		bclr	#3,$fffffa17.w
		move.w	#$2300,sr
		rts


*****************************************************
* MAKE 256 PAL
*
* Entry = A0 Source pal address
*         A1 Destination pal address
*****************************************************
make_256_pal	movem.l	(a0),d0-d7	;get 32 bytes of ST palette
		movem.l	d0-d7,-(sp)	;throw on stack
		move.w	#16-1,d0	;16 words of ST palette
.sort_pal
		move.w	(sp)+,d1	;get palette word
		move.w	d1,d3
		lsr.w	#4,d1
		move.w	d1,d2
		lsr.w	#4,d1
		and.l	#$f,d1	;red
		and.l	#$f,d2	;green
		and.l	#$f,d3	;blue
		lsl.w	#4,d1	;*4 plus red shift into upper 6 bits
		lsl.w	#4,d2	;*4 plus green shift into upper 6 bits
		lsl.w	#4,d3	;*4 plus blue shift into upper 6 bits

;If STFM font then include the following 3 lines
		lsl.w	#1,d1
		lsl.w	#1,d2
		lsl.w	#1,d3

		move.b	d1,(a1)+
		move.b	d2,(a1)+
		clr.b	(a1)+
		move.b	d3,(a1)+
		dbf	d0,.sort_pal
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

;DSP MOD replay routine written by bITmASTER of BSW
;Additional code by Dusan
	dc.b	"*DSP mod player by MAC SYS DATA of PERSISTENCE OF VISION "
	dc.b	"½ POV 1994 *"
	even

init_mod	moveq	#1,d0
		lea	mod,a0

player		movem.l	a0-a6/d0-d7,-(sp)
		MOVE.L	A0,L00B2
		TST.W	D0
		BEQ.S	L0001
		BSR	L00A0
L0001		BSR	L009E
		BSR	L0021
		BSR	L001A
		BSR	L0024
		PEA	L0002
		MOVE.W	#$26,-(A7)
		trap	#$E
		ADDQ.L	#6,A7
		MOVEM.L	(sp)+,A0-A6/D0-D7
		rts
L0002		lea	$FFFF8930.W,a0
		MOVE.L	(a0),L00AA
		move.l	#$902000,(a0)
		move.w	4(a0),L00AB
		move.w	#$101,4(a0)
		move.w	10(a0),L00AC
L0003		RTS

stopmod		LEA	$FFFF8930.W,A0
		move.l	L00AA,(A0)
		move.w	L00AB,4(A0)
		move.w	L00AC,10(A0)
		BCLR	#0,$FFFFFA07.W
		BCLR	#0,$FFFFFA13.W
		MOVE.B	(A0)+,$FFFFFA1B.W
		MOVE.B	(A0)+,$FFFFFA21.W
L0006		RTS

play		lea	L00B8,A0
		lea	L00B7,A1
		lea	$FFFFA202.W,A3
		lea	3(A3),A4
		lea	4(A3),A5
		CLR.W	(A5)
		MOVEQ	#3,D6
L0009		MOVE.B	19(A1),(A4)
		CLR.W	(A5)
		move.w	16(A1),D0
		LEA	(0,A0,D0.W*4),A2
		MOVE.B	1(A2),(A4)
		move.w	2(A2),(A5)
		MOVEQ	#0,D0
L000A		BTST	#0,(A3)
		beq.s	L000A
		move.w	(A5),D0
		tst.W	20(A1)
		beq.s	L000B
		clr.W	20(A1)
		bra.S	L000E
L000B:MOVEM.L	(A1),D1-D4
		add.L	D0,D1
		move.l	D1,D0
		sub.L	D2,D0
		bls.S	L000D
		cmp.L	#2,D4
		bne.s	L000C
		move.l	D2,D1
		bra.S	L000D
L000C		MOVE.L	D3,D1
		DIVUL.L	D4,D4:D0
		add.L	D4,D1
L000D		MOVE.L	D1,(A1)
L000E		MOVEQ	#0,D0
L000F		BTST	#0,(A3)
		beq.s	L000F
		move.w	(A5),D0
		addQ.L	#2,D0
L0010		BTST	#0,(A3)
		beq.s	L0010
		move.w	(A5),D7
		move.w	D7,L00B0
		moveM.L	(A1),D1-D4
		move.l	D2,D5
		sub.L	D1,D5
		cmp.L	D5,D0
		bls.S	L0014
		sub.L	D5,D0
		move.w	D5,D7
		moveA.L	D1,A2
		bsr.S	L0016
		cmp.L	#2,D4
		beq.s	L0012
		cmp.L	D4,D0
		BCS.S	L0011
		move.l	D4,D0
L0011		MOVE.W	D0,D7
		moveA.L	D3,A2
		bsr.S	L0016
		bra.S	L0015
L0012		CLR.B	(A4)
		move.w	#2,(A5)
L0013		BTST	#1,(A3)
		beq.s	L0013
		clr.W	(A5)
		NOP
		clr.W	(A5)
		bra.S	L0015
L0014		MOVE.W	D0,D7
		moveA.L	D1,A2
		bsr.S	L0016
		clr.b	(A4)
		clr.W	(A5)
L0015		ADDA.W	#$16,A1
		addQ.W	#1,L00B1
		DBF	D6,L0009
		bsr	L0026
		rts
L0016		CLR.B	(A4)
		move.w	D7,(A5)
		beq.s	L0019
		lsr.W	#1,D7
L0017		BTST	#1,(A3)
		beq.s	L0017
L0018		MOVE.W	(A2)+,(A5)
		DBF	D7,L0018
L0019		RTS
L001A		MOVEA.L	L00B2,A0
		lea	950(A0),A1
		lea	134(A1),A2
		moveQ	#$1E,D0
		moveQ	#1,D3
		cmpI.L	#$4D2E4B2E,1080(A0)
		beq.s	L001B
		cmpI.L	#$464C5434,1080(A0)
		beq.s	L001B
		lea	470(A0),A1
		lea	130(A1),A2
		moveQ	#$E,D0
		moveQ	#0,D3
L001B		MOVE.L	A1,L00B3
		move.l	A2,L00B4
		move.w	D0,L00B5
		moveA.L	L00B3,A1
		moveA.L	A1,A2
		addQ.L	#2,A1
		moveQ	#$7F,D0
		moveQ	#0,D1
L001C		MOVE.B	(A1)+,D2
		cmp.b	D2,D1
		BCC.S	L001D
		move.b	D2,D1
L001D		DBF	D0,L001C
		cmp.b	1(A2),D1
		BCC.S	L001E
		clr.b	1(A2)
L001E		ADDQ.W	#1,D1
		mulu.L	#$400,D1
		moveA.L	L00B4,A1
		lea	0(A1,D1.L),A1
		addA.W	#$2A,A0
		lea	L00B6,A2
		move.w	L00B5,D0
L001F		MOVE.L	A1,(A2)+
		moveQ	#0,D1
		move.w	(A0),D1
		add.L	D1,D1
		addA.L	D1,A1
		tst.W	D3
		bne.s	L0020
		lsr	4(A0)
L0020		ADDA.W	#$1E,A0
		DBF	D0,L001F
		rts
L0021		LEA	L00B8,A0
		move.w	#$4F,D0
L0022		CLR.L	(A0)+
		DBF	D0,L0022
		move.w	#$31F,D0
		moveQ	#$50,D1
		move.l	#$24665268,D2
L0023		MOVE.L	D2,D4
		DIVU.L	D1,D4
		move.l	D4,(A0)+
		addQ.L	#1,D1
		DBF	D0,L0023
		rts
L0024		LEA	L00AA,A0
		lea	L00B7,A1
		move.w	#3,D0
L0025		MOVE.L	A0,(A1)
		move.l	A0,4(A1)
		clr.L	8(A1)
		move.l	#2,12(A1)
		move.w	#1,20(A1)
		addA.W	#$16,A1
		DBF	D0,L0025
		rts
L0026		MOVEA.L	L00B2,A0
		addQ.W	#1,L00BD
		move.w	L00BD,D0
		cmp.W	L00BE,D0
		BCS.S	L0027
		clr.W	L00BD
		tst.B	L00C7
		beq.s	L002A
		bsr.S	L0028
		bra	L002C
L0027		BSR.S	L0028
		bra	L0031
L0028		MOVEQ	#3,D6
		lea	L00BC,A6
		lea	L00B7,A5
L0029		BSR	L0040
		addA.W	#$2C,A6
		addA.W	#$16,A5
		DBF	D6,L0029
		rts
L002A		LEA	12(A0),A3
		moveA.L	L00B4,A0
		moveQ	#0,D1
		moveA.L	L00B3,A2
		move.w	L00C1,D0
		move.b	2(A2,D0.W),D1
		ASL.L	#8,D1
		ASL.L	#2,D1
		move.w	L00C0,D0
		EXT.L	D0
		add.L	D0,D1
		clr.W	L00BF
		moveQ	#0,D6
		lea	L00B7,A5
		lea	L00BC,A6
L002B		MOVE.W	D6,D2
		bsr	L0032
		moveQ	#0,D0
		move.b	19(A6),D0
		move.w	D0,18(A5)
		addA.W	#$16,A5
		addA.W	#$2C,A6
		addQ.W	#1,D6
		cmp.W	#4,D6
		bne.s	L002B
L002C		ADDI.W	#$10,L00C0
		move.b	L00C6,D0
		beq.s	L002D
		move.b	D0,L00C7
		clr.b	L00C6
L002D		TST.B	L00C7
		beq.s	L002E
		subQ.B	#1,L00C7
		beq.s	L002E
		subI.W	#$10,L00C0
L002E		TST.B	L00C4
		beq.s	L002F
		SF	L00C4
		moveQ	#0,D0
		move.b	L00C2,D0
		lsl.W	#4,D0 
		move.w	D0,L00C0
		clr.b	L00C2 
L002F		CMPI.W	#$400,L00C0
		bne.s	L0031
L0030		MOVEQ	#0,D0
		move.b	L00C2,D0
		lsl.W	#4,D0
		move.w	D0,L00C0
		clr.b	L00C2
		clr.b	L00C3
		addQ.W	#1,L00C1
		andI.W	#$7F,L00C1
		move.w	L00C1,D1
		moveA.L	L00B3,A0
		cmp.b	(A0),D1
		BCS.S	L0031
		moveQ	#0,D1
		move.b	1(A0),D1
		move.w	D1,L00C1
L0031		TST.B	L00C3
		bne.s	L0030
		rts
L0032		TST.L	(A6)
		bne.s	L0033
		bsr	L0043
L0033		MOVE.L	0(A0,D1.L),(A6)
		addQ.L	#4,D1
		btst	D2,L00C8
		beq	L0042
		moveQ	#0,D2
		move.b	2(A6),D2
		and.B	#$F0,D2
		lsr.B	#4,D2
		move.b	(A6),D0
		and.B	#$F0,D0
		OR.B	D0,D2
		tst.B	D2
		beq	L0036
		moveQ	#0,D3
		lea	L00B6,A1
		move.w	D2,D4
		move.b	D2,43(A6)
		subQ.L	#1,D2
		lsl.L	#2,D2
		mulu	#$1E,D4
		move.l	0(A1,D2.L),4(A6)
		move.w	0(A3,D4.L),8(A6)
		move.w	0(A3,D4.L),40(A6)
		move.b	2(A3,D4.L),18(A6)
		move.b	3(A3,D4.L),19(A6)
		move.w	4(A3,D4.L),D3
		beq.s	L0035
		move.l	4(A6),D2
		ASL.W	#1,D3
		add.L	D3,D2
		move.l	D2,10(A6)
		move.l	D2,36(A6)
		moveM.W	4(A3,D4.L),D2/D0
		add.W	D2,D0
		move.w	40(A6),D3
		cmp.W	D3,D0
		bls.S	L0034
		move.w	D3,8(A6)
		sub.W	D3,D0
		sub.W	D0,D2
		move.w	D2,14(A6)
		bra.S	L0036
L0034		MOVE.W	D0,8(A6)
		move.w	D2,14(A6)
		bra.S	L0036
L0035		MOVE.L	4(A6),D2
		move.l	D2,10(A6)
		move.l	D2,36(A6)
		move.w	6(A3,D4.L),14(A6)
L0036		MOVE.W	(A6),D0
		and.W	#$FFF,D0
		beq	L0084
		move.w	2(A6),D0
		and.W	#$FF0,D0
		cmp.W	#$E50,D0
		beq.s	L0037
		move.b	2(A6),D0
		and.B	#$F,D0
		cmp.b	#3,D0
		beq.s	L0038
		cmp.b	#5,D0
		beq.s	L0038
		cmp.b	#9,D0
		bne.s	L0039
		bsr	L0084
		bra.S	L0039
L0037		BSR	L0089
		bra.S	L0039
L0038		BSR	L0050
		bra	L0084
L0039		MOVEM.L	A0-A1/D0-D1,-(A7)
		move.w	(A6),D1
		and.W	#$FFF,D1
		lea	L00BB,A1
		moveQ	#0,D0
		moveQ	#$24,D7
L003A		CMP.W	0(A1,D0.W),D1
		BCC.S	L003B
		addQ.L	#2,D0
		DBF	D7,L003A
L003B		MOVEQ	#0,D1
		move.b	18(A6),D1
		mulu	#$4A,D1
		addA.L	D1,A1
		move.w	0(A1,D0.W),16(A6)
		moveM.L	(A7)+,A0-A1/D0-D1
		move.w	2(A6),D0
		and.W	#$FF0,D0
		cmp.W	#$ED0,D0
		beq	L0084
		btst	#2,30(A6)
		bne.s	L003C
		clr.b	27(A6)
L003C		BTST	#6,30(A6)
		bne.s	L003D
		clr.b	29(A6)
L003D		MOVE.W	#1,20(A5)
		move.l	4(A6),D0
		bne.s	L003E
		move.l	#L00BB,D0
		move.l	D0,(A5)
		move.l	D0,4(A5)
		moveQ	#2,D0
		move.l	D0,12(A5)
		clr.L	10(A6)
		move.w	#1,14(A6)
		bra.S	L003F
L003E		MOVE.L	D0,(A5)
		moveQ	#0,D2
		move.w	8(A6),D2
		add.L	D2,D2
		add.L	D2,D0
		move.l	D0,4(A5)
		move.l	10(A6),8(A5)
		moveQ	#0,D0
		move.w	14(A6),D0
		add.L	D0,D0
		move.l	D0,12(A5)
L003F		MOVE.W	16(A6),D0
		move.w	D0,16(A5)
		ST	42(A6)
		move.w	20(A6),D0
		OR.W	D0,L00BF
		bra	L0084
L0040		BSR.S	L0041
		moveQ	#0,D0
		move.b	19(A6),D0
		move.w	D0,18(A5)
		rts
L0041:BSR	L009B
		move.w	2(A6),D0
		and.W	#$FFF,D0
		beq.s	L0042
		move.b	2(A6),D0
		and.B	#$F,D0
		tst.B	D0
		beq.s	L0044
		cmp.b	#1,D0
		beq	L004B
		cmp.b	#2,D0
		beq	L004E
		cmp.b	#3,D0
		beq	L0055
		cmp.b	#4,D0
		beq	L005C
		cmp.b	#5,D0
		beq	L0066
		cmp.b	#6,D0
		beq	L0067
		cmp.b	#$E,D0
		beq	L0085
		move.w	16(A6),16(A5)
		cmp.b	#7,D0
		beq	L0068
		cmp.b	#$A,D0
		beq	L0077
L0042:RTS
L0043:MOVE.W	16(A6),16(A5)
		rts
L0044:MOVEQ	#0,D0
		move.w	L00BD,D0
	DIVS	#3,D0
	SWAP	D0
		cmp.W	#1,D0
		beq.s	L0045
		cmp.W	#2,D0
		beq.s	L0046
		move.w	16(A6),D2
		bra.S	L0049
L0045:MOVEQ	#0,D0
		move.b	3(A6),D0
		lsr.B	#4,D0
		bra.S	L0047
L0046:MOVEQ	#0,D0
		move.b	3(A6),D0
		and.B	#$F,D0
L0047:ASL.W	#1,D0
		moveQ	#0,D1
		move.b	18(A6),D1
		mulu	#$4A,D1
		lea	L00BB,A0
		addA.L	D1,A0
		moveQ	#0,D1
		move.w	16(A6),D1
		moveQ	#$24,D7
L0048:MOVE.W	0(A0,D0.W),D2
		cmp.W	(A0),D1
	BCC.S	L0049
		addQ.L	#2,A0
	DBF	D7,L0048
		rts
L0049:MOVE.W	D2,16(A5)
		rts
L004A:TST.W	L00BD
		bne.s	L0042
		move.b	#$F,L00C5
L004B:MOVEQ	#0,D0
		move.b	3(A6),D0
		and.B	L00C5,D0
		move.b	#$FF,L00C5
		sub.W	D0,16(A6)
		move.w	16(A6),D0
		and.W	#$FFF,D0
		cmp.W	#$71,D0
	BPL.S	L004C
		andI.W	#$F000,16(A6)
	ORI.W	#$71,16(A6)
L004C:MOVE.W	16(A6),D0
		and.W	#$FFF,D0
		move.w	D0,16(A5)
		rts
L004D:TST.W	L00BD
		bne	L0042
		move.b	#$F,L00C5
L004E:CLR.W	D0
		move.b	3(A6),D0
		and.B	L00C5,D0
		move.b	#$FF,L00C5
		add.W	D0,16(A6)
		move.w	16(A6),D0
		and.W	#$FFF,D0
		cmp.W	#$358,D0
	BMI.S	L004F
		andI.W	#$F000,16(A6)
	ORI.W	#$358,16(A6)
L004F:MOVE.W	16(A6),D0
		and.W	#$FFF,D0
		move.w	D0,16(A5)
		rts
L0050:MOVE.L	A0,-(A7)
		move.w	(A6),D2
		and.W	#$FFF,D2
		moveQ	#0,D0
		move.b	18(A6),D0
		mulu	#$4A,D0
		lea	L00BB,A0
		addA.L	D0,A0
		moveQ	#0,D0
L0051:CMP.W	0(A0,D0.W),D2
	BCC.S	L0052
		addQ.W	#2,D0
		cmp.W	#$4A,D0
	BCS.S	L0051
		moveQ	#$46,D0
L0052:MOVE.B	18(A6),D2
		and.B	#8,D2
		beq.s	L0053
		tst.W	D0
		beq.s	L0053
		subQ.W	#2,D0
L0053:MOVE.W	0(A0,D0.W),D2
		moveA.L	(A7)+,A0
		move.w	D2,24(A6)
		move.w	16(A6),D0
		clr.b	22(A6)
		cmp.W	D0,D2
		beq.s	L0054
	BGE	L0042
		move.b	#1,22(A6)
		rts
L0054:CLR.W	24(A6)
		rts
L0055:MOVE.B	3(A6),D0
		beq.s	L0056
		move.b	D0,23(A6)
		clr.b	3(A6)
L0056:TST.W	24(A6)
		beq	L0042
		moveQ	#0,D0
		move.b	23(A6),D0
		tst.B	22(A6)
		bne.s	L0057
		add.W	D0,16(A6)
		move.w	24(A6),D0
		cmp.W	16(A6),D0
	BGT.S	L0058
		move.w	24(A6),16(A6)
		clr.W	24(A6)
		bra.S	L0058
L0057:SUB.W	D0,16(A6)
		move.w	24(A6),D0
		cmp.W	16(A6),D0
	BLT.S	L0058
		move.w	24(A6),16(A6)
		clr.W	24(A6)
L0058:MOVE.W	16(A6),D2
		move.b	31(A6),D0
		and.B	#$F,D0
		beq.s	L005B
		moveQ	#0,D0
		move.b	18(A6),D0
		mulu	#$4A,D0
		lea	L00BB,A0
		addA.L	D0,A0
		moveQ	#0,D0
L0059:CMP.W	0(A0,D0.W),D2
	BCC.S	L005A
		addQ.W	#2,D0
		cmp.W	#$4A,D0
	BCS.S	L0059
		moveQ	#$46,D0
L005A:MOVE.W	0(A0,D0.W),D2
L005B:MOVE.W	D2,16(A5)
		rts
L005C:MOVE.B	3(A6),D0
		beq.s	L005F
		move.b	26(A6),D2
		and.B	#$F,D0
		beq.s	L005D
		and.B	#$F0,D2
	OR.B	D0,D2
L005D:MOVE.B	3(A6),D0
		and.B	#$F0,D0
		beq.s	L005E
		and.B	#$F,D2
	OR.B	D0,D2
L005E:MOVE.B	D2,26(A6)
L005F:MOVE.L	A4,-(A7)
		move.b	27(A6),D0
		lea	L00BA,A4
		lsr.W	#2,D0
		and.W	#$1F,D0
		moveQ	#0,D2
		move.b	30(A6),D2
		and.B	#3,D2
		beq.s	L0062
		lsl.B	#3,D0
		cmp.b	#1,D2
		beq.s	L0060
		move.b	#$FF,D2
		bra.S	L0063
L0060:TST.B	27(A6)
	BPL.S	L0061
		move.b	#$FF,D2
		sub.B	D0,D2
		bra.S	L0063
L0061:MOVE.B	D0,D2
		bra.S	L0063
L0062:MOVE.B	0(A4,D0.W),D2
L0063:MOVE.B	26(A6),D0
		and.W	#$F,D0
		mulu	D0,D2
		lsr.W	#7,D2
		move.w	16(A6),D0
		tst.B	27(A6)
	BMI.S	L0064
		add.W	D2,D0
		bra.S	L0065
L0064:SUB.W	D2,D0
L0065:MOVE.W	D0,16(A5)
		move.b	26(A6),D0
		lsr.W	#2,D0
		and.W	#$3C,D0
		add.B	D0,27(A6)
		moveA.L	(A7)+,A4
		rts
L0066:BSR	L0056
		bra	L0077
L0067:BSR.S	L005F
		bra	L0077
L0068:MOVE.L	A4,-(A7)
		move.b	3(A6),D0
		beq.s	L006B
		move.b	28(A6),D2
		and.B	#$F,D0
		beq.s	L0069
		and.B	#$F0,D2
	OR.B	D0,D2
L0069:MOVE.B	3(A6),D0
		and.B	#$F0,D0
		beq.s	L006A
		and.B	#$F,D2
	OR.B	D0,D2
L006A:MOVE.B	D2,28(A6)
L006B:MOVE.B	29(A6),D0
		lea	L00BA,A4
		lsr.W	#2,D0
		and.W	#$1F,D0
		moveQ	#0,D2
		move.b	30(A6),D2
		lsr.B	#4,D2
		and.B	#3,D2
		beq.s	L006E
		lsl.B	#3,D0
		cmp.b	#1,D2
		beq.s	L006C
		move.b	#$FF,D2
		bra.S	L006F
L006C:TST.B	27(A6)
	BPL.S	L006D
		move.b	#$FF,D2
		sub.B	D0,D2
		bra.S	L006F
L006D:MOVE.B	D0,D2
		bra.S	L006F
L006E:MOVE.B	0(A4,D0.W),D2
L006F:MOVE.B	28(A6),D0
		and.W	#$F,D0
		mulu	D0,D2
		lsr.W	#6,D2
		moveQ	#0,D0
		move.b	19(A6),D0
		tst.B	29(A6)
	BMI.S	L0070
		add.W	D2,D0
		bra.S	L0071
L0070:SUB.W	D2,D0
L0071:BPL.S	L0072
		clr.W	D0
L0072:CMP.W	#$40,D0
		bls.S	L0073
		move.w	#$40,D0
L0073:MOVE.W	D0,18(A5)
		move.b	28(A6),D0
		lsr.W	#2,D0
		and.W	#$3C,D0
		add.B	D0,29(A6)
		moveA.L	(A7)+,A4
		addQ.L	#4,A7
		rts
L0074:MOVEQ	#0,D0
		move.b	3(A6),D0
		beq.s	L0075
		move.b	D0,32(A6)
L0075:MOVE.B	32(A6),D0
		lsl.W	#7,D0
		cmp.W	8(A6),D0
	BGE.S	L0076
		sub.W	D0,8(A6)
		lsl.W	#1,D0
		add.L	D0,4(A6)
		rts
L0076:MOVE.W	#1,8(A6)
		rts
L0077:MOVEQ	#0,D0
		move.b	3(A6),D0
		lsr.B	#4,D0
		tst.B	D0
		beq.s	L007A 
L0078:ADD.B	D0,19(A6) 
		cmpI.B	#$40,19(A6) 
	BMI.S	L0079 
		move.b	#$40,19(A6) 
L0079:MOVE.B	19(A6),D0 
		rts 
L007A:MOVEQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
L007B:SUB.B	D0,19(A6) 
	BPL.S	L007C 
		clr.b	19(A6)
L007C:MOVE.B	19(A6),D0 
		rts 
L007D:MOVEQ	#0,D0 
		move.b	3(A6),D0
		subQ.B	#1,D0 
		move.w	D0,L00C1
L007E:CLR.B	L00C2 
	ST	L00C3 
		rts 
L007F:MOVEQ	#0,D0 
		move.b	3(A6),D0
		cmp.b	#$40,D0 
		bls.S	L0080 
		moveQ	#$40,D0 
L0080:MOVE.B	D0,19(A6) 
		rts 
L0081:MOVEQ	#0,D0 
		move.b	3(A6),D0
	move.l	D0,D2 
		lsr.B	#4,D0 
		mulu	#$A,D0
		and.B	#$F,D2
		add.B	D2,D0 
		cmp.b	#$3F,D0 
	BHI.S	L007E 
		move.b	D0,L00C2
	ST	L00C3 
		rts 
L0082:MOVE.B	3(A6),D0
		and.W	#$FF,D0 
		beq.s	L0083 
		clr.W	L00BD 
		move.w	D0,L00BE
L0083:RTS 
L0084:MOVE.B	2(A6),D0
		and.B	#$F,D0
		cmp.b	#9,D0 
		beq	L0074 
		cmp.b	#$B,D0
		beq	L007D 
		cmp.b	#$D,D0
		beq.s	L0081 
		cmp.b	#$E,D0
		beq.s	L0085 
		cmp.b	#$F,D0
		beq.s	L0082 
		cmp.b	#$C,D0
		beq	L007F 
		bra	L0043 
L0085:MOVE.B	3(A6),D0
		and.B	#$F0,D0 
		lsr.B	#4,D0 
		beq.s	L0086 
		cmp.b	#1,D0 
		beq	L004A 
		cmp.b	#2,D0 
		beq	L004D 
		cmp.b	#3,D0 
		beq.s	L0087 
		cmp.b	#4,D0 
		beq.s	L0088 
		cmp.b	#5,D0 
		beq	L0089 
		cmp.b	#6,D0 
		beq	L008A 
		cmp.b	#7,D0 
		beq	L008E 
		cmp.b	#8,D0 
		beq	L008F 
		cmp.b	#$E,D0
		beq	L0099 
		cmp.b	#9,D0 
		beq	L0091 
		cmp.b	#$A,D0
		beq	L0095 
		cmp.b	#$B,D0
		beq	L0096 
		cmp.b	#$C,D0
		beq	L0097 
		cmp.b	#$D,D0
		beq	L0098 
		cmp.b	#$F,D0
		beq	L009A 
		rts 
L0086:MOVE.B	3(A6),D0
		and.B	#1,D0 
	ASL.B	#1,D0 
		rts 
L0087:MOVE.B	3(A6),D0
		and.B	#$F,D0
		andI.B	#$F0,31(A6) 
	OR.B	D0,31(A6) 
		rts 
L0088:MOVE.B	3(A6),D0
		and.B	#$F,D0
		andI.B	#$F0,30(A6) 
	OR.B	D0,30(A6) 
		rts 
L0089:MOVE.B	3(A6),D0
		and.B	#$F,D0
		move.b	D0,18(A6) 
		rts 
L008A:TST.W	L00BD 
		bne	L0042 
		move.b	3(A6),D0
		and.B	#$F,D0
		beq.s	L008D 
		tst.B	34(A6)
		beq.s	L008C 
		subQ.B	#1,34(A6) 
		beq	L0042 
L008B		MOVE.B	33(A6),L00C2
		ST	L00C4 
		rts 
L008C		MOVE.B	D0,34(A6) 
		bra.S	L008B 
L008D		MOVE.W	L00C0,D0
		lsr.L	#4,D0 
		and.B	#$3F,D0 
		move.b	D0,33(A6) 
		rts 
L008E		MOVE.B	3(A6),D0
		and.B	#$F,D0
		lsl.B	#4,D0 
		andI.B	#$F,30(A6)
		OR.B	D0,30(A6) 
		rts 
L008F		MOVEM.L	A0-A1/D1-D2,-(A7) 
		moveA.L	10(A6),A0 
		moveA.L	A0,A1 
		move.w	14(A6),D0 
		add.W	D0,D0 
		subQ.W	#2,D0 
L0090		MOVE.B	(A0),D1 
		EXT.W	D1
		move.b	1(A0),D2
		EXT.W	D2
		add.W	D1,D2 
		ASR.W	#1,D2 
		move.b	D2,(A0)+
		DBF	D0,L0090
		move.b	(A0),D1 
		EXT.W	D1
		move.b	(A1),D2 
		EXT.W	D2
		add.W	D1,D2 
		ASR.W	#1,D2 
		move.b	D2,(A0) 
		moveM.L	(A7)+,A0-A1/D1-D2 
		rts 
L0091		MOVE.L	D1,-(A7)
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		beq.s	L0094 
		move.w	L00BD,D1
		bne.s	L0092 
		move.w	(A6),D1 
		and.W	#$FFF,D1
		bne.s	L0094 
		move.w	L00BD,D1
L0092		EXT.L	D1
		DIVU	D0,D1 
		SWAP	D1
		tst.W	D1
		bne.s	L0094 
L0093		MOVE.W	#1,20(A5) 
		move.l	4(A6),D0
		move.l	D0,(A5) 
		moveQ	#0,D1 
		move.w	8(A6),D1
		add.L	D1,D1 
		add.L	D1,D0 
		move.l	D0,4(A5)
		move.w	16(A6),16(A5) 
		move.l	10(A6),8(A5)
		moveQ	#0,D0 
		move.w	14(A6),D0 
		add.L	D0,D0 
		move.l	D0,12(A5) 
L0094		MOVE.L	(A7)+,D1
		rts 
L0095		TST.W	L00BD 
		bne	L0042 
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		bra	L0078 
L0096		TST.W	L00BD 
		bne	L0042 
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		bra	L007B 
L0097		MOVEQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		cmp.W	L00BD,D0
		bne	L0042 
		clr.b	19(A6)
		rts 
L0098		MOVEQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		cmp.W	L00BD,D0
		bne	L0042 
		move.w	(A6),D0 
		and.W	#$FFF,D0
		beq	L0042 
		move.l	D1,-(A7)
		bra	L0093 
L0099		TST.W	L00BD 
		bne	L0042 
		moveQ	#0,D0 
		move.b	3(A6),D0
		and.B	#$F,D0
		tst.B	L00C7 
		bne	L0042 
		addQ.B	#1,D0 
		move.b	D0,L00C6
		rts 
L009A		TST.W	L00BD 
		bne	L0042 
		move.b	3(A6),D0
		and.B	#$F,D0
		lsl.B	#4,D0 
		andI.B	#$F,31(A6)
		OR.B	D0,31(A6) 
		tst.B	D0
		beq	L0042 
L009B		MOVEM.L	A0/D1,-(A7) 
		moveQ	#0,D0 
		move.b	31(A6),D0 
		lsr.B	#4,D0 
		beq.s	L009D 
		lea	L00B9,A0
		move.b	0(A0,D0.W),D0 
		add.B	D0,35(A6) 
		btst	#7,35(A6) 
		beq.s	L009D 
		clr.b	35(A6)
		move.l	10(A6),D0 
		moveQ	#0,D1 
		move.w	14(A6),D1 
		add.L	D1,D0 
		add.L	D1,D0 
		moveA.L	36(A6),A0 
		addQ.L	#1,A0 
		cmpA.L	D0,A0 
		bCS.S	L009C 
		moveA.L	10(A6),A0 
L009C		MOVE.L	A0,36(A6) 
		moveq	#$FF,D0 
		sub.B	(A0),D0 
		move.b	D0,(A0) 
L009D		MOVEM.L	(A7)+,A0/D1 
		rts 
L009E		MOVEM.L	A0-A1,-(A7) 
		lea	L00BC,A0
		lea	L00C9,A1
L009F		CLR.B	(A0)+ 
		cmpA.L	A0,A1 
		bne.s	L009F 
		lea	L00BC,A0
		move.b	#1,20(A0) 
		move.b	#2,64(A0) 
		move.b	#4,108(A0)
		move.b	#8,152(A0)
		move.w	#6,L00BE
		move.b	#$F,L00C8 
		moveM.L	(A7)+,A0-A1 
		rts 
L00A0		MOVEM.L	A0-A6/D0-D7,-(A7) 
		PEA	L00A1 
		move.w	#$26,-(A7)
		TRAP	#$E 
		addQ.L	#6,A7 
		moveM.L	(A7)+,A0-A6/D0-D7 
		rts 
L00A1:LEA	$FFFF8800.W,A0
		move	SR,D1 
		move	#$2700,SR 
		move.b	#$E,(A0)
		move.b	(A0),D0 
		and.B	#$EF,D0 
		move.b	D0,2(A0)
		OR.B	#$10,D0 
		move.b	D0,2(A0)
		move	D1,SR 
		move.l	$4BA.W,D0 
		addQ.L	#2,D0 
L00A2		CMP.L	$4BA.W,D0 
		BLT.S	L00A2 
		move	SR,D1 
		move	#$2700,SR 
		move.b	#$E,(A0)
		move.b	(A0),D0 
		and.B	#$EF,D0 
		move.b	D0,2(A0)
		move	D1,SR 
		lea	$FFFFA200.W,A0
		lea	L00CA,A1
		move.w	#$200,D0
L00A3:TST.B	(A1)
	BMI.S	L00A4 
		addQ.W	#3,A1 
		move.b	(A1)+,5(A0) 
		move.b	(A1)+,6(A0) 
		move.b	(A1)+,7(A0) 
		subQ.W	#1,D0 
		bra.S	L00A3 
L00A4:TST.W	D0
		beq.s	L00A6 
L00A5:CLR.B	5(A0) 
		clr.b	6(A0) 
		clr.b	7(A0) 
		subQ.W	#1,D0 
		bne.s	L00A5 
L00A6:BTST	#2,2(A0)
		beq.s	L00A6 
		clr.b	5(A0) 
		clr.b	6(A0) 
		clr.b	7(A0) 
		lea	L00CB,A1
L00A7:BTST	#2,2(A0)
		beq.s	L00A7 
		move.b	(A1)+,5(A0) 
		move.b	(A1)+,6(A0) 
		move.b	(A1)+,7(A0) 
		tst.B	-3(A1)
		BMI.S	L00A9 
L00A8		BTST	#2,2(A0)
		beq.s	L00A8 
		move.b	(A1)+,5(A0) 
		move.b	(A1)+,6(A0) 
		move.b	(A1)+,7(A0) 
		bra.S	L00A7 
L00A9:RTS 


*******************
   SECTION DATA
*******************

		dc.w	0
L00AA		dc.l	0
L00AB		dc.w	0
L00AC		dc.w	0
L00AF		DCB.W	3,0
L00B0		dc.w	0
L00B1		dc.w	0
L00B2		dc.l	0
L00B3		dc.l	0
L00B4		dc.l	0
L00B5		dc.w	0
L00B6		DCB.W	62,0
L00B7		dc.l	0
L00B8		DCB.W	1760,0
L00B9		dc.w	$0005,$0607,$080A,$0B0D,$1013,$161A,$202b,$4080
L00BA		DC.B	$00,$18,'1Jax',$8D,$A1
	DC.B	$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B	$FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5
	DC.B	$B4,$A1,$8D,'xaJ1',$18
	DC.B	$00,$00

L00BB	DC.W	$358,$328,$2FA,$2D0,$2A6,$280,$25C,$23A,$21A,$1FC,$1E0,$1C5
	DC.W	$1AC,$194,$17D,$168,$153,$140,$12E,$11D,$10D,$FE,$F0,$E2
	DC.W	$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87,$7F,$78,$71
	DC.W	0,$352,$322,$2F5,$2CB,$2A2,$27D,$259,$237,$217,$1F9,$1DD
	DC.W	$1C2,$1A9,$191,$17B,$165,$151,$13E,$12C,$11C,$10C,$FD,$EF
	DC.W	$E1,$D5,$C9,$BD,$B3,$A9,$9F,$96,$8E,$86,$7E,$77,$71,0,$34C,$31C
	DC.W	$2F0,$2C5,$29E,$278,$255,$233,$214,$1F6,$1DA,$1BF,$1A6,$18E
	DC.W	$178,$163,$14F,$13C,$12A,$11A,$10A,$FB,$ED,$E0,$D3,$C7
	DC.W	$BC,$B1,$A7,$9E,$95,$8D,$85,$7D,$76,$70,0,$346
	DC.W	$317,$2EA,$2C0,$299,$274,$250,$22F,$210,$1F2,$1D6,$1BC,$1A3
	DC.W	$18B,$175,$160,$14C,$13A,$128,$118,$108,$F9,$EB,$DE,$D1
	DC.W	$C6,$BB,$B0,$A6,$9D,$94,$8C,$84,$7D,$76,$6F,0
	DC.W	$340,$311,$2E5,$2BB,$294,$26F,$24C,$22B,$20C,$1EF,$1D3,$1B9
	DC.W	$1A0,$188,$172,$15E,$14A,$138,$126,$116,$106,$F7,$E9,$DC
	DC.W	$D0,$C4,$B9,$AF,$A5,$9C,$93,$8B,$83,$7C,$75,$6E
	DC.W	0,$33A,$30B,$2E0,$2B6,$28F,$26B,$248,$227,$208,$1EB,$1CF
	DC.W	$1B5,$19D,$186,$170,$15B,$148,$135,$124,$114,$104,$F5,$E8
	DC.W	$DB,$CE,$C3,$B8,$AE,$A4,$9B,$92,$8A,$82,$7B,$74
	DC.W	$6D,0,$334,$306,$2DA,$2B1,$28B,$266,$244,$223,$204,$1E7
	DC.W	$1CC,$1B2,$19A,$183,$16D,$159,$145,$133,$122,$112,$102,$F4
	DC.W	$E6,$D9,$CD,$C1,$B7,$AC,$A3,$9A,$91,$89,$81,$7A
	DC.W	$73,$6D,0,$32E,$300,$2D5,$2AC,$286,$262,$23F,$21F,$201
	DC.W	$1E4,$1C9,$1AF,$197,$180,$16B,$156,$143,$131,$120,$110,$100
	DC.W	$F2,$E4,$D8,$CC,$C0,$B5,$AB,$A1,$98,$90,$88,$80
	DC.W	$79,$72,$6C,0,$38B,$358,$328,$2FA,$2D0,$2A6,$280,$25C
	DC.W	$23A,$21A,$1FC,$1E0,$1C5,$1AC,$194,$17D,$168,$153,$140,$12E
	DC.W	$11D,$10D,$FE,$F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97
	DC.W	$8F,$87,$7F,$78,0,$384,$352,$322,$2F5,$2CB,$2A3,$27C
	DC.W	$259,$237,$217,$1F9,$1DD,$1C2,$1A9,$191,$17B,$165,$151,$13E
	DC.W	$12C,$11C,$10C,$FD,$EE,$E1,$D4,$C8,$BD,$B3,$A9,$9F
	DC.W	$96,$8E,$86,$7E,$77,0,$37E,$34C,$31C,$2F0,$2C5,$29E
	DC.W	$278,$255,$233,$214,$1F6,$1DA,$1BF,$1A6,$18E,$178,$163,$14F
	DC.W	$13C,$12A,$11A,$10A,$FB,$ED,$DF,$D3,$C7,$BC,$B1,$A7
	DC.W	$9E,$95,$8D,$85,$7D,$76,0,$377,$346,$317,$2EA,$2C0
	DC.W	$299,$274,$250,$22F,$210,$1F2,$1D6,$1BC,$1A3,$18B,$175,$160
	DC.W	$14C,$13A,$128,$118,$108,$F9,$EB,$DE,$D1,$C6,$BB,$B0
	DC.W	$A6,$9D,$94,$8C,$84,$7D,$76,0,$371,$340,$311,$2E5
	DC.W	$2BB,$294,$26F,$24C,$22B,$20C,$1EE,$1D3,$1B9,$1A0,$188,$172
	DC.W	$15E,$14A,$138,$126,$116,$106,$F7,$E9,$DC,$D0,$C4,$B9
	DC.W	$AF,$A5,$9C,$93,$8B,$83,$7B,$75,0,$36B,$33A,$30B
	DC.W	$2E0,$2B6,$28F,$26B,$248,$227,$208,$1EB,$1CF,$1B5,$19D,$186
	DC.W	$170,$15B,$148,$135,$124,$114,$104,$F5,$E8,$DB,$CE,$C3
	DC.W	$B8,$AE,$A4,$9B,$92,$8A,$82,$7B,$74,0,$364,$334
	DC.W	$306,$2DA,$2B1,$28B,$266,$244,$223,$204,$1E7,$1CC,$1B2,$19A
	DC.W	$183,$16D,$159,$145,$133,$122,$112,$102,$F4,$E6,$D9,$CD
	DC.W	$C1,$B7,$AC,$A3,$9A,$91,$89,$81,$7A,$73,0,$35E
	DC.W	$32E,$300,$2D5,$2AC,$286,$262,$23F,$21F,$201,$1E4,$1C9,$1AF
	DC.W	$197,$180,$16B,$156,$143,$131,$120,$110,$100,$F2,$E4,$D8
	DC.W	$CB,$C0,$B5,$AB,$A1,$98,$90,$88,$80,$79,$72,0



L00BC	DCB.W	10,0
	dc.w	$0001,$0000,$0000,$0000 
	DCB.W	18,0
	DC.B	$00,$02,$00,$00,$00,$00,$00,$00 
	DCB.W	18,0
	DC.B	$00,$04,$00,$00,$00,$00,$00,$00 
	DCB.W	18,0
	DC.B	$00,$08,$00,$00,$00,$00,$00,$00 
	DCB.W	8,0 
L00BD	dc.w	0 
L00BE:DCB.W	2,0 
L00BF:DC.B	$00,$00 
L00C0:DC.B	$00,$00 
L00C1:DCB.W	2,0 
L00C2:DC.B	$00 
L00C3:DC.B	$00 
L00C4:DC.B	$00 
L00C5:DC.B	$00 
L00C6:DC.B	$00 
L00C7:DC.B	$00 
L00C8:DC.B	$00 
L00C9:DC.B	$00 
L00CA:DC.B	'P',$00,$00,'D',$F4,$00,'P',$00 
	DC.B	$01,$00,$00,$0E,'P',$00,$02,' ' 
	DC.B	$92,$00,'P',$00,$03,'V',$F4,$00 
	DC.B	'P',$00,$04,$00,$00,'IP',$00
	DC.B	$05,' ',$00,'DP',$00,$06,'`'
	DC.B	$F4,$00,'P',$00,$07,$00,'|',$0E 
	DC.B	'P',$00,$08,'"',$11,$00,'P',$00 
	DC.B	$09,$06,$CE,$00,'P',$00,$0A,$00 
	DC.B	$00,$0C,'P',$00,$0B,$07,$DA,$84 
	DC.B	'P',$00,$0C,$07,'X„P',$00 
	DC.B	$0D,$0A,$E1,$80,'P',$00,$0E,$08 
	DC.B	$F4,$A0,'P',$00,$0F,$00,$00,$01 
	DC.B	'P',$00,$10,'0',$00,$00,'P',$00 
	DC.B	$11,' ',$00,$13,'P',$00,$12,$06 
	DC.B	'@',$A0,'P',$00,$13,$07,'XŽ'
	DC.B	'P',$00,$14,$0B,$F0,$80,'P',$00 
	DC.B	$15,$00,'|EP',$00,$16,' ' 
	DC.B	$8F,$00,'P',$00,$17,' ',$00,$0B 
	DC.B	'P',$00,$18,$0A,$F0,$AA,'P',$00 
	DC.B	$19,$00,'|#P',$00,$1A,'`' 
	DC.B	$F4,$00,'P',$00,$1B,$00,'`',$00 
	DC.B	'P',$00,$1C,$0B,$F0,$80,'P',$00 
	DC.B	$1D,$00,'|EP',$00,$1E,$06 
	DC.B	$C4,$00,'P',$00,$1F,$00,'|"'
	DC.B	'P',$00,' ',$0B,$F0,$80,'P',$00 
	DC.B	'!',$00,'|EP',$00,'"',$07 
	DC.B	'X„P',$00,'#',$0B,$F0,$80 
	DC.B	'P',$00,'$',$00,'|EP',$00 
	DC.B	'% ',$90,$00,'P',$00,'& ' 
	DC.B	$8E,$00,'P',$00,$27,'$',$FF,$00 
	DC.B	'P',$00,'( ',$00,'FP',$00 
	DC.B	')%PEP',$00,'*',$0A 
	DC.B	$F0,$AA,'P',$00,'+',$00,'|@'
	DC.B	'P',$00,',',$0B,$F0,$80,'P',$00 
	DC.B	'-',$00,'|EP',$00,'.%'
	DC.B	'XeP',$00,'/',$0A,$F0,$A2 
	DC.B	'P',$00,'0',$00,'|4P',$00 
	DC.B	'1',$07,'`„P',$00,'2',$0A 
	DC.B	$F0,$80,'P',$00,'3',$00,'|#'
	DC.B	'P',$00,'4%YeP',$00 
	DC.B	'5',$0A,$F0,$A2,'P',$00,'6',$00 
	DC.B	'|:P',$00,'7D`',$00 
	DC.B	'P',$00,'8',$0A,$F0,$80,'P',$00 
	DC.B	'9',$00,'|#P',$00,': '
	DC.B	$00,'eP',$00,';',$0A,$F0,$A2
	DC.B	'P',$00,'<',$00,'|#P',$00 
	DC.B	'=L`',$00,'P',$00,'>',$0A 
	DC.B	$F0,$80,'P',$00,'?',$00,'|#'
	DC.B	'P',$00,'@ ',$00,$0B,'P',$00
	DC.B	'A',$0A,$F0,$AA,'P',$00,'B',$00 
	DC.B	$00,$00,'P',$00,'C',$0A,$F0,$80 
	DC.B	'P',$00,'D',$00,'`',$00,'P',$00 
	DC.B	'E',$0A,$A9,$80,'P',$00,'F',$00 
	DC.B	'|EP',$00,'G',$08,'D+'
	DC.B	'P',$00,'H',$00,$00,$0C,$FF,$FF 
	DC.B	$FF,$FF,$FF,$FF 
L00CB:DC.B	'X',$00,$00,$00,$00,$00,'X',$00 
	DC.B	$01,$00,$00,$00,'X',$00,$02,$00 
	DC.B	$00,$00,'X',$00,$03,$00,$00,$00 
	DC.B	'X',$00,$04,$00,$00,$00,'X',$00 
	DC.B	$05,$00,$00,$00,'X',$00,$06,$00 
	DC.B	$00,$00,'X',$00,$07,$00,$00,$00 
	DC.B	'X',$00,$08,$00,$00,$00,'X',$00 
	DC.B	$09,$00,$00,$00,'X',$00,$0A,$00 
	DC.B	$00,$00,'X',$00,$0B,$00,$00,$00 
	DC.B	'X',$00,$0C,$00,$00,$00,'X',$00 
	DC.B	$0D,$00,$00,$00,'X',$00,$0E,$00 
	DC.B	$00,$00,'X',$00,$0F,$00,$00,$00 
	DC.B	'X',$00,$10,$00,$00,$00,'X',$00 
	DC.B	$11,$00,$00,$00,'X',$00,$12,$00 
	DC.B	$00,$00,'X',$00,$13,$00,$00,$00 
	DC.B	'X',$00,$14,$00,$00,$00,'X',$00 
	DC.B	$15,$00,$00,$00,'X',$00,$16,$00 
	DC.B	$00,$00,'X',$00,$17,$00,$00,$00 
	DC.B	'X',$00,$18,$00,$00,$00,'X',$00 
	DC.B	$19,$00,$00,$00,'X',$00,$1A,$00 
	DC.B	$00,$00,'X',$00,$1B,$00,$00,$00 
	DC.B	'X',$00,$1C,$00,$00,$00,'X',$00 
	DC.B	$1D,$00,$00,$00,'X',$00,$1E,$00 
	DC.B	$00,$00,'X',$00,$1F,$00,$00,$00 
	DC.B	'X',$00,' ',$00,$00,$00,'P',$00 
	DC.B	$00,$0A,$F0,$80,'P',$00,$01,$00 
	DC.B	$00,'@P',$00,$10,$0B,$F0,$80
	DC.B	'P',$00,$11,$00,$01,'>P',$00
	DC.B	'@',$08,$F4,$BE,'P',$00,'A',$00 
	DC.B	$00,$00,'P',$00,'B',$08,$F4,$A0 
	DC.B	'P',$00,'C',$00,$00,$01,'P',$00 
	DC.B	'D',$05,$F4,'&P',$00,'E',$00
	DC.B	$07,$FF,'P',$00,'F',$04,'g',$A6 
	DC.B	'P',$00,'G ',$00,$1B,'P',$00
	DC.B	'Hg',$F4,$00,'P',$00,'I',$00
	DC.B	' ',$00,'P',$00,'J',$06,$00,$A8 
	DC.B	'P',$00,'KI_',$00,'P',$00 
	DC.B	'L',$05,$01,$A3,'P',$00,'M',$08 
	DC.B	$F4,$BF,'P',$00,'N',$00,'0',$00 
	DC.B	'P',$00,'O',$08,$F4,$AC,'P',$00 
	DC.B	'P',$00,'A',$00,'P',$00,'Q',$08 
	DC.B	$F4,$AD,'P',$00,'R',$00,'X',$00 
	DC.B	'P',$00,'S',$08,$F4,$A1,'P',$00 
	DC.B	'T',$00,$01,$F0,'P',$00,'U',$08 
	DC.B	$F4,$A3,'P',$00,'V',$00,$00,$08 
	DC.B	'P',$00,'W',$00,$F0,$B8,'P',$00 
	DC.B	'X',$0A,$A9,$80,'P',$00,'Y',$00 
	DC.B	$00,'XP',$00,'Z',$08,'E+' 
	DC.B	'P',$00,'[f',$F4,$00,'P',$00
	DC.B	'\',$00,' ',$00,'P',$00,']g'
	DC.B	$F4,$00,'P',$00,'^',$00,'$',$00 
	DC.B	'P',$00,'_',$0A,$F0,$80,'P',$00 
	DC.B	'`',$00,$00,'dP',$00,'a',$0A
	DC.B	$A9,$80,'P',$00,'b',$00,$00,'a' 
	DC.B	'P',$00,'c',$08,'E+P',$00 
	DC.B	'd',$0A,'p#P',$00,'e',$00 
	DC.B	$FF,$E5,'P',$00,'f"',$EF,$00
	DC.B	'P',$00,'g"',$C4,$00,'P',$00
	DC.B	'hD',$F4,'LP',$00,'i',$00 
	DC.B	$08,$00,'P',$00,'j',$0A,$F0,$A0 
	DC.B	'P',$00,'k',$00,$00,'mP',$00
	DC.B	'l ',$00,'HP',$00,'mW'
	DC.B	' ',$00,'P',$00,'n`',$F4,$00
	DC.B	'P',$00,'o',$00,$02,$00,'P',$00 
	DC.B	'pa',$F4,$00,'P',$00,'q',$00
	DC.B	$00,$04,'P',$00,'r',$0B,$F0,$80 
	DC.B	'P',$00,'s',$00,$01,$0D,'P',$00 
	DC.B	't`',$F4,$00,'P',$00,'u',$00
	DC.B	$06,$00,'P',$00,'va',$F4,$00
	DC.B	'P',$00,'w',$00,$00,$0C,'P',$00 
	DC.B	'x',$0B,$F0,$80,'P',$00,'y',$00 
	DC.B	$01,$0D,'P',$00,'z`',$F4,$00
	DC.B	'P',$00,'{',$00,$0A,$00,'P',$00 
	DC.B	'|a',$F4,$00,'P',$00,'}',$00
	DC.B	$00,$14,'P',$00,'~',$0B,$F0,$80 
	DC.B	'P',$00,$7F,$00,$01,$0D,'P',$00 
	DC.B	$80,'`',$F4,$00,'P',$00,$81,$00 
	DC.B	$0E,$00,'P',$00,$82,'a',$F4,$00 
	DC.B	'P',$00,$83,$00,$00,$1C,'P',$00 
	DC.B	$84,$0B,$F0,$80,'P',$00,$85,$00 
	DC.B	$01,$0D,'P',$00,$86,$0A,'p',$03 
	DC.B	'P',$00,$87,$00,$FF,$E5,'P',$00 
	DC.B	$88,'F',$F4,$00,'P',$00,$89,'p' 
	DC.B	$00,$00,'P',$00,$8A,$27,$00,$00 
	DC.B	'P',$00,$8B,'D',$84,$00,'P',$00 
	DC.B	$8C,' ',$00,$D0,'P',$00,$8D,'V' 
	DC.B	$02,$00,'P',$00,'Ž ',$00,$C0
	DC.B	'P',$00,$8F,'V',$03,$00,'P',$00 
	DC.B	$90,'D',$8C,$00,'P',$00,$91,' ' 
	DC.B	$00,$D0,'P',$00,$92,'V',$0B,$00 
	DC.B	'P',$00,$93,' ',$00,$C0,'P',$00 
	DC.B	$94,'V',$0A,$00,'P',$00,$95,'D' 
	DC.B	$94,$00,'P',$00,$96,' ',$00,$D0 
	DC.B	'P',$00,$97,'V',$13,$00,'P',$00 
	DC.B	$98,' ',$00,$C0,'P',$00,$99,'V' 
	DC.B	$12,$00,'P',$00,'šD',$9C,$00
	DC.B	'P',$00,$9B,' ',$00,$D0,'P',$00 
	DC.B	$9C,'V',$1A,$00,'P',$00,$9D,' ' 
	DC.B	$00,$C0,'P',$00,$9E,'V',$1B,$00 
	DC.B	'P',$00,$9F,'"',$DE,$00,'P',$00 
	DC.B	$A0,$0A,$DA,'`P',$00,$A1,'`'
	DC.B	$F4,$00,'P',$00,$A2,$00,$02,$00 
	DC.B	'P',$00,$A3,'2',$05,$00,'P',$00 
	DC.B	$A4,'3',$02,$00,'P',$00,$A5,$0D 
	DC.B	$00,$B7,'P',$00,$A6,$0A,$DA,'@' 
	DC.B	'P',$00,$A7,'`',$F4,$00,'P',$00 
	DC.B	$A8,$00,$06,$00,'P',$00,$A9,'2' 
	DC.B	$0D,$00,'P',$00,$AA,'3',$0A,$00 
	DC.B	'P',$00,$AB,$0D,$00,$B7,'P',$00 
	DC.B	$AC,'`',$F4,$00,'P',$00,$AD,$00 
	DC.B	$0A,$00,'P',$00,$AE,'2',$15,$00 
	DC.B	'P',$00,$AF,'3',$12,$00,'P',$00 
	DC.B	$B0,$0D,$00,$B7,'P',$00,$B1,'`' 
	DC.B	$F4,$00,'P',$00,$B2,$00,$0E,$00 
	DC.B	'P',$00,$B3,'2',$1D,$00,'P',$00 
	DC.B	$B4,'3',$1A,$00,'P',$00,$B5,$0D 
	DC.B	$00,$B7,'P',$00,$B6,$0C,$00,'a' 
	DC.B	'P',$00,$B7,'a',$F4,$00,'P',$00 
	DC.B	$B8,$00,$12,$00,'P',$00,$B9,'W' 
	DC.B	$D8,$00,'P',$00,$BA,'!',$F9,$00 
	DC.B	'P',$00,$BB,' ',$00,$0B,'P',$00 
	DC.B	$BC,$0B,$F0,$A2,'P',$00,$BD,$00 
	DC.B	$00,$F8,'P',$00,$BE,'a',$F4,$00 
	DC.B	'P',$00,$BF,$00,$12,$00,'P',$00 
	DC.B	$C0,'W',$D8,$00,'P',$00,$C1,' ' 
	DC.B	'I',$00,'P',$00,$C2,'!',$F9,$00 
	DC.B	'P',$00,$C3,'"4',$00,'P',$00
	DC.B	$C4,' ',$00,$0B,'P',$00,$C5,$0A 
	DC.B	$F0,$AA,'P',$00,$C6,$00,$00,$D3 
	DC.B	'P',$00,$C7,$0B,$F0,$80,'P',$00 
	DC.B	$C8,$00,$00,$F8,'P',$00,$C9,'"' 
	DC.B	$91,$00,'P',$00,$CA,'W',$F4,$00 
	DC.B	'P',$00,$CB,$00,$16,$00,'P',$00 
	DC.B	$CC,' I',$00,'P',$00,$CD,'"'
	DC.B	'$',$00,'P',$00,$CE,' ',$00,'L' 
	DC.B	'P',$00,$CF,$06,$CF,$00,'P',$00 
	DC.B	$D0,$00,$00,$D2,'P',$00,$D1,'D' 
	DC.B	$DC,$00,'P',$00,$D2,'DY',$00
	DC.B	'P',$00,$D3,'#',$D6,$00,'P',$00 
	DC.B	$D4,'`',$F4,$00,'P',$00,$D5,$00 
	DC.B	$12,$00,'P',$00,$D6,'D',$DA,$00 
	DC.B	'P',$00,$D7,'E',$D8,$00,'P',$00 
	DC.B	$D8,'F',$DB,$00,'P',$00,$D9,'F' 
	DC.B	$DB,$E0,'P',$00,$DA,'!',$C7,$00 
	DC.B	'P',$00,$DB,' Z',$E0,'P',$00
	DC.B	$DC,'!',$C6,$00,'P',$00,$DD,'W' 
	DC.B	$E2,$00,'P',$00,$DE,'p',$A0,$00 
	DC.B	'P',$00,$DF,$06,$D8,$00,'P',$00 
	DC.B	$E0,$00,$00,$F0,'P',$00,$E1,' ' 
	DC.B	$00,'HP',$00,$E2,$0A,$F0,$A5
	DC.B	'P',$00,$E3,$00,$00,$EB,'P',$00 
	DC.B	$E4,$0A,$CD,'WP',$00,$E5,'E'
	DC.B	$D8,$00,'P',$00,$E6,'F',$DB,$00 
	DC.B	'P',$00,$E7,'F',$DB,$E0,'P',$00 
	DC.B	$E8,'!',$C7,$00,'P',$00,$E9,' ' 
	DC.B	$00,$E0,'P',$00,$EA,'!',$C6,$00 
	DC.B	'P',$00,$EB,'H',$E6,$00,'P',$00 
	DC.B	$EC,$0A,$DA,$00,'P',$00,$ED,$00 
	DC.B	$00,$EF,'P',$00,$EE,' ',$00,$13 
	DC.B	'P',$00,$EF,' ',$00,'0P',$00
	DC.B	$F0,'H^',$00,'P',$00,$F1,'W'
	DC.B	'R',$00,'P',$00,$F2,'"',$0F,$00 
	DC.B	'P',$00,$F3,'D',$F4,$00,'P',$00 
	DC.B	$F4,$00,$12,$01,'P',$00,$F5,' ' 
	DC.B	$00,'LP',$00,$F6,'Wb',$00 
	DC.B	'P',$00,$F7,$00,$00,$0C,'P',$00 
	DC.B	$F8,'D',$F4,'+P',$00,$F9,$00
	DC.B	$00,$01,'P',$00,$FA,' ',$00,'H' 
	DC.B	'P',$00,$FB,$06,$CF,$00,'P',$00 
	DC.B	$FC,$00,$01,$0B,'P',$00,$FD,'D' 
	DC.B	$E0,$00,'P',$00,$FE,'E',$F4,$00 
	DC.B	'P',$00,$FF,$00,$00,$80,'P',$01 
	DC.B	$00,'D',$F4,$A8,'P',$01,$01,$FF 
	DC.B	$00,$00,'P',$01,$02,'!/',$00
	DC.B	'P',$01,$03,'E',$F4,'NP',$01
	DC.B	$04,$00,$80,$00,'P',$01,$05,'U' 
	DC.B	'Y',$00,'P',$01,$06,'D',$D8,$00 
	DC.B	'P',$01,$07,'D',$F4,$A8,'P',$01 
	DC.B	$08,$FF,$00,$00,'P',$01,$09,'!' 
	DC.B	'/',$00,'P',$01,$0A,' ',$00,'N' 
	DC.B	'P',$01,$0B,'UY',$00,'P',$01
	DC.B	$0C,$00,$00,$0C,'P',$01,$0D,$0A 
	DC.B	$A9,$80,'P',$01,$0E,$00,$01,$0D 
	DC.B	'P',$01,$0F,$08,'Y',$AB,'P',$01 
	DC.B	$10,$0A,$A9,$80,'P',$01,$11,$00 
	DC.B	$01,$10,'P',$01,$12,$08,'E+'
	DC.B	'P',$01,$13,'EY',$00,'P',$01
	DC.B	$14,$0A,$A9,$81,'P',$01,$15,$00 
	DC.B	$01,$14,'P',$01,$16,$08,$E1,$AB 
	DC.B	'P',$01,$17,'D',$A0,$00,'P',$01 
	DC.B	$18,' ',$00,$A8,'P',$01,$19,$0A 
	DC.B	$A9,$81,'P',$01,$1A,$00,$01,$19 
	DC.B	'P',$01,$1B,$08,$CF,'+P',$01
	DC.B	$1C,$0A,$A9,$81,'P',$01,$1D,$00 
	DC.B	$01,$1C,'P',$01,$1E,$08,$C4,'+' 
	DC.B	'P',$01,$1F,$0A,$A9,$80,'P',$01 
	DC.B	' ',$00,$01,$1F,'P',$01,'!',$08 
	DC.B	'O+P',$01,'"WX',$00 
	DC.B	'P',$01,'# ',$00,$0B,'P',$01
	DC.B	'$',$0A,$F0,$AA,'P',$01,'%',$00 
	DC.B	$01,'.P',$01,'&D',$F4,'+' 
	DC.B	'P',$01,$27,$00,$00,$01,'P',$01 
	DC.B	'( ',$00,'HP',$01,')',$06 
	DC.B	$CF,$00,'P',$01,'*',$00,$01,'-' 
	DC.B	'P',$01,'+',$0A,$A9,$80,'P',$01 
	DC.B	',',$00,$01,'+P',$01,'-',$08
	DC.B	'X',$AB,'P',$01,'.',$0A,$A9,$80 
	DC.B	'P',$01,'/',$00,$01,'.P',$01
	DC.B	'0',$08,'O+P',$01,'1W'
	DC.B	'X',$00,'P',$01,'2 ',$00,$0B
	DC.B	'P',$01,'3',$0A,$F0,$AA,'P',$01 
	DC.B	'4',$00,$01,'=P',$01,'5D' 
	DC.B	$F4,'+P',$01,'6',$00,$00,$01
	DC.B	'P',$01,'7 ',$00,'HP',$01 
	DC.B	'8',$06,$CF,$00,'P',$01,'9',$00 
	DC.B	$01,'<P',$01,':',$0A,$A9,$80
	DC.B	'P',$01,';',$00,$01,':P',$01
	DC.B	'<',$08,'X',$AB,'P',$01,'=',$00 
	DC.B	$00,$0C,'P',$01,'>',$0A,$AE,$82 
	DC.B	'P',$01,'?',$00,$01,'BP',$01
	DC.B	'@',$08,$DF,$EF,'P',$01,'A',$00 
	DC.B	$00,$04,'P',$01,'B',$08,$E7,$AF 
	DC.B	'P',$01,'C',$00,$00,$04,'P',$01 
	DC.B	'DDSPP',$01,'E-'
	DC.B	'PaP',$01,'Fula'
	DC.B	'P',$01,'G-EmP',$01 
	DC.B	'HulaP',$01,'It'
	DC.B	'orP',$01,'J V2'
	DC.B	'P',$01,'K.0 P',$01 
	DC.B	'LcodP',$01,'Me'
	DC.B	'riP',$01,'Nght'
	DC.B	'P',$01,'O byP',$01 
	DC.B	'P bIP',$01,'QT'
	DC.B	'mAP',$01,'RSTE'
	DC.B	'P',$01,'SR oP',$01 
	DC.B	'Tf BP',$01,'US'
	DC.B	'W P',$01,'Vof '
	DC.B	'P',$01,'WCC ',$FF,$FF
	DC.B	$FF,$FF,$FF,$FF 
	endc



pic		incbin	pov_big1.pi1
pic2		incbin	pov_big2.pi1

oz_gid		incbin	oz_gid.dat
poverty		incbin	poverty.dat
pacman		incbin	pacman.dat
credits		incbin	credits.dat
theend		incbin	theend.dat
rout_timer	dc.l	10


		IFNE	TRACKER
mod		incbin	spacedeb.mod
		endc



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


		dc.w	$0008,(384)
gid_dot_table
		dc.w	$0008,0,$0004,0,$0002,0,$0001,0

		dc.w	$8000,16,$4000,16,$2000,16,$1000,16
		dc.w	$0800,16,$0400,16,$0200,16,$0100,16
		dc.w	$0080,16,$0040,16,$0020,16,$0010,16
		dc.w	$0008,16,$0004,16,$0002,16,$0001,16

		dc.w	$8000,32,$4000,32,$2000,32,$1000,32
		dc.w	$0800,32,$0400,32,$0200,32,$0100,32
		dc.w	$0080,32,$0040,32,$0020,32,$0010,32
		dc.w	$0008,32,$0004,32,$0002,32,$0001,32

		dc.w	$8000,48,$4000,48,$2000,48,$1000,48
		dc.w	$0800,48,$0400,48,$0200,48,$0100,48
		dc.w	$0080,48,$0040,48,$0020,48,$0010,48
		dc.w	$0008,48,$0004,48,$0002,48,$0001,48

		dc.w	$8000,64,$4000,64,$2000,64,$1000,64
		dc.w	$0800,64,$0400,64,$0200,64,$0100,64
		dc.w	$0080,64,$0040,64,$0020,64,$0010,64
		dc.w	$0008,64,$0004,64,$0002,64,$0001,64

		dc.w	$8000,80,$4000,80,$2000,80,$1000,80
		dc.w	$0800,80,$0400,80,$0200,80,$0100,80
		dc.w	$0080,80,$0040,80,$0020,80,$0010,80
		dc.w	$0008,80,$0004,80,$0002,80,$0001,80

		dc.w	$8000,96,$4000,96,$2000,96,$1000,96
		dc.w	$0800,96,$0400,96,$0200,96,$0100,96
		dc.w	$0080,96,$0040,96,$0020,96,$0010,96
		dc.w	$0008,96,$0004,96,$0002,96,$0001,96

		dc.w	$1,96+(1*384)
		dc.w	$1,96+(2*384)
		dc.w	$1,96+(3*384)
		dc.w	$1,96+(4*384)
		dc.w	$1,96+(5*384)
		dc.w	$1,96+(6*384)
		dc.w	$1,96+(7*384)
		dc.w	$1,96+(8*384)
		dc.w	$1,96+(9*384)
		dc.w	$1,96+(10*384)
		dc.w	$1,96+(11*384)
		dc.w	$1,96+(12*384)
		dc.w	$1,96+(13*384)
		dc.w	$1,96+(14*384)
		dc.w	$1,96+(15*384)
		dc.w	$1,96+(16*384)
		dc.w	$1,96+(17*384)
		dc.w	$1,96+(18*384)
		dc.w	$1,96+(19*384)
		dc.w	$1,96+(20*384)
		dc.w	$1,96+(21*384)
		dc.w	$1,96+(22*384)
		dc.w	$1,96+(23*384)
		dc.w	$1,96+(24*384)
		dc.w	$1,96+(25*384)
		dc.w	$1,96+(26*384)
		dc.w	$1,96+(27*384)
		dc.w	$1,96+(28*384)
		dc.w	$1,96+(29*384)
		dc.w	$1,96+(30*384)
		dc.w	$1,96+(31*384)
		dc.w	$1,96+(32*384)
		dc.w	$1,96+(33*384)
		dc.w	$1,96+(34*384)
		dc.w	$1,96+(35*384)
		dc.w	$1,96+(36*384)
		dc.w	$1,96+(37*384)
		dc.w	$1,96+(38*384)
		dc.w	$1,96+(39*384)
		dc.w	$1,96+(40*384)
		dc.w	$1,96+(41*384)
		dc.w	$1,96+(42*384)
		dc.w	$1,96+(43*384)
		dc.w	$1,96+(44*384)
		dc.w	$1,96+(45*384)

		dc.w	$0001,96+(46*384),$0002,96+(46*384),$0004,96+(46*384),$0008,96+(46*384)
		dc.w	$0010,96+(46*384),$0020,96+(46*384),$0040,96+(46*384),$0080,96+(46*384)
		dc.w	$0100,96+(46*384),$0200,96+(46*384),$0400,96+(46*384),$0800,96+(46*384)
		dc.w	$1000,96+(46*384),$2000,96+(46*384),$4000,96+(46*384),$8000,96+(46*384)

		dc.w	$0001,80+(46*384),$0002,80+(46*384),$0004,80+(46*384),$0008,80+(46*384)
		dc.w	$0010,80+(46*384),$0020,80+(46*384),$0040,80+(46*384),$0080,80+(46*384)
		dc.w	$0100,80+(46*384),$0200,80+(46*384),$0400,80+(46*384),$0800,80+(46*384)
		dc.w	$1000,80+(46*384),$2000,80+(46*384),$4000,80+(46*384),$8000,80+(46*384)

		dc.w	$0001,64+(46*384),$0002,64+(46*384),$0004,64+(46*384),$0008,64+(46*384)
		dc.w	$0010,64+(46*384),$0020,64+(46*384),$0040,64+(46*384),$0080,64+(46*384)
		dc.w	$0100,64+(46*384),$0200,64+(46*384),$0400,64+(46*384),$0800,64+(46*384)
		dc.w	$1000,64+(46*384),$2000,64+(46*384),$4000,64+(46*384),$8000,64+(46*384)

		dc.w	$0001,48+(46*384),$0002,48+(46*384),$0004,48+(46*384),$0008,48+(46*384)
		dc.w	$0010,48+(46*384),$0020,48+(46*384),$0040,48+(46*384),$0080,48+(46*384)
		dc.w	$0100,48+(46*384),$0200,48+(46*384),$0400,48+(46*384),$0800,48+(46*384)
		dc.w	$1000,48+(46*384),$2000,48+(46*384),$4000,48+(46*384),$8000,48+(46*384)

		dc.w	$0001,32+(46*384),$0002,32+(46*384),$0004,32+(46*384),$0008,32+(46*384)
		dc.w	$0010,32+(46*384),$0020,32+(46*384),$0040,32+(46*384),$0080,32+(46*384)
		dc.w	$0100,32+(46*384),$0200,32+(46*384),$0400,32+(46*384),$0800,32+(46*384)
		dc.w	$1000,32+(46*384),$2000,32+(46*384),$4000,32+(46*384),$8000,32+(46*384)

		dc.w	$0001,16+(46*384),$0002,16+(46*384),$0004,16+(46*384),$0008,16+(46*384)
		dc.w	$0010,16+(46*384),$0020,16+(46*384),$0040,16+(46*384),$0080,16+(46*384)
		dc.w	$0100,16+(46*384),$0200,16+(46*384),$0400,16+(46*384),$0800,16+(46*384)
		dc.w	$1000,16+(46*384),$2000,16+(46*384),$4000,16+(46*384),$8000,16+(46*384)

		dc.w	$0001,(46*384),$0002,(46*384),$0004,(46*384),$0008,(46*384)

		dc.w	$8,(45*384)
		dc.w	$8,(44*384)
		dc.w	$8,(43*384)
		dc.w	$8,(42*384)
		dc.w	$8,(41*384)
		dc.w	$8,(40*384)
		dc.w	$8,(39*384)
		dc.w	$8,(38*384)
		dc.w	$8,(37*384)
		dc.w	$8,(36*384)
		dc.w	$8,(35*384)
		dc.w	$8,(34*384)
		dc.w	$8,(33*384)
		dc.w	$8,(32*384)
		dc.w	$8,(31*384)
		dc.w	$8,(30*384)
		dc.w	$8,(29*384)
		dc.w	$8,(28*384)
		dc.w	$8,(27*384)
		dc.w	$8,(26*384)
		dc.w	$8,(25*384)
		dc.w	$8,(24*384)
		dc.w	$8,(23*384)
		dc.w	$8,(22*384)
		dc.w	$8,(21*384)
		dc.w	$8,(20*384)
		dc.w	$0008,(19*384)
		dc.w	$0008,(18*384)
		dc.w	$0008,(17*384)
		dc.w	$0008,(16*384)
		dc.w	$0008,(15*384)
		dc.w	$0008,(14*384)
		dc.w	$0008,(13*384)
		dc.w	$0008,(12*384)
		dc.w	$0008,(11*384)
		dc.w	$0008,(10*384)
		dc.w	$0008,(9*384)
		dc.w	$0008,(8*384)
		dc.w	$0008,(7*384)
		dc.w	$0008,(6*384)
		dc.w	$0008,(5*384)
		dc.w	$0008,(4*384)
		dc.w	$0008,(3*384)
		dc.w	$0008,(2*384)
		dc.w	$0008,(384)
gid_dot_table_end



present_rout	dc.l	null
present_rout_pos	dc.l	rout1
rout1		dc.l	null,100
		dc.l	make_poverty_pal,1
		dc.l	enable_text,1
		dc.l	text_printer,210
		dc.l	put_pov_below,1
		dc.l	move_scrn_up,250-96-40
		dc.l	clear_text,1
		dc.l	enable_text,1
		dc.l	text_printer,212
		dc.l	null,400
		dc.l	move_scrn_up,80
		dc.l	clear_text,1
		dc.l	make_gid_pal,1
		dc.l	put_gid_below,1
		dc.l	move_scrn_up,250-96-40
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
		dc.l	put_credits_below,1
		dc.l	make_credits_pal,1
		dc.l	move_scrn_up,250-96-40
		dc.l	clear_text,1
		dc.l	enable_text,1
		dc.l	text_printer,210
		dc.l	null,400
		dc.l	move_scrn_up,80
		dc.l	put_pac_below,1
		dc.l	make_pacman_pal,1
		dc.l	move_scrn_up,250-96-40
		dc.l	clear_text,1
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
		dc.l	null,2000
		dc.l	0,0




;NOTE:   THE ROUTINE SUPPORTS TAB!!!
ascii_pos	dc.l	ascii
;                123456789012345678901234567890123456789
ascii	dc.b	13,13,13
	dc.b	"   'POVERTY' OR OZ SLIDESHOW 3",13
	dc.b	"   ---------------------------",13,13
	dc.b	"             CREDITS",13
	dc.b	"             -------",13,13
	dc.b	15

	dc.b	13,13,13
	dc.b	"              PART 1",13,13
	dc.b	"      CODED BY MAC SYS DATA",13,13
	dc.b	"          ART BY OZ/MSD",13,13
	dc.b	"      MUSIC RIPPED FROM AMIGA",13
	dc.b	15

;                123456789012345678901234567890123456789
	dc.b	13,13,13
	dc.b	"              PART 2",13,13
	dc.b	"      CODED BY MAC SYS DATA",13,13
	dc.b	"            ART BY OZ",13,13
	dc.b	"           MUSIC BY OZ",13
	dc.b	15

;                123456789012345678901234567890123456789
	dc.b	13,13,13
	dc.b	"         PART 3 (CREDITS)",13,13
	dc.b	"      CODED BY MAC SYS DATA",13,13
	dc.b	"            ART BY OZ",13,13
	dc.b	"         MUSIC BY UNKNOWN",13
	dc.b	15

;                123456789012345678901234567890
	dc.b	13,13,13
	DC.B	"         QUICK GREETS TO...",13,13
	DC.B	"            ADRENALIN",13
	DC.B	"               DEL",13
	DC.B	"             DR SYNE",13
	DC.B	"     GEORGE (BART) AT TOWER PD",13
	DC.B	"             MUG UK",13
	DC.B	"           PURE ENERGY",13
	dc.b	15

	dc.b	13,13,13
	dc.b	"     PERSISTENCE OF VISION",13,13
	dc.b	"    WILL RETURN IN THE YEAR",13
	dc.b	"            OF 1995",13
	dc.b	"    WITH MORE COMPILATIONS.",13,13,13,13
	dc.b	"         RELEASE DATE:",13,13
	dc.b	"          25-DEC-1994",13
	dc.b	15

	dc.b	-1		;end of text in pages....
		even

font	incbin	8X8_comp.FNT

raster_cols
	dc.l	$00000004,$00000008,$0000000c,$00000010
	dc.l	$00000014,$00000018,$0000001c,$00000020
	dc.l	$00000024,$00000028,$0000002c,$00000030
	dc.l	$00000034,$00000038,$0000003c,$00000040
	dc.l	$00000044,$00000048,$0000004c,$00000050
	dc.l	$00000054,$00000058,$0000005c,$00000060
	dc.l	$00000064,$00000068,$0000006c,$00000070
	dc.l	$00000074,$00000078,$0000007c,$00000080
	dc.l	$00000084,$00000088,$0000008c,$00000090
	dc.l	$00000094,$00000098,$0000009c,$000000a0
	dc.l	$000000a4,$000000a8,$000000ac,$000000b0
	dc.l	$000000b4,$000000b8,$000000bc,$000000c0
	dc.l	$000000c4,$000000c8,$000000cc,$000000d0
	dc.l	$000000d4,$000000d8,$000000dc,$000000e0

	dc.l	$040000e0,$080000e0,$0c0000e0,$100000e0
	dc.l	$140000e0,$180000e0,$1c0000e0,$200000e0
	dc.l	$240000e0,$280000e0,$2c0000e0,$300000e0
	dc.l	$340000e0,$380000e0,$3c0000e0,$400000e0
	dc.l	$440000e0,$480000e0,$4c0000e0,$500000e0
	dc.l	$540000dc,$580000d8,$5c0000d4,$600000d0
	dc.l	$640000cc,$680000c8,$6c0000c4,$700000c0
	dc.l	$740000bc,$780000b8,$7c0000b4,$800000b0
	dc.l	$840000ac,$880000a8,$880000a4,$880000a0
	dc.l	$8c00009c,$88000098,$84000094,$80000090
	dc.l	$7c00008c,$78000088,$74000084,$70000080
	dc.l	$6c00007c,$68000078,$64000074,$60000070
	dc.l	$5c00006c,$58000068,$54000064,$50000060
	dc.l	$4c00005c,$48000058,$44000054,$40000050
	dc.l	$3c00004c,$38000048,$34000044,$30000040
	dc.l	$2c00003c,$28000038,$24000034,$20000030
	dc.l	$1c00002c,$18000028,$14000024,$10000020
	dc.l	$0c00001c,$08000018,$04000014,$00000010



*******************
   SECTION BSS
*******************
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
main_pal	ds.l	16
oz_gid_pal	ds.l	16
poverty_pal	ds.l	16
pacman_pal	ds.l	16
credits_pal	ds.l	16
theend_pal	ds.l	16

		even
oldpal		ds.w	16
org_overscanbtm	ds.w	1
old_timerb	ds.l	1
old_vbl		ds.l	1
a09		ds.b	1
a07		ds.b	1
a13		ds.b	1
		even
key		ds.w	1
old_kbd		ds.l	1
vsync_flag	ds.w	1
old_falcon_speaker	ds.w	1
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

screens		ds.b	384*240
		ds.b	384*60

bssend
stop
