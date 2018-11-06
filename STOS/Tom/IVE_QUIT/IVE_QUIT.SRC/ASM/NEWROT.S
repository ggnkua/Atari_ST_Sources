* This routine is the guts of the main screen.
* It has a rotation matrix (precalculated - transposition) incbinned
* It gets passed chunky gfx data (15x16 window into each 32x16 character data)
* It then performs the rotation and builds a buffer of data for the palette split
* This is then picked up by the newpal interrupt handler!

* All code and concept by Tom........



;PASS d0=angle (0-180)
;     a0=bitmap data
;     a1=palsplit buffer



	lea	rtab,a4			; a4=rotation jump table
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a4,d0.w),d0		; d2 now has pointer
	move.l	d0,a5			; a5 now points to rot table!


	REPT	15*16
	move.l	a0,a2			;1
	move.w	(a5)+,d2		; index from rot table into d2
	adda.w	d2,a2
	move.w	(a2),(a1)+
	ENDR

	rts

rtab:
R	SET	0
	REPT	180
	dc.l	rot+R
R	SET	R+15*16*2
	ENDR



rot:	incbin	newrot.dat
