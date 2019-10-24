; RC_INTERSECT


; tw=min(x2+w2,x1+w1)
; th=min(y2+h2,y1+h1)
; tx=max(x2,x1)
; ty=max(y2,y1)
; x2=tx
; y2=ty
; w2=tw-tx
; h2=th-ty
; d0=tw>tx && th>ty

; a0=GRECT1
; a1=GRECT2

	globl rc_intersect;

x	equ	0
y	equ	2
w	equ	4
h	equ	6

rc_intersect:
	movem.l	d1-d4/d7,-(sp)
	move.w	x(a1),d1
	move.w	x(a0),d7
	move.w	d1,d3
	cmp.w	d3,d7
	ble.s	c3
	move.w	d7,d3
c3:	add.w	w(a1),d1
	add.w	w(a0),d7
	cmp.w	d7,d1
	ble.s	c1
	move.w	d7,d1
c1:	move.w	y(a1),d2
	move.w	y(a0),d7
	move.w	d2,d4
	cmp.w	d4,d7
	ble.s	c4
	move.w	d7,d4
c4:	add.w	h(a1),d2
	add.w	h(a0),d7
	cmp.w	d7,d2
	ble.s	c2
	move.w	d7,d2
c2:	cmp.w	d3,d1
	sgt.b	d0
	cmp.w	d4,d2
	sgt.b	d7
	and.b	d7,d0
	ext.w	d0
	move.w	d3,x(a1)
	move.w	d4,y(a1)
	sub.w	d3,d1
	sub.w	d4,d2
	move.w	d1,w(a1)
	move.w	d2,h(a1)
	movem.l	(sp)+,d1-d4/d7
	rts
	
		