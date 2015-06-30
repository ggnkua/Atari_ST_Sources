; -------------------------------------------------------------------
; D‚codage de la bibliothŠque
;
; Appel: ~C:decd%(L:biblio%+6,W:cle&)
; -------------------------------------------------------------------

	move.l	4(sp),a0		; Adresse du fichier 
	move.w	#%1011011101110110,d0	; Cl‚ de d‚codage
	move.w	#14999,d1		; 15000 mots: 1000 boots

loop:
	eor.w	d0,(a0)+		; D‚codage
	dbra 	d1,loop
	rts

	rts

