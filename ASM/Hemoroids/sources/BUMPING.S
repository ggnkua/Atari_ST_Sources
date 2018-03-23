	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	lea	old_a7(pc),a0
  	move.l	a7,2(a0)
	lea	new_a7(pc),a7

	lea	curve(pc),a0
	lea	old_curv(pc),a1
	rept	28
	move.l	a0,(a1)+
	endr

	clr.b	$ffff8260.w
	move.l	$44e.w,a0
	lea	-32000(a0),a0
	move.l	a0,screen
	lea	old_place(pc),a1
	rept	28
	move.l	a0,(a1)+
	endr

	move	#7999,d7
cls	move.l	#$0,(a0)+
	dbf	d7,cls
	move.l	a0,screen+4
	move	#7999,d7
cls2	move.l	#$0,(a0)+
	dbf	d7,cls2

	move.l	#$00000777,$ffff8240.w
               	move.l	#$04440777,$ffff8244.w
	move.l	#$07770777,$ffff8248.w
	move.l	#$07770777,$ffff824c.w
	move.l	#$04440444,$ffff8250.w
	move.l	#$04440444,$ffff8254.w
	move.l	#$04440444,$ffff8258.w
	move.l	#$04440444,$ffff825c.w

	move.l	$70.w,old_vbl+2

;	move.l	#new_vbl,$70.w

wait_key	jsr	new_vbl(pc)
	cmpi.b	#$b9,$fffffc02.w
	bne.s	wait_key
exit

old_vbl	move.l	#0,$70.w
old_a7	move.l	#0,a7

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

	ds.l	128
new_a7

new_vbl	lea	screen(pc),a0
	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep	d0,(a0)

.loop_factor	move	#27,d0
.loop_boing	move	d0,d1
	move	d1,d2
	lsl	#2,d1
	lea	validity(pc),a2
	tst.b	(a2,d2.w)
	beq	.dont_do_it

	lea	old_curv(pc),a0
	lea	(a0,d1.w),a0
	move.l	(a0),a1
	moveq	#0,d7
	move	(a1)+,d7

	cmpi.l	#19000,d7
	bhi.s	.dont_launch_next
 	move.b	#1,-1(a2,d2.w)
.dont_launch_next

	move	(a1)+,d6
	cmpi	#-1,(a1)
	bne	.ok

 	clr.b	(a2,d2.w)

	tst	d0
	bne.s	.ok1

;	here,i modify the code for the other sentence

.myself	lea	.nop_nop(pc),a2
	lea	.replace_nop(pc),a3
	move	2(a2),2(a3)
	move.l	#$4e714e71,(a2)
.ok1

	lsr	d1
	move.l	screen+4(pc),a3
.base_offset	lea	75*160+24(a3),a3	;0
	adda.l	d7,a3		;4
	move.l	screen(pc),a4		;6
	lea	75*160+24(a4),a4	;10
	adda.l	d7,a4		;14
	lea	add_screen(pc),a5	;16
	add	(a5,d1.w),a3		;20
	add	(a5,d1.w),a4		;24
	lsl	d1

	move.b	(a3),(a4)
	move.b	2(a3),2(a4)
	move.b	160(a3),160(a4)
	move.b	162(a3),162(a4)
	move.b	320(a3),320(a4)
	move.b	322(a3),322(a4)
	move.b	480(a3),480(a4)
	move.b	482(a3),482(a4)
	move.b	640(a3),640(a4)
	move.b	642(a3),642(a4)
	move.b	800(a3),800(a4)
	move.b	802(a3),802(a4)
	move.b	960(a3),960(a4)
	move.b	962(a3),962(a4)
	move.b	1120(a3),1120(a4)
	move.b	1122(a3),1122(a4)
	move.b	1280(a3),1280(a4)
	move.b	1282(a3),1282(a4)
	move.b	1440(a3),1440(a4)
	move.b	1442(a3),1442(a4)
	move.b	1600(a3),1600(a4)
	move.b	1602(a3),1602(a4)
	move.b	1760(a3),1760(a4)
	move.b	1762(a3),1762(a4)
	move.b	1920(a3),1920(a4)
	move.b	1922(a3),1922(a4)
	move.b	2080(a3),2080(a4)
	move.b	2082(a3),2082(a4)
	move.b	2240(a3),2240(a4)
	move.b	2242(a3),2242(a4)

	lea	curve(pc),a1
	move.l	a1,(a0)

	bra	.dont_do_it
.ok	move.l	a1,(a0)

	lsr	d1

.text	lea	ajoute1(pc),a0
	lea	fonts(pc),a2
	adda	(a0,d1.w),a2             
	lea	32(a2),a2

	lea	old_place(pc),a3
	lsl	d1
	adda	d1,a3
	tst	flag
	beq	.base_offset2-4

	move.l	(a3),a4

	move.l	28*4(a3),(a3)

	moveq	#0,d2

	movep	d2,-2560(a4)
	movep	d2,-2400(a4)
	movep	d2,-2240(a4)
	movep	d2,-2080(a4)
	movep	d2,-1920(a4)
	movep	d2,-1760(a4)
	movep	d2,-1600(a4)
	movep	d2,-1440(a4)
	movep	d2,-1280(a4)
	movep	d2,-1120(a4)
	movep	d2,-960(a4)
	movep	d2,-800(a4)
	movep	d2,-640(a4)
	movep	d2,-480(a4)
	movep	d2,-320(a4)
	movep	d2,-160(a4)
	movep	d2,(a4)
	movep	d2,160(a4)
	movep	d2,320(a4)
	movep	d2,480(a4)
	movep	d2,640(a4)
	movep	d2,800(a4)
	movep	d2,960(a4)
	movep	d2,1120(a4)
	movep	d2,1280(a4)
	movep	d2,1440(a4)
	movep	d2,1600(a4)
	movep	d2,1760(a4)
	movep	d2,1920(a4)
	movep	d2,2080(a4)
	movep	d2,2240(a4)
 	movep	d2,2400(a4)
	movep	d2,2560(a4)

	move.l	screen(pc),a0
.base_offset2	lea	75*160+24(a0),a0	;0
	adda.l	d7,a0		;4
	lea	add_screen(pc),a4	;6
	lsr	d1		;10
	add	(a4,d1.w),a0		;12
 	move.l	a0,28*4(a3)

	lea	rotation(pc),a3
	lea	(a3,d6.w),a3
	lea	table(pc),a4

***************************************************************************

	rept	16
	lea	(a0),a1
	move	(a3)+,d7
	move	(a4,d7.w),d7
	adda	d7,a1
	move.b	-(a2),2(a1)
	move.b	-(a2),(a1)
	endr

.dont_do_it
	dbf	d0,.loop_boing

	st	flag

.nop_nop	jmp	.end_nop_nop(pc)

	lea	.nop_nop(pc),a2
	move	#$4efa,(a2)+
.replace_nop	move	#0,(a2)

	lea	validity(pc),a2
	move.b	#1,13(a2)
	lea	.myself(pc),a2
	move	#$4ef9,(a2)+
	lea	exit(pc),a3
	move.l	a3,(a2)
	lea	.loop_factor(pc),a2
	move	#13,2(a2)
	lea	.text(pc),a2
	addi	#28*2,2(a2)
	lea	.base_offset2(pc),a2
	addi	#160*16-24+104+4,2(a2)
	add	#2*28,8(a2)
	bchg.b	#6,12(a2)

	lea	.base_offset(pc),a2
	add	#160*16-24+104+4,2(a2)
	add	#160*16-24+104+4,12(a2)
	add	#2*28,18(a2)
	bchg.b	#6,20(a2)
	bchg.b	#6,24(a2)

	lea	old_place(pc),a2
	rept	14
	move.l	screen(pc),(a2)+
	endr

.end_nop_nop

	rts

flag	dc.w	0
screen	ds.l	2
	dc.w	-2560,-2400,-2240,-2080,-1920,-1760,-1600,-1440,-1280,-1120,-960,-800,-640,-480,-320,-160
table	dc.w	0,160,320,480,640,800,960,1120,1280,1440,1600,1760,1920,2080,2240,2400,2560
	dc.w	0
validity	ds.w	13
	dc.w	1
old_curv	ds.l	28
old_place	ds.l	28*2
curve	incbin	a:\curve.dat
	dc.l	-1
ajoute1	dc.w	10*32,4*32,4*32,15*32,45*32,24*32,14*32,20*32,17*32,45*32,15*32,17*32,4*32
 	dc.w	15*32,0,17*32,0,19*32,8*32,14*32,13*32,45*32,7*32,45*32,22*32,8*32,19*32,7*32
	dc.w	24*32,0*32,28*32,2*32,14*32,25*32,45*32,7*32,4*32,17*32,4*32,45*32,8*32,18*32

	dc.w	0,32,64,32*3,32*4,32*5,32*6,32*7,32*8,32*9,32*10,32*11,32*12,32*13,32*14,32*15,32*16,32*17,32*18,32*19,32*20,32*21,32*22,32*23,32*24,32*25,32*26,32*27
	dc.w	28*32,29*32,30*32,31*32,32*32,33*32,34*32,35*32,36*32,37*32,38*32,39*32,40*32,41*32,42*32,43*32,44*32,45*32

add_screen	dc.w	0,1,8,9,16,17,24,25,32,33,40,41,48,49,56,57,64,65,72,73,80,81,88,89,96,97,104,105
add_screen2	dc.w	56,55,48,47,40,39,32,31,24,23,16,15,8,7

rotation	incbin	a:\rotated.dat
fonts	incbin	a:\tiny.fnt
	ds.l	8
	end