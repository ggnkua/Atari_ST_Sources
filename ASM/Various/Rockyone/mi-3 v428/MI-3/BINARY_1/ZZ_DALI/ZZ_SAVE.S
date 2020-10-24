* rocky.one 			for Mi-3 et MI-9		15/04/2016
* modifi‚							25/05/2017
* modifi‚						        14/07/2017
* pour MI-3, inversion buffer dans basic	        	29.09.2019
*
*
*                    	SAVE ZZ-ROUGH AND DALI
*		        ----------------------	           
* 
* Source : buffer file format Degas
* but	 : buffer 45050 bytes
*              
* apl%	:	0 for Dali  compressed		45043   bytes maximum
*		1 for Zz_Rought			45050 	bytes maximum
*	        2 for dali uncompressed		32128	bytes
*
* 		Call  zz_save(L Source,L But, apl%)
*		----------------------------------
*
* return:	file size in high d0
* 		File_Size = low(lpeek(Reserved(0))) and $ffff
*
* zz_rought only low resolution
*-------------------------------------------------------------------------
;a0 a2 a5 Source
;a1 a3 a4 but

		movem.l	d1-d7/a0-a6,-(a7)
	 	movem.l	60(sp),a0-a1	
		exg.l	a0,a1
		move.w	68(sp),d6

		lea.l	2(a0),a5	; point on source palette
		lea.l	34(a0),a0	; point to data source image 

		cmp.b 	#2,d6
		beq	dali_normal
	
		lea.l	60(a1),a3	;erly bytes repetition
		lea.l	8060(a1),a4	;early long words of the picture

*		moveq.l	#0,d7		;long word of the picture
		moveq.l	#0,d1		;number repetition of a long word
		moveq.l	#0,d3		;number of bytes of repetition
		moveq.l	#39,d4		;40 colonne

		move.l	(a0),d7
		
column:		move.w	#199,d2		;200 line
		movea.l	a0,a2

line:		cmp.l	(a2),d7		
		bne.s	save		

		cmpi.b	#255,d1
		bne.s	egal

save:		addq.w	#1,d3
		move.b	d1,(a3)+
		move.l	d7,(a4)+	
		moveq.l	#0,d1
		move.l	(a2),d7		; read new lW
		
egal:		addq.b	#1,d1	
		lea.l	160(a2),a2

		dbra.w	d2,line	

		addq.w	#4,a0		; next column
	
		dbra.w	d4,column	

		addq.w	#1,d3
		move.b	d1,(a3)+
		move.l	d7,(a4)+

;........................................ hedear file...................
;
header:		movea.l	a1,a2		; but
		tst.b	d6		; 1 = zz_rought / 0 = dali 
		beq.s	palette
;
		lea.l	rgh(pc),a4	;  Header zz_rought	
zz_rought:	move.b	(a4)+,(a2)+	; '(c)F.MARCHAL'
		bne.s	zz_rought
		suba.w	#1,a2

		move.l	d3,d1		; Number bytes of repeat
		bsr.s	hex_ascii	; in ascii
;

palette:	bsr.s 	save_palette

		tst.b	d6		; dali ?
		bne.s	recopy

;........................................ For Dali
		move.l	d3,d1		; Nunber of bytes of repeat
		bsr.s	hex_ascii	; in ascii
		move.l	d3,d1		; 
		lsl.l	#2,d1           ; *4 = Size data image
		bsr.s	hex_ascii	; in ascii
;
;........................................ Recopy bytes
recopy:		move.l	d3,d1
		lea.l	60(a1),a3
		subq.b	#1,d3
copy_byte:	move.b	(a3)+,(a2)+
		dbra.w	d3,copy_byte

;........................................ Recopy data
		lea.l	8060(a1),a3
		lsl.w	#2,d1	
		subq.b	#1,d1

copy_data:	move.b	(a3)+,(a2)+
		dbra.w	d1,copy_data	
;........................................ Return size file

file_size:	suba.l	a1,a2
		move.l	a2,d0

		movem.l	(sp)+,d1-d7/a0-a6

		rts
;.............................................................................

dali_normal:	lea.l	4(a1),a2
		bsr.s	save_palette

		adda.w	#92,a2

		move.l	#7999,d1
data_copy:	move.l	(a0)+,(a2)+
		dbra.w	d1,data_copy	
		bra.s	file_size
;........................................

save_palette:	moveq.l	#31,d1
copy_palette:	move.b	(a5)+,(a2)+
		dbra.w	d1,copy_palette
		rts
;........................................
hex_ascii:
	moveq.l	#0,d2
decimal:
	ext.l	d1
	beq.s	ascii	
	divu.w	#10,d1
	swap	d1
	lsl.l	#4,d2
	add.b	d1,d2
	addq.b	#1,d2
	swap	d1
	bra.s	decimal
		
ascii:	move.b	d2,(a2)
	andi.b	#$f,(a2)
	addi.b	#$2f,(a2)+
	lsr.l	#4,d2
	bne.s	ascii

	move.b	#$d,(a2)+
	move.b	#$a,(a2)+
	rts
;........................................
	even
rgh:	dc.b	'(c)F.MARCHAL',$0

	end 
;------------------------------------------------------------------------
