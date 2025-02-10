*	OUTPUT e:\code\synthy.art\curent\fichiers.inl\pack_pc1.inl
*	OPT O+,A+,P+
***********	Compactage Degas basse r‚solution ST
* 4(sp) L Adresse de l'image
* 8(sp) L Adresse du buffer destination
* En retour dans D0, taille des donn‚es compact‚es en octets                        
;                         save pc1
;------------------------------------------------------------------------
 	movem.l	d1-d7/a0-a6,-(a7)
	movem.l	60(sp),a0-a1
*	move.l	4(sp),a0
*	move.l	8(sp),a1
	lea	LineBuffer(pc),a2
	even
	moveq	#2,d5
	move.w	#200,d7		Nb ligne
	bra.s	ConvertLine

*	dc.b	"DegasPacker by Nucleus/HMD"
*	EVEN
*
NextLine:	
	subq.b	#1,d6
	bmi.s	ConvertLine
	lea.l	40(a4),a4

NewCode:	
	move.l	a3,a5		Start adr
	move.b	(a3)+,d0
	cmp.l	a3,a4
	beq.s	CodeCOPY
SameLoop:	
	cmp.b	(a3)+,d0
	bne.s	NotSame
	cmp.l	a3,a4
	bne.s	SameLoop
	bra.s	CodeREPEAT
	
NotSame:	
	move.l	a3,d1
	sub.l	a5,d1
	cmp.w	d5,d1
	bne.s	CodeREPEAT1
	cmp.l	a3,a4
	beq.s	CodeCOPY
	move.b	-1(a3),d0
NotSameLoop:	
	move.b	(a3)+,d1
	cmp.b	d0,d1
	beq.s	Same2
	move.b	d1,d0
	cmp.l	a3,a4
	bne.s	NotSameLoop
CodeCOPY_1:	
	bra.s	CodeCOPY

Same2:	
	cmp.l	a3,a4
	beq.s	CodeCOPY
	cmp.b	(a3),d0
	bne.s	NotSameLoop
	sub.l	d5,a3
	bra.s	CodeCOPY
;................

ConvertLine:	
	subq.w	#1,d7
	bmi.s	EndOfPict
	moveq	#3,d6
	move.l	a2,a3
	lea	40(a3),a4		
	lea	40(a4),a5		
	lea	40(a5),a6
	moveq	#19,d0
ConvLoop:	
	move.w	(a0)+,(a3)+
	move.w	(a0)+,(a4)+		
	move.w	(a0)+,(a5)+		
	move.w	(a0)+,(a6)+		
	dbf	d0,ConvLoop
	move.l	a2,a3
	lea	40(a3),a4
	bra.s	NewCode
		
CodeCOPY:	
	move.l	a3,d1
	sub.l	a5,d1
	subq.w	#1,d1
	move.b	d1,(a1)+
copy:	
	move.b	(a5)+,(a1)+
	dbf	d1,copy
	cmp.l	a3,a4
	bne.s	NewCode
	bra	NextLine
CodeREPEAT1:	
	subq.l	#1,a3
CodeREPEAT:	
	move.l	a3,d1
	sub.l	a5,d1
	subq.w	#1,d1		Nb pattern-1
	neg.b	d1
	move.b	d1,(a1)+
	move.b	d0,(a1)+
	cmp.l	a3,a4
	bne	NewCode
	bra	NextLine
;..............................................
EndOfPict:	
	move.l	a1,d0
	sub.l	64(sp),d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts		
	even
LineBuffer:	ds.b	160

		dc.l	25,"HMD!"
