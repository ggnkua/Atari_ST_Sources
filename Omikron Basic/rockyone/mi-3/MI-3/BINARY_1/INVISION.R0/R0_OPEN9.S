;rockyone			pour MI-9		 	 16.10.2017
;
;		open invision	R01  1 plan  all resol
; 				R02  2 plans medium resol
;				R04  4 plans low resol
;
;	open only pic the image <= width and height screen 
;		      
;
; source: 	adr buffer invision
; But		adr buffer 32034 octets
; size		file size
; type		number in the extention RO?
; rez		resolution choisie pour R01, sinon resolution de l'‚cran
;
;
;		call 	RO_open( L source, L but, W zise, W typ, W rez)
;		-------------------------------------------------------
;
; Return 	in low do	
;				-4 If the image too large for 
;				   requested resolution 
; 
;--------------------------------------------------------------------------
;+0 largeur	minimum, 32 pixels 2 word, 33 pixel 3 word...
;+2 hauteur     '''''''''''''''''''''''''
;+4 image
;+? palette image  R01 no pal
; 		   R04 96 bits
;		   R02 24 bits	
;          
;-------------------------------------------------------------------------
;free:	a6
;*********
;ao SOURCE
;a2 end file source
;d1 nb_word by line source
;d2 nb_line source
;
;a1 BUT
;a3 Start all line
;a4 End of a line
;a5 param puis end but
;d0 ofset word       
;d3 mask for last word
;d4 size line screen 160 160 80
;d5 copy de d1
;d6 number in extension
;d7 resolution

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1		; source and but
		movem.w	68(sp),d5-d7		; 
  		lea.l	0(a0,d5.w),a2		; end source

;.......................................test resol image/screen.........
		cmpi.b	#1,d6			; R01  ?
		beq.s	ok_resol

		move.b	d6,d7			; resol for R02,R04
		lsr.b	#1,d7			;             1,  2 
		andi.b	#1,d7			;	      1,  0

ok_resol:	
;.......................................test size image/screen..........

		moveq.l	#-4,d0			;R image too large
		move.w	d7,d2			; resol image
		mulu.w	#6,d2			; 
		lea.l	param(pc),a5
		adda.w	d2,a5
		move.w	(a0),d1			; image width in pixel
		cmpm.w	(a0)+,(a5)+
 		bmi	error			; >
		move.w	(a0),d2			; image height 
		cmpm.w	(a0)+,(a5)+			 
		bmi	error			; >

;.......................................with image in word...........
		moveq.l	#0,d0
		moveq.l	#0,d3			; reset mask last word
		move.w	d1,d0			; with image in pixel	 
		divu.w	#16,d0
		move.w	d0,d1
		mulu.w	d6,d1		 	; SOURCE, WORD BY LINE
		swap	d0		
		tst.w	d0			
		beq.s	not_odd			; >0 if odd width
		move.w	d0,d4
		subq.w	#1,d0
set_bit:	bset.b 	d0,d3
		dbra	d0,set_bit
		ror.w	d4,d3
not_odd:

;................................................

 		moveq.l	#8,d0			; Offset word
		lsr.b 	d7,d0			;         8,4,2  R01
		cmp.b	#1,d6			; R01 ?
		beq.s	ok_offset		; yes
		moveq.l	#2,d0			;         2	 R02 R04
ok_offset:
      		subq.b  #1,d1            	; Nb_word -1 for dbra      
		subq.b	#1,d2			; Nb_line -1 for dbra 
		move.w	(a5),d4			; Line screen size

;.......................................transfert image....................

		move.w	d7,(a1)			; But: write resolution
		lea.l	34(a1),a3		; But: jump palette
		movea.l	a3,a4
		lea.l	32000(a3),a5		; End screen

lines_pic:  	adda.w	d4,a4			; End of a line  
		move.w	d1,d5			; Nb word by line
copy_line:	move.w	(a0)+,(a3)		; Copy_image
		adda.w	d0,a3			; Offset word
		dbra	d5,copy_line		; 

		tst.w	d3			; odd width ?
		beq.s	next_line		; no	
		move.w	d6,d5			; number plane

odd_word:	move.w	#$ffff,d7
		sub.w	d3,d7
		and.w	d3,(a0)
		add.w	d7,(a0)
		move.w	(a0)+,(a3)
		adda.w	d0,a3			; offset word	
		subq.b	#1,d5
		bhi.s	odd_word
		
next_line:	bsr.s	finish_line
		movea.l	a4,a3			; start next line
		dbra	d2,lines_pic		

		bsr.s	finish_screen		

;........................................palette ?.........................
		cmpi.w	#2,(a1)+	
		beq.s	no_pal			; only 2 color in high resol
		cmpa.l	a0,a2			; end source if "R01" ?
		beq.s	no_pal

		bsr.s	palette
		bra.s	end_prg
no_pal:		move.l	#$fff0000,(a1)		; colors high resol
;-----------------------------------------------
end_prg:	moveq.l	#0,d0
error:		movem.l	(sp)+,d1-d7/a0-a6
		rts
;-----------------------------------------------
finish_screen:	movea.l	a5,a4	
finish_line:	cmpa.l	a4,a3			; End_line screen ?
		bpl.s	end_line		
		move.w	#$ffff,(a3)		
		adda.w	d0,a3			; offset
		bra.s	finish_line
end_line:	rts
;........................................palette de couleur RVB / HARD
;d0
;d1 = 2
;d3 read r ,v ,b
;d5 add r, v, b
;d6 index for  a1

palette:	move.l	#0,d6
		move.l	a2,d5
		lea.l	vdi_2(pc),a3	; table de conversion resol 2
		subq.b	#4,d5
		beq.s	read_color

		addq.l	#2,a3		; table de conversion resol 1
		subi.b	#20,d5
		beq.s	read_color

		addq.l	#4,a3		; table de conversion resol 0

read_color: 	moveq.l	#2,d1		;3 valeurs a lire
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
		dbra	d1,rvb

		move.b	(a3)+,d6		; index couleur VDI HARD
		move.w	d5,0(a1,d6.w)		; Save color
		cmpa.l	a0,a2			; end source ?
		bhi.s	read_color
		rts
;-------------------------------------------------------------------------
Vdi_2:	dc.b 	0,2
	dc.b 	0,6,2,4
	dc.b 	0,30,2,4,8,12,6,10,14,16,18,20,24,28,22,26
	even
;-------------------------------------------------------------------------
;	        height, wifth, line size
param:	dc.w	320,200,160		; R01 R04
	dc.w	640,200,160		; R01 R02
	dc.w	640,400,80		; R01
	end
;*************************************************************************	