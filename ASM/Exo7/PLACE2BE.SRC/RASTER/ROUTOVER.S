**********************
* ROUTINES INTEGREES *
**********************
overgd:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	89,$4e71
	rts
bas:
	move.b	d0,(a5)
	dcb.w	14,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	85,$4e71
	rts
*****************************
* CALC_ADR_BLOC X + LIGNE X *
* = COPIE DE LA LIGNE SUR   *
* TOUT L'ECRAN              *
*****************************
calc_adr_bloc1:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	move.l	adresse,a0
	movem.l	(a0),d3-d7/a1-a4
	move.l	invisible,a0
	lea	204+2*4(a0),a0
	dcb.w	56,$4e71
	rts
calc_adr_bloc2:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	move.l	adresse,a0
	lea	9*4(a0),a0
	movem.l	(a0),d3-d7/a1-a4
	move.l	invisible,a0
	lea	204+2*4+9*4(a0),a0
	dcb.w	54,$4e71
	rts
calc_adr_bloc3:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	move.l	adresse,a0
	lea	9*4*2(a0),a0
	movem.l	(a0),d3-d7/a1-a4
	move.l	invisible,a0
	lea	204+2*4+9*4*2(a0),a0
	dcb.w	54,$4e71
	rts
calc_adr_bloc4:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	move.l	adresse,a0
	lea	9*4*3(a0),a0
	movem.l	(a0),d3-d7/a1-a4
	move.l	invisible,a0
	lea	204+2*4+9*4*3(a0),a0
	dcb.w	54,$4e71
	rts
calc_adr_bloc5:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	move.l	adresse,a0
	lea	9*4*4(a0),a0
	movem.l	(a0),d3-d7/a1-a4
	move.l	invisible,a0
	lea	204+2*4+9*4*4(a0),a0
	dcb.w	54,$4e71
	rts
calc_adr_bloc6:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	move.l	adresse,a0
	lea	9*4*5(a0),a0
	movem.l	(a0),d4-d6
	move.l	invisible,a0
	lea	204+2*4+9*4*5(a0),a0
	dcb.w	66,$4e71
	rts
ligne1:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	movem.l	d3-d6,(a0)
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	11,$4e71
	movem.l	d7/a1-a3,4*4(a0)
	
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	move.l	a4,8*4(a0)
	lea	230(a0),a0
	movem.l	d3-d7/a1-a4,(a0)
	movem.l	d3-d7/a1-a4,230(a0)
	movem.l	d3-d7/a1-a4,460(a0)
	movem.l	d3-d7/a1-a4,690(a0)
	rts
ligne2:
	move.b	d0,(a5)
;	dcb.w	2,$4e71
	lea	230*4(a0),a0
	
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	movem.l	d3-d6,(a0)
	
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	11,$4e71
	movem.l	d7/a1-a3,4*4(a0)
	
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	move.l	a4,8*4(a0)
	lea	230(a0),a0
	movem.l	d3-d7/a1-a4,(a0)
	movem.l	d3-d7/a1-a4,230(a0)
	movem.l	d3-d7/a1-a4,460(a0)
	movem.l	d3-d7/a1-a4,690(a0)
	rts
ligne3:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
;	dcb.w	10,$4e71
	move.l	d4,(a0)+
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	nop
	
	move.b	d1,(a6)
;	dcb.w	2,$4e71
	lea	230-4*3(a0),a0
	
	move.b	d0,(a6)
;	dcb.w	11,$4e71
	move.l	d4,(a0)+
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	lea	230-4*3(a0),a0
	
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71
	rept	8
	move.l	d4,(a0)+
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	lea	230-4*3(a0),a0
	endr
	nop
	rts
palette_back:
	move.b	d0,(a5)
	dcb.w	2,$4e71
	move.b	d2,(a5)
	dcb.w	10,$4e71
	move.b	d1,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
	dcb.w	11,$4e71
	move.b	d2,(a6)
	dcb.w	2,$4e71
	move.b	d0,(a6)
;	dcb.w	89,$4e71

	lea	$ffff8240.w,a5
	lea	palette2,a6
	rept	8
	move.l	(a6)+,(a5)+
	endr
	lea	$ffff820a.w,a5
	lea	$ffff8260.w,a6
	dcb.w	89-49
	rts
noppe:	nop
	rts	
