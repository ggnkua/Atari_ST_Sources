;
; Box collision detection.
;
; This should mainly be used for two boxes of different sizes, see the
; manual page for more details.
;
; ~C:box_hit(x1,y1,width1,height1,x2,y2,width2,height2)
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

box_hit	movem.l	d1-7,-(a7)
	movem	32(a7),d0-7	; get all values in one instruction
	add	d4,d6		; x2+width2
	cmp	d6,d0		; compare with x1
	bgt.s	.miss		; less than, miss
	add	d0,d2		; x1+width1
	cmp	d2,d4		; compare with x2
	bgt.s	.miss		; less than, miss
	add	d5,d7		; y2+height2
	cmp	d7,d1		; compare with y1
	bgt.s	.miss		; greater than, miss
	add	d1,d3		; y1+height1
	cmp	d3,d5		; compare with y2
	bgt.s	.miss		; greater than, miss
.hit	moveq	#-1,d0		; otherwise a hit ! return -1
	movem.l	(a7)+,d1-7
	rts
.miss	moveq	#0,d0		; miss, return 0
	movem.l	(a7)+,d1-7
	rts