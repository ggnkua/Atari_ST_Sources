;	This routine builds a buffer for the palsplit command for
;	the first (raster) part of the demo

;	Pass it the following:
;	a0 = STOS array of addresses (controlled by sine wave) into 512 colour spectrum (512x colour words)
;	a1 = pal buffer address
;	a2 = pointer to variable that holds value to set colour 8.  This allows the STOS logo to change colour after rasters are cleared :)

;	All code by Tom on this one...............
;	Uses the same principle as the pal.tos screen



	moveq	#14,d0
	lea	14(a1),a5

loop:
	move.l	(a0)+,a3
	cmp.b	#7,d0
	beq	skip

ADDIT	SET	0

	REPT	100
	move.w	(a3)+,ADDIT(a1)
ADDIT	SET	ADDIT+32
	ENDR

skip:	lea	2(a1),a1
	dbf	d0,loop

	move.w	2(a2),d0

ADDIT	SET	0
	REPT	100
	move.w	d0,ADDIT(a5)
ADDIT	SET	ADDIT+32
	ENDR

	rts