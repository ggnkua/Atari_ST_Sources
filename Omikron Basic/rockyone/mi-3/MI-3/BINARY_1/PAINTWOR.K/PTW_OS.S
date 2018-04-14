; ROCKY.ONE			pour MI-3.PRG			19/10/2016
;
;				PAINT WORK
; 
;			open save  SC0 SC1 SC2
;			open 	   CL0 CL1 CL2
;		 	----------------------
;
;Does not open and save color cycles of images
;---------------------------------------------
;
;	+  2 		r‚solution 	1  word
;	+  4 		palette		16 word
;	+ 36 		file name	12 byte
;	+ 54 		header		 9 byte'AnivisionA'
;	+ 63 		flag		 1 byte
;	+ 64 to 127    	data interface PaintWork ( zero is compatible :)
;       +128		data image 
;   	.............................................
;    	After end data 	
;	+ 4	16 word		palette
;	+32	long word	#4
;	+36	long word	#5	
;
;     	       |------------|------------------------------|
;              |  Word 2    |           Byte 63            |
;     |--------|------------|---------------|--------------|
;     | File   | r‚solution | uncompressed  |  compressed  |
;     |--------|------------|---------------|--------------|
;     | .PG0-2 |  0  1  2   | $00  $10  $20 | $80 $90  $a0 | 
;     | .SC0-2 |  0  1  2   | $01  $11  $21 | $81 $91  $a1 | open save
;     | .CL0-2 |  0  1  2   | $02  $12  $22 | $82 $92  $a2 | open
;     | .PT0-2 |  0  1  2   | $04  $14  $24 |	           |
;     | .CYC   |  0  1  2   | $05  $15  $25 |	           |
;     |--------|------------|---------------|--------------|
;
;			OPEN		SAVE
; Source:	buffer( fife_size )	Alway,  byte 0(Source)=0 !
; But 	:	32066 bytes    		32172 bytes for uncompresssed image 
; Op%	=	0			    1
; Pack%	=	0			    1 non compact‚
;					    0 compact‚'
;
; Return in
; Low d0	 0 pas d'erreur		File size
;		-2 mauvais fichier
; High d0	R‚solution image
;
;
;  		open  Call  PAIN_WORK ( L Source, L But, W Op%,W 0 )
;  		save  Call  PAIN_WORK ( L but, L save, W Op%, W pack% )
;		*******************************************************
;
; for open: but +0 , 1 Word r‚solution voulue
;------------------------------------------------------------------------
;d2 dbra d2,....
;d7 Op%, R‚sol
;
		movem.l	d1-d7/a0-a6,-(a7)	 
		movem.l	60(a7),a0-a1		;source/destination
		move.w	68(sp),d7
		
		tst.b	d7			; open or save ?
		bne	save_ptw
		
;........................................test header
		moveq.l	#-2,d0			;R. bad file
		lea.l	54(a0),a2

		lea.l	header(pc),a3		; "ANvisionA"

		move.w	(a3)+,d1
test:		cmpm.b	(a3)+,(a2)+	
		bne	erreur
		dbra.w	d1,test
;...............................

		move.b	(a2),d1         ; byte 63
		andi.b	#$f,d1
		beq	erreur		; Pg0-2  file page
		cmp.b	#3,d1		
		bpl	erreur		;
	
		addq.l	#2,a0
		move.w	(a0)+,d7	; stok resol pic
		move.w	d7,(a1)+	; copie resolution
	
		bsr.s	copy_palette

;.......................................Test byte 63
   
		btst.b	#7,(a2)+	; image compacte ?
		lea.l	64(a2),a0	; = 	lea.l 	92(a0),a0p
;					;	pointe sur 128(a0)
		bne.s	depact		; oui 

		bsr.s 	no_pack
		bra.s	end_open
;.......................................fichier compress‚

depact:		moveq.l	#7,d1
		lsr.b	d7,d1	; 7, 3, 1
		subq.b	#1,d1	; 6, 2, 0	 pour eori
		move.b	d1,d0	
		lsr.b	#1,d0	; 3, 1, 0	; nombre de plan
 		moveq.l	#1,d5			; eori 1 / d1 

		lea.l   2(a1),a2		; pointe sur prochain plan
		lea.l	32000(a1),a3		; fin d'un plan

		moveq.l	#0,d2

lire_code:	moveq.l	#0,d3
		move.b	(a0)+,d3
		bmi.s	literal			;<0

		subq.b	#1,d3			; -1 pour dbra
		move.b	(a0)+,d4		; data to repeat

repeat_data:	move.b	d4,(a1)
		adda.w	d5,a1
		eor.b	d1,d5

		cmpa.l	a1,a3			; fin du plan ?
		bhi.s 	idem_1			; non  a3 > a1
	
		subq.b	#1,d0		        ; nombre de plan -1
		bmi.s	end_open             
	
		movea.l	a2,a1		        ; plan suivant
		addq.l	#2,a2
		addq.l	#2,a3		        ; fin du plan
*		moveq.l	#1,d5
idem_1:		dbra.w	d3,repeat_data
	
		bra.s	lire_code

;................................literal

literal:	andi.b	#$7f,d3
		subq.b	#1,d3

copy:		move.b	(a0)+,(a1) 
		adda.l	d5,a1
		eor.b	d1,d5
 
		cmpa.l	a1,a3		        ; fin du plan ?
		bhi.s	idem_2		        ; non
 
		subq.l	#1,d0		        ; nombre de plan-1
		bmi.s	end_open 

		movea.l	a2,a1		        ; plan suivant
		addq.l	#2,a2
		addq.l	#2,a3
*		moveq.l	#1,d5
idem_2:		dbra.w	d3,copy
		
		bra.s	lire_code
	
;......................................................................

end_open:	moveq.l	#0,d0

erreur:		
end_prg:	movem.l	(a7)+,d1-d7/a0-a6
		rts

copy_palette:	moveq.l	#7,d2		; 16 couleurs									
color:		move.l	(a0)+,(a1)+
		dbra.w	d2,color
		rts
;.......................................copy image non compress‚

no_pack:	move.w	#7999,d2
loop:		move.l	(a0)+,(a1)+
		dbra.w	d2,loop
		rts

;_______________________________________SAVE SC0-3_____________________
save_ptw:
*		move.w	68(sp),d3 		; pack%
		exg.l	a0,a1	

		movea.l	a1,a4		; pour calul taille fichier
		lea.l	128(a1),a2	; start data destination
;
		addq.l	#2,a1
		move.w	(a0)+,d1
		move.w	d1,(a1)+	; resolution image

		movea.l	a0,a5		, pour copier en fin du fichier
		bsr.s	copy_palette

		lea.l	tag(pc),a3	; tag file 
		bsr.s 	write

		addq.w	#6,a1		; point to header

*		lea.l	header(pc),a3	; 'ANvisionA'
		bsr.s 	write
	
		move.b	0(a3,d1.w),(a1)+	; bit 63 :  $01,$11,$21

		lea.l	64(a1),a1		; star image destination

*		tst.b	d3			; Compresser ? 
*		beq.s	pack
		bsr.s	no_pack
*		bne.s	end_file
;.......................................suite format PAINT WORK SC0-2

end_file:	movea.l	a5,a0		; pointe sur palette source
		addq.l	#4,a1		 
		bsr.s	copy_palette

		move.l	#4,(a1)+	; cycle color off
		move.l	#5,(a1)+	;   "     "    "

		suba.l	a4,a1		; file size
		move.l	a1,d0
		bra.s	end_prg
;.......................................

write:		move.w	(a3)+,d2
loop1:		move.b	(a3)+,(a1)+
		dbra.w	d2,loop1
		rts
;........................................................................
	even
tag:	dc.w	$b
	dc.b	' Mi3-Mi9.prg'
	even
header:	dc.w	$8
	dc.b	'ANvisionA',$01,$11,$21,6,2,0
	even

	end
;-------------------------------------------------------------------------
