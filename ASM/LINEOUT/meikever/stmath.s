SINTABLE_LEN:	=	2048
SIN1:		=	13176774	; sin(2ã/2048)*2^32
COS1:		=	4294947083	; cos(2ã/2048)*2^32

; input:
; d0.l=s (sh,sl)
; d2.l=d (dh,dl)
; output:
; d1.l=rhi=sl*dl + (sl*dh).lo<<16 +(sh*dl).lo<<16
; d2.l=rlo=sh*dh + (sl*dh).hi+x0 + (sh*dl).hi+x1
lmulu:	move.l	d2,d3
	swap	d3			; d3.w=dh
	move.w	d3,d1			; d1.w=dh
	move.w	d2,d4			; d4.w=dl
	mulu.w	d0,d2			; d2.l=dl*sl
	mulu.w	d0,d3			; d3.l=dh*sl
	swap	d0			; d0.w=sh
	mulu.w	d0,d1			; d1.l=dh*sh
	mulu.w	d0,d4			; d4.l=dl*sh

	move.l	d3,d5
	swap	d5
	clr.w	d5			; d5.l=(dh*sl).lo<<16
	add.l	d5,d2			; d2.l=dl*sl + (dh*sl).lo<<16

	clr.w	d3
	swap	d3			; d3.l=(dh*sl).hi
	addx.l	d3,d1			; d1.l=dh*sh + (dh*sl).hi+x0

	move.l	d4,d5
	swap	d5
	clr.w	d5			; d5.l=(dl*sh).lo<<16
	add.l	d5,d2			; d2.l=rlo=dl*sl + (dh*sl).lo<<16 + (dl*sh).lo<<16

	clr.w	d4
	swap	d4			; d4.l=(dl*sh).hi
	addx.l	d4,d1			; d1.l=rhi=dh*sh + (dh*sl).hi+x0 + (dl*sh).hi+x1
	
	rts

init_sincos_table:
	lea	sine_tbl,a0
	moveq	#-1,d0
	lsr.l	#1,d0				; d0.l=cos[0]=.99999~=1
	moveq	#0,d1				; d1.l=sin[0]=0
	move.l	#SIN1,d6
	move.l	#COS1,d7
	suba.l	a1,a1
; n=1
.loop:	swap	d0				; d0.w=high word of cos[n]
	swap	d1				; d1.w=high word of sin[n]
	move.w	d1,2+(SINTABLE_LEN)*3(a0)	; copy +sin[n] in cos-4th quadrant
	move.w	d0,SINTABLE_LEN*1(a0)		; copy +cos[n] in sin-2nd quadrant
	sub.w	d1,2+(SINTABLE_LEN)*1(a0)	; copy -sin[n] in cos-2nd quadrant
	sub.w	d0,SINTABLE_LEN*3(a0)		; copy -cos[n] in sin-4th quadrant
	sub.w	d0,2+(SINTABLE_LEN)*2(a0)	; copy -cos[n] in cos-3rd quadrant
	sub.w	d1,SINTABLE_LEN*2(a0)		; copy -sin[n] in sin-3rd quadrant
	move.w	d1,(a0)+			; save sin[n] (16 bit signed value) in first quadrant
	move.w	d0,(a0)+			; save cos[n] (16 bit signed value) in first quadrant
	swap	d0				; d0.l=cos[n] (16:16)
	swap	d1				; d1.l=sin[n] (16:16)
	move.l	d1,d4				; d4.l=sin[n] (16:16)
	move.l	d0,d5				; d5.l=cos[n] (16:16)
	move.l	d1,d2				; d2.l=sin[n] (16:16)
	move.l	d0,d3				; d3.l=cos[n] (16:16)

	movem.l	d0/d2/d4/d5,-(sp)
	move.l	d6,d0
	move.l	d1,d2
	bsr	lmulu				; d6,d3:d1, d3.l=sin[1]*sin[n-1]
	move.l	d1,d3
	move.l	d2,d1
	movem.l	(sp)+,d0/d2/d4/d5

	movem.l	d1/d3-d5,-(sp)
	move.l	d0,d2
	move.l	d7,d0
	bsr	lmulu				; d7,d2:d0, d2.l=cos[1]*cos[n-1]
	move.l	d2,d0
	move.l	d1,d2
	movem.l	(sp)+,d1/d3-d5

	movem.l	d0/d2-d4,-(sp)
	move.l	d6,d0
	move.l	d5,d2
	bsr	lmulu				; d6,d1:d5, d0.l=sin[1]*cos[n-1]
	move.l	d2,d5
	movem.l	(sp)+,d0/d2-d4

	movem.l	d1-d3/d5,-(sp)
	move.l	d7,d0
	move.l	d4,d2
	bsr	lmulu				; d7,d0:d4, d1.l=cos[1]*sin[n-1]
	move.l	d2,d4
	move.l	d1,d0
	movem.l	(sp)+,d1-d3/d5

	sub.l	d3,d2				; d2.l=(cos1*cos[n-1])-(sin1*sin[n-1])
	add.l	d0,d1				; d1.l=sin[n+1]=(sin1*cos[n])+(cos1*sin[n])
	move.l	d2,d0				; d0.l=cos[n+1]=(cos1*cos[n])-(sin1*sin[n])
	addq	#1,a1
	cmpa.w	#SINTABLE_LEN/4,a1
	blt	.loop

	rts

