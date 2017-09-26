;
; ~C:backdrop%(x,y,L:gfx,L:screen)
;
	
backdrop
	movem.l	d1-7/a0-6,-(a7)
	movem	60(a7),d1-2
	movem.l	64(a7),a0-1
	and	#$1f,d1
	and	#$1f,d2
	lsl	#7,d1
	lea	(a0,d1.w),a0
	move	#32,d1
	sub	d2,d1
	move	d2,d3
	lsl	#2,d3
	lea	(a0,d3.w),a2	; first gfx block
	move.l	a0,a3		; second gfx block
	
	moveq	#5,d0
.ylp	move.l	a2,a4
	move.l	a3,a5
	move	d2,d3
	move	d1,d4
.lp1	subq	#1,d4
	blt.s	.lp2
	move	(a4)+,d5
	move	d5,(a1)
	move	d5,16(a1)
	move	d5,32(a1)
	move	d5,48(a1)
	move	d5,64(a1)
	move	d5,80(a1)
	move	d5,96(a1)
	move	d5,112(a1)
	move	d5,128(a1)
	move	d5,144(a1)
	move	(a4)+,d5
	move	d5,8(a1)
	move	d5,24(a1)
	move	d5,40(a1)
	move	d5,56(a1)
	move	d5,72(a1)
	move	d5,88(a1)
	move	d5,104(a1)
	move	d5,120(a1)
	move	d5,136(a1)
	move	d5,152(a1)
	lea	160(a1),a1
	bra.s	.lp1
.lp2	subq	#1,d3
	blt.s	.done2
	move	(a5)+,d5
	move	d5,(a1)
	move	d5,16(a1)
	move	d5,32(a1)
	move	d5,48(a1)
	move	d5,64(a1)
	move	d5,80(a1)
	move	d5,96(a1)
	move	d5,112(a1)
	move	d5,128(a1)
	move	d5,144(a1)
	move	(a5)+,d5
	move	d5,8(a1)
	move	d5,24(a1)
	move	d5,40(a1)
	move	d5,56(a1)
	move	d5,72(a1)
	move	d5,88(a1)
	move	d5,104(a1)
	move	d5,120(a1)
	move	d5,136(a1)
	move	d5,152(a1)
	lea	160(a1),a1
	bra.s	.lp2
.done2	dbf	d0,.ylp
	movem.l	(a7)+,d1-7/a0-6
	rts
