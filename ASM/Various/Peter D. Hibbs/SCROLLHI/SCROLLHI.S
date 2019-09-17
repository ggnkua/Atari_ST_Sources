scroll_lines	equ	23
scroll_top	equ	0
scroll_left	equ	0
scroll_width	equ	80

;Scroll area of screen up one line and blank bottom line
;ENTRY screen = start address of screen
;      scroll_lines = Number of lines to scroll (1-23)
;      scroll_top   = Top line of scroll area (0-23)
;      scroll_left  = Left most column to scroll (0-78)
;      scroll_width = Number of columns to scroll (1-80)
;EXIT  window area scrolled up one text line

scroll_hi	movem.l	a1-a2/d0-d2,-(sp)

	move.l	screen,a2		get screen addr
	move	#scroll_lines*16-1,d2	set up counters
	move	#scroll_width-1,d0	and pointers
	add	#80*scroll_top*16+scroll_left,a2
	move.l	a2,a1
	add	#80*16,a1

scroll_hi1	movem.l	a1-a2/d0,-(sp)	
scroll_hi2	move.b	(a1)+,(a2)+		copy data up
	dbra	d0,scroll_hi2
	movem.l	(sp)+,a1-a2/d0
	add	#80,a2
	add	#80,a1
	dbra	d2,scroll_hi1		

	move	#16-1,d0		clear bottom line
scroll_hi3	move	#scroll_width-1,d1
	move.l	a2,-(sp)
scroll_hi4	clr.b	(a2)+
	dbra	d1,scroll_hi3
	move.l	(sp)+,a2
	add	#80,a2
	dbra	d0,scroll_hi3

	movem.l	(sp)+,a1-a2/d0-d2
	rts

screen	ds.l	1	screen address