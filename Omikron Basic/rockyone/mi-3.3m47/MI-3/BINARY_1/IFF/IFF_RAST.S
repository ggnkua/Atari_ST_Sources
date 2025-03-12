; rockyone			Pour MI-3			28.09.2020
;								07.10.2020
;rectif addresse black pal bas ‚cran				17.10.2O20
;""     pour fichier compress‚					26.10.2020
;add file RST							01.10.2020
;add file FUL et BHL de Canvas					06.12.2020
;checked black palettes						18.12.2020
;-------------------------------------------------------------------------
;		OPEN FILE RASTER IFF et RST de Neochrome Master
;		-----------------------------------------------
;
;		Routine de preparation du buffer palette
;		utilis‚ aussi pour les fichier raster de Canvas.prg
; 
; Buf2	  32OOO bytes	buffer ecran contenant l'image (=Buf_ecr+34)
; Buf_pic 72416 bytes	buffer image 
; 
;     Extend%  File
;	0	IFF (avec raster)	neo28.prg
;	1       RST  6800 		neo28.prg
;	2       FUL resol 0 and 1 	canvas.prg
;	3       BHL low resol     	canvas.prg
;	4	BHL medium resol  	canvas.prg
;	5 save  RST                     neo28.prg
;
; 			    a0       a0	  	d1	     d2
;	call iff_raster( L buf2, L buf_pic, offset_raster, extend% )
;			    60 	     64		  68	     70
;	------------------------------------------------------------
;
; Return	 in d0	-6 if error raster
: 
; Buf_pic   
;  Adr	    SPU    IFF
; +32000  19200    288	Pal_restor_H ligne O to 9  (2016 bytes)
; +49184   2016    672  Pal_restor_B Ligne 179 to 199 and or 182 to 199
; +51200  19200	  6400  Pal_display  Ligne 0 to 199 
; +70400   2016    672  Black pal pour 21 lignes 
; ( Les adresses des blocs sont identique pour les images SPU )
;-------------------------------------------------------------------------
; a0 adresse "RAST" +4 			; Address peer or odd
; a1 
; a2
; a3 buffer pal display
;.........................................................................
;start
	movem.l	a0-a6/d1-d7,-(sp)
        cmpi.w	#5,70(sp)
	beq	save_rst
	moveq.l	#0,d1
	move.l	64(sp),a0		; buf_pic
	movem.w	68(sp),d1-d2		; Adr fichier / ofset palette iff
	andi.l	#$ffff,d1
	lea.l	32000(a0),a2		; Adr Pal_restore
	lea.l	19200(a2),a3		; Adr Pal_display

	adda.l	d1,a0			; Adr palettes source
	movea.l	a2,a1			; Bakup address

*	tst.b	d2			; fichier "IFF" ?
*	beq.s	file_iff

	cmpi.b	#1,d2			; file RST ?
	bmi.s	file_iff		; <
	bhi.s	canvas_raster		; >
	

	move.l	#6800,d0
	bra.s	file_rst

file_iff:
	andi.l	#1,d1			; Peer address ?
	beq.s	peer_address		; Yes

;---------------------------------------
; Replace les Words sur une adresse pair
   	lea.l	6804(a0),a4		; Dernier word des palettes.
recopy:	move.b	-(a4),1(a4)		; Tous les words sur adresse pair
	cmpa.l	a0,a4
	bne.s	recopy		
	addq.l	#1,a0			; Peer address ! First color word !
;---------------------------------------
; Test des datas
peer_address:
	move.l	(a0)+,d0		; Taille du bloc de raster
file_rst:
	divu.w	#34,d0			; nombre de ligne de raster
	andi.l	#$ff,d0			;
	subq.w	#1,d0			; Nombre de raster  !!?? 
	bmi	error			; <0

	movea.l	a3,a4			; Address for pal display
;----------------------------------------
;tri des raster
	subq.w	#1,d0			;  198... si il y a un seul raster
	moveq.l	#0,d1			
	move.w	(a0),d1			; number of First palette raster
	lsl.w	#5,d1			; *32
	adda.w	d1,a2			; 
	move.w	(a0)+,d1

FillPalBuffer
;premier bboc
	movem.l	(a0)+,d2-d7/a5-a6
Fill1	movem.l	d2-d7/a5-a6,(a3)
	lea.l	32(a3),a3

	addq.w	#1,d1
	tst.w	(a0)		; afficher cette palette
	bne.s	activ_pal   	; yes

	lea.l	34(a0),a0
	subq.l	#1,d0
	bmi.s	truc

	bra.s	fill1

activ_pal:	
	cmp.w	(a0),d1		; recopier la palettte ?
	bne.s	Fill1		; yes 

	addq.l	#2,a0		; pointe sur la prochaine palette
	dbra.w	d0,FillPalBuffer

truc:
;deuxiŠme bloc
	move.l	#200,d0		; comparateur du compteur de palette
	bsr.s	n_fill		; copie a0 sur a3

;troisiŠme bloc
	movea.l	a4,a0	; Transf‚re d'adresse pour la 
	movea.l	a2,a3	; routine de copie
	moveq.l	#0,d1	; Init du compteur de boucle 
	bsr.s	n_fill
;-------------------------------------------------------------------------
; Copie des palettes pour la ligne "info fichier" en haut de l'ecran et, 
;	Pour le menu de mi-3 et le menu du diaporama 
; Palettes noir pour masquer les raster 
; ( Ces deux r‚gles s'appliques aussi aux images.SPU )
;*************************************************************************
**  ( *96 pour rester allign‚ avec les adresses SPU )
canvas_raster:
	movea.l	a1,a3			; Pal restore H	destination
*	lea.l	179*96(a1),a3		; Pal restore B	destination
	lea.l	19200(a1),a0		; Pal display H	source
	lea.l	179*32(a0),a4		; Pal display B	source
	lea.l	19200+30(a0),a2		; Adresse des palettes noir
:
;backup palette pour off menu haut ecran et ligne "info fichier"
	bsr.s	pal_copy		; Copie des palettes a0 sur a3
  
;backup palettes  pour off menu bas ecran et menu diaporama        
	lea.l	179*96(a1),a3		; Pal restore B
	movea.l	a4,a0			; Pal display B
 	bsr.s	pal_copy		; Copie des palettes  a0 sur a3

	moveq.l	#20,d0			; 21 palettes noir et blanc
white:	move.w	#$FFF,(a2)
	move.w  #$FFF,8(a2)
	lea.l	32(a2),a2
	dbra.w d0,white
;.......................................	

;copy image to screen for viewer
	movem.l	60(sp),a0		; Adr start image	
	move.l	$44E,a3			; Adr screen
	move.l	#32000/32-1,d0
	bsr.s	recopy_Nbytes		; pic_to_screen pour le diaporama
;-------------------------------------------------------------------------
end_RST:
	moveq.l	#0,d0
MAIN:	movem.l (sp)+,a0-a6/d1-d7
	rts

error:	moveq.l #-6,d0			; Raster_error% !???
	bra.s MAIN
;-------------------------------------------------------------------------
save_rst:
	movem.l 60(sp),a0-a1
	moveq.l	#0,d0
	lea.l	6800(a0),a2

s_copy:	move.w	d0,(a0)+	; index palette
	movem.l	(a1)+,d1-d7/a4
	movem.l	d1-d7/a4,(a0)
	lea.l	32(a0),a0
	addq.l	#1,d0
	cmpa.l	a0,a2
	bhi.s	s_copy
	move.l	#6800,d0
	bra.s main
;-------------------------------------------------------------------------
n_fill:	movem.l	(a0)+,d2-d7/a5-a6
Fill20	movem.l	d2-d7/a5-a6,(a3)
	lea.l	32(a3),a3
	addq.w	#1,d1
	cmp.w	d0,d1
	bne.s	Fill20
	rts
;---------------------------------------
Pal_copy:	moveq.l	#20,d0		; 21 palette pour le menu diaporama
recopy_Nbytes:	movem.l	(a0)+,d2-d7/a5-a6
		movem.l	d2-d7/a5-a6,(a3)
		lea.l	32(a3),a3
		dbra.w	d0,recopy_Nbytes
		rts

	end
;*************************************************************************
