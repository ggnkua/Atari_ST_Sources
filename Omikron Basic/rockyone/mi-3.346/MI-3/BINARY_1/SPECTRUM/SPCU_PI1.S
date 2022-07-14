;rockyone			pour MI-3 Mi-9			02.07.2018	
;
;debug conversion palette for SPU image				26.05.2019
;modif								10.07.2019
;Allignement des buffers avec ceux des images raste iff		19.10.2020
;			
;Source	: Spc2low.s of Synthetic_Art 1
;-------------------------------------	
;
;			convert	SPC and SPU to PI1
;			**************************
;
; Buf_ecr  32034 bytes
;		 	
;		+ 34 image specrum d‚compress‚
;
; Buf_pic  72224 bytes
; +     0	 5120	bytes	Table de conversion  16*320
; +  5120	  320	bytes	Line buffer
; +  5440	 5424	free	bytes
; + 10864	 2016	bytes 	63 palettes pour diaporama 
; + 1288O	19200 	free 	bytes
; + 32000	19200	bytes 	597 palettes Spectrum d‚compress‚e
; + 51200   	19200	bytes	597 palettes pour affichage
; + 70400	 2016	bytes 	63 palettes pour diaporama
;   72416	bytes  
;
;					a0	   a1	
;			call Spc_Pi1( L Puf_pic, L Buf_ecr )
;				    
;
; Return dans Buf_Ecr :  +0  $0     2 bytes
;			 +2   ?    32 bytes  Palette grise 16 couleurs
;			 +34  ? 32000 bytes  Image converti pour diaporama
;
;
;-------------------------------------------------------------------------

	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	64(sp),a0-a1		; buf_pic 
	

	lea.l	32000(a0),a2		; adresse des palette a converir

	move.w	#0,(a1)+		; R‚soluion image  Low-res
	movem.l	Gray_pal(pc),d0-d7	; Palette grise
	movem.l	d0-d7,(a1)		; 
	
	lea.l	32(a1),a1
*	lea.l	32+160(a1),a1		; Adr image destination
	movea.l	a0,a3			; Adr table de conversion
	lea.l	320*16(a3),a4		; Adr line buffer de conversion


;cr‚ation table de conversion ............................................

		movea.l	a4,a5		; Adr fin de la table de conversion
		move.w	#160,d5
		move.w	#319,d6		; x
PreCalcXL:	moveq.l	#15,d7		; c
PreCalcCL:	move.w	d7,d1		; c'
		moveq.l	#10,d0
		mulu.w	d7,d0		; x1=c*10
		addq.w	#1,d0	
		btst.b	#0,d7
		beq.s	Even
		subq.w	#6,d0
Even:		cmp.w	d6,d0
		bgt.s	Next
		addi.w	#16,d1
		add.w	d5,d0
		cmp.w	d6,d0
		bgt.s	Next
		addi.w	#16,d1
Next:		add.w	d1,d1
		move.b	d1,-(a5)
		dbra.w	d7,PreCalcCL
		dbra.w	d6,PreCalcXL

;...............Indexer les palettes sur la palette grise ...............
	
		movea.l	a2,a5		; adr palette Spectrum 

		move.w	#16*3*200-1,d7  ; 3 palettes par ligne 19104 octets
	
ConvColor:	moveq.l	#$7,d0			
		and.b	(a5),d0
		moveq.l	#$7,d1
		move.b	1(a5),d2
		and.b	d2,d1
		lsr.b	#4,d2
		andi.b	#$7,d2			; index color sur 3 bits !
		add.b	d1,d0
		add.b	d2,d0
		add.b	d0,d0
		divu.w	#3,d0
		move.w	d0,(a5)+		; index color 0 … 15
		dbra.w	d7,ConvColor

;............................................conversion image.............
*		moveq.l	#39,d7		
*first_line:	clr.l	(a1)+			; clear first line
*		dbra.w	d7,first_line

		
		movea.l	a1,a0			; But = source

		move.l	#199,d7			; Line Index (1 to 200)
LineLoop:	moveq.l	#19,d6
		movea.l	a4,a6			; line buffer
		movea.l	a3,a5			; convert table

; ( addx : adition source + destination avec le bit X du CCR )

XLoop1:		movem.w	(a0)+,d0-d3		; 4 words 
		moveq.l	#15,d5			; 16 bit par word
XSLoop1:	moveq.l	#0,d4
		add.w	d3,d3
		addx.w	d4,d4
		add.w	d2,d2
		addx.w	d4,d4	
		add.w	d1,d1
		addx.w	d4,d4
		add.w	d0,d0
		addx.w	d4,d4
		move.b	0(a5,d4.w),d4
		move.b	1(a2,d4.w),(a6)+
		lea.l	16(a5),a5
		dbra.w	d5,XSLoop1
		dbra.w	d6,XLoop1

		lea	32*3(a2),a2		;3 palettes suivante

		movea.l	a4,a6			; line buffer
		moveq.l	#19,d6			; 20 word par ligne
XLoop2:		moveq.l	#15,d5			; 16 pixel par word
XSLoop2:	move.b	(a6)+,d4
		lsr.b	#1,d4
		addx.w	d0,d0
		lsr.b	#1,d4
		addx.w	d1,d1
		lsr.b	#1,d4
		addx.w	d2,d2
		lsr.b	#1,d4
		addx.w	d3,d3
		dbra.w	d5,XSLoop2

		movem.w	d0-d3,(a1)		; copy to but a2
		addq.l	#8,a1
		dbra.w	d6,XLoop2		; 20 word par lignes
		dbra.w	d7,LineLoop		; 199 lignes
;.........................................................................
		movem.l	(sp)+,d0-d7/a0-a6
		rts
;.........................................................................	

Gray_pal:	dc.w	0,$888,$111,$999,$222,$aaa,$333,$bbb
		dc.w	$444,$ccc,$555,$ddd,$666,$eee,$777,$fff

		end
;*************************************************************************