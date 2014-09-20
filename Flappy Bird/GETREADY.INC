
;'Get Ready' screen

	SECTION	TEXT
	
;----------------------------------
;Reset for 'Get Ready' screen
getreadyreset
	bsr		birdreset						;Reset bird
	move.w	#112,birdx
	moveq.w	#93,d0
	move.w	d0,birdy
	move.w	d0,titlewavebasey
	moveq.l	#0,d0
	move.w	d0,titlewave
	move.l	d0,bcdscore						;Reset game score
	move.w	d0,exitcount
	rts
	
;----------------------------------
;Repair screen after exit
getreadyrepaironexit
	move.l	#160*92+56,d0					;Screen offset
	bsr		titleclearbird
	bsr		getreadyrepairready
	bra		getreadyrepairfiretoflap		;(does RTS)
	
;----------------------------------
;'Get Ready' screen handler
getreadyhandler
	move.w	#RASTERSET_GETREADY,nextrasterset

	cmp.w	#2,exitcount					;Repair last screen on both swap buffers
	bgt.s	.norepair
	bsr		titlerepaironexit
.norepair

	bsr		getreadydrawready
	bsr		getreadydrawfiretoflap
	move.l	#160*92+56,d0					;Screen offset
	bsr		titleclearbird
	bsr		titleanimbird
	bsr		birddraw
	bsr		gamescoredraw
	bsr		floorupdate

	move.w	flapbutton,d0					;Read input
	beq.s	.noinput
	bsr		gamereset
	move.l	#gamehandler,handler
	lea		flapsfx,a0
	bsr		soundplay0
.noinput
	rts

;----------------------------------
;Draw 'Get Ready' logo
getreadydrawready					;12764 cycles, 25 rasters
	lea		getreadyimg,a0			;12
	move.l	offscreenbse,a1			;20
	lea		160*38+40(a1),a1		;8

	moveq.w	#17-1,d7				;4
.loop
	movem.l	(a0)+,d0-d6/a2-a6		;108	;Planes 1+2+3+4 for 96 pixels
	movem.l	d0-d6/a2-a6,(a1)		;104
	movem.l	(a0)+,d0-d6/a2			;76		;Next 64 pixels
	movem.l	d0-d6/a2,48(a1)			;72
	lea		160(a1),a1				;8		;Next line
	movem.l	(a0)+,d0-d6/a2-a6		;108
	movem.l	d0-d6/a2-a6,(a1)		;104
	movem.l	(a0)+,d0-d6/a2			;76
	movem.l	d0-d6/a2,48(a1)			;72
	lea		160(a1),a1				;8
	dbra.w	d7,.loop				;10/14
	rts

;----------------------------------
;Draw game instructions
getreadydrawfiretoflap				;3172 cycles, 6 rasters
	move.l	offscreenbse,a1			;20
	lea		160*84+64(a1),a1		;8

	INCLUDE	"\SRC\DATA\FIREFLAP.INC"		;Compiled sprite, 3144 cycles
	rts

;----------------------------------
;Repair 'Get Ready' logo
getreadyrepairready					;6688 cycles, 13 rasters
	move.l	offscreenbse,a1			;20
	lea		160*38+40(a1),a1		;8

	move.l	#$ffff0000,d0			;12		;Sky, colour index 1
	moveq.l	#0,d1					;4
	move.l	d0,d2					;4
	move.l	d1,d3					;4
	move.l	d0,d4					;4
	move.l	d1,d5					;4
	move.l	d0,d6					;4
	move.l	d1,a2					;4
	move.l	d0,a3					;4
	move.l	d1,a4					;4
	move.l	d0,a5					;4
	move.l	d1,a6					;4
	
	moveq.w	#17-1,d7				;4
.loop
	movem.l	d0-d6/a2-a6,(a1)		;104	;Clear
	movem.l	d0-d6/a2,48(a1)			;76
	lea		160(a1),a1				;8		;Next line
	movem.l	d0-d6/a2-a6,(a1)		;104
	movem.l	d0-d6/a2,48(a1)			;76
	lea		160(a1),a1				;8
	dbra.w	d7,.loop				;10/14
	rts
	
;----------------------------------
;Repair sky lines over game instructions, 304 cycles
REPAIRFIRETOFLAPLINES	MACRO
	movem.l	d0-d3,(a1)				;40
	movem.l	d0-d3,160(a1)			;44
	movem.l	d0-d3,320(a1)			;44
	movem.l	d0-d3,480(a1)			;44
	movem.l	d0-d3,640(a1)			;44
	movem.l	d0-d3,800(a1)			;44
	movem.l	d0-d3,960(a1)			;44
	ENDM

;----------------------------------
;Repair game instructions
getreadyrepairfiretoflap			;5024 cycles, 9.8 rasters
	move.l	skyimg,a0				;20
	lea		80*17+16(a0),a0			;8		;Offset to sky line
	move.l	offscreenbse,a1			;20
	lea		160*84+72(a1),a1		;8		;Matching line on screen

	move.l	#$ffff0000,d0			;12		;Sky, colour index 1
	moveq.l	#0,d1					;4
	move.l	d0,d2					;4
	move.l	d1,d3					;4

	REPAIRFIRETOFLAPLINES			;304	;Clear sky section, 28 lines
	lea		1120(a1),a1				;8
	REPAIRFIRETOFLAPLINES			;304
	lea		1120(a1),a1				;8
	REPAIRFIRETOFLAPLINES			;304
	lea		1120(a1),a1				;8
	REPAIRFIRETOFLAPLINES			;304
	lea		1112(a1),a1				;8

	moveq.w	#21-1,d7				;4		;Clear with sky image
.loop
	movem.l	(a0),d0-d6/a2			;76		;Read Planes 1+2+3+4 for 64 pixels of sky image
	lea		80(a0),a0				;8		:Next line in source sky
	movem.l	d0-d6/a2,(a1)			;72		;Write to screen
	lea		160(a1),a1				;8		;Next screen line
	dbra.w	d7,.loop				;10/14
	rts
