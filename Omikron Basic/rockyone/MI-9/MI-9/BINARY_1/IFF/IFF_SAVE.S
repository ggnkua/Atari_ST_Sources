;rockyone			POUR MI-3			19/07/2016
;debug palette							26/02/2017
;debug palette haute r‚solution ( ajout moveq.l #0,d5)	 	11/04/2017
;
;			SAVE NEO IFF compress‚ ou non compress‚
;	
;		       	Utiliser PC_save pour compression
;			-----------------------------------
;
;Destination		Bufer 32066 bytes minimum pour le retour
;Pack%			0 non compress‚
;			1 compress‚	
;Size 			taille du fichier source si pack% =1 
; 
;	CALL IFF_save( L Source, L destination , Pack%, Size% )
;	--------------------------------------------------------
;
; Return dans	destination le fichier au format DEGAS  32034 octets
;
; Return dans 	Low d0 la taille du fichier
;
;-------------------------------------------------------------------------	
;a0 source
;a1 destination
	movem.l	d1-d7/a0-a6,-(sp)
	movem.l 60(sp),a0-a1
	move.w	68(sp),d1		; Pack%
        lea.l	34(a0),a4		; adresse data source
	movea.l	a1,a2
;
	lea.l   param(pc),a3
	moveq.l	#0,d2
	move.b	1(a0),d2		; R‚solution source
	lsl.w	#4,d2			; *16
	adda.w	d2,a3
;
	move.l	#'FORM',(a1)+		;+0
	addq.l	#4,a1			;+4 La taile du fichier aprŠs ce
;					;long word et inscrite plus loing
	move.l	#'ILBM',(a1)+		;+8
	move.l	#'BMHD',(a1)+		;+12
	move.l	#$14,(a1)+		;+16
	move.w	(a3),(a1)+		;+20 Largeur image
	move.w	(a3)+,14(a1)
	move.w	(a3),(a1)+		;+22 Hauteur image
	move.w	(a3)+,14(a1)
	move.l	#0,(a1)+		;+24
	move.w	(a3)+,d2
	move.b	d2,(a1)+		;+28 Nombre de plan
	addq.l	#1,a1			;+29
	move.b	d1,(a1)+		;+30 byte pack
	lea.l	9(a1),a1		;+31
;
;...........................................................palette......
		moveq.l	#0,d6
		move.l	#'CMAP',(a1)+		;+40 
		move.w	(a3),d6			; nombre de couleur
		move.l	d6,(a1)+		;+44	Couleurs * 3

		adda.w	d6,a1			; fin palette but
		divu.w	#3,d6

		lea.l	2(a0,d6.w),a0		; fin couleur source
 		adda.w	d6,a0

		subq.l	#1,d6			; -1 pour dbra
		lea.l	vdi_0(pc),a5		; Table conversion vdi

*		moveq.l	#0,d3
		moveq.l	#0,d5
color:		moveq.l	#2,d4
		move.w	-(a0),d3
bvr:		move.b	d3,d5			
		andi.b	#$f,d5
		move.b	0(a5,d5.w),-(a1)		 
		lsr.w	#4,d3
		dbra.w	d4,bvr
		dbra.w	d6,color

		movea.l	a4,a0			; pointe data source
		adda.w	(a3)+,a1			
;........................................

		move.l	#'BODY',(a1)+		;+92	

		tst.b	d1			; source compress‚ ?
		beq.s	normal			; non
;
;........................................SOURCE COMPACTE..................
		moveq.l	#0,d1
		move.w	70(sp),d1		; taille du fichier source
		ext.l	d1
		andi.l	#$ffff,d1
		subi.w	#34,d1			;66
		move.l	d1,(a1)+		;+96	nombre de data

copy_data:	move.b	(a4)+,(a1)+
		subq.l	#1,d1
		bhi.s	copy_data	; >0
		bra.s	end_prg
;
;.......................................IFF NON COMPACTE................
normal:		move.l	#32000,(a1)+		;+96	Nombre de data

		move.w	(a3)+,d2		; Nombre de ligne
		move.w	(a3)+,d3		; Ecart entre deux word 

ligne:		movea.l	a4,a0		 	; D‚but d'un plan de ligne
		move.w	(a3),d4			; Nombre de plan par ligne

plan:		move.w	2(a3),d5		; Nb word par plan de ligne

word:		move.w	(a0),(a1)+
		adda.w	d3,a0
		dbra.w	d5,word

		lea.l -158(a0),a0		
		dbra.w	d4,plan			; Plan suivant de la ligne

		lea.l	160(a4),a4		;	
		dbra.w	d2,ligne		; Ligne suivante

;........................................end_prg...............

end_prg:	moveq.l #0,d0
		swap	d0
		suba.l	a2,a1		 	; taille du fichier
		move.l	a1,4(a2)
		subq.l	#8,4(a2)
		move.l	a1,d0 			; taille du fichier
;						; 32104 pas compress‚
		movem.l	(a7)+,d1-d7/a0-a6
		rts
;........................................
;       Largeur, Hauteur, Plan, Taille_color, Ligne, Ecart, Plan, Word	
	even
param:		dc.w	320,200,4,48,199,8,3,19
		dc.w	640,200,2,12,199,4,1,39
		dc.w	640,400,1,6,199,2,0,79
;		 0   1   2  3   4   5   6   7	
vdi_0:	dc.b	$00,$20,$40,$60,$80,$a0,$c0,$e0
;		 8   9   a  b   c   d   e   f
	dc.b	$10,$30,$50,$70,$90,$b0,$d0,$f0
			even
	end
;-------------------------------------------------------------------------