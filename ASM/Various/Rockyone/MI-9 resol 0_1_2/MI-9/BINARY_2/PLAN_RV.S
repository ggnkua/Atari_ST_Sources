;	rockyone						16/11/2015
;Modifi‚ pour MI-9						04/12/2012
;
;		  Rotation veticale de plan d'image 
;
;	          Basse moyenne et haute r‚solution
;
;	CALL plan_Rv( L source,L destination, masque%,Limit%)
;	
;	masque%  %1111		
;	plan      4321
;	Limit%	 Nombre de word a recopier sur l'‚cran
;--------------------------------------------------------------------------
	movem.l	d0-d7/a0-a6,-(a7)
	movem.l	64(a7),a0-a1
	move.w	72(a7),d1
	
	move.b	($44C),d4	; resolution
	move.l	#199,d2		; 200 ligne

	moveq.l	#20,d3		; nombre de word par plan sur une ligne	
	lsl.b	d4,d3		; 20 40 80 word celons r‚solution
	subq.b	#1,d3		; -1 pour dbra

	moveq.l	#8,d6		; nombre de byte entre deux word d'un plan
	lsr.b	d4,d6		; 8 4 2 celons r‚solution

	move.l	#320,d7		; destination : ligne suivante 160 byte * 2  
	adda.w	#31840,a1	; destination : dernier word d'un plan 

	cmpi.b	#2,d4		; Haute r‚solution ?
	bne.s	no_heigh
;				; --------------------- haute resol -------
	move.l	#399,d2		; 400 ligne
	moveq.l	#39,d3		; 40 word par ligne
	move.l	#160,d7		; destination :ligne suivante 80 byte * 2	
	adda.w	#80,a1		; destination : dernier word d'un plan  
;				; -----------------------------------------
no_heigh
;--------------------------------------------------------------------------
*	move	d2,d4		
*	move	d3,d5		 

planes:	btst.b	#0,d1		; retourner ce plan ?
	beq.s	plan_suivant

	movea.l	a0,a2		; source      : premier word d'un plan
	movea.l	a1,a3		; destination : dernier word d'un plan 
	move.w	d2,d4		; initialise compteur de ligne 

ligne:	move.w	d3,d5		; initailise compteur de word par ligne

word:	move.w	(a2),(a3)	
	adda.w	d6,a2		
	adda.w	d6,a3
	dbra.w	d5,word		; prochain word du plan

	suba.w	d7,a3		; destination :ligne suivante
	dbra.w	d4,ligne	; ligne suivante

plan_suivant:
	addq.l	#2,a0	; source      : sur plan suivant
	addq.l	#2,a1	; destination : sur plan suivant

	lsr.b	#1,d1		; masque      : sur plan suivant
	bne.s	planes

;................................recopy on source..............

	movem.l	64(sp),a0-a1
	move.l	#7999,d1
copy:	move.l	(a1)+,(a0)+
	dbra.w	d1,copy

;................................RECOPY ON SCREEN...............

	move.l	68(sp),a0
	movea.l	a0,a2
	adda.w	74(sp),a2
	move.l	$44e,a1
recopy:	move.l	(a0)+,(a1)+
	cmpa.l	a0,a2
	bhi.s	recopy
;...............................................................
	movem.l	(a7)+,d0-d7/a0-a6
	rts
	end
