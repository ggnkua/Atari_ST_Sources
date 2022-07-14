; modified by rockyone		pour  MI-3 MI-9			19/03/2017	
; Add  SPU							22/03/2017
; 
; Modifi‚ pour MI-3						07.07.2019		
;				OPEN SPC SPU
;
;		Chargez les fichier Spectrum … Source+34
;		----------------------------------------
;
; Source	77698 octets 
; Ecran         Adresse physique de l'‚cran.	
; File_size     taille du fichier spectrum
;
; 		Call Spc_SPU ( L Source, L Ecran, Low(file_size) )
;		--------------------------------------------------
;
; Retour:  d0 =  0  Ok
;	   d0 = -2  Erreur
;
;
; Retour buffer Source
; +0		   34 octets  Reserv‚ pour Pi1
; +34		32000 octets  Image d‚compress‚e
; +32000 	19104 octets  597 Palettes :  Restaure, Save
; +51104	19104 octets  597 Palettes :  Affichage, Convert
; +70208	 2016 octets  63 palettes  :  pour 21 lignes ‚cran
; +72224	 5120 octets  Reserv‚ 	   :  table conversion
; +77344	  320 octets  Reserv‚      :  conversion lignes image
;	Total	77698 octets
;
; Retour Screen, image d‚compress‚
;
;-------------------------------------------------------------------------
;SPC : 
; 	 +0	W	'SP'
;  	 +2	W	$0
;  	 +4	LW	taille de l'image compress‚
;  	 +8	LW	taille des palettes compress‚
; 	+12	LW	d‚but des data images compres‚
;			total < = 50014 octets
;
;SPU :  +0              data image   32000
;	+32000	        palette      19104 
;			total	     51104 octets
;-------------------------------------------------------------------------

		movem.l	d1-d7/a0-a6,-(sp)	
		movem.l	60(sp),a0-a1
		move.w	68(sp),d6
		
		lea.l	34(a0),a0	

		moveq.l	#-2,d0
		cmpi.w	#$5350,(a0)		; "SP" ?
		beq.s	spc			
;-------------------------------------------------------------------------
;				SPU
;-------------------------------------------------------------------------
		ext.l	d6
		cmpi.w	#51104,d6		; file size ?
		bne	error

		movea.l	a0,a3
		bsr.s	cls_first_line		; Efface premiŠre ligne
;						; de l'image
		bsr.s	copy_pic
 
		lea.l	19104(a0),a2
		bsr.s 	copy_pal

		movea.l	a2,a0
		bra	black_pal
;------------------------------------------------------------------------
;				Sub routines
;------------------------------------------------------------------------
cls_first_line:	moveq.l	#39,d7			; Efface la 1Šre ligne.
clear:		clr.l	(a3)+
		dbra.w	d7,clear
		rts

copy_pic	move.l	#32000/16-1,d1
recopy:		move.l	(a0)+,(a1)+		; copy to destination
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra.w	d1,recopy
		rts

copy_pal:	move.w	#19104/8-1,d0
recopy_pal:	move.l	(a0)+,(a2)+
		move.l	(a0)+,(a2)+
		dbra.w	d0,recopy_pal
		rts
;-----------------------------------------------------------------------
;				SPC
;-----------------------------------------------------------------------

spc:		lea.l	12(a0),a4		; data image source
		moveq.l	#1,d1			; Saut de plans.
		moveq.l	#7,d2

		movea.l	a1,a3			
		bsr.s 	cls_first_line		; Efface premiŠre ligne
		movea.l	a3,a1			; de l'‚cran
		
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
		adda.w	d1,a1
		exg.l	d1,d2
		dbra.w	d3,literal
	
depac_end:	cmpa.l	a6,a1			; Fin d'un plan ?
		bcs.s	depac			; Non => on y retourne.
		bne	error

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
		cmp.l	4(a0),d7		; Taille image compact‚
		bne.s	error			; Erreur ! => Fin.
;...............................................
;a4 a3 source
;a2 buffer palette
		movea.l	a0,a2
		adda.l	#51104,a2

		move.l	8(a0),d1		; Taille palette compact‚
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
	
pal_end:	move.w	#$fff,(a2)+		; couleur 15
		dbra.w	d4,pal
		suba.l	a3,a4			; Nunber byte depacted
		cmp.l	d1,a4			; Compare avec la taille
;						; de la palette compress‚
		bne.s	error

		move.l	64(sp),a1
		exg.l	a0,a1
		bsr	copy_pic	

		movea.l	a1,a2	
		lea.l	19104(a2),a0	
		bsr	copy_pal
;-------------------------------------------------------------------------
;				Menu palettes
;-------------------------------------------------------------------------
black_pal:	move.l	#63-1,d0		; 63 palettes = 21 lignes
loop:		move.w	#$fff,30(a0)		; pour afichage info_file
		adda.l	#32,a0			; et menu diaporama sur
		dbra.w	d0,loop			; les images Spectrum  
		
		moveq.l	#0,d0			; return no error
;-------------------------------------------------------------------------
error:
end_prg:	movem.l	(sp)+,d1-d7/a0-a6	

		rts		
		end		
;-------------------------------------------------------------------------	

	