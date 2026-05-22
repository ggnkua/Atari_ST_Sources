;rockyone	 		pour MI-3  Mi-9		      21/06/2016
;
;modif rvb						      21/02/2017
;optimisation du code
;
;......................................................................
;
;		Transforme fichier PNT et  PTI en fichier DEGAS
;		Utilisez ensuite Pc_open pour d‚compress‚ et ou
;		afficher l'image
;
;		Prism-Paint v1.1	PNT compress‚ ou non compress‚
;		True-Paint  v1.03	TPI n'est jamais compress‚
;		       
;			
; Source	Bufer 32034 bytes minimum pour le retour
;		Contenant tout le fichier image
; 
; 
;			CALL Pnt_Tpi_Open( L Source)
;			----------------------------
;
; Return dans	Source le fichier au format DEGAS  32034 octets
;		Ou le fichier original si erreur
;			
; Return dans 	Low d0   -1 erreur r‚solution
;			 -2 erreur entete fichier ou taille image
;
; Return dans	High d0  La r‚solution de l'image meme en cas d'erreur
;			 de r‚solution  ‚cran/image
;
; Ne teste pas la taille des data
;
;-------------------------------------------------------------------------	
;a0 source
;a1 destination
		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0

		movea.l	a0,a1			;destination= source
		lea.l	header(pc),a2

;-----------------------------------------------OPEN---------------------

		moveq.l	#-2,d0			;R. bad file
		cmp.l	#$504e5400,(a0)+	   
		bne	end_prg		

*		moveq.l	#5,d3
*pnt:		cmpm.b	(a2)+,(a0)+
*		bne	end_prg
*		dbra.w	d3,pnt

		cmp.w	#$100,(a0)+		; Test version PNT TPI
		bne	end_prg			
;						;  0  1  2 resol ?
		move.w	6(a0),d3		;  4  2  1 nb plan
		lsr.b	#1,d3			;  2  1  0
		mulu.w	#12,d3			; 24 12  0
		adda.w	d3,a2			 

		move.w	(a2),d2			; stok nb_color

		moveq.l	#3,d4		
test_header:	cmpm.w	(a2)+,(a0)+
		bne	end_prg
		dbra.w	d4,test_header

		moveq.l	#-1,d0			;R. bad resol		
		move.w	(a2)+,d7		;R. resol
		bne.s	ok_pic
		cmpi.b	#2,$44c			; screen resol
		beq.s	end_prg
ok_pic:		
		move.w	(a0)+,d3		; byte comresssion PNT
		mulu.w	#$80,d3			; 
		move.b	d3,(a1)+		; byte compression DEGAS
		move.b	d7,(a1)+		; write resol
		
		move.l	(a0)+,d4		;Taille data image de PNT	

		lea.l	108(a0),a0		;point to PNT palette

;........................................palette de couleur RVB / HARD
;d0
;d1 = 2
;d2 nombre de couleur
;d3 lecteure r ,v ,b
;d5 add r, v, b
;d6 index d'‚crite dans a1
		moveq.l	#0,d6
		lea.l	vdi_0(pc),a3	; table de conversion resol 0
		tst.b	d7		 
		beq.s	ok_resol			
		lea.l	16(a3),a3	; table de conversion resol 1
		cmpi.b	#1,d7		 
		beq.s	ok_resol	
		addq.l	#4,a3		; table de conversion resol 2

ok_resol:	subq.l	#1,d2		; color -1 pour dbra		
open_color: 	moveq.l	#2,d1		;3 valeurs a lire
		moveq.l	#0,d5
rvb:		moveq.l	#0,d3		
		move.w	(a0)+,d3	; read word R then V then B
		andi.w	#$fff,d3
		lsl.w	#4,d3
		divu.w	#1000,d3
	
		move.b	d3,d0
		lsr.w	#1,d3
		cmpi.b	#8,d3
		bne.s	c8_rvb
		addq.b	#7,d3
c8_rvb:		andi.b	#1,d0
		beq.s	ok_rvb
		addq.b	#8,d3
ok_rvb:		lsl.w	#4,d5		
		add.b	d3,d5	
		dbra.w	d1,rvb

		move.b	(a3)+,d6		; index couleur VDI HARD
		move.w	d5,0(a1,d6.w)		; Save color
		dbra.w	d2,open_color

; effacer zone header PNT non recouverte si resolution >0

		adda.w	(a2),a1		; +taille palette 4,8,32
		tst.b	d7
		beq.s	ok_pal
		move.w	d7,d1
		addq.l	#4,d1
clean:		move.l	#0,(a1)+
		dbra.w	d1,clean

ok_pal:		moveq.l	#0,d0			;R. not error
	
;.................................Copy data image..................

; taille data image toujours pair pour fichier non compress‚    
;	    pair ou impair pour fichier compress‚

copy_image:	
		subq.l	#1,d4
copy_data:	move.b	(a0)+,(a1)+
		dbra.w	d4,copy_data

;........................................end_prg...............
end_prg:	swap	d0
		move.w	d7,d0		; R‚sol. image pour Box_Alerte
		swap	d0 		; Erreur si n‚gatif
		movem.l	(a7)+,d1-d7/a0-a6
		rts

;....color,largeur, hauteur, plan,  resol, tail palette...
	even
header	
*	dc.b	'PNT',$00,$01,$00
	dc.w	2,640,400,1,2,4	 
	dc.w	4,640,200,2,1,8
	dc.w	16,320,200,4,0,32
	even
Vdi_0:	dc.b 	0,30,2,4,8,12,6,10,14,16,18,20,24,28,22,26
	dc.b 	0,6,2,4
	dc.b 	0,2
	even

	end
;-------------------------------------------------------------------------
