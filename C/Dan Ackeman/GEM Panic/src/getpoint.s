/* Collision Detection Routine */

.text

.globl get_point

get_point:
; PHD: Pure C passes parameters in registers (by default). 
;	movea.l	4(sp),a0	; pointer to MFDB
	movea.l	(a0),a1		; .fd_addr
	move.w	6(a0),d1	; .fd_height
	move.w	8(a0),d2	; .fd_wdwidth
	movea.l	a1,a0
	muls	d2,d1
	ext.l	d2
	lsl.l	#1,d2
G1:	subq.l	#2,d1
	bmi.s	G4
	move.l	(a1)+,d0
	tst.l	d0
	beq.s	G1
	suba.l	#4,a1
G2:	move.b	(a1)+,d0
	tst.b	d0
	beq.s	G2
	suba.l	#1,a1
	move.l	a1,d1
	sub.l	a0,d1
	divs	d2,d1
	swap	d1
	lsl.w	#3,d1
	subq.w	#1,d1
G3:	addq.w	#1,d1
	lsl.b	#1,d0
	bcc.s	G3
	move.l	d1,d0
	rts
G4:	addq.l	#1,d1
	bne.s	G5
	move.w	(a1),d0
	tst.w	d0
	bne.s	G2
G5:	moveq.l	#-1,d0
	rts
	END