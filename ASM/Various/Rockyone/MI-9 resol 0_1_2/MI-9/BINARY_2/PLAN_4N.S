* rockyone			pour MI-9			23/11/2015
* modifi‚							16/07/2017
*			
*			rotation numeros des plans 1 2 3 4
*						   4 1 2 3
*						   3 4 1 2
*						   2 3 4 1
*			  
*		call plan_4n( L source,L but,W key%,W limit%)
*	
*	Key%	[7] or [9]
*	 
*-------------------------------------------------------------------------
*
*	a0	source
*	a1	destination
*	d0	sens
*	d1	resolution
*	d2	nombre de ligne
*	
*
*-------------------------------------------------------------------------
		movem.l	d0-d7/a0-a6,-(a7)
		movem.l	64(a7),a0-a1
		move.w	72(a7),d2	; key ?

		tst.b	$44c		; screen resol ?
		beq.s	basse_resol

;--------------------------------------- rotation moyenne resolution -----
;sens gauche = sens droite
		move.w	#7999,d0	; 8000 word par plan
moyenne_resol:	move.w	(a0)+,2(a1)	; plan 1 sur plan 2 
		move.w  (a0)+,(a1)	; plan 2 sur plan 1
		addq.l	#4,a1
		dbra.w	d0,moyenne_resol	

		bra.s	recopy

;-------------------------------------- rotation basse resolution --------
basse_resol:	move.w	#3999,d0
		cmpi.b	#55,d2		; key ? 
		beq.s	word_droit

;........................................ rotation sens gauche
word_gauche:	move.w	(a0)+,6(a1)     ; plan 1 sur plan 4 
		move.w  (a0)+,(a1)+	; plan 2 sur plan 1
		move.w	(a0)+,(a1)+	; plan 3 sur plan 2
		move.w	(a0)+,(a1)+	; plan 4 sur plan 3
		addq.l	#2,a1
	
		dbra.w	d0,word_gauche	;  4000 word par plan

		bra.s	recopy
;........................................ rotation sens droit
word_droit:	move.w	6(a0),(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		addq.l	#2,a0

		dbra.w	d0,word_droit

;.......................................recopy sur source

recopy:		movem.l	64(sp),a0-a1
		lea.l	32000(a0),a2
copy:		move.l	(a1)+,(a0)+
		cmpa.l	a0,a2
		bhi.s	copy

;.......................................copy sur ‚cran

		move.l	64(sp),a0		; adr pic
		movea.l	a0,a2
		adda.w	74(sp),a2		; limit menu
		move.l	$44e,a1			; adr screen
screen:		move.l	(a0)+,(a1)+
		cmpa.l	a0,a2
		bhi.s	screen
;.................................. FIN ................

fin:		movem.l	(a7)+,d0-d7/a0-a6
		rts
		end
;.........................................................................