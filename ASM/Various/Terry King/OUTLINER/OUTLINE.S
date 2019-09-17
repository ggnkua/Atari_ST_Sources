; Monochrome Outliner - Takes around 3.5 seconds for full screen
; Outlines image on physical screen and stores the result in
; the output buffer.
;
; Written by Terry King for Peter Hibbs c/o ICTARI 12/2/95
; Set TAB to 8.

; This outliner uses the following algorithm :
;
;    If the source pixel is white then do not plot a pixel at the
;    destination.
;
;    If any pixel surrounding the source pixel is white then plot
;    a pixel at the destination.
;
;    If all the pixels surrounding the source pixel are black then
;    do not plot a pixel at the desintion.
;
outline	move.w	#2,-(a7)
	trap	#14		; get physical screen address
	addq.l	#2,a7
	move.l	d0,a0
	lea	piccy+34,a1
	move.w	#8000-1,d1
clp	move.l	(a1)+,(a0)+	; copy picture to screen
	dbf	d1,clp

	move.l	d0,a0		; get screen address
	lea	80(a0),a0	; a0 -> x,y
	move.l	a0,a1		; a1 -> x-1,y
	move.l	a1,a2		; a2 -> x+1,y
	lea	buffer,a3
	lea	80(a3),a3	; a3 -> destination x,y 
	moveq	#7,d0		; d0 -> left pixel position
	moveq	#6,d1		; d1 -> middle pixel position
	moveq	#5,d2		; d2 -> right pixel position

	move.w	#398-1,d7	; 398 lines, top and bottom lines not used
y_loop	move.w	#640-1,d6
x_loop	btst.b	d1,(a0)		; test x,y
	beq.s	noplot
	btst.b	d0,(a1)		; test x-1,y
	beq.s	plot
	btst.b	d2,(a2)		; test x+1,y
	beq.s	plot
	btst.b	d1,-80(a0)	; test x,y-1
	beq.s	plot
	btst.b	d1,+80(a0)	; test x,y+1
	bne.s	noplot
plot	bset.b	d1,(a3)		; plot point
noplot	subq.w	#1,d0		; move bit position right (left pixel)
	bpl.s	xy1		; branch if still 0-7
	moveq	#7,d0		; otherwise reset bit position
	addq.l	#1,a1		; and increase to next screen location
xy1	subq.w	#1,d1		; move bit position right (middle pixel)
	bpl.s	xy2
	moveq	#7,d1
	addq.l	#1,a0		; increase screen positions and
	addq.l	#1,a3		; also increase destination address
xy2	subq.w	#1,d2		; move bit position right (right pixel)
	bpl.s	xy3
	moveq	#7,d2
	addq.l	#1,a2		; increase screen position
xy3	dbf	d6,x_loop
	dbf	d7,y_loop
	
	move.w	#2,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,a0		; copy buffer to screen
	lea	buffer,a1
	move.w	#8000-1,d0
dlp	move.l	(a1)+,(a0)+
	dbf	d0,dlp
	move.w	#8,-(a7)
	trap	#1		; wait for key
	addq.l	#2,a7
	clr	-(a7)
	trap	#1		; exit

buffer	ds.b	32000
piccy	incbin	title.pi3
