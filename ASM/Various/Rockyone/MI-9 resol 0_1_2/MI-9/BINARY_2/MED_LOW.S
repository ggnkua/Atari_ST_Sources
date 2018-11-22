;Rockyone							24.07.2018
;
;			Converssion image PI2 to PI1 
;			''''''''''''''''''''''''''''
;			
;
; Source  Image PI2
; Temp 	  Buffer 32008 bytes
; Plans%  Nombre de plans:      0 pour convertir sur 2 plans
;	   		        1 pour convertir sur 4 plans
;
;
; Sur 2 plans :    - la palette de couleur n'est pas modifier
;		   - tous les bits image ne sont pas sauvegard‚
;		   - les cycles de couleurs seront correct.
;
; Sur 4 Plans:    -  la palette de couleur est modifi‚ 
;		  -  tous les bits image sont sauvegard‚
;		 
;
; Dans les 2 cas,  - L'aspect … l'‚cran est identique
;		   - Certains pixels n'ont pas la bonne couleurs
;
;		call L_to_M ( L Source, L temp, W plans )
;		****************************************
;
; Retourn image dans Source
;-------------------------------------------------------------------------
		movem.l	d0-d7/a0-a6,-(sp)
		movem.l	64(sp),a0-a1

		move.w	#0,(a0)		; byte resolution 0
		lea.l	32034(a0),a2	; end buffer source	
		addq.l	#8,a1

		tst.w	72(sp)
		bne.s	sur_4plans
;------------------------------------ conersions sur 2 plans -------------
	
		adda.w	#34,a0

next_words_	bsr.s	read_data
bit_w0_:	btst.b	#31,d0	
		beq.s	bit_w1_
		bset.b	d7,d2	

bit_w1_:	btst.b	#31,d1
		beq.s	next_
		bset.b	d7,d3

next_:		lsl.l	#2,d0
		lsl.l	#2,d1
		
		dbra.w	d7,bit_w0_

		move.w	d2,(a1)+	; but	plan 1
		move.w	d3,(a1)+	;	plan 2
		addq.l	#4,a1

		cmp.l	a0,a2		; End image ?
		bhi.s	next_words_	; non
		bra.s	recopy

;-------------------------------------------------------------------------
read_data:	move.w	(a0)+,d0	;source plan 1 
		move.w	(a0)+,d1	;	plan 2	
		swap	d0
		swap	d1
		move.w	(a0)+,d0	;	plan 1
		move.w	(a0)+,d1	;	plan 2

		moveq.l	#0,d2
		moveq.l	#0,d3

		moveq.l	#15,d7
		rts
		
;------------------------------------ conersions sur 4 plans -------------


sur_4plans:	addq.l	#2,a0		; modification de la palette
		move.l	(a0)+,d0
		move.l	(a0)+,d1

		moveq.l	#2,d3
pal:		move.l	d0,(a0)+
		move.l	d1,(a0)+
		dbra.w	d3,pal
;........................................

next_words:	bsr.s	read_data
		moveq.l	#0,d4
		moveq.l	#0,d5

bit_w0:		btst.b	#31,d0	
		beq.s	bit_w1
		bset.b	d7,d2	

bit_w1:		btst.b	#30,d0
		beq.s	bit_w2
		bset.b	d7,d4

bit_w2:		btst.b	#31,d1	
		beq.s	bit_w3
		bset.b	d7,d3	 

bit_w3:		btst.b	#30,d1
		beq.s	next
		bset.b	d7,d5

next:		lsl.l	#2,d0
		lsl.l	#2,d1
		
		dbra.w	d7,bit_w0

		move.w	d2,(a1)+	; but	plan 1
		move.w	d3,(a1)+	;	plan 2
		eor.w	d4,(a1)+	;	plan 3
		eor.w	d5,(a1)+	;	plan 4		

		cmp.l	a0,a2
		bhi.s	next_words

;........................................ recopy on source
recopy:		lea.l	-32000(a2),a2
loop:		move.l	-(a1),-(a0)
		cmpa.l	a2,a0
		bhi.s	loop			
;.......................................;
	movem.l	(sp)+,d0-d7/a0-a6
	rts

	end
;**************************************************************************