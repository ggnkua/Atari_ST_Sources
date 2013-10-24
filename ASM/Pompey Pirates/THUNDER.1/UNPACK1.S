; ** JPM 1989
; 
; ** THUNDER V1.1
;
; ** The UNPACK routines.
;
; ** A2 - Address of packed data (header included).
; ** A4 - Address to unpack the data to.
;
; ** Uses A2-A4.
; ** Uses D0-D3

unpack	move.l	a2,a3			Copy start.
	add.l	#12,a2			Skip packed header info.
	add.l	-4(a2),a3		length + start = finish address.
	moveq	#0,d0
	move.l	d0,d1
m1	moveq	#0,D3
	move.b	(a2)+,D3
	lsl.w	#8,D3
	move.b	(a2)+,D3
	btst	#$e,D3
	beq.s	n2
	btst	#$f,D3
	bne.s	u1
	bra.s	u2
n2	btst	#$f,D3
	beq.s	n1
	bclr	#$f,D3
	move.b	(a2)+,d1
n1	add.w	#$2000,D3
s4	lsr.w	#1,D3
	BEQ.S	s3
	BCC.S	s1
	move.b	d1,(a4)+
	bra.s	s2
s1	move.b	(a2)+,(a4)+
s2	bra.s	s4
s3	cmpa.l	a3,a2			IF not EOF THEN
	blt.s	m1			back and do some more.
exit	rts

; ** UNRUN.  Nice simple loop!!

u2:	bclr	#14,D3
	move.b	(a2)+,d2
l1	move.b	d2,(a4)+
	dbf	D3,l1
	bra.s	m1

; ** REPEAT.

u1:	moveq	#0,d0
	bclr	#14,D3
	bclr	#15,D3
	lsl.l	#8,D3
	move.b	(a2)+,D3
	swap	D3
	move.b	D3,d0
	move.w	#0,D3
	swap	D3
	subq.l	#1,d0
	move.l	a4,a1
	sub.l	D3,a1
l2	move.b	(a1)+,(a4)+
	dbf	d0,l2
	bra.s	m1
