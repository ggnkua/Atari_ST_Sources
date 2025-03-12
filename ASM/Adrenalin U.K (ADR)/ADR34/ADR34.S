*************************************************************************
*				ADRENALIN 34				*
*				------------				*
*									*
* Coded by:	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Art by:	KID							*
*									*
*									*
* Music by:	??? ripped TCB mod					*
*									*
*									*
*************************************************************************


multinop	MACRO
		rept	\1
		nop
		endr
		ENDM

RTE		equ	$4E73
RTS		equ	$4E75



;***********************************************************************
begin		jmp	menu(pc)
run_me		tst.l	prg_name
		beq.s	clean_exit
		move.l	#null,a1
		sub.l	#run_me,a1
		add.l	#null-run_me,a1
		move.l	a1,-(sp)
		move.l	#begin-$100,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp
		pea	0.w
		pea	0.w
		move.l	prg_name(pc),-(sp)
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
clean_exit	clr.w	-(sp)
		trap	#1
		ds.l	128
prg_name	dc.l	0

prog1		dc.b	'PROG1.PRG',0
	even
prog2		dc.b	'PROG2.PRG',0
	even
prog3		dc.b	'PROG3.PRG',0
	even
prog4		dc.b	'PROG4.PRG',0
	even
prog5		dc.b	'PROG5.PRG',0
	even
prog6		dc.b	'PROG6.PRG',0
	even
prog7		dc.b	'PROG7.PRG',0
	even
prog8		dc.b	'PROG8.PRG',0
	even
prog9		dc.b	'PROG9.PRG',0
	even


null		dc.l	0


menu		pea	0.w
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save

		move	USP,a0
		move.l	a0,usp_save

		move.l	$ffff8200.w,base_save
		move.b	#2,$ffff820a.w		;50Hz

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,screen_base
		move.l	d0,a0
		lea	230*63+160(a0),a0
		move.l	a0,fid1+2

		lsr.l	#8,d0		;set screen base
		move.b	d0,screen_low
		lsr.l	#8,d0
		move.b	d0,screen_hi

		bsr	save_old
		bsr	clear_screen

		bsr	sort_pic

		lea	module,a0
		moveq	#-1,d0
		jsr	replay+$24

		move	#$2700,SR
		jsr	set_isr
		clr.w	vsync_flag
		move	#$2300,SR

main_loop	tst.w	vsync_flag
		beq.s	main_loop

		clr.w	vsync_flag
		clr.b	$ffff8260.w

		move.b	screen_hi(pc),$ffff8201.w
		move.b	screen_low(pc),$ffff8203.w

		movem.l	left+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		moveq	#0,d0		;low rez
		moveq	#2,d1		;high rez

		lea	$ffff8260.w,a0
		lea	$ffff820a.w,a1

		move.w	#20-1,d5
		move.w	#827-1,d4
no_top		dbf	d4,no_top

		clr.b	$fffffa19.w	;stop timera

		move	#$2100,SR
		stop	#$2100
		move	#$2300,SR
		move.w	#30-1,d4
.loop		dbf	d4,.loop

		move.b	#0,$ffff820a.w

		multinop	8

		move.b	#2,$ffff820a.w
		move.w	#RTS,replay+$894e

		moveq	#12,d2

wait_scrn	move.b	$ffff8209.w,d3		;wait for left of scrn
		beq.s	wait_scrn

		sub.b	d3,d2		;get into side border solidly
		rol.w	d2,d2
		jsr	replay+$8918
		multinop	26
top_side	multinop	9
		move.b	d1,(a0)		;rez fiddles for side border
		nop
		move.b	d0,(a0)
		jsr	replay+$8918
		multinop	25
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	25
		jsr	replay+$8918
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	89
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		dbf	d5,top_side

		moveq	#54-1,d5
		multinop	7
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		jsr	replay+$8918
		multinop	25
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	25
		jsr	replay+$8918
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)

make_pal	move.w	#0,$ffff8240.w	;DYNAMIC CODE *DO NOT ALTER*
		move.w	#0,$ffff8242.w
		move.w	#0,$ffff8244.w
		move.w	#0,$ffff8246.w
		move.w	#0,$ffff8248.w
		move.w	#0,$ffff824a.w
		move.w	#0,$ffff824c.w
		move.w	#0,$ffff824e.w
		move.w	#0,$ffff8250.w
		move.w	#0,$ffff8252.w
		move.w	#0,$ffff8254.w
		move.w	#0,$ffff8256.w
		move.w	#0,$ffff8258.w
		move.w	#0,$ffff825a.w
		move.w	#0,$ffff825c.w
		move.w	#0,$ffff825e.w

		multinop	25
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	3
main_no_sides	multinop	9
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		jsr	replay+$8918
		multinop	25
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	25
		jsr	replay+$8918
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	89
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		dbf	d5,main_no_sides

		moveq	#11,d5		;lower border code
		multinop	7
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		jsr	replay+$8918
		multinop	25
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	25
		jsr	replay+$8918
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	25
		jsr	replay+$8918
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		nop
		nop
		move.b	d0,(a1)
		multinop	8
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		move.b	d1,(a1)
		jsr	replay+$8918
		multinop	23
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12

border_no_sides	move.b	d1,(a0)		;main border loop
		nop
		move.b	d0,(a0)
		jsr	replay+$8918
		multinop	25
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	25
		jsr	replay+$8918
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	12
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	89
		move.b	d0,(a1)
		move.b	d1,(a1)
		multinop	13
		move.b	d1,(a0)
		nop
		move.b	d0,(a0)
		multinop	9
		dbf	d5,border_no_sides

		move.w	#RTE,replay+$894e	;fiddle TCB replay code
		move.b	#2,$fffffa19.w
		movem.l	a0-a1/d0-d5,-(sp)
		jsr	replay+$28
		movem.l	(sp)+,a0-a1/d0-d5


;* NOT USUAL POV CHECK AS WE ONLY HAVE A COUPLE OF REGISTERS LEFT
		cmp.b	#1,$fffffc02.w
		bne.s	key1
		clr.l	prg_name
		bra	stop

key1		cmp.b	#2,$fffffc02.w
		bne.s	key2
		move.l	#prog1,prg_name
		bra	stop

key2		cmp.b	#3,$fffffc02.w
		bne.s	key3
		move.l	#prog2,prg_name
		bra	stop

key3		cmp.b	#4,$fffffc02.w
		bne.s	key4
		move.l	#prog3,prg_name
		bra	stop

key4		cmp.b	#5,$fffffc02.w
		bne.s	key5
		move.l	#prog4,prg_name
		bra.s	stop

key5		cmp.b	#6,$fffffc02.w
		bne.s	key6
		move.l	#prog5,prg_name
		bra.s	stop

key6		cmp.b	#7,$fffffc02.w
		bne.s	key7
		move.l	#prog6,prg_name
		bra.s	stop

key7		cmp.b	#8,$fffffc02.w
		bne.s	key8
		move.l	#prog7,prg_name
		bra.s	stop

key8		cmp.b	#9,$fffffc02.w
		bne.s	key9
		move.l	#prog8,prg_name
		bra.s	stop

key9		cmp.b	#$a,$fffffc02.w
		bne	main_loop
		move.l	#prog9,prg_name


stop		move.w	#$2700,sr
		move.l	base_save,$ffff8200.w
		bsr	return_old
		bsr	clear_screen

		movem.l	org_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	usp_save(pc),a0
		move	a0,USP

flush		btst	#0,$fffffc00.w
		beq.s	clear
		move.b	$fffffc02.w,d0
		bra.s	flush

clear		move.w	#$2300,sr
		move.l	stack_save(pc),-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		bra	run_me

new_vbl		move.w	#1,vsync_flag
		move.w	#$2700,sr
		move.l	#null_rte,$68.w
		clr.b	$fffffa19.w
		move.b	#$18,$fffffa1f.w
		move.b	#2,$fffffa19.w
		move.w	#$2300,sr
		rte

null_rte	rte

save_old	move.b	$fffffa07.w,old_a07
		move.b	$fffffa09.w,old_a09
		move.b	$fffffa13.w,old_a13
		move.b	$fffffa15.w,old_a15
		move.b	$fffffa19.w,old_a19
		move.b	$fffffa1F.w,old_a1f
		move.l	$134.l,old_134
		move.l	$70.w,old_70
		move.l	$68.w,old_68
		move.l	$44e.w,old_scrn
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,org_pal
		move.b	#$12,$fffffc02.w
		rts

set_isr		clr.b	$fffffa09.w
		clr.b	$fffffa15.w
		move.b	#$18,$fffffa1f.w
		move.b	#2,$fffffa19.w
		move.b	#$20,$fffffa07.w
		move.b	#$20,$fffffa13.w
		bclr	#3,$fffffa17.w
		move.l	#replay+$8918,$134.w
		move.l	#new_vbl,$70.w
		move.l	#null_rte,$68.w
		rts

return_old	move.b	old_a07(pc),$fffffa07.w
		move.b	old_a09(pc),$fffffa09.w
		move.b	old_a13(pc),$fffffa13.w
		move.b	old_a15(pc),$fffffa15.w
		move.b	old_a19(pc),$fffffa19.w
		move.b	old_a1f(pc),$fffffa1F.w
		move.l	old_134(pc),$134.l
		move.l	old_70(pc),$70.w
		move.l	old_68(pc),$68.w
		move.l	old_scrn,$44e.w
		move.b	#8,$fffffc02.w
		rts





clear_screen	move.l	screen_base,a0
		move.l	a0,a1
		add.l	#(384*160),a1
.loop		clr.l	(a0)+
		cmp.l	a0,a1
		bne.s	.loop
		rts

sort_pic
;sort pic palette
		lea	big_pic+2,a0
		lea	make_pal,a1
		move.w	(a0)+,2(a1)
		move.w	(a0)+,8(a1)
		move.w	(a0)+,14(a1)
		move.w	(a0)+,20(a1)
		move.w	(a0)+,26(a1)
		move.w	(a0)+,32(a1)
		move.w	(a0)+,38(a1)
		move.w	(a0)+,44(a1)
		move.w	(a0)+,50(a1)
		move.w	(a0)+,56(a1)
		move.w	(a0)+,62(a1)
		move.w	(a0)+,68(a1)
		move.w	(a0)+,74(a1)
		move.w	(a0)+,80(a1)
		move.w	(a0)+,86(a1)
		move.w	(a0)+,92(a1)

		move.l	screen_base,a1
		lea	168(a1),a1
		lea	left+34,a0
		lea	160*60(a0),a2	;depth of logo
		bsr	move_data

		move.l	screen_base,a1
		lea	328(a1),a1
		lea	right+34,a0
		lea	9600(a0),a2
.loop		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	96(a0),a0
		lea	32(a1),a1
		lea	166(a1),a1
		cmp.l	a0,a2
		bne.s	.loop

fid1		lea	230*63+160,a1	;DYNAMIC CODE (CODE GEN) **LEAVE ALONE**
		lea	(a1),a2
		add.l	#180*230,a2
		lea	big_pic+34,a3
		bsr	print_big_pic		;print main big_pic
		rts

print_big_pic	lea	(a3),a0
		move.w	#200-1,d7	;big_pic is 12 lines deep
.loop		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		move.l	8(a0),8(a1)
		move.l	12(a0),12(a1)
		move.l	16(a0),16(a1)
		move.l	20(a0),20(a1)
		move.l	24(a0),24(a1)
		move.l	28(a0),28(a1)
		move.l	32(a0),32(a1)
		move.l	36(a0),36(a1)
		move.l	40(a0),40(a1)
		move.l	44(a0),44(a1)
		move.l	48(a0),48(a1)
		move.l	52(a0),52(a1)
		move.l	56(a0),56(a1)
		move.l	60(a0),60(a1)
		move.l	64(a0),64(a1)
		move.l	68(a0),68(a1)
		move.l	72(a0),72(a1)
		move.l	76(a0),76(a1)
		move.l	80(a0),80(a1)
		move.l	84(a0),84(a1)
		move.l	88(a0),88(a1)
		move.l	92(a0),92(a1)
		move.l	96(a0),96(a1)
		move.l	100(a0),100(a1)
		move.l	104(a0),104(a1)
		move.l	108(a0),108(a1)
		move.l	112(a0),112(a1)
		move.l	116(a0),116(a1)
		move.l	120(a0),120(a1)
		move.l	124(a0),124(a1)
		move.l	128(a0),128(a1)
		move.l	132(a0),132(a1)
		move.l	136(a0),136(a1)
		move.l	140(a0),140(a1)
		move.l	144(a0),144(a1)
		move.l	148(a0),148(a1)
		move.l	152(a0),152(a1)
		move.l	156(a0),156(a1)
		move.l	160(a0),160(a1)
		move.l	164(a0),164(a1)
		move.l	168(a0),168(a1)
		move.l	172(a0),172(a1)
		move.l	176(a0),176(a1)
		move.l	180(a0),180(a1)
		move.l	184(a0),184(a1)
		move.l	188(a0),188(a1)
		move.l	192(a0),192(a1)
		move.l	196(a0),196(a1)
		move.l	200(a0),200(a1)
		move.l	204(a0),204(a1)
		move.l	208(a0),208(a1)
		move.l	212(a0),212(a1)
		move.l	216(a0),216(a1)
		move.l	220(a0),220(a1)
		move.l	224(a0),224(a1)
		lea	230(a0),a0
		lea	230(a1),a1
		dbf	d7,.loop
		rts

move_data	movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,(a1)
		lea	32(a1),a1	;160 bytes of data moved
		lea	70(a1),a1	;make upto 230 bytes which is overscan width

		cmp.l	a0,a2
		bne.s	move_data
		rts


********************************
	SECTION DATA
********************************

screen_hi	dc.b	6		;screen_base
screen_low	dc.b	0
	even

vsync_flag	dc.w	0
stack_save	dc.l	0
screen_base	dc.l	0

old_a07		dc.b	0
old_a09		dc.b	0
old_a13		dc.b	0
old_a15		dc.b	0
old_a19		dc.b	0
old_a1f		dc.b	0
old_134		dc.l	0
old_70		dc.l	0
old_68		dc.l	0
old_scrn	dc.l	0

usp_save	dc.l	0 
base_save	dc.l	0 

org_pal		ds.b	32

left	incbin	left.pi1

right	incbin	right.pi1

big_pic	incbin	manga.kid

replay	incbin	tracker.rot


module	incbin	tcb.mod

	ds.b	256
screens	ds.b	160*384


