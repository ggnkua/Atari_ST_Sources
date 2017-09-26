;
; ~C:fuzz%(word width,pixel height,l:screen)
;	
	
fuzz	movem.l	d1-7/a0-6,-(a7)
	movem	60(a7),d6-7
	move.l	64(a7),a6
	move	#$11,-(A7)
	trap	#14
	addq.l	#2,a7
	subq	#1,d6
	bmi.s	.end
	subq	#1,d7
	bmi.s	.end
.fc	movem.l	d6/a6,-(a7)
.fe	move	d0,d1
	lsl	#1,d0
	sub	d1,d0
	add	d0,d0
	add	d0,d0
	add	d1,d0
	addq	#1,d0
	move	d0,d1
	lsr	#3,d1
	eor	d0,d1
	move	d1,0(a6)
	move	d1,2(a6)
	move	d1,4(a6)
	move	d1,6(a6)
	addq.l	#8,a6
	dbf	d6,.fe
	movem.l	(a7)+,d6/a6
	lea	160(a6),a6
	dbf	d7,.fc
.end	movem.l	(a7)+,d1-7/a0-6
	rts	
