buffer_dots	equ	$1f0000-128*16*32*6-256*2
ZM	=	110
Width2	=	320
Height2	=	200


	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	PEA	DEMO(PC)
	MOVE.W	#38,-(SP)
	TRAP	#14
	LEA	6(SP),SP
	CLR.W	-(SP)
	TRAP	#1


DEMO
;	movem.l	$ffff8240.w,d0-d7
;	movem.l	d0-d7,save_colors

	move.l	screen,d0
	add.w	#256,d0
	and.w	#$ff00,d0
	move.l	d0,screen
	move.l	screen+4,d0
	add.w	#256,d0
	and.w	#$ff00,d0
	move.l	d0,screen+4

	bsr	Predecale_balles

Main	
	lea	ZBuffer,a0
	move.w	#ZB-ZBuffer-ZM*4,d0
	move.w	#ZM*2-1,d1
.make
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	add.w	#108,d0
	dbra	d1,.make

	lea	Sin2(pc),a0
	move.w	#639,d0
.asr	asr.w	(a0)+
	dbra	d0,.asr
	
	lea	Par3D(pc),a0
	move.l	#-300*$8000,Ty(a0)
	move.w	#4,AxInc(a0)
	move.w	#50,Ax(a0)
	move.w	#-4,AyInc(a0)
	move.w	#10,Ay(a0)
	move.w	#2,AzInc(a0)
	move.w	#150,Az(a0)

click
	move.w	#37,-(sp)
	trap	#14
	lea	2(sp),sp

;.vs	tst.w	Sync
;	beq.s	.vs
;	move.w	#-1,Sync

	cmp.w	#5,Clock2
	beq.s	.end

	bsr	efface_baballes
;	move.w	#$700,$ffff8240.w
	bsr	Vek
;	move.w	#$777,$ffff8240.w

	lea	Screen(pc),a0
	move.l	(a0)+,d0
	move.l	(a0),d1
	move.l	d0,(a0)
	move.l	d1,-(a0)

	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	cmpi.b	#$39,$fffffc02.w
	bne.s	click
.end
	rts

Vek
	move.l	Object(pc),a0
	lea	Points,a1
	moveq	#26,d0
.trans
	rept	3
	cmpm.w	(a0)+,(a1)+
	slt	d2
	sgt	d3
	sub.b	d2,d3
	ext.w	d3
	add.w	d3,-2(a1)
	endr
	dbra	d0,.trans

	lea	Par3D(pc),a0
	move.w	AxInc(a0),d0
	add.w	d0,Ax(a0)
	and.w	#511*2,Ax(a0)
	move.w	AyInc(a0),d0
	add.w	d0,Ay(a0)
	and.w	#511*2,Ay(a0)
	move.w	AzInc(a0),d0
	add.w	d0,Az(a0)
	and.w	#511*2,Az(a0)

	tst.w	Clock2
	bgt.s	.skip1
	tst.l	Ty(a0)
	bge.s	.skip2
	add.l	#$8000,Ty(a0)
.skip1
	cmp.w	#4,Clock2
	blt.s	.skip2	
	sub.l	#$8000,Ty(a0)
.skip2
	addq.w	#1,Clock1
	cmp.w	#400,Clock1
	blt.s	.cont
	clr.w	Clock1
	addq.w	#1,Clock2
	cmp.w	#2,Clock2
	bgt.s	.cont
	add.l	#27*6,Object
.cont
	movem.w	Az(a0),d0-d2
;	move.w	#$077,$ffff8240.w
	bsr	Calc3D
;	move.w	#$770,$ffff8240.w
	bsr	Rotate

;	move.w	#$070,$ffff8240.w
	lea	ZBuffer,a0
	lea	ZM*4(a0),a1
	moveq	#0,d7
	move.w	BallPtr(pc),d7
	addq.w	#4,BallPtr
	and.w	#511,BallPtr
	move.l	pt_eff,a6
	move.w	#ZM*2-1,d6
CopyBalls
	movem.w	(a0)+,d0/d5
	cmp.w	d5,d0
	beq.s	next
	move.w	d5,-4(a0)
copy
	subq.w	#4,d0
	move.w	d0,-(sp)
	movem.w	(a1,d0.w),d1/d2
	cmp.w	#319-32,d1
	
	move.w	d1,d0
	and.w	#$f,d0
	lsr.w	#1,d1
	and.w	#$f8,d1
	mulu	#160,d2
	move.l	screen(pc),a3
	add.w	d1,d2
	add.w	d2,a3
	move.l	a3,(a6)+

	lea	table_balls,a2
	move.l	(a2,d7.w),a2
	mulu	#32*6,d0
	add.w	d0,a2
	lea	buffer_mask,a4
	add.w	d0,a4

	move.w	d5,-(sp)
	bsr	affiche_baballe		
	move.w	(sp)+,d5

	addq.w	#4,d7
	and.w	#511,d7

	move.w	(sp)+,d0
	cmp.w	d5,d0
	bne.s	copy
next
	dbra	d6,CopyBalls	
	rts


Rotate
	lea	Points,a0
	lea	ZBuffer+ZM*4,a1
	move.w	#Width2/2-16,a2 
	move.w	#Height2/2-16,a3
	move.l	Par3D+Ty(pc),a4
	moveq	#26,d5 
  	move.w	#16384,d6
calc 
	movem.w	(a0)+,d0/d1/d2	; x,y,z
  
	move.w	d0,d7 
C	muls	#0,d7
	move.w	d1,d4 
F	muls	#0,d4
	sub.l	d4,d7 
	move.w	d2,d4 
I	muls	#0,d4
	sub.l	d4,d7 
  	asl.l	#5,d7		; z/q
	swap	d7
  	add.w	d6,d7		; Q=1-z/q
  
	move.w	d0,d3 
A	muls	#0,d3 
	move.w	d1,d4 
D	muls	#0,d4 
	add.l	d4,d3 
	move.w	d2,d4	 
G	muls	#0,d4 
	add.l	d4,d3 
	asr.l	d3
	divs	d7,d3		; X/Q
	add.w	a2,d3		; Xp

B	muls	#0,d0 
E	muls	#0,d1 
H	muls	#0,d2 
	add.l	d0,d2 
	add.l	d1,d2
	add.l	a4,d2
 	asr.l	d2
	divs	d7,d2		; Y/Q 
	add.w	a3,d2		; Yp

	cmp.w	#Width2-32,d3
	blt.s	.clip1
	move.w	#Width2-32,d3
.clip1	tst.w	d3
	bpl.s	.clip11
	moveq	#0,d3

.clip11	cmp.w	#Height2-32,d2
	blt.s	.clip22
	move.w	#height2-32,d2
.clip22	cmp.w	#-32,d2
	ble.s	hidden
.clip2
	sub.w	d6,d7
	asr.w	#2,d7		; -z*4
	and.b	#$fc,d7
	neg.w	d7
	move.w	(a1,d7.w),d0
	move.w	d3,(a1,d0.w)
	move.w	d2,2(a1,d0.w)
	addq.w	#4,(a1,d7.w)
hidden
	dbra	d5,calc
	rts 


 
Calc3D 
	lea	Sin2(pc),a2 
	lea	256(a2),a1
	lea	C(pc),a3
	move.w	#511*2,d7
  
; C = -Sin2 y 
 
	move.w	(a2,d1.w),d3	; Sin2 y /2 
	add.w	d3,d3
	move.w	d3,2(a3)
 
; F = cos y * Sin2 x = (Sin2 x+y + Sin2 x-y)/2 
 
	move.w	d2,d3		; x 
	add.w	d1,d3		; x+y 
	and.w	d7,d3 
	move.w	(a2,d3.w),d5	; Sin2 x+y /2 
	move.w	d2,d4 
	sub.w	d1,d4		; x-y 
	and.w	d7,d4 
	add.w	(a2,d4.w),d5	; (Sin2 x+y + Sin2 x-y)/2 
	move.w	d5,F-C+2(a3) 
 
; I = cos y * cos x = (cos y+x + cos y-x)/2 
 
	move.w	(a1,d3.w),d5	; cos y+x /2 
	add.w	(a1,d4.w),d5	; (cos y+x + cos y-x)/2 
	move.w	d5,I-C+2(a3) 
 
; A = cos z * cos y = (cos z+y + cos z-y)/2 
 
	move.w	d0,d3		; z 
	add.w	d1,d3		; z+y 
	and.w	d7,d3 
	move.w	(a1,d3.w),d5	; cos z+y /2 
	move.w	d0,d4 
	sub.w	d1,d4		; z-y 
	and.w	d7,d4 
	add.w	(a1,d4.w),d5	; (cos z+y + cos z-y)/2 
	move.w	d5,A-C+2(a3) 
 
; D = -Sin2 z * cos x + cos z * Sin2 y * Sin2 x 
; D = (cos z+y-x + cos z-y+x - cos z+y+x - cos z-y-x)/4 - (Sin2 z+x + Sin2 z-x)/2  
 
	move.w	d3,d5		; z+y 
	sub.w	d2,d5		; z+y-x 
	and.w	d7,d5 
	move.w	(a1,d5.w),d6	; cos z+y-x /2 
	move.w	d4,d5 
	add.w	d2,d5		; z-y+x 
	and.w	d7,d5 
	add.w	(a1,d5.w),d6	; cos z+y-x /2 + cos z-y+x /2 
	asr.w	d6 
	move.w	d3,d5 
	add.w	d2,d5 
	and.w	d7,d5 
	move.w	(a1,d5.w),d7	; cos z+y+x /2 
	move.w	d4,d5 
	sub.w	d2,d5 
	and.w	#511*2,d5 
	add.w	(a1,d5.w),d7	; cos z+y+x /2 + cos z-y-x /2 
	asr.w	d7 
	sub.w	d7,d6 
	move.w	d0,d5		; z 
	add.w	d2,d5		; z+x 
	and.w	#511*2,d5 
	move.w	(a2,d5.w),d5	; Sin2 z+x /2 
	move.w	d0,d7 
	sub.w	d2,d7 
	and.w	#511*2,d7 
	add.w	(a2,d7.w),d5	; + Sin2 z-x /2 
	sub.w	d5,d6 
	move.w	d6,D-C+2(a3) 
 
; G = Sin2 z * Sin2 x + cos z * Sin2 y * cos x 
; G = (win y+x+z + Sin2 y+x-z + Sin2 y-x+z + Sin2 y-x-z)/4 + (cos z-x - cos z+x)/2 
 
	move.w	d3,d5		; z+y 
	add.w	d2,d5		; y+x+z 
	and.w	#511*2,d5 
	move.w	(a2,d5.w),d5	; Sin2 y+x+z 
	move.w	d2,d6		; x 
	sub.w	d4,d6		; x-(z-y) = x-z+y = y+x-z 
	and.w	#511*2,d6 
	add	(a2,d6.w),d5 
	asr.w	d5 
	move.w	d3,d6		; z+y 
	sub.w	d2,d6		; y-x+z 
	and.w	#511*2,d6 
	move.w	(a2,d6.w),d6 
	move.w	d4,d7 
	neg.w	d7		; y-z 
	sub.w	d2,d7		; y-z-x = y-x-z 
	and.w	#511*2,d7 
	add.w	(a2,d7.w),d6 
	asr.w	d6 
	add.w	d5,d6 
	move.w	d0,d5 
	sub.w	d2,d5		; z-x 
	and.w	#511*2,d5 
	move.w	(a1,d5.w),d5 
	move.w	d0,d7 
	add.w	d2,d7		; z+x 
	and.w	#511*2,d7 
	sub.w	(a1,d7.w),d5 
	add.w	d5,d6 
	move.w	d6,G-C+2(a3) 
 
; B = Sin2 z * cos y = (Sin2 z+y + Sin2 z-y)/2 
  
	move.w	(a2,d3.w),d5 
	add.w	(a2,d4.w),d5 
	move.w	d5,B-C+2(a3) 
 
; E = cos z * cos x + Sin2 z * Sin2 y * Sin2 x 
; E = (Sin2 z+y-x + Sin2 z-y+x - Sin2 z+y+x - Sin2 z-y-x)/4 + (cos z+x + cos z-x)/2 
 
	move.w	d3,d5 
	sub.w	d2,d5		; z+y-x 
	and.w	#511*2,d5 
	move.w	(a2,d5.w),d5 
	move.w	d4,d6 
	add.w	d2,d6		; z-y+x 
	and.w	#511*2,d6 
	add.w	(a2,d6.w),d5 
	asr.w	d5 
	move.w	d3,d6 
	add.w	d2,d6		; z+y+x 
	and.w	#511*2,d6 
	move.w	(a2,d6.w),d6 
	move.w	d4,d7 
	sub.w	d2,d7		; z-y-x 
	and.w	#511*2,d7 
	add.w	(a2,d7.w),d6 
	asr.w	d6 
	sub.w	d6,d5 
	move.w	d0,d6 
	add.w	d2,d6		; z+x 
	and.w	#511*2,d6 
	move.w	(a1,d6.w),d6 
	move.w	d0,d7 
	sub.w	d2,d7		; z-x 
	and.w	#511*2,d7 
	add.w	(a1,d7.w),d6 
	add.w	d5,d6 
	move.w	d6,E-C+2(a3) 
 
; H = - cos z * Sin2 x + Sin2 z * Sin2 y * cos x 
; H = (cos z-y-x - cos z+y+x + cos z-y+x - cos z+y-x)/4 - (Sin2 x+z + Sin2 x-z)/2 
 
	move.w	d4,d5 
	sub.w	d2,d5		; z-y-x 
	and.w	#511*2,d5 
	move.w	(a1,d5.w),d5 
	move.w	d3,d6		; z+y 
	add.w	d2,d6		; z+y+x 
	and.w	#511*2,d6 
	sub.w	(a1,d6.w),d5 
	asr.w	d5 
	move.w	d4,d6 
	add.w	d2,d6		; z-y+x 
	and.w	#511*2,d6 
	move.w	(a1,d6.w),d6 
	move.w	d3,d7
	sub.w	d2,d7		; z+y-x 
	and.w	#511*2,d7 
 	sub.w	(a1,d7.w),d6 
	asr.w	d6 
	add.w	d6,d5 
	move.w	d2,d3 
	add.w	d0,d3		; x+z 
	and.w	#511*2,d3 
	move.w	(a2,d3.w),d3 
	sub.w	d0,d2		; x-z 
	and.w	#511*2,d2 
	add.w	(a2,d2.w),d3 
	sub.w	d3,d5 
	move.w	d5,H-C+2(a3) 
	rts 
  
efface_baballes
	move.l	pt_eff+4,a0
	move.l	pt_eff,pt_eff+4
	move.l	a0,pt_eff
	move.w	#26,d1
efbb	move.l	(a0)+,a1
	moveq	#0,d0
burne	set	0
	rept	32
	move	d0,burne(a1)
	move	d0,burne+8(a1)
	move	d0,burne+16(a1)
burne	set	burne+160
	endr
	dbra	d1,efbb
	rts

affiche_baballe
clito	set	0
	rept	16
	movem.w	(a4)+,d0-d5
	and.w	d0,clito(a3)
	and.w	d1,clito+8(a3)
	and.w	d2,clito+16(a3)
clito	set	clito+160
	and.w	d3,clito(a3)
	and.w	d4,clito+8(a3)
	and.w	d5,clito+16(a3)
clito	set	clito+160
	endr

anus	set	0
	rept	16
	movem.w	(a2)+,d0-d5
	or.w	d0,anus(a3)
	or.w	d1,anus+8(a3)
	or.w	d2,anus+16(a3)
anus	set	anus+160
	or.w	d3,anus(a3)
	or.w	d4,anus+8(a3)
	or.w	d5,anus+16(a3)
anus	set	anus+160
	endr
	rts

Predecale_balles
	lea	buffer_mask,a1
	move.w	#0,d7
nextm	lea	mask,a0
	move.w	#31,d6
linem	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0),d0
	move.w	8(a0),d1
	ror.l	d7,d0
	ror.l	d7,d1
	move.w	d0,(a1)
	not.w	(a1)+
	swap	d0
	or.w	d0,d1
	not.l	d1
	or.w	d1,(a1)+
	swap	d1
	move.w	d1,(a1)+
	lea	16(a0),a0
	dbra	d6,linem
	addq	#1,d7
	cmpi.w	#16,d7
	bne	nextm

	lea	dotsballs,a2
	lea	buffer_dots,a1
	move.w	#127,d5
nextanim
	move.w	#0,d7
nextb	move.l	a2,a0
	move.w	#31,d6
lineb	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0),d0
	move.w	2(a0),d1
	ror.l	d7,d0
	ror.l	d7,d1
	move.w	d0,(a1)+
	swap	d0
	move.w	d0,(a1)
	or.w	d1,(a1)+
	swap	d1
	move.w	d1,(a1)+
	lea	6(a0),a0
	dbra	d6,lineb
	addq	#1,d7
	cmp.w	#16,d7
	bne	nextb
	lea	6*32(a2),a2
	dbra	d5,nextanim
	rts
pt_eff	dc.l	efface1
	dc.l	efface2
efface1	dcb.l	30,$1f8000
efface2	dcb.l	30,$1f0000


table_balls
tb	set	0
	rept	128
	dc.l	buffer_dots+tb
tb	set	tb+32*6*16
	endr

mask	incbin	a:mask.dat
dotsballs
	incbin	a:dotballs.dat
buffer_mask
	ds.b	16*32*6


Obj1	incbin	Objex.Dat

Screen	dc.l	screens+80*160
	dc.l	screens+380*160
Clock1	dc.w	0
Clock2	dc.w	0
Sync	dc.w	0
Object	dc.l	Obj1
BallPtr	dc.w	0
Par3D	ds.b	66
	RsReset
Az	rs.w	1 
Ay	rs.w	1 
Ax	rs.w	1 
AxInc	rs.w	1 
AyInc	rs.w	1 
AzInc	rs.w	1 
Tx	rs.l	1 
Ty	rs.l	1 
Tz	rs.l	1 

Sin2	incbin	Sin.DAT

		
	Section	bss


Points	ds.b	27*6
ZBuffer	ds.l	ZM*2
ZB	ds.b	ZM*2*108
screens	ds.b	300*160*2
	end
