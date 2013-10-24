; //////////////////////////////////////////////////////////////////////////
; Random. Zufallsroutine.
; Die Erzeugung	ist	nicht absolut unregelnmÑûig, aber brauchbar
; (vor allem, wenn der HBL z.B.	wÑhrend	des	MenÅs etwas	durchpauert	!).
; Der HBL sollte abgeschaltet werden, wenn das Programm auûerhalb eines
; MenÅs o.Ñ. ist und Rechenzeit gebraucht wird !

; Routine entwickelt (ziemlich flott) fÅr "Lamemine" (Juli 1993)
; (c) Coderight	1993 Jochen	Knaus, aka BDC/AURA
; Entwickelt mit dem Turboass 1.76.

; PC-relativiert und Destallation 28.6.1994	mit	Easy-Ass.
; Die ErgÑnzungen wurden noch NICHT durchgetestet !!!!!!!

; Ret.:	Zufallszahl	(32	Bit) in	d0.l
; //////////////////////////////////////////////////////////////////////////

PMOD			EQU		0

		IFEQ	PMOD
				MC68030					; muls.l
				ORG		0
				OPT		D-,O+
				MODUL	"F:\LIB\RANDOM.INC"

				bra.w	install_rand_hbl
				bra.w	destall_rand_hbl
				bra.w	random
				bra.w	stop_rand_hbl
				bra.w	go_rand_hbl

				DC.B	'PMOD'
				DC.B	'Random: 32Bit..',0
				DC.B	'BDCannibal/AURA',0
				DC.B	'069306940110'
				DC.B	'20--------------'
		ENDIF

install_rand_hbl:							; Installiert Zufallshbl:
				pea		(a0)				; d0.l - Startwert
				lea		old_sr(pc),a0
				move	sr,(a0)+
				move	#$2700,sr
				move.l	$68.w,(a0)+
				move.l	d0,(a0)				; Userstartwert
				lea		rand_hbl(pc),a0
				move.l	a0,$68.w
				move.l	(sp)+,a0
				move.w	#$2100,-(sp)		; HBL erlauben
				rtr

destall_rand_hbl:							; Zufallshbl aus.
				move	#$2700,sr
				move.w	old_sr(pc),-(sp)
				move.l	old_sr+2(pc),$68.w
				rtr

stop_rand_hbl:	pea		(a0)					; HBL stoppen...
				lea		rte(pc),a0
				move.l	a0,$68.w
				ori		#$2300,sr
				move.l	(sp)+,a0
				rts

go_rand_hbl:	pea		(a0)					; HBL go...
				lea		rand_hbl(pc),a0
				move.l	a0,$68.w
				andi	#$feff,sr
				move.l	(sp)+,a0
				rts

random:			movem.l	D1-D2/a0,-(SP)

				move.l	last(PC),D0		; Letzte Zahl
				bne.s	no_zero

				move.l	crandom(PC),D0
				swap	D0
				or.l	crandom(PC),D0

no_zero:		move.l	#$31415926,D1  ; Mit Konstanten	multiplizieren
				DC.L $4C010000
				not.l	D0
				addq.l	#1,D0

				move.l	crandom(PC),D1
				rol.l	d1,d0
				DC.L $4C010000				; miûbrauchen

				lea		last(pc),a0			; PC-relativ halten.
				move.l	D0,(a0)
				ror.l	#8,D0
				movem.l	(SP)+,D1-D2/a0
				rts

rand_hbl:		pea		(a0)				; Schwer PC-relativ...
				lea		crandom(pc),a0
				addq.l	#1,(a0)				; HBL als Randomcount miûbrauchen.
				move.l	(sp)+,a0
rte:			rte

old_sr:			dc.w	0
				dc.l	0
crandom:		DC.L $87654321				; ZufallszÑhler	Start
last:			DC.L 0						; Letzte Zufallszahl
