;rockyone		 for MI-3				01.01.2021
;
;
;	Save RST file of NeochromeMaster 2.28
;
; Soure : adresse des palettes
; But   : adresse de sauvegarde ( 6800 bytes )
;
;		call rsr_s( L but, L source )
;		*****************************
;
;
; Return file size in d0
;-------------------------------------------------------------------------
	movem.l	d1-d7/a0-a6,-(sp)
	movem.l	60(sp),a0-a1
	lea.l	200*34(a0),a2
	moveq.l	#0,d0

copy:	move.w	d0,(a0)+		; index palette
	movem.l	(a1)+,d2-d7/a4-a5
	movem.l	d2-d7/a4-a5,(a0)
	lea.l	32(a0),a0
	addq.l	#1,d0
	cmpa.l	a0,a2
	bhi.s	copy

	move.l	#6800,d0		; file size
	movem.l	(sp)+,d1-d7/a0-a6
	rts
	end		