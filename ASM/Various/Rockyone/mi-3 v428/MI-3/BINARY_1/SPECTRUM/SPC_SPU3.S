; modified by rockyone		pour  MI-3 MI-9			19/03/2017
;	
; Add  SPU							22/03/2017
; Ajout copy palette et palette noir pour le diaporama		03.06.2019
; Modif. l'image ne serat plus conserv‚ aprŠs conversion	07.07.9019
; modifi‚ pour petits fichiers SPC 				09.07.2019
; Modif retour eror: -2 bad header or bad file size		11.09.2019
;		     -5 bad dcompressed
; Alignement des buffers palettes sur ceux d'IFF		19.10.2020
;-------------------------------------------------------------------------		
;
;				OPEN SPC SPU
;
; Source	72224 Fichier Spectrum charg‚ … source+0
; Ecran         Adresse physique de l'‚cran
; Buf_ecr       32034 : ecr_buf = buf_ecr+34
; File_size     taille du fichier spectrum
;
;	Call Spc_SPU ( L Source, L Screen, L Ecr_buf, Low(file_size) )
;	--------------------------------------------------------------
;
; Retour:  D0 =  0  Ok
;	   D0 = -2  Erreur
;
;
; Retour buffer Source
;   +0       5120 octets : reserv‚s pour table de conversion
;   +5120     320 octets : reserv‚s pour conversion ligne image
;   +5440                : 
;   +32000  19200 octets : palettes Restauration, Sauvegarde, Conversion
;   +51200  19200 octets : palettes Affichage
;   +70400   2016 octets : 63 palettes / 21 lignes, pour le diaporama
;   total   72416 octets
;
;
; Retour Screen   image 
; Retour Ecr_Buf  image pour restauration et conversion en gris
;
;  - l'image Spectrum est perdue aprŠs la conversion en gris -
;-------------------------------------------------------------------------
;SPC : 
; 	 +0	W	'SP'
;  	 +2	W	$0
;  	 +4	LW	taille de l'image compress‚
;  	 +8	LW	taille des palettes compress‚
; 	+12	LW	d‚but des data images compres‚
;
;SPU :  +0              data image   32000
;	+32000	        palette      19104 
;			total	     51104 octets
;-------------------------------------------------------------------------
;a0 buf_pic
;a1 screen
;a2 buf_ecr+34
		movem.l	d1-d7/a0-a6,-(sp)	
		movem.l	60(sp),a0-a2
		move.w	72(sp),d6		; file size

		movea.l	a0,a3			; adr. copy palette		
		adda.l	#51200,a3
		lea.l	32000(a1),a6		; End of screen

		moveq.l	#-2,d0
		cmpi.w	#$5350,(a0)		; "SP" ?
		bne	spu			

;-------------------------------------------------------------------------
;				SPC
;-------------------------------------------------------------------------
; init
;a0 source
;a1 screen
;a2 buf_ecr
;a3 = a0  
;a6 end screen

		lea.l	12(a0),a4		; address image data
		moveq.l	#1,d1			; for byte offset 
		moveq.l	#7,d2			;

		bsr	first_line		; clear first line screen

		lea.l 	8(a6),a5		; end of last plane

depac:		move.b	(a4)+,d3		; start of unpacking
		ext.w	d3			; pack-bit method
		bpl.s	literal

		neg.w	d3
		addq.w	#1,d3
		move.b	(a4)+,d7
	
full:		move.b	d7,(a1)
		adda.l	d1,a1			; address next byte
		exg.l	d1,d2
		dbra.w	d3,full

		bra.s	depac_end
	
literal:	move.b	(a4)+,(a1)
		adda.w	d1,a1
		exg.l	d1,d2
		dbra.w	d3,literal
	
depac_end:	cmpa.l	a6,a1			; End of a plan ?
		bcs.s	depac			; No => continu
		bne	error

		addq.l	#2,a6			; End of the next plan.
		lea.l	-31840(a6),a1		; Beginning of next plan.
		cmp.l	a5,a6			; Last plan ?
		bcs.s	depac
;...............................................	
		move.l	a4,d7			; Calculate the number
		addq.l	#1,d7			; of uncompressed bytes...
		bclr	#0,d7			; 
		lea.l	12(a0),a4

		sub.l	a4,d7		
		cmp.l	4(a0),d7		; Compacted image size
		bne.s	error			; Error ! => End.
;...............................................
;a4 a5 source
;a3 buffer palette
; palettes decompress‚es dans pal_display (199*96 to 200*96)
		lea.l	96(a3),a2		; Pal_restor line 1
 		move.l	8(a0),d1		; Compacted pallet size.
		lea.l	12(a0,d7),a4		; Palett address.
		movea.l	a4,a5			; For control

		move.w	#$254,d4		; Nomber of palettes -1
		moveq.l	#0,d7

pal:		moveq.l	#13,d2			; Unpacking the palette.
		move.w	(a4)+,d3
		lsr.w	#1,d3
		move.w	d7,(a2)+
color:		lsr.w	#1,d3
		bcc.s	empty			; 
		move.w	(a4)+,(a2)+
		dbra.w	d2,color
		bra.s	pal_end
	
empty:		move.w	d7,(a2)+
		dbra.w	d2,color
	
pal_end:	move.w	#$fff,(a2)+		; Color 15
		dbra.w	d4,pal
		suba.l	a5,a4			; Nunber byte depacted.
		cmp.l	d1,a4			; Compare with the size of
;						; the compressed pallets.
		bne.s	error
		
;-------------------------------------------------------------------------
;
;-------------------------------------------------------------------------
; recopy Pal_Display dans Pal_restor
recopy_pal:	movea.l	a3,a0			; Pal_display
		lea.l	-19200(a0),a1		; Pal_restor

		lea.l	19200(a1),a6		; Copy the palettes for 
		bsr.s	copy_32			; the slideshow.

; 21 palettes noir pour la ligne "Info fichier" et le menu du diaporama
		lea.l	19200+30(a3),a3
		move.w	#63-1,d0		; 63 palettes = 21 ligne.
black_pal:	move.w	#$fff,(a3)		; To display Info_File
		adda.w	#32,a3			; and slide show menu on
		dbra.w	d0,black_pal		; image.

; copie Screen to Ecr_buf
		bsr.s	recopy_pic		; image on Buf_Ecr a2

;inutile maintenant que tout l'ecran est copier
*		move.l	60(sp),a1		; clears first line of
*		bsr.s	first_line		; the image source.

		moveq.l	#0,d0			; Return no error.
;-------------------------------------------------------------------------
;bad header or bad size file

bad_header:					
end_prg:	movem.l	(sp)+,d1-d7/a0-a6	
		rts
error: 		moveq.l	#-5,d0			; eror in compressed data
		bra.s	end_prg
;------------------------------------------------------------------------
;				Sub routines
;------------------------------------------------------------------------
first_line:	moveq.l	#160/8-1,d7		; Clears the first line
clear:		clr.l	(a1)+			
		clr.l	(a1)+
		dbra.w	d7,clear
		rts
;		--------------------------------		
recopy_pic:	movem.l	68(sp),a0-a1		
		lea.l	32000(a1),a6		; recopy 32000 byte
copy_32:	move.l	(a0)+,(a1)+		; or   19104     bytes
		move.l	(a0)+,(a1)+		; or   19200     bytes
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		cmpa.l	a1,a6
		bhi.s	copy_32
		rts		
;-------------------------------------------------------------------------
;				SPU
;-------------------------------------------------------------------------
spu:		ext.l	d6
		cmpi.w	#51104,d6	; File size ?
		bne.s	bad_header	; Error !!

; image to screen
		bsr.s	first_line	; a1 Clear first line screen
		lea.l	160(a0),a0	; a0 Jump first line image
		bsr.s	copy_32		; a0 on a1 Image on the screen 

; a1=a6 screen
; a0= source + 32000
; a3= source + 51200
; aligne les datas palettes dans le buffer pal_display
;	a0 :  	source 199*3*32 palettes
; 	a1 :	but    200*3*32 palettes
;	
; palette to Pal_display
	lea.l	96(a3),a1	; but + 3 palette noir ( ligne 0 )
	lea.l	19200(a3),a6	; limite de copie        : 19104 bytes
	bsr.s	copy_32		; On the source +51200

; aO = source+51104
; a3 = source+51200	
; recopy toutes les palettes dans le buffer pal_restore source+32000
;
; Pal_display to Pal_restor
	bra.s	recopy_pal

	END
;-------------------------------------------------------------------------
	