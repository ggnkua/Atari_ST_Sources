;rockyone			pour MI-3 & Mi-9		02.08.2019
;
;init d6 for open	 					24.09.2019
;
; 
;
;			 	DESPIC.GFB 
;
;		   
;		Open	call Gfb_Os( L source, L but, 0 )
;
;Return  -2 dans d0 si ereur
;	
;		save	call Gfb_Os( L but, L source, 1 )
;
;Return taille du fichier
;	
;-------------------------------------------------------------------------
; + 0  L 	'GF25'
; + 4  L	nombre de couleur  ST: 2, 4, 16  Falcon: 256
; + 8  L	largeur en pixel
; +12  L	hauteur en pixel
; +14  L	taille des data images
; +20  		copie d'‚cran
; +32020	palette de couleur VDI dans l'ordre VDi
;
;-------------------------------------------------------------------------

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1

		lea.l	header(pc),a3	

		moveq.l	#0,d3
		moveq.l	#2,d1		; for test and write header


		tst.w	68(sp)	
		bne	save_gfb	; open or save ?

;-------------------------------------------------------------------------
;				OPEN GFB
;-------------------------------------------------------------------------

open_gfb:	moveq.l	#-2,d0
		cmpm.l	(a3)+,(a0)+		; id 
		bne.s	error

loop1:		movea.l	a0,a2
		movea.l	a3,a4
		moveq.l	#2,d2
loop2:		cmpm.l	(a2)+,(a4)+		
		bne.s	no_good

		dbra.w	d2,loop2

		bra.s	data_size

no_good:	adda.l	#14,a3
		dbra.w	d1,loop1

		bra.s	error

data_size:	cmpi.l	#32000,(a2)+
		bne.s	error

		move.w	d1,(a1)+	; Resolution image
		lea.l	32(a1),a3	; Pointe But sur data image	
		bsr 	copy_image

;........................................palette de couleur RVB | HARD
		move.l	-12(a4),d2		; number colors

*		move.w	(a4),d4			; offset table 
*		lea.l	vdi_hard(pc),d4.w),a3

		lea.l	vdi_hard(pc),a3
		adda.w	(a4),a3
		moveq.l	#0,d6
open_color:	moveq.l	#2,d1		
		moveq.l	#0,d5

rvb:		moveq.l	#0,d3		
		move.w	(a2)+,d3	; Read Word R then V then B
		andi.w	#$fff,d3
		lsl.w	#4,d3
		divu.w	#1000,d3
	
		move.b	d3,d4
		lsr.w	#1,d3
		cmpi.b	#8,d3
		bne.s	c8_rvb
		addq.b	#7,d3
c8_rvb:		andi.b	#1,d4
		beq.s	ok_rvb
		addq.b	#8,d3

ok_rvb:		lsl.w	#4,d5
		add.b	d3,d5		; add r,v,b
		dbra.w	d1,rvb	

		move.b	(a3)+,d6	; index couleur VDI HARD
		move.w	d5,0(a1,d6.w)	; Save color

		subq.b	#1,d2
		bhi.s	open_color

		moveq.l	#0,d0

;........................................................................
error
end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts


;......................................................................
	even
header:	dc.l	'GF25'		;Identit‚
	dc.l	2,640,400	;Nb couleur, largeur, hauteur
	dc.w	20		;Offset table vdi/hard
	dc.l	4,640,200
	dc.w	16
	dc.l 	16,320,200
	dc.w	0
	
Vdi_hard:	
	dc.b 	0,30,2,4,8,12,6,10,14,16,18,20,24,28,22,26
	dc.b 	0,6,2,4
	dc.b 	0,2
	even
;..........................................................................
copy_image:	move.l	#8000-1,d0
copy_lw		move.l	(a2)+,(a3)+	
		dbra.w	d0,copy_lw
		rts

;-------------------------------------------------------------------------
;				SAVE GFB
;-------------------------------------------------------------------------
save_gfb:	move.l	(a3)+,(a0)+	; ID file

		addq.l	#1,a1
		moveq.l	#2,d0
		sub.b	(a1)+,d0		; resol image source
		mulu.w	#14,d0			

		adda.w	d0,a3
	
		move.l	(a3)+,d2		; nunber colors
		move.l	d2,(a0)+
		move.l	(a3)+,(a0)+		; width
		move.l	(a3)+,(a0)+		; height
		move.l	#32000,(a0)+		; size of the image


		move.w	(a3),d4		 	; offset table

		movea.l	a0,a3		
		lea.l	32(a1),a2

		bsr.s	copy_image		; a2 to a3


		lea.l	vdi_hard(pc,d4.w),a4	;

		moveq.l	#0,d6

		addq.l	#6,a3

read_color:	moveq.l	#2,d1
		move.b	(a4)+,d6		; read index vdi color
		move.w	0(a1,d6.w),d3		; read hard color

save_bvr:	moveq.l	#0,d5
		move.b	d3,d5			; B, then V, then R

		andi.b	#$f,d5
		mulu.w	#1000,d5
		divu.w	#15,d5

		move.b	d5,d0
		mulu.w	#2,d5
		cmpi.w 	#1000,d5
		blt.s	c8_vbr
		subi.w	#1000,d5
c8_vbr:		andi.b	#3,d0
		beq.s	ok_vbr
		addq.b	#1,d5

ok_vbr:		move.w	d5,-(a3)
		lsr.w	#4,d3 		
		dbra.w	d1,save_bvr

		adda.l	#12,a3		; point to next Bleue 

		subq.b	#1,d2
		bhi.s	read_color

		move.l	#33556,d0		;R. file size
		bra	end_prg

		end
;-------------------------------------------------------------------------



