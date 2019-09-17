;Main cursor shape equates (shapes 6 & 7 not often used)

arrow	equ	0
text_cursor	equ	1
bee	equ	2
finger	equ	3
hand	equ	4
crosshair	equ	5

;Move this MACRO definition to start of source file (if you want to use it)

ms_shape	MACRO		\ident_code
	move.l	d0,-(sp)
	move	\1,d0
	bsr	mouse_shape
	move.l	(sp)+,d0
	ENDM

;Set new mouse shape
;ENTRY d0=mouse ident code (0-7 for GEM mice and 8-n for user mice)
;EXIT  mouse shape changed

mouse_shape	movem.l	d0-d2/a0-a2,-(sp)
	and.l	#$ffff,d0
	cmp	#8,d0	is it a GEM mouse ?
	blt	mouse_shape1	yes so skip

	sub	#8,d0	calc mouse data address
	mulu	#74,d0
	lea	mouse_data,a0
	add.l	d0,a0	and point a0 at data

	move	#255,d0	255=user design code
mouse_shape1	graf_mouse	d0,a0	change shape
	movem.l	(sp)+,d0-d2/a0-a2
	rts

;Mouse data buffer (74 bytes/shape) Move to BSS section and set pathname

mouse_data	incbin	D:\MOUSE_KA\MICE\1FRAME\BOOMBOMB.DAT
	incbin	D:\MOUSE_KA\MICE\1FRAME\BELL.DAT
