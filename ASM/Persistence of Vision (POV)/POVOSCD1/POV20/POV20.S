




;-------------------------------------------------------------------------;
;       The following source code and art have been released by           ;
;       PERSISTENCE OF VISION for use by others for NON-Profit            ;
;   making purposes only. The code is supplied as is and no claim can     ;
;    be made against PERSISTENCE OF VISION for loses incured through      ;
;                    the use and/or missuse of it.                        ;
;                                                                         ;
;          All soundtracks are copyright of the original authors          ;
;-------------------------------------------------------------------------;
;
;                       This code was released on
;                         Persistence Of Vision
;                      Official Source Code Disc 1

*************************
* POV 20                *
*************************

BUFFER_SIZE:	EQU	160*24+(32*24)
WIDTH:		EQU	32

	move.l	sp,a5
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
	add.l	#12,sp		;okay that's it memory free & allocated


*** Clear bss as most packers don't
		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
clear_bss	clr.b	(a0)+
		sub.l	#1,d0
		bne.s	clear_bss

		bsr	set_super
wait_for_drive	move.w	$ff8604,d0
		btst	#7,d0
		bne.s	wait_for_drive

		move.l	#screen,d0
		clr.b	d0
		move.l	d0,new_base

		bsr	hide_cursor
		bsr	save_pal
		bsr	get_base
		move.l	new_base,a0	;screen_base
		bsr	set_low_rez
		bsr	set_palette
		bsr	transfer
		bsr	set_up_for_border

;************************************************************************
;*                          SUPER STUNTMAN				*
;*                          --------------				*
;* Stolen by: MAC SYS DATA of P.O.V. 05/09/89 20:30			*
;*									*
;* Include files:-							*
;*                 AUTO117.IMG into TUNE				*
;************************************************************************
	move.b	$484,old484
	move.b	#2,$484		;off with keyclick/bell

;****************************************************************
; There is more than one tune in this code....
; 0=AUTOMATION 117
; 1=Jingle
; 2=Jingle
	move.l	#0,D0
	jsr	tune

	bsr	show_hertz

	move.w	#$ffff,horiz_sync
main_loop:
	tst.w	horiz_sync
	bne	main_loop
;	move.w	#$070,$ffff8240.w
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	scroll
	bsr	show_buffer
;	move.w	pic+2,$ffff8240.w
	MOVE.W	#$FFFF,horiz_sync
	move.b	$fffc02,d0
	cmp.b	#01,d0		;escape
	beq	exit

	cmp.b	#$b,d0		;0 key
	bne.s	not_zero
	tst.w	zero_counter
	bne.s	aa
	eor.w	#$111,pic+2
	eor.w	#$ffff,toggle
	bsr.s	show_hertz
	move.w	#10,zero_counter
	bra	main_loop

show_hertz:
	tst.w	toggle
	bne.s	not_50
	pea	in50
	bra.s	print
not_50:	pea	in60
print:	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

zero_counter:	dc.w	0
not_zero:
	tst.w	zero_counter
	beq.s	car
aa:	sub.w	#1,zero_counter

car:	cmp.b	#2,d0		;1 key
	blt	main_loop
	cmp.b	#5,d0		;4 key
	bge	main_loop

	move.l	d0,-(sp)
	bsr	isr_off
	move.l	old_base,a0	;screen_base
	bsr	set_low_rez
	move.l	(sp)+,d0

	move.b	old484,$484
;key is in D0.L
	and.l	#$ff,d0
	cmp.b	#4,d0	;3 key
	beq.s	run_info
	lea	filenames,a6
	sub.b	#2,d0
	mulu	#14,d0
	add.w	d0,a6

	tst.w	toggle
	beq.s	hz50
	eor.b	#2,$ff820a
hz50:
	bsr	black_pal
; poke filename to screen
	move.l	old_base,a0
	add.w	#160*199,a0
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	move.l	(a6)+,(a0)+
	bsr	user_mode
	clr.w	-(sp)		;to AUTORUN in AUTO folder
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp

run_info:
	tst.w	toggle
	beq.s	hz50i
	eor.b	#2,$ff820a
hz50i:
	pea	0
	pea	be
	pea	info
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	clr.w	-(sp)
	trap	#1
	
exit:	bsr	isr_off
	move.b	old484,$484
;reset rez
	move.l	old_base,a0
	bsr	set_med_rez

	bsr	restore_pal
	bsr	show_cursor
	bsr	user_mode
	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

***************
* SUBROUTINES *
***************
scroll	move.l	line_ptr,a6
	cmp.b	#$ff,(a6)
	bne	loop3
	lea	scroll_line,a6	;restart message
	move.l	a6,line_ptr
loop3	tst.w	scroll_number
	bne	loop2
	move.w	#WIDTH,scroll_number
	clr.l	d0
	move.b	(a6)+,d0	;get letter
	move.l	a6,line_ptr
	cmp.b	#32,d0
	beq.s	space
	cmp.b	#"a",d0
	bge.s	letter
	cmp.b	#"!",d0
	beq.s	exclaim
	cmp.b	#".",d0
	beq.s	fullstop
	cmp.b	#"'",d0
	beq.s	invert
	cmp.b	#",",d0
	beq.s	comma
	cmp.b	#"?",d0
	beq.s	question
	cmp.b	#"2",d0
	beq.s	n2
	cmp.b	#"0",d0
	beq.s	n0
letter:
	sub.w	#65,d0	;NOT ASCII BOUND - A=65, B=66, C=67
	mulu	#16*24,d0
	lea	font_set,a6
	add.l	d0,a6	;letter address is in a6
	bra.s	put
n0:	lea	font+384*41,a6
	bra.s	put
n2:	lea	font+384*43,a6
	bra.s	put
fullstop:
	lea	font+384*39,a6
	bra.s	put
exclaim:
	lea	font+384*35,a6
	bra.s	put
invert:
	lea	font+384*31,a6
	bra.s	put
question:
	lea	font+384*36,a6
	bra.s	put
comma:
	lea	font+384*37,a6
	bra.s	put
space:	lea	font,a6
;transfer letter into buffer
; each line in buffer is 160+16 bytes long.
put:	move.w	#24-1,d0
	lea	buffer+160,a1
put2:	movem.l	(a6),d2/d3/d4/d5
	movem.l	d2/d3/d4/d5,(a1)
	add.w	#16,a6
	add.w	#160+16,a1
	dbf	d0,put2

loop2:
	lea	buffer,a5	;scroll buffer
	move.l	a5,a4
	move.w	#3-1,d1
planes:	
	move.w	#24-1,d0
loopy:
	roxl	168(a5)
	roxl	160(a5)
	roxl	152(a5)
	roxl	144(a5)
	roxl	136(a5)
	roxl	128(a5)
	roxl	120(a5)
	roxl	112(a5)
	roxl	104(a5)
	roxl	96(a5)
	roxl	88(a5)
	roxl	80(a5)
	roxl	72(a5)
	roxl	64(a5)
	roxl	56(a5)
	roxl	48(a5)
	roxl	40(a5)
	roxl	32(a5)
	roxl	24(a5)
	roxl	16(a5)
	roxl	8(a5)
	roxl	(a5)

	add.w	#160+16,a5
	dbf	d0,loopy
	addq.w	#2,a4	;next plane
	move.l	a4,a5
	dbf	d1,planes
	sub.w	#1,scroll_number
	rts


show_buffer:	;puts scrolline buffer to screen
	lea	buffer,a0
	move.l	new_base,a1
	add.l	#32320,a1
	move.w	#24-1,d0
.loop:
	move.l	(a0),(a1)
	move.w	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.w	12(a0),12(a1)
	move.l	16(a0),16(a1)
	move.w	20(a0),20(a1)
	move.l	24(a0),24(a1)
	move.w	28(a0),28(a1)
	move.l	32(a0),32(a1)
	move.w	36(a0),36(a1)
	move.l	40(a0),40(a1)
	move.w	44(a0),44(a1)
	move.l	48(a0),48(a1)
	move.w	52(a0),52(a1)
	move.l	56(a0),56(a1)
	move.w	60(a0),60(a1)
	move.l	64(a0),64(a1)
	move.w	68(a0),68(a1)
	move.l	72(a0),72(a1)
	move.w	76(a0),76(a1)
	move.l	80(a0),80(a1)
	move.w	84(a0),84(a1)
	move.l	88(a0),88(a1)
	move.w	92(a0),92(a1)
	move.l	96(a0),96(a1)
	move.w	100(a0),100(a1)
	move.l	104(a0),104(a1)
	move.w	108(a0),108(a1)
	move.l	112(a0),112(a1)
	move.w	116(a0),116(a1)
	move.l	120(a0),120(a1)
	move.w	124(a0),124(a1)
	move.l	128(a0),128(a1)
	move.w	132(a0),132(a1)
	move.l	136(a0),136(a1)
	move.w	140(a0),140(a1)
	move.l	144(a0),144(a1)
	move.w	148(a0),148(a1)
	move.l	152(a0),152(a1)
	move.w	156(a0),156(a1)
	add.w	#160,a1
	add.w	#160+16,a0
	dbf	d0,.loop
	rts


*************************************
* INTERRUPT SERVICE ROUTINES (ISRs) *
*************************************
new_vbl	;$70

	movem.l	d0-a6,-(sp)

	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr.b	$fffffa1b.w
	move.l	#new_timerb,$120.W
	clr.w	horiz_sync
	jsr	tune+$e
;flash the disc drive light
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d7
	cmp.b	#15,d7
	blt.s	no_flash
	move.b	#14,$ffff8800.w
	bclr	#1,$ffff8802.w
	movem.l (sp)+,d0-a6
	clr.b	$fffffa1b.w
	MOVE.B	#199,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	rte
no_flash:
	move.b	#14,$ffff8800.w
	or.b	#%00000010,$ffff8802.w
	movem.l (sp)+,d0-a6
	clr.b	$fffffa1b.w
	MOVE.B	#199,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	rte


new_timerb:	;$120
		clr.b	$fffffa1b.w
		move.l	d0,-(sp)
		REPT	50
		nop
		ENDR
		moveq	#0,d0
.loop		cmp.b	$ffff8209.w,d0
		bne.s	.loop
		CLR.B	$FFFF820A.W
		REPT	22
		nop
		ENDR
		MOVE.B	#2,$FFFF820A.W
		move.l	#$02250447,$ffff8242.w
		move.l	#$01140336,$ffff8246.w
		move.l	(sp)+,d0
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
	MOVE.L	#new_timerb,$120.W

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



set_super:
	clr.l	-(sp)		;set supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	rts

transfer:
	move.l	new_base,a0
	add.w	#32000,a0
	lea	pic+34,a1
	add.w	#32000,a1
line	move.l	new_base,a2
	lea	-160(a1),a1
	cmp.l	#pic,a1		;are we at top of the pic?
	ble.s	transfer_done
build_line:
	movem.l	(a1)+,d0-d7
	bsr.s	move_block
	movem.l	(a1)+,D0-d7
	bsr.s	move_block
	movem.l	(a1)+,D0-d7
	bsr.s	move_block
	movem.l	(a1)+,D0-d7
	bsr.s	move_block
	movem.l	(a1)+,D0-d7
	bsr.s	move_block
	lea	-160(a1),a1
	cmp.l	a0,a2
	bne.s	build_line
	lea	-160(a0),a0
	bra.s	line
move_block:
	movem.l	d0-d7,(a2)
	lea	$20(a2),a2
	moveq	#3,d0
t_wait:	dbf	d0,t_wait
	rts
transfer_done:
	rts

pause:	move.w	d0,-(sp)
	move.w	#1000,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
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

black_pal
	lea	$ffff8240.w,a0
	move.w	#8-1,d0
.loop:	clr.l	(a0)+
	dbf	d0,.loop
	rts

get_base	move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,old_base
		rts

set_med_rez
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
	dc.w	$f00,$780,$f10,$790,$f20,$7A0,$f30,$7B0
	dc.w	$f40,$7C0,$f50,$7D0,$f60,$7E0,$f70,$7F0
	dc.w	$eF0,$670,$dF0,$570,$cF0,$470,$bF0,$370
	dc.w	$aF0,$270,$9F0,$170,$8F0,$070,$0F1,$078
	dc.w	$0F2,$079,$0F3,$07A,$0F4,$07B,$0F5,$07C
	dc.w	$0F6,$07D,$0F7,$07E,$0E7,$06F,$0D7,$05F
	dc.w	$0C7,$04F,$0B7,$03F,$0A7,$02F,$097,$01F
	dc.w	$087,$00F,$806,$10E,$905,$20D,$A04,$30C
	dc.w	$B03,$40B,$C02,$50A,$D01,$609
	dc.w	$ffff
	dc.w	$f00,$780,$f10,$790,$f20,$7A0,$f30,$7B0
	dc.w	$f40,$7C0,$f50,$7D0,$f60,$7E0,$f70,$7F0
	dc.w	$eF0,$670,$dF0,$570,$cF0,$470,$bF0,$370
	dc.w	$aF0,$270,$9F0,$170,$8F0,$070,$0F1,$071
	dc.w	$0F2,$072,$0F3,$073,$0F4,$074,$0F5,$075


toggle:	dc.w	0	;50 hertz
	even
line_ptr	dc.l	scroll_line

scroll_line:
 dc.b "MAC SYS DATA PRESENTS "
 dc.b "DISC 20.  "
 dc.b "ALL CODE AND GRAFIX BY "
 dc.b "MAC SYS DATA.   "
 dc.b "MUSIC STOLEN FROM SUPER STUNT MAN BY MAC SYS DATA.      "
 DC.B "WELL HERE WE ARE AGAIN WITH SOME MORE PACKED DEMOS ON OUR "
 DC.B "20TH DISC.  ON THIS ONE IS THE FIRST EVER PACKED STE ONLY DEMO, "
 DC.B "IT WAS WRITTEN BY THE OVERLANDERS AND IS RATHER SIMPLE BUT IT "
 DC.B "DOES SHOW OFF THE STE'S DMA SOUND AND HARDWARE SCROLLING.    "
 DC.B "      BYE...     "
 DC.B "                                            "
	dc.b	$ff,$ff,$ff,$ff
	even
in50:	dc.b	27,'Y86',"50 Hertz PAL ",0
	even
in60:	dc.b	27,'Y86',"60 Hertz NTSC",0
	even

font	dcb.b	384,0	;one chars length
font_set:
	incbin	"32x24.fnt"
	even
pic	incbin	"pov20.PI1"
	even
tune:	incbin	"auto117.img"
	even
filenames:
	dc.b	"ALF.MSD",0,0,0,0,0,0,0
	dc.b	"STE_ACID.MSD",0,0
info:	dc.b	"INFO20.POV",0,0,0,0
	even


	SECTION BSS
bssstart

horiz_sync	ds.w	1
old_base	ds.l	1

scroll_number	ds.w	1

stack_save	ds.l	1
old70		ds.l	1
old120	 	ds.l	1
olda07		ds.l	1
olda09		ds.b	1
olda17		ds.b	1
olda1b		ds.b	1
olda21		ds.b	1
old484		ds.b	1
	even

old_pal		ds.b	32
buffer	 ds.b	BUFFER_SIZE
be

new_base	ds.l	1
	ds.b	256
screen	ds.b	32000+160*32
bssend