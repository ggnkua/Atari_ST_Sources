;ok pour le code genere
;mais il faut penser a decouper la zone de sauvegarde d'addresses
;en parties:1 pour chaque forme du premier move
;chaque part=384*4 octets
;donc ajouter:16*4 puis 15*4 puis 14*5 ...


GEN_CODE
	move	#16*4,a2
	lea	GEN,a0
	lea	ADR_TAB,a1
	move.l	#$1FFFF,d5		;valeur du move de depart
	moveq	#15,d7
*//////////////////////////////////
LOOP_GEN4
	add.l	a2,a1		;pour 'sauter' 16,15... premieres pos(pour l'organisation de la table) 
	subq	#4,a2
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
	move.l	a0,(a1)+		;sauve adresse de la 'procedure'
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
	move	#$4e75,(a0)+
	move	a5,d2
	dbf	d0,LOOP_GEN2
	addq	#1,d2
	dbf	d3,LOOP_GEN
	dbf	d7,LOOP_GEN4
	move	#0,$ffff9800
	lea	ADR_TAB,a1
*	move.l	16*4+(384+383+382+381+380+379+378+377+376+375+374+373+372+371+370)*4(a1),a0
	move.l	16*4(a1),a0
	jsr	(a0)
	rts
	SECTION	BSS
GEN	DS.B	100000*5
ADR_TAB	DS.B	1000*25