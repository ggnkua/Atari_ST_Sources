;==============================
;=
;=  c2p
;=
;= 8bpp -> 4bpl (downscaled)
;= *slow*, non table method
;=
;= (a0)->source (a1)->dest.
;= a2.w: source increment
;==============================

		section	text
c2p		moveq.l	#0,d1		; Clear 4 planar words
		move.l	d1,d2

		moveq.l	#16-1,d0	; Convert a 16 pixel block

.block		move.b	(a0),d3		; Get a pixel
		addq.l	#3,a0		; Increment source pointer *slow* :)
		
		lsr.b	#4,d3		; Downscale

		add.l	d1,d1		; Next pixel
		add.l	d2,d2

		lsr.b	d3		; Scan and convert to 4 planes
		bcc.s	.clear1
		bset.l	#16,d1
.clear1		lsr.b	d3
		bcc.s	.clear2
		addq.w	#1,d1
.clear2		lsr.b	d3
		bcc.s	.clear3
		bset.l	#16,d2
.clear3		lsr.b	d3
		bcc.s	.clear4
		addq.w	#1,d2
.clear4		dbra	d0,.block

		move.l	d1,(a1)+	; Write out 16 pixels
		move.l	d2,(a1)+

		rts

		section	bss
TgaLoadBuffer	ds.b	3*max_x		; Loading buffer (one row b,g,r)
