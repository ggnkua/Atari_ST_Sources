;
; Decompressor for Degas Elite image.
;
; This one was also written first in GFA then converted.
;
; 	~C:decompress(L:source,L:destination)
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

decompress
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	64(a7),a5		; compressed screen
	move.l	68(a7),a6		; destination screen

	move.l	#$00070001,d0		; offsets to next screen word (1/7)
	move	#199,d2			; 200 lines
lines	moveq	#3,d5			; 4 bit planes
planes	moveq	#40,d7			; X coord

drawln	moveq	#0,d3			; make sure high byte is clear
	move.b	(a5)+,d4		; get byte
	cmp.b	#127,d4			
	bhi.s	comp			; compressed if >127

uncomp	move.b	d4,d3			; otherwise uncompress line
	sub	d3,d7			; subtract from width count
	subq	#1,d7
unloop	move.b	(a5)+,(a6)		; direct copy
	add	d0,a6			; next screen word
	swap	d0			; swap word increase (7/1)
	dbf	d3,unloop		; number of bytes to copy
	bra.s	drw_ret			; finished this bit ...
	
comp	move.b	d4,d3
	neg.b	d3			; negate to make positive
	sub	d3,d7			; subtract from width count
	subq	#1,d7
	move.b	(a5)+,d6
coloop	move.b	d6,(a6)			; keep copying this byte
	add	d0,a6
	swap	d0
	dbf	d3,coloop
	
drw_ret	tst	d7			; completed 40 bytes width ?
	bgt.s	drawln			; not yet, so loop

	lea	-158(a6),a6
	dbf	d5,planes		; next bit plane
	lea	152(a6),a6
	dbf	d2,lines		; next line

	movem.l	(a7)+,d0-d7/a0-a6
	rts
