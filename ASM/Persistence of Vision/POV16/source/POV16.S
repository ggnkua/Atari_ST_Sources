




;-------------------------------------------------------------------------;
;       The following source code and art have been released by           ;
;       PERSISTENCE OF VISION for use by others for NON-Profit            ;
;   making purposes only. The code is supplied as is and no claim can     ;
;    be made against PERSISTENCE OF VISION for loses incured through      ;
;                    the use and/or missuse of it.                        ;
;                                                                         ;
;          All soundtracks are copyright of the original authors          ;
;-------------------------------------------------------------------------;





*************************
* POV 16		*
*************************

BUFFER_SIZE	EQU	42*18
WIDTH		EQU	16

start	move.l	sp,a5
	move.l	4(a5),a5
	move.l	$C(a5),d0
	add.l	$14(a5),d0
	add.l	$1C(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp	 ;okay that's it memory free & allocated

		bsr	set_super
wait_for_drive	tst.w	$43e
		bne.s	wait_for_drive

		bsr	hide_cursor
		bsr	save_pal
		bsr	set_palette
		bsr	get_base

*** SCREEN CALCULATION CODE UPDATED TO PRESENT SYSTEM 27/12/93 by MSD
		move.l	#screen,d0
		clr.b	d0
		move.l	d0,new_base

		move.l	new_base,a0	;screen_base
		bsr	set_low_rez
		bsr	clear_lower_border
		bsr	set_up_for_border

;************************************************************************
;*			 F.O.F.T.					*
;*			 -------					*
;* Stolen by: MAC SYS DATA of P.O.V. 17/3/90 11:45			*
;*      From: F.O.F.T. 35						*
;* Include files:-							*
;*		FOFT.IMG into TUNE					*
;************************************************************************
	move.b	#2,$484	;off with keyclick/bell

;****************************************************************
; There is more than one tune in this code....
; 0=tune 0 - FOFT 35 the only proper tune
; 1=tune 1
; 2=tune 2
; 3=tune 3
	clr.l	d0
	jsr	tune
	bsr	transfer
	bsr	steal_pov_logo

	move.w	#$ffff,horiz_sync
main_loop:
	tst.w	horiz_sync
	bne	main_loop
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	show_buffer
	bsr	clear_pov_area
	bsr	animate_pov

	MOVE.W	#$FFFF,horiz_sync
	move.b	$fffc02,d0
	cmp.b	#01,d0	 ;escape
	beq	exit

	cmp.b	#$b,d0	 ;0 key
	bne.s	not_zero

	tst.w	zero_counter
	bne.s	aa
	eor.w	#$111,pic+2
	move.w	#10,zero_counter
	eor.w	#$ffff,hertz
	bra	main_loop
zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter
car:	cmp.b	#2,d0	  ;1 key
	blt	main_loop
	cmp.b	#5,d0	  ;4 key
	bge	main_loop

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

;key is in D0.L
	and.l	#$ff,d0
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	tst.w	hertz
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	clr.w	$ffff8240.w
	move.w	#$fff,$ffff825e.w
	bsr	user_mode
	move.l	#0,-(sp)
	pea	laddr
	move.l	a6,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	bsr	set_super
pop:	move.w	$116,$ff8240
	nop
	nop
	bra.s	pop
exit:
	bsr	isr_off

;reset rez
	move.l	old_base,a0
	bsr	set_med_rez
;	bsr	set_low_rez

	bsr	restore_pal
	bsr	show_cursor
	bsr	user_mode
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

***************************
* CUSTOM SUPPORT ROUTINES *
***************************
animate_pov:
	move.l	new_base,a1
	add.l	#160*147+88,a1
	move.l	animation_position,a0
	cmp.w	#$ffff,(a0)
	bne.s	no_animation_reset
	move.l	#animation_table,a0
	move.l	a0,animation_position
no_animation_reset:
	move.w	(a0),d0
	and.l	#$ffff,d0
	add.l	d0,a1
	lea	pov_logo,a0
	move.w	#14-1,d0
.loop:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	add.l	#160-72,a1
	dbf	d0,.loop
	add.l	#2,animation_position
	rts

clear_pov_area:
	move.l	new_base,a0
	add.l	#160*147+88,a0
	clr.l	d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	d6,a1	
	move.l	a1,a2
	move.w	#50-1,d7
.loop:
	movem.l d0-d6/a1/a2,(a0)
	add.l	#36,a0
	movem.l d0-d6/a1/a2,(a0)
	add.l	#160-36,a0
	dbf	d7,.loop
	rts

***************
* SUBROUTINES *
***************
scroll: move.l	line_ptr,a6
	cmp.b	#$ff,(a6)
	bne	loop3
	lea	scroll_line,a6  ;restart message
	move.l	a6,line_ptr
loop3
	tst.w	scroll_number
	bne	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
	move.b	(a6)+,d0
	move.l	a6,line_ptr
	sub.w	#32,d0
	lsl.w	#5,d0	;*32 (1 plane char set)
	lea	font,a6
	add.l	d0,a6	;letter address is in a6
;transfer letter into buffer
; each line in buffer is 42 bytes long.
	lea	buffer+42,a1
	move.w	(a6)+,40(a1)
	move.w	(a6)+,82(a1)
	move.w	(a6)+,124(a1)
	move.w	(a6)+,166(a1)
	move.w	(a6)+,208(a1)
	move.w	(a6)+,250(a1)
	move.w	(a6)+,292(a1)
	move.w	(a6)+,334(a1)
	move.w	(a6)+,376(a1)
	move.w	(a6)+,418(a1)
	move.w	(a6)+,460(a1)
	move.w	(a6)+,502(a1)
	move.w	(a6)+,544(a1)
	move.w	(a6)+,586(a1)
	move.w	(a6)+,628(a1)
	move.w	(a6),670(a1)	;32 bytes per char

loop2:
	lea	buffer+42,a5	;scroll buffer
	move.w	#16-1,d0
loopy:
	roxl	40(a5)
	roxl	38(a5)
	roxl	36(a5)
	roxl	34(a5)
	roxl	32(a5)
	roxl	30(a5)
	roxl	28(a5)
	roxl	26(a5)
	roxl	24(a5)
	roxl	22(a5)
	roxl	20(a5)
	roxl	18(a5)
	roxl	16(a5)
	roxl	14(a5)
	roxl	12(a5)
	roxl	10(a5)
	roxl	8(a5)
	roxl	6(a5)
	roxl	4(a5)
	roxl	2(a5)
	roxl	(a5)

	add.w	#42,a5
	dbf	d0,loopy
	sub.w	#1,scroll_number
	rts

show_buffer:	;puts scrolline buffer to screen
	lea	buffer,a0
	move.l	new_base,a1
	add.w	#32000+320,a1
	move.w	#16-1,d7
.loop:
	move.w	(a0)+,(a1)
	move.w	(a0)+,8(a1)
	move.w	(a0)+,16(a1)
	move.w	(a0)+,24(a1)
	move.w	(a0)+,32(a1)
	move.w	(a0)+,40(a1)
	move.w	(a0)+,48(a1)
	move.w	(a0)+,56(a1)
	move.w	(a0)+,64(a1)
	move.w	(a0)+,72(a1)
	move.w	(a0)+,80(a1)
	move.w	(a0)+,88(a1)
	move.w	(a0)+,96(a1)
	move.w	(a0)+,104(a1)
	move.w	(a0)+,112(a1)
	move.w	(a0)+,120(a1)
	move.w	(a0)+,128(a1)
	move.w	(a0)+,136(a1)
	move.w	(a0)+,144(a1)
	move.w	(a0)+,152(a1)
	add.w	#2,a0
	add.w	#160,a1
	dbf	d7,.loop
	rts



*************************************
* INTERRUPT SERVICE ROUTINES (ISRs) *
*************************************
new_vbl:	;$70

	MOVEM.L d0-a6,-(A7)
	MOVEM.L pic+2(PC),d0-d7
	MOVEM.L d0-d7,$FFFF8240.W

	move.l	a0,d0
	move.l	pal_position,a0
	cmp.w	#$ffff,(a0)
	bne.s	no_colour_reset
	move.l	#pal_table,pal_position
no_colour_reset	move.l	d0,a0
		clr.b	$fffffa1b.w
		MOVE.L	#horiz_isr,$120.W
		clr.w	horiz_sync

		jsr	tune+$1f0
;flash the disc drive light
		move.b	#10,$ff8800
		move.b	$ff8800,d7
		cmp.b	#13,d7
		blt.s	no_flash
		move.b	#14,$ff8800
		bclr	#1,$ff8802

		movem.l (sp)+,d0-a6
		MOVE.B	#199,$FFFFFA21.W
		MOVE.B	#8,$FFFFFA1B.W
		rte
no_flash	move.b	#14,$ff8800
		or.b	#%00000010,$ff8802
		movem.l (sp)+,d0-a6
		MOVE.B	#199,$FFFFFA21.W
		MOVE.B	#8,$FFFFFA1B.W
		rte

horiz_isr:	;$120
		clr.b	$fffffa1b.w
		move.l	d0,-(sp)
		rept	50
		nop
		endr
		moveq	#0,d0
.loop		cmp.b	$ffff8209.w,d0
		bne.s	.loop
		CLR.B	$FFFF820A.W
		rept	22
		nop
		endr
		MOVE.B	#2,$FFFF820A.W

		move.l	d1,-(sp)
		move.l	a0,-(sp)
		move.l	pal_position,a0
		move.w	#20-1,d0
col_loop	move.w	(a0)+,d1
		cmp.w	#$ffff,d1
		bne.s	ad
		move.w	(a0)+,d1
ad:		move.w	d1,$ffff8242.w
		rept	115
		nop
		endr
		dbf	d0,col_loop
		move.l	(sp)+,a0
		move.l	(sp)+,d1
		move.l	(sp)+,d0
		add.l	#2,pal_position
		clr.w	$ffff8242.w
		rte

********************
* SERVICE ROUTINES *
********************

set_up_for_border:
	ori.w	#$700,sr
	move.l	$70,old70
	move.l	$120,old120
	move.b	$fffffa07,olda07
	move.b	$fffffa09,olda09
	move.b	$fffffa17,olda17
	move.b	$fffffa1b,olda1b
	move.b	$fffffa21,olda21

	MOVE.L	#new_vbl,$70.W
	MOVE.L	#horiz_isr,$120.W

	MOVE.B	#1,$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	BCLR	#0,$FFFFFA0F.W
	BSET	#0,$FFFFFA13.W
	BCLR	#3,$FFFFFA17.W
	CLR.B	$FFFFFA1B.W
	CLR.B	$FFFFFA21.W
	MOVE.W	#$2300,SR
	rts

isr_off:
	ORI.W	#$700,SR
	CLR.B	$FFFF8260.W
	move.l	old120,$120
	move.l	old70,$70

	MOVE.B	olda07,$FFFFFA07
	MOVE.B	olda09,$FFFFFA09
	MOVE.B	olda17,$FFFFFA17
	move.b	olda1b,$fffffa1b
	move.b	olda21,$fffffa21

	MOVE.W	#$2300,SR

endmusic:
	lea	$ff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


clear_lower_border:
	move.l	new_base,a0
	add.l	#32000,a0
	move.w	#45-1,d0
clr_:	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbf	d0,clr_
	rts

steal_pov_logo:
	lea	pov_logo,a1
	move.l	new_base,a0
	lea	160*147+88(a0),a0
	move.w	#14-1,d0
.loop:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	add.w	#160-72,a0
	dbf	d0,.loop
	rts

set_super:
	clr.l	-(sp)	  ;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

transfer:
	lea	pic+34,a0
	move.l	new_base,a1
	move.l	a1,a3
	add.l	#32000-160,a3
	lea	pic+34+(160*199),a2
	move.w	#100-1,d0
.loop:
	movem.l	(a0),d1/d2/d3/d4/d5/d6/d7/a4/a5/a6
	movem.l	d1-d7/a4-a6,(a1)
	add.w	#40,a0
	add.w	#40,a1
	movem.l	(a0),d1/d2/d3/d4/d5/d6/d7/a4/a5/a6
	movem.l	d1-d7/a4-a6,(a1)
	add.w	#40,a0
	add.w	#40,a1
	movem.l	(a0),d1/d2/d3/d4/d5/d6/d7/a4/a5/a6
	movem.l	d1-d7/a4-a6,(a1)
	add.w	#40,a0
	add.w	#40,a1
	movem.l	(a0),d1/d2/d3/d4/d5/d6/d7/a4/a5/a6
	movem.l	d1-d7/a4-a6,(a1)
	add.w	#40,a0
	add.w	#40,a1
	add.w	#160,a0
	add.w	#160,a1

	movem.l	(a2),d1/d2/d3/d4/d5/d6/d7/a4/a5/a6
	movem.l	d1-d7/a4-a6,(a3)
	add.w	#40,a2
	add.w	#40,a3
	movem.l	(a2),d1/d2/d3/d4/d5/d6/d7/a4/a5/a6
	movem.l	d1-d7/a4-a6,(a3)
	add.w	#40,a2
	add.w	#40,a3
	movem.l	(a2),d1/d2/d3/d4/d5/d6/d7/a4/a5/a6
	movem.l	d1-d7/a4-a6,(a3)
	add.w	#40,a2
	add.w	#40,a3
	movem.l	(a2),d1/d2/d3/d4/d5/d6/d7/a4/a5/a6
	movem.l	d1-d7/a4-a6,(a3)
	add.w	#40,a2
	add.w	#40,a3
	sub.w	#160*3,a2
	sub.w	#160*3,a3

	bsr	pause
	dbf	d0,.loop
	rts

pause:	move.l	d0,-(sp)
	move.w	#10000,d0
pau:	nop
	dbf	d0,pau
	move.l	(sp)+,d0
	rts

user_mode:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

save_pal:
	lea	old_pal,a1
	lea	$ffff8240,a0
	move.w	#16-1,d0
save_p:
	move.w	(a0)+,(a1)+
	dbf	d0,save_p
	rts

restore_pal:
	lea	old_pal,a0
	bra.s	set_p

set_palette:
	lea	pic+2,a0
set_p:	lea	$ffff8240,a1
	move.w	#16-1,d0
set_pal:
	move.w	(a0)+,(a1)+
	dbf	d0,set_pal
	rts

get_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base
		rts

set_med_rez:
	move.w	#1,-(sp)
	bra.s	set_rez

set_low_rez:
	clr.w	-(sp)
set_rez:
	move.l	a0,-(sp)
	move.l	a0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

hide_cursor:
	pea	di_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

show_cursor:
	pea	ei_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp
	rts
ei_mouse:
	dc.b	$14,8
	even
di_mouse:
	dc.b	$12,$1a
	even

	ds.l	40

********
* Data *
********
	section data
pal_position:	dc.l	pal_table
pal_table:
	dc.w	$700,$700,$710,$710,$720,$720,$730,$730
	dc.w	$740,$740,$750,$750,$760,$760,$770,$770
	dc.w	$670,$670,$570,$570,$470,$470,$370,$370
	dc.w	$270,$270,$170,$170,$070,$070,$071,$071
	dc.w	$072,$072,$073,$073,$074,$074,$075,$075
	dc.w	$076,$076,$077,$077,$067,$067,$057,$057
	dc.w	$047,$047,$037,$037,$027,$027,$017,$017
	dc.w	$007,$007,$106,$106,$205,$205,$304,$304
	dc.w	$403,$403,$502,$502,$601,$601
	dc.w	$ffff

	dc.w	$700,$700,$710,$710,$720,$720,$730,$730
	dc.w	$740,$740,$750,$750,$760,$760,$770,$770
	dc.w	$670,$670,$570,$570,$470,$470,$370,$370
	dc.w	$270,$270,$170,$170,$070,$070,$071,$071
	dc.w	$072,$072,$073,$073,$074,$074,$075,$075


animation_position	dc.l	animation_table
animation_table		dc.w	0,0,160,160,320,480,640
			dc.w	800,1120,1440
			dc.w	1760,2080,2560,3040,3520,4000,4640,5280
			dc.w	5280+480
			dc.w	4640,4000,3520,3040,2560,2080,1760,1440,1120,800,640
			dc.w	480,320,160,160
			dc.w	$ffff
stack_save	dc.l	0
old70:	dc.l	0
old120: dc.l	0
olda07: dc.l	0
olda09: dc.b	0
olda17: dc.b	0
olda1b: dc.b	0
olda21: dc.b	0
	even
horiz_sync	dc.w	0
old_base	dc.l	0

scroll_number	dc.w	16
old_pal		ds.b	32
hertz		dc.w	0	;initially 50Hz
line_ptr	dc.l	scroll_line
buffer		dcb.b	BUFFER_SIZE,0

scroll_line:
 dc.b "   MAC SYS DATA PRESENTS - PERSISTENCE OF VISION 16.      CREDITS:   "
 dc.b "MENU CODED BY "
 dc.b "MAC SYS DATA,    GRAFIX BY ALY AND MAC SYS DATA,  "
 dc.b "    THE MUSIC IS FROM F.O.F.T.        MEMBERS OF P.O.V. ARE ;-     "
 dc.b "MAC SYS DATA,    BORIS,    DR.SYNE    AND ALY.        "
 dc.b "HI TO;-    ALAN R,  GEORGE,  BASHER,  VAPOUR,  NIEL OF COR BLIMEY AND "
 dc.b "THE LOST BOYS.       "
 DC.B "     IF YOU WISH TO COLLECT MORE PERSISTENCE "
 DC.B "OF VISION DISCS, THEY ARE AVAILABLE DIRECTLY FROM THE BLACKPOOL CLUB OR "
 dc.b "FROM PD LIBRARIES EVERYWHERE. "
 DC.B "  ----- IMPORTANT NEWS -----     COMING TO A SCREEN NEAR YOU "
 dc.b "SOON ...  P.O.V. 7!      "
 DC.B "THIS INTRO WAS CODED BY MAC SYS DATA ON 21-3-90, THE DISC WAS RELEASED "
 dc.b "ON 27-4-90, WE SHOULD MAKE DISC 20 BY MID MAY.      DISC 20 MAY BE A "
 dc.b "LITTLE DIFFERENT THAN OUR PREVIOUS ONES AND WILL INCLUDE AN INFO FILE. "
 dc.b "        WE ARE CONSTANTLY LOOKING FOR NEW DEMOS TO PUT ON OUR "
 DC.B "DISCS BUT LATELY THE SUPPLY HAS DRIED UP, AS A RESULT THE NEXT FEW "
 DC.B "DISCS WILL CONTAIN MORE LARGE SAMPLED SOUND DEMOS AND MORE ONE MEG "
 DC.B "PAMPUK SINGLE PARTED DEMOS. IF YOU WANT HALF MEG ONES, GET WRITING SOME. "
 DC.B " HERE ARE A FEW OF THE DEMOS I HAVE RECEIVED IN THE LAST WEEK... "
 DC.B " ASTERIX DEMO, STARWARS RAP (COMPLETED VERSION), "
 DC.B "SAS DEMO, BON JOVI DEMO (1 MEG) AND BORIS VALEGO PICTURE DEMO (60HZ ONLY). "
 DC.B "I HAVE ALREADY PACKED THE FOLLOWING - DEF DEMO, IVOR BIGGUN DEMO (1 MEG), "
 DC.B "SHINY BUBBLES (1 MEG), ART MACHINE DEMO (THIS MAY APPEAR ON POV 7, AS "
 DC.B "SOON AS BORIS FINISHES IT), CHARLIE CHAPLIN DEMO (THIS IS A JOKE OF A "
 DC.B "DEMO), FOREIGN AFFAIR AND TWO OXYGENE DEMOS.     "
 DC.B "I HAVE ALSO STARTED WORK ON THE CONSTELLATIONS DEMO AND SWEDISH NEW YEAR "
 DC.B "DEMO 1 (WHICH IS PROVING A BITCH TO HACK).      IF ANYBODY OUT THERE "
 DC.B "WITHOUT AN STE BUT WANTS TO SEE THE OFFICAL STE DEMO THEN GET HOLD OF THE "
 DC.B "CONSTELLATIONS DEMO. THE THIRD DEMO IS VIRTUALLY THE SAME, BUT ON AN STE "
 DC.B "THERE IS A 12.5KHZ SAMPLED SOUND PLAYING, A FEW MORE COLOURS AND A FONT "
 DC.B "THAT IS READABLE!      ANYWAY IF ALL YOU STE OWNERS WANT TO SEE THE "
 DC.B "OFFICAL DEMO, THEN KEEP A LOOK OUT FOR FUTURE P.O.V. DISCS 'COS I'VE HAVE "
 DC.B "A GO AT HACKING IT, BUT I CAN'T PROMISE ANYTHING.        "
 DC.B "                                 "
	dc.b	$ff,$ff,$ff,$ff
	even

font:
	incbin	"med_font.dat"
	even
pic	incbin	"pov16.PI1"
tune:	incbin	"35.IMG"
pov_logo	dcb.b	(72*14),0
filenames:
	dc.b	"SUCCESS.EXE",0,0,0
	dc.b	"RENDEZ.POV",0,0,0,0
	dc.b	"TEX3.MSD",0,0,0,0,0,0

	SECTION BSS
new_base	ds.l	1
laddr		ds.l	1
		ds.b	256
screen		ds.b	32000
		ds.b	160*20
