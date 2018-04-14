;rockyone			POUR MI-3			19/07/2016
;Correction palette						26/02/2017
;Suppresion de tests pour fichiers de Invision			21/10/2017
;
;			OPEN IFF compress‚ ou non compress‚
;NEO 2.24 et 2.28
;Positive_image
;Invision
;	
;		       	Utiliser PC_Open pour d‚compression
;			-----------------------------------
;
;Destination		Bufer 32034 bytes minimum pour le retour
;		
; 
; 
;			CALL IFF_Open( L Source, L destination )
;			---------------------------------------
;
; Return dans	destination le fichier au format DEGAS  32034 octets
;
;			
; Return dans 	Low d0   -1 erreur r‚solution
;			 -2 erreur entete fichier ou taille image
;
; Return dans	High d0  La r‚solution de l'image meme en cas d'erreur
;			 de r‚solution  ‚cran/image
;
;+ 0	L	FORM
;+ 4	L	Longueur du fichier qui suit
;+ 8	L	ILBM
;+12	L	BMHD
;+16	L	$14
;+20	W	Largeur image
;+22	W	Hauteur image
;+24	W	X offset
;+26	W	Y offset
;+28	B	Nombre de plan
;+29	B	mask
;+30	B	Flag compression 0 no, 1 pakbits, 2 rle vertical
;+31	B	Initilis‚ 0
;+32	W	Couleur transparante
;+34	B	X aspet  5=640*200, 10=320*200/640*400, 20=320*400
;+34	B       		1 pic invision.prg
;+35	B	Y aspec  $11	1 pic invision.prg	
;+36	W	Largeur image	0 pic ivision .prg
;+38	W	Hauteur image	0 pic invision.prg
;+40	L	CMAP
;+44	L	Nombre de valeur RVB ( couleur * 3)
;+48 	B	Valeur RVB....
;+	L	BODY
;+	L	Longeur du block image
;-------------------------------------------------------------------------	
;a0 source
;a1 destination
		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1

		moveq.l	#-2,d0			;R. erreur entete
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3

		cmp.l	#'FORM',(a0)+		;+0 'FORM '
		bne	error
		cmp.l	#$fa60,(a0)+		;Positive Image resol 1 ?
		bne.s	ok_plan
		move.b	#2,20(a0)		;+28 , 2 plans ! pas  4	 !
	

ok_plan:	cmp.l	#'ILBM',(A0)+		;+8
		bne	error			
		cmpi.l	#'BMHD',(A0)+		;+12
		bne	error			
		cmpi.l	#$14,(A0)+		;+16
		bne	error			
		move.w	(a0)+,d2		;+20 Largeur image
*		cmp.w	14(a0),d2		;+36
*		bne	error
		move.w	(a0)+,d3		;+22 Hauteur image
*		cmp.w	14(a0),d3		;+38
*		bne	error
		mulu.w	d2,d3
		tst.l	(a0)+			;+24 
		bne 	error
	
		moveq.l	#0,d2
		move.b	(a0)+,d2		;+28 Nombre de plan

		cmpi.b	#4,d2			; >4 ? 
		bhi	error

		tst.b	(a0)+			;+29
		bne 	error

		move.l	d2,d4			; largeur hauteur nb plan
		lsr.l	#1,d4			;   4, 2, 1, / 2, 1, 0
		lsl.l	d4,d3			; 
		cmpi.l	#256000,d3		; * par d2 is not good 
		bne	error
;........................................Test resolution image / ‚cran
		moveq.l	#-1,d0			; R. erreur r‚solutioon
		move.l	d2,d3		        ;     4  2  1
		subi.w	#5,d3			;    -1 -3 -4
		neg.w	d3			;     1  3  4
		lsr.b	#1,d3			;     0  1  2
		move.w	d3,d7			;R. Stok resolution image
		andi.b	#2,d3
		move.b	$44c,d4			; R‚solution ‚cran
		andi.b	#2,d4
		cmp.b	d3,d4
		bne	error			;d2=2  d3<2 ou d2<2  d3=2

;.........................................................................
		moveq.l	#-2,d0			;R. bad file

		move.b	(a0)+,d1		;+30  byte packed
* 		moveq.l	#3,d4
*loop2:
*		tst.b	(a0)+			;+31,32,33,34,35
*		bne.s 	error
*		dbra.w 	d4,loop2

		lea.l	9(a0),a0

;........................................save au format Degas............	
;
		lsl.b	#7,d1		;*128
		move.b	d1,(a1)+	; byte pack 0 ou $80 format DEGAS
		move.b	d7,(a1)+	; resol	format DEGAS
		movea.l	a1,a6		; A6 control transfer palette 
;					;     effectu‚
;					; A1 = adresse pour palette
		lea.l	32(a1),a2	; A2 = adresse pour data

		bsr.s 	pal		;Neo 2.28 palette avant data
;					;Neo 2.24 palette aprŠs data

		cmp.l	#'BODY',(a0)+	;+40 ou + 54 ou + +96
		bne.s	error

		tst.b	d1		; source compress‚ ?
		beq.s	no_pack		; non

;........................................fichier compress‚...............
		move.l	(a0)+,d3	; Taille des data compress‚
		subq.b	#1,d3		; -1 pour dbra

copy:		move.b	(a0)+,(a2)+
		dbra.w	d3,copy

		bra.s	end_prg

;.......................................image non compress‚..............
no_pack:	moveq.l	#0,d1

		cmpi.l	#64000,(a0)	; Moyenne resol Positive Image
		bne.s	no_positive	;           and Invision.prg
		addq.l	#4,a0
		move.l	#160,d1		;les ligne sont doubl‚ !!!
		bra.s	positive

no_positive:	cmpi.l	#32000,(a0)+		;+44
		bne.s	error

positive:	subq.b	#1,d2		;nombre de plan -1 pour dbra

		lea.l	param(pc),a3
		move.w	d7,d3		; resol image
		mulu.w	#6,d3
		adda.w	d3,a3
		move.w	(a3)+,d3	; Nombre de ligne
		move.w	(a3)+,d4	; Ecart entre deux word d'un plan

ligne:		movea.l	a2,a4		; D‚but d'un plan de ligne
		move.w	d2,d6		; Nombre de plan

plan:		move.w	(a3),d5		; Nombre de word par plan

word:		move.w	(a0)+,(a4)
		adda.w	d4,a4
		dbra.w	d5,word		; Word suivant

		lea.l -158(a4),a4		
		dbra.w	d6,plan		; Plan suivant de la ligne

		lea.l	160(a2),a2
		adda.l	d1,a0		; Moyenne resol: ligne doubl‚ dans
;					; fichier de Positive Image
					
		dbra.w	d3,ligne	; Ligne suivante

;........................................end_prg....................

end_prg:	bsr.s	pal		; Palette aprŠs data image ??
		moveq.l #0,d0
error:		swap	d0
		move.w	d7,d0		; R. r‚sol image pour Box_Alerte
		swap	d0 		; Erreur si n‚gatif
		movem.l	(a7)+,d1-d7/a0-a6
		rts
;........................................palette de couleur RVB | HARD

pal:		cmpa.l 	a1,a6
		bne.s	no_pal		; la palette est d‚jas transf‚r‚

		cmpi.l	#'CMAP',(a0)
		bne.s	no_pal

		addq.l	#4,a0

		move.l	(a0)+,d6	; Nombre d'octets de couleur
		divu.w	#3,d6		; Nombre de couleur 
		subq.l	#1,d6		; -1 pour dbra

		lea.l	vdi_0(pc),a3
		moveq.l	#0,d3
color:		moveq.l	#0,d4
		moveq.l	#2,d5
rvb:		move.b	(a0)+,d3	; R
		lsr.b	#4,d3
		lsl.w	#4,d4
		add.b	0(a3,d3.w),d4
		dbra.w	d5,rvb

		move.w	d4,(a1)+	; Save color
		dbra.w	d6,color
no_pal:		rts
;........................................
	even
;		nb_ligne, offset_word, nb_word ....  3 r‚solutions
param:	dc.w	199,8,19,199,4,39,199,2,79
	even
;                0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
vdi_0:	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
	even

	end
;-------------------------------------------------------------------------