; Line routine by Axel/HMD (ST)

Ht	=	199	; screen height -1
Wd	=	319	; screen width -1



; Plane and offset conversion table for X coordinates

	lea	Offset,a0
	lea	(Wd+1)*4(a0),a1
	moveq	#0,d0
lp
	moveq	#$f,d1
	and.w	d0,d1
	move.w	#$8000,d2
	lsr.w	d1,d2
	move.w	d2,(a0)+
	moveq	#-1,d2
	lsr.w	d1,d2
	move.w	d2,(a1)+	
	moveq	#$f0,d1
	and.w	d0,d1
	asr.w	d1
	move.w	d1,(a0)+
	move.w	d1,(a1)+
	addq.w	#1,d0
	cmp.w	#Wd+1,d0
	blo.s	lp

; Conversion table for Y coordinates

	lea	MulY,a0
	move.w	#Ht,d0
	moveq	#0,d1
calc
	move.w	d1,(a0)+
	add.w	#160,d1
	dbra	d0,calc
	
	move.l	Screen(pc),a0	; screen address
	lea	MulY,a2
	lea	Offset,a3
	lea	(Wd+1)*4(a3),a1
	move.w	#3,d0		; x1
	move.w	#50,d1		; y1
	move.w	#317,d2		; x2
	move.w	#150,d3		; y2
	bsr	FastLine	; draw!
	
	Illegal			
	


X1	Equr	d0
Y1	Equr	d1
X2	Equr	d2
Y2	Equr	d3

ret	rts
FastLine
	cmp.w	Y1,Y2
	bge.s	.skip4
	exg	Y1,Y2
	exg	X1,X2
; Y1<Y2		
.skip4
	cmp.w	#Ht,Y1
	bgt.s	ret
	bls.s	.skip5
 
; Y1<0 => clipping

	muls	Y2,X1
	move.w	X2,d4
	muls	Y1,d4
	sub.l	d4,X1
	move.w	Y2,d4
	bmi.s	ret
	sub.w	Y1,d4
	divs	d4,X1
	sub.w	Y1,Y1

.skip5
	cmp.w	#Ht,Y2
	ble.s	.skip6

; Y2>Ht => clipping

	move.w	Y2,d4
	muls	X1,d4
	move.w	X2,d5
	muls	Y1,d5
	sub.l	d5,d4
	sub.w	X1,X2
	muls	#Ht,X2
	add.l	d4,X2
	sub.w	Y1,Y2
	divs	Y2,X2
	move.w	#Ht,Y2

.skip6
	cmp.w	X1,X2
	ble.s	.skip1
	exg	X1,X2
	exg	Y1,Y2
; X2<X1
.skip1
	cmp.w	#Wd,X2
	bgt.s	ret
	bls.s	.skip2
 
; X2<0 => clipping

	muls	X1,Y2
	move.w	Y1,d4
	muls	X2,d4
	sub.l	d4,Y2
	move.w	X1,d4
	bmi.s	ret
	sub.w	X2,d4
	divs	d4,Y2
	sub.w	X2,X2

.skip2
	cmp.w	#Wd,X1
	ble.s	.skip3

; X1>Wd => clipping

	move.w	X1,d4
	muls	Y2,d4
	move.w	Y1,d5
	muls	X2,d5
	sub.l	d5,d4
	sub.w	Y2,Y1
	muls	#Wd,Y1
	add.l	d4,Y1
	sub.w	X2,X1
	divs	X1,Y1
	move.w	#Wd,X1

.skip3
	sub.w	Y1,Y2		; Dy
	beq	HLine

	sub.w	X1,X2		; Dx
	beq	VLine

	neg.w	d2
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a3,d0.w),d0
	add.w	d1,d1
	add.w	(a2,d1.w),d0
	add.w	d0,a0
	swap	d0
	move.w	#160,d1
 
	tst.w	d3
	bpl.s	.skip9
	neg.w	d3
	neg.w	d1
 
.skip9
	cmp.w	d3,d2
	bgt	DxGtDy
	beq	DxEqDy
	
DxLtDy
	swap	d2		; Dx/Dy*65536
	clr.w	d2
	divu	d3,d2
	
	lsl.w	#4,d3
	neg.w	d3
	add.w	#16*Ht,d3
	moveq	#0,d4
	or.w	d0,(a0)
	jmp	.line(pc,d3.w)
.line
	rept	Ht
	add.w	d2,d4
	bcc.s	*+10		;.skip
	add.w	d0,d0
	bcc.s	*+6		;.skip
	subq.w	#8,a0
	moveq	#1,d0
;.skip	
	add.w	d1,a0
	or.w	d0,(a0)
	endr
	rts
	
DxGtDy
	swap	d3		; Dy/Dx*65536
	clr.w	d3
	divu	d2,d3

	lsl.w	#3,d2
	move.w	d2,d4
	add.w	d4,d4
	add.w	d4,d2
	neg.w	d2
	add.w	#24*Wd,d2
	moveq	#0,d4
	move.w	(a0),d5
	or.w	d0,d5
	jmp	.line(pc,d2.w)
.line
	rept	Wd
	add.w	d3,d4
	bcc.s	*+8		;.skip1
	move.w	d5,(a0)
	add.w	d1,a0
	move.w	(a0),d5
;.skip1
	add.w	d0,d0
	bcc.s	*+10		;.skip2
	move.w	d5,(a0)
	moveq	#1,d0
	subq.w	#8,a0
	move.w	(a0),d5
;.skip2
	or.w	d0,d5
	endr
	move.w	d5,(a0)
	rts
	
DxEqDy
	add.w	d2,d2
	add.w	d2,d2
	move.w	d2,d3
	add.w	d3,d3
	add.w	d3,d2
	neg.w	d2
	add.w	#12*Ht,d2
	or.w	d0,(a0)
	jmp	.line(pc,d2.w)
.line
	rept	Ht
	add.w	d0,d0
	bcc.s	*+6		;.skip
	subq.w	#8,a0
	moveq	#1,d0
;.skip	
	add.w	d1,a0
	or.w	d0,(a0)
	endr
	rts
	
VLine		
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a3,d0.w),d0
	
	tst.w	d3
	bpl.s	.skip
	add.w	d3,d1
	neg.w	d3
.skip
	add.w	d1,d1
	add.w	(a2,d1.w),d0
	add.w	d0,a0
	swap	d0
 
 	neg.w	d3
	add.w	d3,d3
	add.w	d3,d3
	add.w	#4*Ht,d3
	or.w	d0,(a0)
	jmp	.line(pc,d3.w)
.line
k	set	Ht*160
	rept	Ht
	or.w	d0,k(a0)
k	set	k-160
	endr
	rts

HLine
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a1,d0.w),d0
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a1,d2.w),d2
	add.w	d1,d1
	move.w	(a2,d1.w),d1
	add.w	d0,d1
	add.w	d1,a0

	sub.w	d0,d2
	bmi.s	.cont
	swap	d0
	swap	d2
	not.w	d0
	and.w	d2,d0
	or.w	d0,(a0)
	rts
.cont
	swap	d0
	not.w	d0
	or.w	d0,(a0)
	add.w	d2,a0
	moveq	#-1,d0
	asr.w	d2
	jmp	.line+4(pc,d2.w)
k	set	18*8
	rept	18
	move.w	d0,k(a0)
k	set	k-8
	endr
.line	
	swap	d2
	or.w	d2,(a0)
	rts



Offset	ds.l	(Wd+1)*2
MulY	ds.w	Ht+1
Screen	dc.l	$78200
