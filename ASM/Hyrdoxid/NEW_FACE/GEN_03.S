GEN_CODE
	lea	GEN,a0
	lea	ADR_TAB-4,a1
	move.l	#$1FFFF,d5		;valeur du move de depart
	moveq	#15,d7
	move	#14,a2
	move.l	#%1000000000000000,a3
*//////////////////////////////////
LOOP_GEN4
;le rien
	move.l	a0,(a1)+
	move.l	#$4ef0A990,(a0)+	;jmp(a6.l) a6=RETOUR
;les 15 premiers pix
	move.l	d5,-(sp)
	moveq	#0,d5
	move	a2,d3
	move.l	a3,d4
	cmpi.w	#-1,d3
	beq.s	NO_16PIX
	move.l	d4,d5
PREMIER
	move.l	a0,(a1)+		;sauve adresse de la 'procedure'
	move	#$30bc,(a0)+	;le move.w
	move	d5,(a0)+
	move.l	#$4ef0a990,(a0)+
	lsr.l	d4
	or.l	d4,d5	
	dbf	d3,PREMIER
	move.l	a0,(a1)+		;sauve adresse de la 'procedure'
	subq	#1,a2
	move.l	a3,d4
	lsr.l	d4
	move.l	d4,a3
NO_16PIX
	move.l	(sp)+,d5


	moveq	#22,d3
	moveq	#-1,d2
	lsr.l	d5	
LOOP_GEN
	move.l	#%10000000000000000,d4
	move.l	d4,d1
	moveq	#15,d0		;compteur pour 1-16 pix
	move	d2,a5
LOOP_GEN2	
	moveq	#0,d6
;le move de depart
	move	#$317c,(a0)+	;le move.w
	move	d5,(a0)+		;valeur du move
	move	d6,(a0)+
	add	#16,d6
	cmpi	#-1,d2
	beq.s	NO_MOVE2
LOOP_GEN3
;move pour *16 pix
	move	#$317c,(a0)+	;le move.w
	move	#-1,(a0)+		;valeur du move
	move	d6,(a0)+
	add	#16,d6
	dbf	d2,LOOP_GEN3
NO_MOVE2
;move de 1 a 16 pix
	cmpi.l	#$10000,d1
	beq.s	NO_MOVE
	move	#$317c,(a0)+	
	move	d1,(a0)+		;valeur du move
	move	d6,(a0)+
NO_MOVE
	lsr.l	d4
	or	d4,d1
;le rts
	move.l	#$4ef0a990,(a0)+
	move	a5,d2
	move.l	a0,(a1)+		;sauve adresse de la 'procedure'
	dbf	d0,LOOP_GEN2
	addq	#1,d2
	dbf	d3,LOOP_GEN
	dbf	d7,LOOP_GEN4
*	move	#0,$ffff9800
*	lea	ADR_TAB,a1
*	move.l	16*4+(384+384+383+382+381+380+379+378+377+376+375+374+373+372+371)*4(a1),a0
*	move.l	16*4+384*4(a1),a0
*	jsr	(a0)
	rts
*	SECTION	BSS
*GEN	DS.B	485000
*	ds.w	50
*ADR_TAB	DS.B	1000*25