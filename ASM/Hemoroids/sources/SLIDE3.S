screen	=	$60000

	dc.w	$a00a

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.b	#$12,$fffffc02.w
	sf	$484.w

	move	#$2700,sr

	clr.b	$ffff8260.w

	lea	old_sp(pc),a0
	move.l	a7,2(a0)
    	lea	new_sp(pc),a7

	lea	phyz(pc),a1
	move.l	#screen,d0
	move.l	d0,a0
	move.l	d0,(a1)+

	move	#15794,d7
cls	move.l	#$00000000,(a0)+
	dbf	d7,cls

	lea	52(a0),a0
	move.l	a0,(a1)

	move	#15794,d7
cls2	move.l	#$00000000,(a0)+
	dbf	d7,cls2

	move.l	d0,a0

	lea	$ffff8200.w,a0
	move.b	d0,$d(a0)
	lsr.l	#8,d0
	movep	d0,1(a0)

	lea	old_colors(pc),a0
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

	lea	picture2,a1
	lea	picture(pc),a0

	move	#117*2-1,d7
loop1	move.l	(a0)+,d0
	lsr.l	#8,d0
	andi.l	#$00ff00ff,d0
	move.l	d0,(a1)+	
	dbf	d7,loop1

	move	#27,d6
loop2	move	#117*2-1,d7
loop3	move.l	(a0)+,d0
	move.l	-936-4(a0),d1
	andi.l	#$00ff00ff,d1
	lsl.l	#8,d1

	lsr.l	#8,d0
	andi.l	#$00ff00ff,d0
	or.l	d1,d0
	move.l	d0,(a1)+

	dbf	d7,loop3
	dbf	d6,loop2

	lea	colors(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	old_hbl(pc),a0
	move.l	$68.w,2(a0)
	lea	new_hbl(pc),a0
	move.l	a0,$68.w
	lea	old_vbl(pc),a0
	move.l	$70.w,2(a0)
	lea	new_vbl(pc),a0
	move.l	a0,$70.w
	lea	old_imra(pc),a0
	move.b	$fffffa05.w,3(a0)
	move.b	$fffffa07.w,9(a0)
	move.b	$fffffa09.w,15(a0)

	bset	#4,$fffffa05.w
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w

	move.l	a7,restore_stack+2
	stop	#$2300

************************ Main loop,LET'S GO!!! ****************************

wait_key	stop	#$2300
	move	#$2100,sr

	lea	dark(pc),a0
	movem.l	(a0),d0-d7
 	movem.l	d0-d7,$ffff8240.w

	move.l	phyz+4(pc),d0
	move.l	phyz,phyz+4
	move.l	d0,phyz

	lea	$ffff8201.w,a1
	lsr.l	#8,d0
	movep	d0,(a1)

	move	.pos_counter+2(pc),d7
	subq	#8,d7

	eori	#1,scroll_flag
	tst	scroll_flag
	beq	.no_scroll

.change_it	lea	used_table,a0
	addi.l	#8,.change_it+2

.pos_counter	move	#0,d7
	addq	#8,.pos_counter+2

	cmpi	#29*2*8-8,d7
	beq	exit

	lea	come_back1(pc),a2
	lea	list(pc),a1

	moveq	#0,d0
	move.b	(a0)+,d0
	lsl	#2,d0
	move.l	(a1,d0.w),-4(a2)
	move.b	(a0)+,d0
	lsl	#2,d0
	move.l	(a1,d0.w),6(a2)
	move.b	(a0)+,d0
	lsl	#2,d0
	move.l	(a1,d0.w),16(a2)
	move.b	(a0)+,d0
	lsl	#2,d0
	move.l	(a1,d0.w),26(a2)
	move.b	(a0)+,d0
	lsl	#2,d0
	move.l	(a1,d0.w),36(a2)
	move.b	(a0)+,d0
	lsl	#2,d0
	move.l	(a1,d0.w),46(a2)
	move.b	(a0)+,d0
	lsl	#2,d0
	move.l	(a1,d0.w),56(a2)

	move.b	(a0),d0
	beq.s	.no_scroll
	add.b	d0,phyz+2
	add.b	d0,phyz+6

.no_scroll
	lea	.pichoose(pc),a0
	move.l	2(a0),d0
	move.l	8(a0),2(a0)
	move.l	d0,8(a0)

	move	d7,d6
	cmpi	#29*8+8*3,d6
	blo.s	.dont_sub
	subi	#8*5,d6
.dont_sub
	move.l	phyz(pc),a0
	lea	160+230*58+248(a0),a0
	lea	(a0,d6.w),a0

	lea	premul(pc),a1
	lsr	d7
	move.l	(a1,d7.w),d7

.pichoose	lea	picture2,a1
	lea	picture,a1
	lea	(a1,d7.l),a1

	clr.l	(a0)
	clr.l	4(a0)
	clr.l	230(a0)
	clr.l	234(a0)
	lea	460(a0),a0

	rept	117
	move.l	(a1)+,(a0)
	move.l	(a1)+,4(a0)
	lea	230(a0),a0
	endr

.wait_hbl	tst	(a6)
	bne.s	.wait_hbl

	move	#$2700,sr

	lea	$ffff820a.w,a6
	lea	$56(a6),a7
	lea	$36(a6),a5
	moveq	#0,d7

;	works from 75 to 81 on DJB's STe

	rept	76
	nop
	endr

	move.b	d7,(a6)
	rept	10
	nop
	endr
	move	a6,(a6)

	moveq	#0,d0
.wait_beg	move.b	-1(a6),d0
	beq.s	.wait_beg

	neg	d0
	lsl.l	d0,d0

	rept	68
	nop
	endr

	lea	come_back1(pc),a0	;[8]
	jmp	line1	;[12]
come_back1	lea	come_back2(pc),a0	;[8]
	jmp	line1	;[12]
come_back2	lea	come_back3(pc),a0	;[8]
	jmp	line3	;[12]
come_back3	lea	come_back4(pc),a0	;[8]
	jmp	line3	;[12]
come_back4	lea	come_back5(pc),a0	;[8]
	jmp	line3	;[12]
come_back5	lea	come_back6(pc),a0	;[8]
	jmp	line3	;[12]
come_back6	lea	come_back7(pc),a0	;[8]
	jmp	line6	;[12]
come_back7
	nop
	nop
	nop
	nop
	nop

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	lea	colors(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	moveq	#0,d7

	rept	48
	nop
	endr

	move.b	d7,(a6)
	move	a6,(a6)

	rept	13
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	9
	nop
	endr

	move	#218,d6	;[8]
.full1	nop
	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	89
	nop
	endr

	move.b	d7,(a6)
	move	a6,(a6)

	rept	13
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	8
	nop
	endr

	dbf	d6,.full1

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	89
	nop
	endr

	move.b	d7,(a6)
	move	a6,(a6)

	rept	13
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	5
	nop
	endr

	move.b	d7,(a6)

	rept	5
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	move	a6,(a6)

	rept	87
	nop
	endr

	move.b	d7,(a6)
	move	a6,(a6)

	rept	13
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	11
	nop
	endr

;	jmp	restore_stack(pc)

	moveq	#44,d6	;[4]
.full2	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	89
	nop
	endr

	move.b	d7,(a6)
	move	a6,(a6)

	rept	13
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	9
	nop
	endr

	dbf	d6,.full2

restore_stack	move.l	#0,a7

	cmpi.b	#$39,$fffffc02.w
	bne	wait_key
exit
	move	#$2700,sr

old_vbl	move.l	#0,$70.w
old_hbl	move.l	#0,$68.w
old_imra	move.b	#0,$fffffa05.w
	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w

	lea	old_colors(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

old_sp	move.l	#0,a7

	move	#$2300,sr

	move.b	#$8,$fffffc02.w
	st	$484.w

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	dc.w	$a009

	clr.l	-(sp)
	trap	#1

***************************************************************************

	ds.l	128
new_sp
old_colors	ds.l	8
dark	ds.l	8

***************************************************************************

new_hbl	lea	full_counter(pc),a6
	subq	#1,(a6)
	rte

new_vbl	move	#$003,$ffff8240.w
	lea	full_counter(pc),a6
	move	#$22,(a6)

	rte

****************** Synchro lines for hard-scroll **************************

;	prototype ligne 54

line1	rept	40
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	10
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	68-7
	nop
	endr

	jmp	(a0)	;8

;	prototype ligne 80

line2	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	35
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	83-7
	nop
	endr

	jmp	(a0)

;	prototype ligne 158

line3	rept	92
	nop
	endr

	move.b	d7,(a6)
	move	a6,(a6)

	rept	32-7
	nop
	endr

	jmp	(a0)

;	prototype ligne 160

line4	rept	128-7
	nop
	endr

	jmp	(a0)

;	prototype ligne 186

line5	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	84
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	34-7
	nop
	endr

	jmp	(a0)

;	prototype ligne 204

line6	rept	94
	nop
	endr

	move.b	d7,(a6)
	move	a6,(a6)

	rept	13
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	12-7
	nop
	endr

	jmp	(a0)

;	prototype ligne 230 octets

line7	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	89
	nop
	endr

	move.b	d7,(a6)
	move	a6,(a6)

	rept	13
	nop
	endr

	move	a7,(a7)
	nop
	move.b	d7,(a7)

	rept	12-7
	nop
	endr

	jmp	(a0)

***************************************************************************

full_counter	dc.w	0
phyz	dc.l	0
	dc.l	0
scroll_flag	dc.w	1

premul	dc.l	0*936,1*936,2*936,3*936,4*936,5*936,6*936,7*936,8*936,9*936,10*936,11*936,12*936,13*936,14*936
	dc.l	15*936,16*936,17*936,18*936,19*936,20*936,21*936,22*936,23*936,24*936,25*936,26*936,27*936,28*936
	dcb.l	29,29*936
list	dc.l	line1,line2,line3,line4,line5,line6,line7
used_table	dc.b	0,0,2,2,2,2,5,0	;0   [3b0]
	dc.b	0,0,3,3,3,3,5,0	;8   [3b8]
	dc.b	0,0,0,3,5,5,6,0	;16  [3c0]
	dc.b	0,0,0,3,4,6,6,0	;24  [3c8]
	dc.b	0,0,1,4,4,4,6,0	;32  [3d0]
	dc.b	0,0,0,2,5,6,6,0	;40  [3d8]
	dc.b	0,0,1,2,4,6,6,0	;48  [3e0]
	dc.b	0,0,2,2,3,4,6,0	;56  [3e8]
	dc.b	0,1,2,2,4,4,4,0	;64  [3f0]
	dc.b	0,0,2,2,2,5,6,0	;72  [3f8]
	dc.b	0,1,2,2,2,4,6,0	;80  [400]
	dc.b	0,2,2,2,2,3,4,0	;88  [408]
	dc.b	0,0,3,3,5,5,5,0	;96  [410]
	dc.b	0,0,3,3,3,6,6,0	;104 [418]
	dc.b	0,0,0,5,6,6,6,0	;112 [420]
	dc.b	0,0,1,4,6,6,6,0	;120 [428]
	dc.b	0,0,2,3,4,6,6,0	;128 [430]
	dc.b	0,1,2,4,4,4,6,0	;136 [438]
	dc.b	0,0,2,2,5,6,6,0	;144 [440]
	dc.b	0,1,2,2,4,6,6,0	;152 [448]
	dc.b	0,2,2,2,3,4,6,0	;160 [450]
	dc.b	1,2,2,2,4,4,4,0	;168 [458]
	dc.b	0,2,2,2,2,5,6,0	;176 [460]
	dc.b	0,0,5,5,5,5,5,0	;184 [468]
	dc.b	0,0,3,5,5,6,6,0	;192 [470]
	dc.b	0,0,3,4,6,6,6,0	;200 [478]
	dc.b	0,1,4,4,4,6,6,0	;208 [480]
	dc.b	0,0,2,5,6,6,6,0	;216 [488]
	dc.b	0,1,2,4,6,6,6,0	;224 [490]
	dc.b	0,2,2,3,4,6,6,0	;232 [498]
	dc.b	1,2,2,4,4,4,6,0	;240 [4a0]
	dc.b	0,2,2,2,5,6,6,1	;248 [4a8]
	dc.b	0,0,2,2,2,2,5,0	;256 [3b0]+$100
	dc.b	0,0,3,3,3,3,5,0	;264 [3b8]
	dc.b	0,0,0,3,5,5,6,0	;272 [3c0]
	dc.b	0,0,0,3,4,6,6,0	;280 [3c8]
	dc.b	0,0,1,4,4,4,6,0	;288 [3d0]
	dc.b	0,0,0,2,5,6,6,0	;296 [3d8]
	dc.b	0,0,1,2,4,6,6,0	;304 [3e0]
	dc.b	0,0,2,2,3,4,6,0	;312 [3e8]
	dc.b	0,1,2,2,4,4,4,0	;320 [3f0]
	dc.b	0,0,2,2,2,5,6,0	;328 [3f8]
	dc.b	0,1,2,2,2,4,6,0	;336 [400]
	dc.b	0,2,2,2,2,3,4,0	;344 [408]
	dc.b	0,0,3,3,5,5,5,0	;352 [410]
	dc.b	0,0,3,3,3,6,6,0	;360 [418]
	dc.b	0,0,0,5,6,6,6,0	;368 [420]
	dc.b	0,0,1,4,6,6,6,0	;376 [428]
	dc.b	0,0,2,3,4,6,6,0	;384 [430]
	dc.b	0,1,2,4,4,4,6,0	;392 [438]
	dc.b	0,0,2,2,5,6,6,0	;400 [440]
	dc.b	0,1,2,2,4,6,6,0	;408 [448]
	dc.b	0,2,2,2,3,4,6,0	;416 [450]
	dc.b	1,2,2,2,4,4,4,0	;424 [458]
	dc.b	0,2,2,2,2,5,6,0	;432 [460]
	dc.b	0,0,5,5,5,5,5,0	;440 [468]
	dc.b	0,0,3,5,5,6,6,-1 ;448 [470]
;	dc.b	0,0,3,4,6,6,6,0 ;456 [478]
;	dc.b	0,1,4,4,4,6,6,0	;464 [480]
;	dc.b	0,0,2,5,6,6,6,0	;472 [488]
;	dc.b	0,1,2,4,6,6,6,0	;480 [490]

colors	incbin	a:\doc_bit.col
picture	incbin	a:\doc_bit.dat
	ds.l	234*2
picture2	ds.l	6786+234
	
	end