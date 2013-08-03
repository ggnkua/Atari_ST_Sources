** Routine RUN IT!
* Entr‚e : d0 adresse du prog. … lancer
*	d1 adresse de retour
*	d2 = -1 si ce n'est pas le premier 
* 	     lancement du programme

TrapVect	equ	$80

	lea	SaveVect(pc),a0
	move.l	$70.w,(a0)+
	move.l	$84.w,(a0)+
	move.l	$88.w,(a0)+
	move.l	$80+13*4.w,(a0)+
	move.l	$80+14*4.w,(a0)+

	lea	Charge(pc),a0
	move.l	d0,(a0)
	lea	Return(pc),a0
	move.l	d1,(a0)
	
; Routine de relocation 
	move.l	Charge(pc),a0
	move.l	2(a0),d0
	add.l	6(a0),d0		
	move.l	d0,d1
	add.l	$e(a0),d0	
	
	lea	$1c(a0),a0		
	add.l	a0,d1
; adresse de fin du programme
; (debut de la zone BSS)
	lea	End(pc),a2
	move.l	d1,(a2)
	
; si deja lance => pas de relocation
	tst.l	d2
	bmi.s	FinReloc

; a1 = table de relocation
	lea	0(a0,d0.l),a1	
	lea	LogAdr(pc),a2
	move.l	a0,(a2)

	add.l	(a1)+,a0
	move.l	LogAdr(pc),d1
	add.l	d1,(a0)
	moveq	#0,d0
	
BclReloc	move.b	(a1)+,d0
	tst.b	d0	
	beq.s	FinReloc
	cmp.b	#1,d0
	beq.s	IncrAdr
	add.w	d0,a0
	move.l	LogAdr(pc),d1
	add.l	d1,(a0)
	bra.s	BclReloc
IncrAdr	lea	$fe(a0),a0
	bra.s	BclReloc

; Effacement de sa section BSS	
FinReloc	move.l	Charge(pc),a0
	move.l	$a(a0),d0
	move.l	End(pc),a1
	lsr.l	#2,d0
	addq.l	#1,d0
ClrBSS	clr.l	(a1)+
	subq.l	#1,d0
	bne.s	ClrBSS

; Reprise de quelques exceptions
	lea	TrapVect.w,a0
	lea	Trp1(pc),a1
	lea	Rte(pc),a2
	move.l	a1,4(a0)
	move.l	a2,4*13(a0)
	move.l	a2,4*14(a0)

	move.l	Charge(pc),a0
	jmp	(a0)

Rte	rte

Trp1	tst.w	6(sp)
	bne.s	FinTrp1
	
	lea	SaveVect(pc),a0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$84.w
	move.l	(a0)+,$88.w
	move.l	(a0)+,$80+13*4.w
	move.l	(a0)+,$80+14*4.w

	move.l	Return(pc),a0
	jmp	(a0)
	
FinTrp1	rte

SaveVect	ds.l	5
Charge	dc.l	0
Return	dc.l	0
LogAdr	dc.l	0
End	dc.l	0

