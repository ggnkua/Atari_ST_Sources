
**********************************************************************

Jump2:	dc.l 0
	dc.l GetSgn-Jump2
	dc.l Pi-Jump2
	dc.l Deg-Jump2
	dc.l Rad-Jump2
	dc.l Zerau-Jump2

**********************************************************************
*	ENTREE DE LA TRAPPE
****************************
Entrappe:	lsl.w #2,d0
	bmi.s DirFonc
	cmp.l #$12345678,d2
	beq.s BFloat
	movem.l d4-d7/a1-a6,-(sp)
	lea Jump2(pc),a1
	move.l 0(a1,d0.w),a1
	jsr (a1)
	movem.l (sp)+,d4-d7/a1-a6
	rte
BFloat:	cmp.w #12*4,d0
	beq.s BFl1
	moveq #0,d0
	moveq #0,d1
	rte
* Mauvais FLOAT
BFl1:	move.l a0,-(sp)
	lea badflo(pc),a1
papl:	move.b (a1)+,(a0)+
	bne.s papl
	move.l a0,d0
	move.l (sp)+,a0
	sub.l a0,d0
	subq.l #1,d0
	rte

; Fonctions SUPPLEMENTAIRES
DirFonc	and.w #$ff,d0
	beq.s Inverse
	lea Jump2(pc),a1
	add.l 0(a1,d0.w),a1
	jmp (a1)
Base:	
;-----> INVERSE
Inverse	bchg #31,d3			;0 ---> INVERSE le signe
	rte
;-----> RAMENE LE SIGNE en D0
GetSgn	tst.l d3
	bne.s Gs0
	tst.l d4
	beq.s Gs2
Gs0:	btst #31,d3			;1 ---> TROUVE le signe, en D0
	bne.s Gs1
	moveq #1,d0
	rte
GS1:	moveq #-1,d0
	rte
Gs2:	moveq #0,d0
	rte
;-----> PI
pi	move.l #$400921fb,d3
	move.l #$54442d18,d4
	rte
;-----> DEG
deg	movem.l a2-a6/d5-d7,-(sp)
	move.l d3,d1
	move.l d4,d2
	move.l #$400921fb,d3
	move.l #$54442d18,d4
	bsr Deg
	move.l d0,d3
	move.l d1,d4
	move.l #$40668000,d1
	move.l #$00000000,d2
	bsr Deg
	move.l d0,d3
	move.l d1,d4
	movem.l (sp)+,a2-a6/d5-d7
	rte
;-----> RAD
rad	movem.l a2-a6/d5-d7,-(sp)
	move.l d3,d1
	move.l d4,d2
	move.l #$40668000,d3
	move.l #$00000000,d4
	bsr Rad
	move.l d0,d3
	move.l d1,d4
	move.l #$400921fb,d1
	move.l #$54442d18,d2
	bsr Rad
	move.l d0,d3
	move.l d1,d4
	movem.l (sp)+,a2-a6/d5-d7
	rte
;-----> ZERO: ramene le ZERO (pour DIM)
zerau:	moveq #0,d3
	moveq #0,d4
	rte

badFlo:	dc.b 21," BAD FLOAT TRAP ",18,0


