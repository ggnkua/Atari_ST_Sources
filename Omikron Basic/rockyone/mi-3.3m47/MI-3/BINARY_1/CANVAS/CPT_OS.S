;rockyone			for MI-3			29/09/2016
;modifi‚ open							04.05.2018
;raster								27.12.2020
;coretion pour premier index negatif				18.01.2021
;corection Ful en haute r‚solution				01.04.2021
;
;			CANVAS 	open CPTand FUL
;				save CPT
;
;
; Source: 	buffer  fichier image
; But		buffer	32034 octets
; Size		File size - 0 for save -
; Op%		0  save file		open% xor 1		open%=1
;   		1  open CPT	    	open% xor 1		open%=0
; 		4  open FUL		"	  " + 3
;		5  HBL low resol	"	  " + 4 + resol_image
;		6  HBL medium resol	"	  " + 5 + resol_image
;
;				        60     64     68      70
;		open  call canvas( L Source, L But, W Op%, W Low(Size) )
;		save  call canvas( L But, L Source, W Op%  W 0,)
;
;
; Return	low d0		0, not error
;				-2, bad file
;				File size if Op%=0
;
;------------------------------------------------------------------------- 
;  FORMAT PTC			FULL
;------------                  -----------------------
;				+  0    Palett index
;				+8OO    first raster
;				+N*48   fin des raster
;				+576    $000A000A
;  +0	16 word palette		+ 32    16 word palette
;  +32	 1 word resolution	+ 32     1 word r‚solution
;........................................
;  +34 	 1 word repeat			.      Zone data repeat
;  +36   1 word offset			.
;  +38   X word DATA			.	X * Plan
;  +...					.	--------
;........................................
;  
;  +???	1 word	$ffff 	Fin de data a recopier ( $fff >> repeat = 0 )
;  +    1 word  offset
;  +    X word  data    Copier ces X data si l'offset est plus petit que 
;			la somme des offsets copiŠ
;
;  Fin d'un fichier sans data unique 
;	
;........................................
;  +	X word  data unique        	.   zone data unique
;  +   	...				.
;  Fin d'un fichier avec data unique
;........................................


		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1

		move.w	68(sp),d0
		bne	open_cpt

;.................................................SAVE CPT................
						
		exg.l a0,a1

		lea.l	32000(a1),a3	; Tampon pour data_unique
		movea.l	a3,a5		; A recopier dans (a1) aprŠs 
;					; dernier data_repeat

		moveq.l	#0,d0
		move.w	(a0)+,d0	; R‚solution image
	
		bsr	pal_copy
;
		move.w	d0,(a1)+	; R‚solution image
;........................................
;	
		move.l	#4000,d1	; Max_offset
		lsl.w	d0,d1			
		subq.l	#1,d1		; -1 pour dbra

		moveq.l	#4,d2		; Nombre de word a comparer a
		lsr.b	d0,d2		; chaque offset 	4, 2, 1
		move.l	d2,d3		; Nb_word
		subq.l	#1,d3		; Cpt_word -1 pour dbra	3, 1, 0

		moveq.l	#0,d4		; Cpt_word
		moveq.l	#8,d5		; Saut_: Nombre de byte entre 
		lsr.b	d0,d5		; chaque offset		8 ,4 , 2

		moveq.l	#0,d6		; Cpt_offset
		moveq.l	#0,d7		; Cpt_unique
;					; Comptage r‚p‚tition dans (a1)
;........................................

save_loop:	cmp.w	d1,d6		; Max_offset > Cpt_offset 
		bhi.s	end_data	

		move.w	d3,d4		; Reset Cpt_word

		movea.l	a0,a4
		lea.l	0(a0,d5.w),a2

test1:		cmpm.w	(a4)+,(a2)+
		bne.s	unique		; >>> data unique puis loop:
		dbra.w	d4,test1		
;					......... DATA REPEAT.............

		adda.l	d5,a0		; add 1 offset a A0
		move.w	d6,2(a1)	; Offset pour ces data

loop2:		move.w	d3,d4		; Reset Cpt_word
		addq.w	#1,(a1)		; Nombre de r‚p‚tition (-1)
		addq.w	#1,d6		; Ofset pour prochain data_repeat

test2:		cmpm.w	(a4)+,(a2)+
		bne.s	different
		dbra.w	d4,test2	

		adda.l	d5,a0		; add 1 offset a A0 
		cmp.w	d1,d6		; Max_offset > Cpt_offset 
		bne.s	loop2	

different:	bsr.s	data_repeat		
		bra.s	save_loop	

;........................................
data_repeat:  	addq.l	#4,a1
		move.w	d3,d4		; Reset Cpt_word	

copy_2:		move.w	(a0)+,(a1)+	; copy word data repeat
		dbra.w	d4,copy_2

		addq.w	#1,d6		; Offset pour prochain data_repeat
		rts
;........................................

unique:		move.l	d3,d4		; Reset Cpt_word
copy_1:		move.w	(a0)+,(a3)+	; copy words data unique
		dbra.w	d4,copy_1

		addq.w	#1,d7		; Cpt_unique

		addq.w	#1,d6		; Offset pour prochain data_repeat
		bra.s 	save_loop
;........................................

end_data:	move.w	#$ffff,(a1)	; flag dernier data repeat
		move.w	d6,2(a1)
		bsr.s data_repeat

		tst.w	d7		; Cpt_unique  ?
		beq.s	end_save	 

		mulu.w	d2,d7		; * par Nb_word ( 4, 2 ,1 )
		subq.w	#1,d7		; -1 pour dbra
recopie:	move.w (a5)+,(a1)+
		dbra.w	d7,recopie
;.......................................................................

end_save:	move.l	60(sp),a4	;	Attention a0 a1 invers‚ 
		suba.l	a4,a1
		move.l	a1,d0
end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts
;.........................................

pal_copy:	move.l	(a0)+,(a1)+	
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		rts

;------------------------------------------------------OPEN_file----------

open_cpt:	cmpi.b	#4,d0		; file.ful ?
		bmi.s	data_image	; no, cpt file
		beq.s	ful_file
		bhi	hbl_file	

		
;...........................................................
ful_file:	lea.l 800+48+576(a0),a0	; +1424 bytes
seek:		cmpi.l	#$000a000a,(a0)+
		bne.s	seek		
										
		movea.l	a0,a3		;
		suba.l	#48+576+4,a3	; Points to the last palette 
;					; in the list.
		lea.l	32-4(a0),a0     ; Equal at the start of CPT file
;					; - point on the palett - 
;...........................................................

data_image:	move.w	32(a0),d7	; Image resolution  
		move.w	d7,rezol
		moveq.l	#8,d1		;
		lsr.b	d7,d1	 	; 8,4,2 number of bytes to copy 
;					; at each offset

;........................................Look for $FFF
		addq.l	#4,d1		; + 2 word 
		move.w	70(sp),d2	; file size
		andi.l	#$ffff,d2
*		sub.l	d3,d2		; for file FUL

		lea.l	34(a0),a4	; First number of repetition
		lea.l	0(a0,d2.w),a6	; End of file

		moveq.l	#-2,d0		; Flag bad file
find:		cmpi.w	#$ffff,(a4)	; ?
		beq.s	ok

		adda.l	d1,a4
		cmpa.l	a4,a6		; End of file ?
		bhi.s	find		; No 

		bra.s	end_prg		; Error !!!
;........................................

ok:		
*		moveq.l	#0,d0		; Flag not error
		move.w	#-1,(a4)
		lea.l	0(a4,d1.w),a6	; a6 Point to single datas 
;					;    Or end of file.
;					; a4 Point to #$ffff  

		subq.b	#4,d1		; reset value 8,4,2
;
;........................................return the image to Degas format...
;
		move.w	32(a0),(a1)+	; Write uncompressed and resol.

		bsr.s	pal_copy	; Copy color palett

		addq.l	#2,a0		; Skip the word of resolution

		move.w	d1,d2		; 8,4,2
		lsr.b	#1,d2		; Number of words to copy at the
		subq.b	#1,d2		; each offset.  -1 for dbra
		moveq.l	#0,d3		; Reset words counter
		moveq.l	#0,d4		; Reset offset counter		
		moveq.l	#0,d5		; Total number of repetitions		
		moveq.l	#0,d6		; Offset
		move.w	#4000,d7	; Number offset
		move.w	rezol,d0	; Image resolution
		lsl.w	d0,d7		;

** boucle **
lire_code:	move.w	(a0)+,d5	; Read number of repetition ?
		bpl.s	read_offset	; >= 0   

		moveq.l	#0,d5
read_offset:	move.w	(a0)+,d6						

test_offset:	cmp.w	d6,d4		; Offset   Compteur_Offset ?
		bmi.s	data_unique	;	 >
		beq.s	repeat_data	;        =
		bra.s	end_cpt		 
;.......................................

data_unique:	move.w	d2,d3		; reset word counter
loop_unique:	move.w	(a6)+,(a1)+		 
		dbra.w	d3,loop_unique	; 

		addq.w	#1,d4		; Offset conter +1
		bra.s	test_offset
;........................................

repeat_data:	move.w	d2,d3		; reset compteur word
		movea.l	a0,a2
copie:		move.w	(a2)+,(a1)+		 
		dbra.w	d3,copie	; Number of plan -1
	
		addq.w	#1,d4		; Offset conter +1
		dbra.w	d5,repeat_data	

		adda.l	d1,a0		; Pointe sur word control suivant

		cmp.w	d7,d4		; Max_Offset > Offset_conter
		bmi.s	lire_code	; Non

end_cpt:	moveq.l	#0,d0		; Return no error for basic
		cmp.w	#1,68(sp)	; File CPT ?
		beq	end_prg		; Yes
		bra.s	raster_palette  ; FUL file
;--------------------------------------------------------------------------
; 			FULL OPEN
;
; Buf_pic of MI-3 equal  72416 bytes
;----------------------------------- 
;
; Address: SPU    IFF/FUL
; +32000  19200    288  Pal_restor_H line O to 9
; +49184   2016    672  Pal_restor_B for line 179 to 199 or line 182 to 199
; +51200  19200   6400  Pal_display  Line 0 to 199 
; +70400   2016    672  Black pal for 21 lines 
; total 72416 bytes
; - Identical addresses for Spectrum image.SPU -
;-------------------------------------------------------------------------
; a0  Paletts index
; a3  Paletts VDI
; 
; a1  		Buffer pal display start at 51200(a0)
; a2 		End at 57600(a0)  
; a6  		Conversion table
; d0  		Number of copy of paletts
; d1  		Number color per paletts
; d2-d7/a4-a5 	Copy paletts
;-------------------------------------------------------------------------
hbl_file:	move.w	70(sp),d3	; file size
		andi.l	#$FFFFFFFF,d3
		subq.w	#5,d0		; screen resol
		move.w	d0,rezol
		movea.l	a0,a3
		adda.l	d3,a3		; eof file HBL
		suba.l	#48,a3		; Point on the last palett
;---------------------------------------
raster_palette:
	move.l	60(sp),a0		; Palett index 
	movea.l	a0,a1			;
	adda.l	#51200,a1		; Buffer pal_display of MI-3
	lea.l	32*199(a1),a2		; End =32*200-32
				
	move.w	rezol,d5		; Image resolution
	lsl.b	#4,d5			; *16
	lea.l	vdi_hard(pc,d5.w),a6	; Conversion table

	cmpi.w	#2,rezol		; High resolution ?
	beq.s	all_raster		; Yes

	moveq.l	#4,d0			; Copy 5 time the first palett
	move.w	#0,(a0)			; First index of the palett

all_raster:		
	tst.w	(a0)+			; Negativ index ?
	bmi.s	recopy_pal		; Copy the palett 4 times

*new_palett:
						
	moveq.l	#0,d3			; Reset registre
	moveq.l	#16-1,d1		; 16 coulors per palett
o_pal:	moveq.l	#0,d2			; Reset registre
	move.b	(a3)+,d2		; R
*	andi.w	#$f,d2			
 	lsl.b	#4,d2			
	add.b	(a3)+,d2		; V
	lsl.w	#4,d2				
	add.b	(a3)+,d2		; B
	move.b	(a6)+,d3		; Conversion index
*	andi.l	#$fff,d2		
	move.w	d2,0(a1,d3.w)		; write the new index
	dbra.w	d1,o_pal		
					
	suba.w	#48*2,a3		; point on next palette source
	suba.w	#16,a6			; Reset conversion table
;.....................			
	subq.l	#1,d0			; Copy this palett 3 time
	movem.l	(a1)+,d2-d7/a4-a5	
						
recopy_pal:								
	movem.l	d2-d7/a4-a5,(a1)			
	lea.l	32(a1),a1	
	dbra.w	d0,recopy_pal			

	moveq.l	#3,d0					
	cmpa.l	a1,a2			; 200 paletts ?
	bhi.s	all_raster		
	bmi.s	end_raster

	moveq.l	#2,d0
	bra.s	all_raster

end_raster:
	moveq.l	#0,d0				
	bra	end_prg			
					
;.......................................
		even			
rezol:		dc.w	$0		
vdi_hard:				
*		   * *     *		
*		0 15 1 2 4 6  3  5  7  8  9 10 12 14 11 13	; basse
	dc.b	0,30,2,4,8,12,6,10,14,16,18,20,24,28,22,26	; *2
					
*		  *           *		
*		0 3 1 2 4  6 15  5  7  8  9 10 12 14 11 13	; moyenne
	dc.b	0,6,2,4,8,12,30,10,14,16,18,20,24,28,22,26

*		  *                                       *				
*		0 1 3  6  4  7  5  8  9 10 11 14 12 15 13 2	; haute
	dc.b	0,3,9,18,12,21,15,24,27,30,33,42,36,45,39,6

					
	end			
**************************************************************************
