;----------------------------------
;Draw masked medal background lines
MEDALBKGLINE1	MACRO				;260 cycles
	move.l	#$FFE0FFE0,d0			;12
	and.l	d0,(a0)+				;20
	and.l	d0,(a0)+				;20
	moveq.l	#0,d1					;4
	move.l	d1,d2					;4
	move.l	d1,d3					;4
	move.l	d1,d4					;4
	move.l	d1,d5					;4
	move.l	d1,d6					;4
	movem.l	d1-d6,(a0)				;56
	movem.l	d1-d6,24(a0)			;60
	lea		48(a0),a0				;8
	move.l	#$07FF07FF,d0			;12
	and.l	d0,(a0)+				;20
	and.l	d0,(a0)					;20
	lea		160-60(a0),a0			;8
	ENDM

MEDALBKGLINE2	MACRO				;388 cycles
	move.l	#\1,d0					;12
	and.l	d0,(a0)					;20
	or.l	#\2,(a0)+				;28
	and.l	d0,(a0)					;20
	or.l	#\3,(a0)+				;28
	move.l	#\4,d1					;12
	move.l	#\5,d2					;12
	move.l	d1,d3					;4
	move.l	d2,d4					;4
	move.l	d1,d5					;4
	move.l	d2,d6					;4
	movem.l	d1-d6,(a0)				;56
	movem.l	d1-d6,24(a0)			;60
	lea		48(a0),a0				;8
	move.l	#\6,d0					;12
	and.l	d0,(a0)					;20
	or.l	#\7,(a0)+				;28
	and.l	d0,(a0)					;20
	or.l	#\8,(a0)				;28
	lea		160-60(a0),a0			;8
	ENDM

MEDALBKGLINE3	MACRO				;348 cycles
	move.l	#\1,d0					;12
	and.l	d0,(a0)					;20
	or.l	#\2,(a0)+				;28
	and.l	d0,(a0)					;20
	or.l	#\3,(a0)+				;28
	movem.l	a1-a6,(a0)				;56
	movem.l	a1-a6,24(a0)			;60
	lea		48(a0),a0				;8
	move.l	#\4,d0					;12
	and.l	d0,(a0)					;20
	or.l	#\5,(a0)+				;28
	and.l	d0,(a0)					;20
	or.l	#\6,(a0)				;28
	lea		160-60(a0),a0			;8
	ENDM

MEDALBKGLINE4	MACRO				;252 cycles
	and.l	d0,(a0)+				;20
	and.l	d0,(a0)					;20
	or.l	d1,(a0)+				;20
	movem.l	a1-a6,(a0)				;56
	movem.l	a1-a6,24(a0)			;60
	lea		48(a0),a0				;8
	and.l	d2,(a0)+				;20
	and.l	d2,(a0)					;20
	or.l	d3,(a0)					;20
	lea		160-60(a0),a0			;8
	ENDM

MEDALBKGLINE5	MACRO				;332 cycles
	and.l	d0,(a0)+				;20
	and.l	d0,(a0)					;20
	or.l	d1,(a0)+				;20
	movem.l (a1)+,d4-d7				;44
	movem.l d4-d7/a3-a6,(a0)		;72
	lea		32(a0),a0				;8
	move.l	(a1)+,(a0)+				;20
	move.l	(a1)+,(a0)+				;20
	move.l	(a1)+,(a0)+				;20
	move.l	(a1)+,(a0)+				;20
	and.l	d2,(a0)+				;20
	and.l	d2,(a0)					;20
	or.l	d3,(a0)					;20
	lea		160-60(a0),a0			;8
	ENDM

MEDALBKGLINE6	MACRO				;312 cycles
	and.l	d0,(a0)+				;20
	and.l	d0,(a0)					;20
	or.l	d1,(a0)+				;20
	movem.l d6-d7/a3-a6,(a0)		;56
	lea		24(a0),a0				;8
	move.l	(a1)+,(a0)+				;20
	move.l	(a1)+,(a0)+				;20
	move.l	(a1)+,(a0)+				;20
	move.l	(a1)+,(a0)+				;20
	move.l	(a1)+,(a0)+				;20
	move.l	(a1)+,(a0)+				;20	
	and.l	d2,(a0)+				;20
	and.l	d2,(a0)					;20
	or.l	d3,(a0)					;20
	lea		160-60(a0),a0			;8
	ENDM

;----------------------------------

	;Compiled sprite, 16328 cycles, 32 rasters

	sub.l	a1,a1					;8		;Setup movem.l a1-a6,(a0) for colour 8
	move.l	#$0000FFFF,a2			;12
	move.l	a1,a3					;4
	move.l	a2,a4					;4
	move.l	a1,a5					;4
	move.l	a2,a6					;4
	
	MEDALBKGLINE1					;260
	MEDALBKGLINE2	$FF80FF80,$001F001F,$001F0000,$FFFFFFFF,$FFFF0000,$01FF01FF,$F800F800,$F8000000	;388
	MEDALBKGLINE3	$FF00FF00,$00600060,$0060001F,$00FF00FF,$06000600,$0600F800	;348
	MEDALBKGLINE3	$FF00FF00,$00000000,$0000007F,$00FF00FF,$00000000,$0000FE00	;348
	MEDALBKGLINE3	$FE00FE00,$00800080,$0080007F,$007F007F,$01000100,$0100FE00	;348

	move.l	#$FE00FE00,d0			;12		;Setup for middle masks
	move.l	#$000000FF,d1			;12
	move.l	#$007F007F,d2			;12
	move.l	#$0000FF00,d3			;12
	
	moveq.w	#4-1,d7					;4		;4 blank lines
.loop
	MEDALBKGLINE4					;252
	dbra.w	d7,.loop				;10/14
	
	lea		medalscoreimg,a1		;12		;Source text
	REPT 6							;1992
	MEDALBKGLINE5
	ENDR
	sub.l	a1,a1					;8		;Restore a1

	moveq.w	#14-1,d7				;8		;14 blank lines
.loop2
	MEDALBKGLINE4					;252
	dbra.w	d7,.loop2				;10/14

	lea		medalbestimg,a1			;12
	move.w	newbest,d4				;16		;Do have new high-score?
	beq.s	.nohighscore			;10/8	;No
	lea		168(a1),a1				;8
.nohighscore
	move.l	a3,d6					;4
	move.l	a4,d7					;4
	REPT 7							;2184
	MEDALBKGLINE6
	ENDR
	sub.l	a1,a1					;8
	
	moveq.w	#16-1,d7				;8		;16 blank lines
.loop3
	MEDALBKGLINE4					;252
	dbra.w	d7,.loop3				;10/14

	MEDALBKGLINE3	$FE00FE00,$00800000,$000000FF,$007F007F,$01000000,$0000FF00	;348
	MEDALBKGLINE3	$FF00FF00,$00400000,$0000007F,$00FF00FF,$02000000,$0000FE00	;348
	MEDALBKGLINE3	$FF00FF00,$00600000,$0000007F,$00FF00FF,$06000000,$0000FE00	;348
	MEDALBKGLINE2	$FF80FF80,$001F0000,$0000001F,$FFFF0000,$0000FFFF,$01FF01FF,$F8000000,$0000F800	;388
	MEDALBKGLINE1					;260
