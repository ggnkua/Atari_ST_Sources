*-------------------------------------------------------------------------*
		TEXT
*-------------------------------------------------------------------------*
		
		*------------*
		
VDI:		MACRO		
		
		movem.l	d0-d1/a0-a2,-(sp)
		
		lea	_V_ARRAYS,a0
		move	#\1,([a0])
		move.l	a0,d1
		
		moveq	#115,d0
		trap	#2
		
		movem.l	(sp)+,d0-d1/a0-a2
		
		ENDM
		
		*------------*
		
ESC:		MACRO		
		
		movem.l	d0-1/a0-2,-(sp)
		
		lea	_V_ARRAYS,a0
		move	#5,([a0])
		move	#\1,([a0],5*2.w)
		
		move.l	a0,d1
		moveq	#115,d0
		
		trap	#2
		
		movem.l	(sp)+,d0-1/a0-2
		
		ENDM
		
		*------------*
		
GDP:		MACRO		
		
		movem.l	d0-1/a0-2,-(sp)
		
		lea	_V_ARRAYS,a0
		move	#11,([a0])
		move	#\1,([a0],5*2.w)
		
		move.l	a0,d1
		moveq	#115,d0
		
		trap	#2
		
		movem.l	(sp)+,d0-1/a0-2
		
		ENDM
		
		****
		
		; appel vdi rapide
		; sans sauvegarde de registre
		
fvdi		MACRO		
		
		lea	_V_ARRAYS,a0
		move	#\1,([a0])
		move.l	a0,d1
		
		moveq	#115,d0
		trap	#2
		
		ENDM
		
		*------------*

*-------------------------------------------------------------------------*
		DATA
*-------------------------------------------------------------------------*

		*------------*
_V_ARRAYS:
		dc.l	_V_CONTROL
		dc.l	_V_INTIN
		dc.l	_V_PTSIN
		dc.l	_V_INTOUT
		dc.l	_V_PTSOUT
		
		*------------*

*-------------------------------------------------------------------------*
		BSS
*-------------------------------------------------------------------------*
		
		*------------*
_V_CONTROL
		ds.w	13
_V_INTIN		
		ds.w	256
_V_INTOUT		
		ds.w	32
_V_PTSIN
		ds.w	64
_V_PTSOUT
		ds.w	16
		
		*------------*

*-------------------------------------------------------------------------*