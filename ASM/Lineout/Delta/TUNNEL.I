; Tunnel generation library. For convenience only, basicly.

; Generate offsettable for tunnel.
; Only one quadrant is actually calculated. The rest is (inverse) mirrored.
; 0 1  + -
; 2 3  - +
Tunnel.genOffsetMap:
	lea	Tunnel.offsetMap,a0
	lea	320*2(a0),a1
	movea.l	a0,a2
	adda.l	#320*199*2,a2
	movea.l	a0,a3
	adda.l	#320*200*2,a3
	move.l	#199,d7				; d7.l=y (15:1)

.yloop:	move.l	#319,d6				; d6.l=x (15:1)

.xloop:
; Calc ringnumber..
	move.l	d6,d0
	move.l	d7,d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1
; d1.l=trunc(2x)^2+trunc(2y)^2
	bsr	Math.sqrt
; d0.l=sqrt[trunc(2x)^2+trunc(2y)^2]
	move.l	#5000<<16,d5			; d5.l=radius of tunnel (16:16)
	divu.l	d0,d5
	andi.w	#$007F,d5
	lsl.w	#8,d5

; Calc raynumber.. tan(rayangle)=y/x, rayangle=arctan(y/x)
	move.l	d7,d0
	move.l	d6,d1
	bsr	Frac.atan2
; Convert radians to degrees [0..127].
	muls.l	#20860/2,d1
	swap	d1
	lsr.w	#8,d1
;	andi.w	#$007F,d1
	move.b	d1,d5
	move.w	d5,(a0)+			; d1.w=raynumber, store it.
	move.w	d5,-(a3)
	not.b	d5
	andi.w	#$7F7F,d5
	move.w	d5,(a2)+
	move.w	d5,-(a1)

	subq.w	#2,d6
	bpl.s	.xloop

	adda.w	#160*2,a0
	adda.w	#480*2,a1
	suba.w	#480*2,a2
	suba.w	#160*2,a3
	subq.w	#2,d7
	bpl.s	.yloop
	rts

Tunnel.calcFlareOctant:
	lea	Tunnel.squareTable,a0
	move.w	#-255,d0

.calc_sqr_loop:
	move.w	d0,d1
	muls.w	d1,d1
	move.l	d1,(a0)+
	addq.w	#2,d0
	bmi.s	.calc_sqr_loop

	lea	Tunnel.flareOctant,a0
	move.l	#256-1,d7
	lea	Tunnel.squareTable,a4

.yloop:	move.l	#256-1,d6
	move.l	(a4)+,d5
	lea	Tunnel.squareTable,a5

.xloop:	cmp.l	d6,d7
	blt.s	.next

; In upper triangle, so calc it..

; Calc raynumber.. tan(rayangle)=y/x, rayangle=arctan(y/x)
	move.l	d7,d0
	move.l	d6,d1
	bsr.l	Frac.atan2
; Convert radians to degrees [0..127].
	lsr.l	#8,d1
	mulu.w	#20860,d1
	lsr.l	#8,d1
	move.w	d1,d4

; Calc ringnumber..
	move.l	(a5),d1
	add.l	d5,d1
; d1.l=trunc(2x)^2+trunc(2y)^2
	bsr.l	Math.sqrt
; d0.l=sqrt[trunc(2x)^2+trunc(2y)^2]
	divu.w	#362,d0				; d0=/(2*sqrt[2*(128)^2])
	lsr.w	#8,d0
	move.b	d0,d4
	move.w	d4,(a0)+

.next:	addq	#4,a5
	subq.w	#2,d6
	bpl.s	.xloop

	subq.w	#2,d7
	bpl.s	.yloop

	rts


	BSS

Tunnel.offsetMap:
	DS.W	320*200
Tunnel.flareOctant:
	DS.W	128*128/2
Tunnel.squareTable:
	DS.L	128