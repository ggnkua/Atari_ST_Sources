/************************************************************************
 *																		*
 * 	Modul TRAP1.S														*
 *																		*
 *	Copyright 1991: Oliver Spornitz und Detlev Nolte 					*
 *																		*
 *	Funktion: H„ngt sich in den GEMDOS-Trap ein und berwacht die		*
 *	Funktionen: '0  Pterm0', 											*
 *				'49 Ptermres',											*
 *				'75 Pexec'    und 										*
 *				'76 Pterm'												*
 *																		*
 *	Wird eine dieser Funktionen aufgerufen, verzeigt die Traproutine	*
 *	in die entsprechenden Unterroutinen zum Aufl”sung wechseln.			*
 ************************************************************************/


		xdef	install
		xdef    pexec_name
		xref	_pexec_setres
		xref	_pterm_setres


trap1_vec	= $84
		
		
				
		; GEMDOS-TRAP-Routine installieren

install:	lea		OldTRAP1(pc),a0      	; Alten Trap1Vektor retten
        	move.l	trap1_vec,(a0)       	;
            lea		MYTRAP1(pc),a0       	;
            move.l	a0,trap1_vec         	; und neuen Vektor eintragen
			rts


		; Die umgeleitete TRAP1-Routine :
		; XBRA-Protokoll

			DC.b 	"XBRAPWSW"				; !! Ja, das ist alles !!
OldTRAP1:	DC.l 	0

MYTRAP1:	tst.w	change					; Aufl”sung „ndern ?
			beq		oldtrap1				; nein -> weiter
			;movem.l	a2-a6/d2-d7,-(sp)
			lea	6(sp),a0					; USP nach A0

			move.w	(a7),d0					; Statusregister nach d0
			btst	#13,d0					; SUPER Bit gesetzt ?
			bne		trap1_supercall
			move.l	USP,a0
trap1_supercall:
			move.w	(a0),d0					; gemdos fn
			move.w	2(a0),_d1				; mode bei pexec
			move.l	4(a0),pexec_name		; name bei pexec
			cmp		#0,d0
			beq		pterm0
			cmp		#$4c,d0
			beq		pterm
			cmp		#$4b,d0
			bne		oldtrap1
			;movem	d1-d7/a1-a6,-(sp)
pexec:		cmp		#0,_d1
			beq		pexec0
			cmp		#4,_d1
			beq		pexec4
			cmp		#6,_d1
			beq		pexec6
			bra 	oldtrap1
pexec0:
pexec4:
pexec6:		cmp		#0,pexeccount
			beq		pexec_setres  	;
		
			addq	#1,pexeccount
			bra		oldtrap1

pexec_setres:	
			movem.l	a0-a6/d1-d7,-(sp)
			bsr		_pexec_setres
			movem.l (sp)+,a0-a6/d1-d7
			tst		d0
			bne   	oldtrap1
			move.w	#1,pexeccount
			bra		oldtrap1
pterm:
ptermres:
pterm0:		cmp		#1,pexeccount
			beq		pterm_setres
			cmp		#0,pexeccount
			beq		oldtrap1
			subq	#1,pexeccount
			bra		oldtrap1

pterm_setres:
			movem.l	a0-a6/d0-d7,-(sp)
			bsr		_pterm_setres
			movem.l (sp)+,a0-a6/d0-d7

			move	#0,pexeccount
			bra		oldtrap1		

oldtrap1:	;movem.l	(sp)+,a2-a6/d2-d7
			move.l	OldTRAP1,-(sp)
			rts

change: 	dc.w	1 						; 0=Pexec-handler nicht aktiv
pexec_name:	dc.l	0 						; Name bei Pexec
pexeccount:	dc.w	0 						; anzahl der verschachtelten pexecaufrufe

_d1:		dc.w	0
_d0:		dc.w	0
_a0:		dc.w	0
_a1:		dc.w	0