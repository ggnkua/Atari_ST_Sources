;rockyone			MI-3 uniquemnet			22/04/2017
;modifier							25.07.2018
;								02.09.2019
;Retir‚ la copie sur ‚cran pour avoir la touche R dans le diaporama.
;
;
;			
; source	adresse buffer image +34	
; menu%		1 menu sur ‚cran
; pos%		0 position haute
; 		1 position basse
; op%		0 effacement data
;		1 inversion data
;
;					64      68      70   72
;			call cls_inv( L source, menu%, pos%, op%)
;
;
;
;-------------------------------------------------------------------------
; used d0-d1/a0-a2

		movem.l	d0-d7/a0-a6,-(sp)
		move.l	64(sp),a0
		movea.l	a0,a1
		lea.l	32000(a0),a2		; end source

		moveq.l	#0,d0
		tst.w	72(sp)
		beq.s	cls

		
inv:		eori.l	#$ffffffff,(a1)+
		cmpa.l	a1,a2
		bhi.s	inv
*		bra.s	screen
		bra.s	_end

cls:		move.l	d0,(a1)+
		cmpa.l	a1,a2
		bhi.s	cls

*screen:	move.l	$44e,a1			; adresse ‚cran
*		tst.w	68(sp)			; menu sur ‚cran ?
*		beq.s	to_screen		; No

*		tst.w	70(sp)			; menu bas ?
*		beq.s	menu_bas

*menu_haut:	lea.l	18*160(a0),a0
*		lea.l	18*160(a1),a1

*		cmpi.b	#2,$44c			; haute resolution ?
*		bne.s	to_screen		; no
*		suba.w	#80,a0			; 35 ligne en haute resol
*		suba.w	#80,a1
*		bra.s	to_screen

*menu_bas:	lea.l	-2880(a2),a2

*to_screen:	move.l	(a0)+,(a1)+
*		cmpa.l	a0,a2
*		bhi.s	to_screen
;........................................................................
	
_end:		movem.l (sp)+,d0-d7/a0-a6
		rts

		end
;-------------------------------------------------------------------------



