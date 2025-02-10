;rockyone			pour MI-3			02.08.2019
;
;	Echange deux index de couleur palette et data image
;
;	Image basse resolution et ST d‚marr‚ en moyenne r‚solution.
;
;
;buf_ecr	Buffer image format Degas 32034/32066 bytes
;adrcolor	Adresse du tableau Color%(x)
;
;					
;		call 	exange_c( L buf_ecr, Adrcolor )
;
;
;-------------------------------------------------------------------------
;used a0-a2/d0-d7
;
		movem.l	d0-d7/a0-a6,-(sp)
		movem.l	64(sp),a0-a1

		move.w	4(a1),d0		; Index du texte a
		move.w	12(a1),d1		; ‚changer avec celui ci
		cmp.w	d0,d1	        	; Index identique ?
		bne.s	suite			; <>

		move.w	6(a1),d0		; Index du fond ...
		move.w	14(a1),d1		
		cmp.w	d0,d1
		beq	_end			; =

suite:		move.w	d0,d2
		swap	d0
		move.b	d1,d0			

		move.b	d2,d3
		eor.b	d1,d3
		move.b	d3,masq			; plans a modifier

;		------------------------------------------------
;			Echange 2 couleurs dans la palette
;		------------------------------------------------

		lsl.b	#1,d2
		lsl.b	#1,d1
		move.w	2(a0,d2.w),d4
		move.w	2(a0,d1.w),2(a0,d2.w)
		move.w	d4,2(a0,d1.w)
;		-----------------------------------------------

		lea.l	34(a0),a0		; adresse de l'image
		lea.l	32000(a0),a2		; fin de l'image


;		-----------------------------------------------
;			Recherche couleur pixels … echanger
;		-----------------------------------------------

resol_0		movem.w	(a0),d3-d6		;  4 plans par colonnes
		moveq.l	#0,d1			; Reset mask
		moveq.l	#15,d2			; 16 bits par plan  

all_pixel:	moveq.l	#0,d7

		btst.b	d2,d3
		beq.s	bit_1	
		addq.l	#%1,d7			 
										
bit_1:		btst.b	d2,d4
		beq.s	bit_2	
		addq.b	#%10,d7

bit_2:		btst.b	d2,d5
		beq.s	bit_3	
		addq.b	#%100,d7

bit_3:		btst.b	d2,d6
		beq.s	cmp_index
		addq.b	#%1000,d7
	
cmp_index:	cmp.b	d0,d7		; = index couleur a ‚changer ?
		beq.s	masq_word	;   Oui 

		swap	d0
		cmp.b	d0,d7		; =  Index couleur a ‚changer ?
		bne.s	no_change	; <> Non

masq_word:	bset.b	d2,d1		; Masque des 16 bits a modifier
;					; pour les 4 plans.
no_change:	dbra.w	d2,all_pixel 	; 16 prochain pixel.

		tst.w	d1
		beq.s	next_c

;		------------------------------------------------
;		Echange des couleurs dans les donn‚es de l'image
;		------------------------------------------------				
		moveq.l	#0,d7
		move.b	masq,d7

plan_1:		btst.b	#0,d7			; modifier ce plan ?
		beq.s	plan_2			; non
		eor.w	d1,d3		;  (a0)

plan_2:		btst.b	#1,d7
		beq.s	plan_3
		eor.w	d1,d4		; 2(a0)

plan_3:		btst.b	#2,d7		
		beq.s	plan_4
		eor.w	d1,d5		; 4(a0)

plan_4:		btst.b	#3,d7
		beq.s	save_word
		eor.w	d1,d6		; 6(a0)	

save_word:	movem.w	d3-d6,(a0)
next_c:		addq.l	#8,a0 			; prochaine colonne

		cmpa.l	a0,a2			; = Fin image ?
		bhi.s	resol_0 		; > Non, continuer

		
;..............................................
_end		movem.l	(sp)+,d0-d7/a0-a6
		rts
masq:		dc.b	0

		end
;-------------------------------------------------------------------------