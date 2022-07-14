;Rockyone			Pour MI-3 MI-9			17/09/2016
;
;optimisation du code						18/02/2017
;test tag "LSd!"						26.03.2018
;Test file size							16.09.2019
;Modif appel							10.01.2021
;
;			CANVAS 	 CNV fichier sans r‚solution
;			------------------------------------
;
;    ***************************************************************
;    *	Rez%  : Doit toujours ‚tre la r‚solution de l'image avant  *
;    *	        open ou save  afin d'avoir une palette correct.    *
;    ***************************************************************
;
;
; 		             open		 save
; 	|-------------|------------------|------------------|
; 	| Source      |  32048 octets    |   32034 octets   |
; 	|-------------|------------------|------------------|
; 	| Destination |   32034 octets   |   32048 octets   |
; 	|-------------|------------------|------------------|
; 	| Op%	      |       0  	 |  	   1        |
; 	|-------------|-------------------------------------|
; 	| Rez%	      |    Egal  r‚solution de l'image      |
; 	|-------------|-------------------------------------|
;
;
;	open	Call Canvas ( L Source, L Destination, Op%, Rez%)
;	save	Call Canvas ( L Destination, L Source, Op%, Rez%)
;	call cnv_os ( L but, L source, Op%, low(file_size, res% )
;	---------------------------------------------------------
;
;
;
; +0 	48 byte palette
; +48 	data non compress‚
; ou
; +48  	1 L.W 	"LSD!" 	Tag Automation v2.3r
; +52  	1 L.W		taille fichier d‚packt‚
; +56  	1 L W		taille fichier packt‚ -52
;-------------------------------------------------------------------------

		movem.l d1-d7/a0-a6,-(a7) 
		movem.l	60(sp),a0-a1
		moveq.l	#0,d7
		move.w	68(sp),d6
		move.w 	70(sp),d0
		move.w	72(sp),d7
;		movem.w	68(sp),d0/d6-d7	;low( file_size),op% ,rez%

		move.w	d7,d5		; resolution impos‚
		lsl.w	#4,d5		; *16 offset table couleur
		moveq.l	#15,d1		; Compteur couleur palette
		moveq.l	#0,d3		; Offset couleur destination

		tst.b	d6		;open or save ?
		bne.s	save_pic

;--------------------------------------- OPEN CNV -----------------------

		cmpi.l	#'LSD!',48(A0)
		bne.s	not_lsd
		cmpi.l	#32000,52(a0)
		bne.s	error
		bra.s	ok_file	

not_lsd:	ext.l	d0
		cmpi.l	#32048,d0
		bne.s	error

ok_file:	move.w	d7,(a1)+ 		; resol demand‚ ! 		

		lea.l	color_open(pc,d5.w),a6	; table conversion couleur

o_pal:		moveq.l	#0,d2
		move.b	(a0)+,d2		; R
		lsl.b	#4,d2
		add.b	(a0)+,d2		; V
		lsl.w	#4,d2
		add.b	(a0)+,d2		; B

		move.b	(a6)+,d3		; Index de conversion
		move.w	d2,0(a1,d3.w)		
	
		dbra.w	d1,o_pal

		cmpi.l	#'LSD!',(A0)	        ; file ".cnv" compact‚
		beq.s	_end

		lea.l	32(a1),a1
		bra.s 	copy_image

;......................................SAVE CNV..........................

save_pic:	exg.l	a0,a1

		addq.l	#2,a0			; Source : start palette
		lea.l	color_save(pc,d5.w),a6	; Table de couleur
	
s_pal:		move.b	(a6)+,d3  		; index de conversion
		lea.l	0(a1,d3.w),a2	

		move.b	(a0)+,d2		; R
		andi.b	#$f,d2		
		move.b	d2,(a2)+	

		move.b	(a0),d2			; V
		lsr.b	#4,d2		
		move.b	d2,(a2)+	

		move.b	(a0)+,d2		; B
		andi.b	#$f,d2		
		move.b	d2,(a2)+	 

		dbra.w	d1,s_pal
	
		lea.l	48(a1),a1

;......................................data image non compact‚......

copy_image:	move.w	#7999,d6
copy:		move.l	(a0)+,(a1)+
		dbra.w	d6,copy
		move.l	#32048,d0	; file size
;------------------------------------------------------------------------

_end:		movem.l (a7)+,d1-d7/a0-a6 
		rts 
error:		moveq.l	#-2,d0
		bra.s	_end
;......................................table couleurs..................
;
; Canvas charge que qatre couleurs en moyenne r‚solution, mais en
; sauvegarde 16 ?? BUG !!!

	even
color_open:	
*		   * *     *
*		0 15 1 2 4 6  3  5  7  8  9 10 12 14 11 13	; basse
	dc.b	0,30,2,4,8,12,6,10,14,16,18,20,24,28,22,26	; *2
	even		
*		  *           *
*		0 3 1 2 4  6 15  5  7  8  9 10 12 14 11 13	; moyenne
	dc.b	0,6,2,4,8,12,30,10,14,16,18,20,24,28,22,26
	even	
*		  *  *
*		0 1 15 2 4 6  3  5  7  8  9 10 12 14 11 13	; haute
	dc.b	0,2,30,4,8,12,6,10,14,16,18,20,24,28,22,26
	even
;
color_save:	
* 		  *    *                                  *                    
*		0 2 3  6  4  7  5  8  9 10 11 14 12 15 13 1	; basse
	dc.b	0,6,9,18,12,21,15,24,27,30,33,42,36,45,39,3	; *3
 	even
*		      *				         *
*		0 2 3 1  4  7  5  8  9 10 11 14 12 15 13 6	; moyenne
	dc.b	0,6,9,3,12,21,15,24,27,30,33,42,36,45,39,18
	even
*		  *                                       *				
*		0 1 3  6  4  7  5  8  9 10 11 14 12 15 13 2	; haute
	dc.b	0,3,9,18,12,21,15,24,27,30,33,42,36,45,39,6
	even
	
	end
;*************************************************************************
