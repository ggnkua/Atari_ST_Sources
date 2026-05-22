;rockyone			pour MI-3 Mi-9			02.07.2018	
;			
;Source	Spc2low.s de Sybthetic Art v1
;	
;
;			convert	SPC TO PI1
;
;
;buffer: adresse 	taille ( en octets )
;
;A0	 Screen		32000 	Image Spectrum d‚compress‚s
;A1      Palette	19104	Palette Spectrum d‚compress‚
;A3      a1+19104        9552   Table de conversion
;A4	 a1+28656         320   Ligne buffer
;	
;
;A2	 But    	32066 	octets pour image Pi1
;
;				  a0	    a1	    a2
;		call Spc_Pi1( L Screen, L palette L But )
;
;-------------------------------------------------------------------------

	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	64(sp),a0-a2

	move.w	#0,(a2)+		; Low-res
	movem.l	Gray_pal(pc),d0-d7	; palette
	movem.l	d0-d7,(a2)
	lea.l	32(a2),a2		; Adr image destination

	lea.l	19104(a1),a3		; Adr table de conversion
	lea.l	320*16(a3),a4		; Adr line buffer


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

;................................. convertir les palettes en gris.......
	
		movea.l	a1,a5		; adr palette Spectrum 

		move.w	#16*3*199-1,d7  ; 3 palettes par ligne 19104 octets
		moveq.l	#0,d6

ConvColor	andi.b	#15,d6		;16 couleurs par palette
		bne.s	Skip			

		clr.w	(a5)+
		bra.s	Cont			

Skip:		moveq.l	#$7,d0			
		and.b	(a5)+,d0
		moveq.l	#$7,d1
		move.b	(a5),d2
		and.w	d2,d1
		lsr.b	#4,d2
		add.b	d1,d0
		add.b	d2,d0
		add.w	d0,d0
		divu.w	#3,d0
		move.b	d0,(a5)+
Cont:		addq.b	#1,d6			
		dbra.w	d7,ConvColor

;............................................conversion image.............

		lea.l	160(a0),a0		; jump first line 

		moveq.l	#39,d7		
first_line:	clr.l	(a2)+
		dbra.w	d7,first_line


		move.l	#198,d7			; LineIndex (1-199)
LineLoop:	moveq.l	#19,d6
		movea.l	a4,a6			; line buffer
		movea.l	a3,a5			; convert table

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
		move.b	1(a1,d4.w),(a6)+
		lea.l	16(a5),a5
		dbra.w	d5,XSLoop1
		dbra.w	d6,XLoop1

		lea	32*3(a1),a1		;3 palettes suivante

		movea.l	a4,a6			; line buffer
		moveq.l	#19,d6			; 20 word par ligne
XLoop2:		moveq.l	#15,d5			; 15 pixel par word
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

		movem.w	d0-d3,(a2)		;copy to but
		addq.l	#8,a2
*		lea.l	8(a2),a2		 
		dbra.w	d6,XLoop2
		dbra.w	d7,LineLoop
;.........................................................................
		movem.l	(sp)+,d0-d7/a0-a6
		rts
;.........................................................................	

Gray_pal:	dc.w	0,$888,$111,$999,$222,$aaa,$333,$bbb
		dc.w	$444,$ccc,$555,$ddd,$666,$eee,$777,$fff

		end
;*************************************************************************