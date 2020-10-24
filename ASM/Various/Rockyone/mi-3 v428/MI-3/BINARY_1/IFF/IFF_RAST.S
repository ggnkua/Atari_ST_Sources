; rockyone			Pour MI-3			28.09.2020
;								07.10.2020
;rectif addresse black pal bas ‚cran				17.10.2O20
;-------------------------------------------------------------------------
;				RASTER IFF
;
;	Routine de preparation du buffer pallettes
; 
; Buf_ecr : buffer ecran contenant l'image au format pi1
; Buf_pic : buffer du ficher image
; +2		palette de limage
; +32000	adresse du bloc Pal_raster_Restore
; +19200	adresse du bloc Pal_raster_Display
; +19200	adresse du bloc de palette noir
; ( Les adresses des blocs sont identique pour les images SPU ) 
; 
;	call iff_raster( L buf_ecr, L buf_pic, L offset_raster )
;-------------------------------------------------------------------------
; a0 adresse "RAST" +4 		; Address peer or odd
; a1 buffer pal restore
; a2 buffer pal display

	movem.l	a0-a6/d1-d7,-(sp)

	movem.l	60(sp),a0		; Adr bufer image	
	lea.l	32000(a0),a2
	move.l	$44E,a3			; Adr screen
	move.l	#32000/32-1,d0
	bsr	recopy_Nbytes		; pic_to_screen pour le diaporama
;.........................................................................
;start
	movem.l	64(sp),a0-a1		; Adr fichier / ofset palette	
	lea.l	32000(a0),a2		; Adr Pal_restore
	lea.l	19200(a2),a3		; Adr Pal_display

	add.l	a1,a0			; Adr des palettes source
	movea.l	a2,a1			; Bakup address for:
	move.l	a0,d7			; Init resgistre
	andi.l	#1,d7			; Peer address ?
	beq.s	peer_address		; Yes

;--------------------------------------------------------
; Replace les Words sur une adresse pair
   	lea.l	6804(a0),a4		; Dernier word des palettes.
recopy:	move.b	-(a4),1(a4)		; Tous les words sur adresse pair
	cmpa.l	a0,a4
	bne.s	recopy		
	addq.l	#1,a0			; Peer address ! First color word !
;--------------------------------------------------------
; Test des data
peer_address:
	movea.l	a3,a4			; Address for pal display
	move.l	(a0)+,d0		; 6800 ?
	divu.w	#34,d0			;  200
	andi.w	#$ff,d0			;
	subq.w	#1,d0			; Nombre de raster <=0 !!?? 
	bmi.s	error
;--------------------------------------------------------

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

	cmp.w	(a0),d1		; recopier la palette
	bne.s	Fill1		; yes 

	addq.l	#2,a0		;lecture de lindex de la prochaine palette
	dbra.w	d0,FillPalBuffer

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

	movea.l	a1,a3			; Adr buffer pal restore H
*	lea.l	179*96(a1),a		; Adr buffer pal restore B
	lea.l	19200(a1),a0		; Adr buffer pal display H
	lea.l	179*32(a0),a4		; Adr buffer pal display B

;backup palette haut eran pour off menu et ligne "info fichier"
	lea.l	19200+30(a0),a2		; Adresse des palettes noir
	bsr.s	pal_copy		; Copie des palettes a0 sur a3
  
;backup palettes bas ecran pour off menu et menu diaporama        
	lea.l	179*96(a1),a3		; Pal restore B
	movea.l	a4,a0			; Pal display B
 	bsr.s	pal_copy		; Copie des palettes  a0 sur a3

	moveq.l	#20,d0			; 21 palettes noir et blanc
white:	move.w	#$FFF,(a2)
	lea.l	32(a2),a2
	dbra.w d0,white
	
;--------------------------------------------------------
	moveq.l	#0,d0
MAIN:	movem.l (sp)+,a0-a6/d1-d7
	rts

;--------------------------------------------------------
;	cr‚ation d'un numero d'ereur pour le signaler … l'utilsateur
error:	moveq.l #-6,d0		; Raster_error% !???
	bra.s MAIN
;--------------------------------------------------------
n_fill:	movem.l	(a0)+,d2-d7/a5-a6
Fill20	movem.l	d2-d7/a5-a6,(a3)
	lea.l	32(a3),a3
	addq.w	#1,d1
	cmp.w	d0,d1
	bne.s	Fill20
	rts
;--------------------------------------------------------
Pal_copy:	moveq.l	#20,d0		; 21 palette pour le menu diaporama

recopy_Nbytes:	movem.l	(a0)+,d2-d7/a5-a6
		movem.l	d2-d7/a5-a6,(a3)
		lea.l	32(a3),a3
		dbra.w	d0,recopy_Nbytes
		rts

	end
;*************************************************************************
