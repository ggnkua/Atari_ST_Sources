; modified by rockyone		pour  MI-3 MI-9			19/03/2017	
; Add  SPU							22/03/2017
;
; Routine de d‚compactage d'images Spectrum (*.SPC) DEPACSPC.S
; 
;SPC : 
; 	 +0	W	'SP'
;  	 +2	W	$0
;  	 +4	LW	taille de l'image compress‚
;  	 +8	LW	taille des palettes compress‚
; 	+12	LW	d‚but des data images compres‚
;
;			60	64	  68          72	74
; 	Call Depac(L Source, L Ecran, L Palettes, Couleur_15,Spu_size)
;
;	Source     : Adresse du fichier … d‚compacter.
;	Ecran      : Adresse physique de l'‚cran.
;	Palettes   : Adresse du buffer recevant les palettes.
;	Couleur_15 : Couleur no 15. Blanc ($777) le plus fr‚quemment.
;
; Retour : D0 = 0 => OK.
;	   D0 =-2 => Erreur.
;-------------------------------------------------------------------------

		movem.l	d1-d7/a0-a6,-(sp)	
		movem.l	60(sp),a0-a2
		movem.w	72(sp),d5-d6		
		
		moveq.l	#0,d0

		cmpi.w	#$5350,(a0)		; "SP" ?
		beq.s	spc			

;.......................................SPU............................

		cmpi.w	#25552,d6		; file size ? 51104\2
		bne	error

		bsr.s	first_line		; ‚fface premiŠre ligne
		lea.l	160(a0),a0	

		move.l	#7959,d1
copy_pic:	move.l	(a0)+,(a1)+		; copy to screen
		dbra.w	d1,copy_pic

		move.l	#4775,d1		; 19104/4-1
copy_pal:	move.l	(a0)+,(a2)+	
		dbra.w	d1,copy_pal

		bra	end_prg

;------------------------------------------------------------------------
first_line:	moveq.l	#39,d7			; Efface la 1Šre ligne.
clear:		clr.l	(a1)+
		dbra.w	d7,clear
		rts
;-----------------------------------------------SPC----------------------

spc:		lea.l	12(a0),a4		; data image source
		moveq.l	#1,d1			; Saut de plans.
		moveq.l	#7,d2

		bsr.s first_line

		lea.l	31840(a1),a6		; fin ‚cran
		lea.l 	8(a6),a5		; dernier plan

depac:		move.b	(a4)+,d3		; D‚but du d‚compactage.
		ext.w	d3			; M‚thode des pack-bits.
		bpl.s	literal

		neg.w	d3
		addq.w	#1,d3
		move.b	(a4)+,d7
	
full:		move.b	d7,(a1)
		adda.l	d1,a1			; Saut de plan.
		exg.l	d1,d2
		dbra.w	d3,full

		bra.s	depac_end
	
literal:	move.b	(a4)+,(a1)
		adda.l	d1,a1
		exg.l	d1,d2
		dbra.w	d3,literal
	
depac_end:	cmpa.l	a6,a1			; Fin d'un plan ?
		bcs.s	depac			; Non => on y retourne.
		bne.s	error

		addq.l	#2,a6			; fin du plan suivant
		lea.l	-31840(a6),a1		; On passe au plan suivant.
		cmp.l	a5,a6			; Dernier plan ?
		bcs.s	depac
;...............................................	
		move.l	a4,d7			; 
		addq.l	#1,d7			; calculer le nombre
		bclr	#0,d7			; d'octets d‚compact‚s...
		lea.l	12(a0),a4

		sub.l	a4,d7		
		cmp.l	4(a0),d7		; taille image compact‚
		bne.s	error			; Erreur ! => Fin.
;...............................................
;a4 a3 source
;a2 buffer palette

		lea.l	12(a0,d7),a4		; On pointe sur la palette.
		movea.l	a4,a3			; pour control

		move.w	#$254,d4		; Nb de palettes - 1.
		moveq.l	#0,d7

pal:		moveq	#13,d2			; D‚pactage de la palette.
		move.w	(a4)+,d3
		lsr	#1,d3
		move.w	d7,(a2)+
	
color:		lsr.w	#1,d3
		bcc.s	empty
		move.w	(a4)+,(a2)+
		dbra.w	d2,color
		bra.s	pal_end
	
empty:		move.w	d7,(a2)+
		dbra.w	d2,color
	
pal_end:	move.w	d5,(a2)+		; couleur 15
		dbra.w	d4,pal
		suba.l	a3,a4			; Nunber byte depacted
		cmp.l	8(a0),a4		; Compare avec nombre
;						; dans l'en-tˆte du fichier.
		beq.s	end_prg

;-------------------------------------------------------------------------
error:		moveq.l	#-2,d0
end_prg:	movem.l	(sp)+,d1-d7/a0-a6	
		rts				
;-------------------------------------------------------------------------	

	