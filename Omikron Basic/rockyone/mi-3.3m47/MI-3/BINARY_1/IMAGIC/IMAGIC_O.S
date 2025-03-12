;rockione			for MI-3 Mi-9			13.08.2018
;
; Source 	file_size   bytes
; But		32034+6     bytes (+ 6 buffer 1 word and 1 long word )
; 
;				OPEN IC1-3
;
;			call imagic( L source, L but )
;			''''''''''''''''''''''''''''''
;
;
; Return in low d0 -2 if erreur
;-------------------------------------------------------------------------
;Imagic image decompressoion code for PureC
;code taken from Imagic demo -> denisdem.prg
;size of unpacked data is always 32000 bytes (st resolutions)
;dis-assembled and modified by Lonny Pursell
;
;note: after processing the 64 byte header, call this subroutine
;      thus source address would be start of file + 64
;
;extern cdecl depack_icx(void *src, void *dst);
;-------------------------------------------------------------------------
; +0	l	IMDC
; +4	w	r‚solution
; +6	w	16 word palette
; +38	w	datte format Gemdos
; +40	w	heures format Gemdos
; +42	b	8 bytes  non de l'image de basse pour compresion delta)
;		sinon zero
; +50	w	longeur du segment data image
; +52	l       registration number $11000007
; +56   b       8 bytes reserved
; +64   b	0= non compress‚, 1 = compress‚
;
; si compress‚,
; +65	b	>-1 = compession delta, sinon =-1
; +66 	b	byte d'‚chapement
; +67	b	copie du byte d'‚chapement
;		d6 = bitmap size in bytes
;-------------------------------------------------------------------------
;used d0-d7/a0-a6
;
;a0	source
;a1	destination  write pic
;a2	start destination
;a3	buffer 1 word and 1 long word
;d1	lw
;d2	
;d6	w
;d7	
		movem.l	d1-d7/a0-a6,-(sp)	
		movem.l	60(sp),a0-a1

		cmpi.l	#'IMDC',(a0)+
		bne	error

		move.w	(a0)+,(a1)+		; image resolution

		moveq.l	#7,d1			; 16 colors
colors:		move.l	(a0)+,(a1)+		
		dbra.w	d1,colors

		lea.l	26(a0),a0		; start data image packed
		move.l	a1,a2			; Start destination
		lea.l	32000(a1),a3		; address buffer 1 W 1 LW
		move.l	a3,2(a3)		; End destination
		
		moveq	#0,d1
		moveq	#0,d2
		move.b	(a0)+,d1		; 64(a0)byte compression
		move.b	(a0)+,d2
		move.b	(a0)+,d7		; byte d'‚chapement
		mulu.w	#80,d2
		cmpi.b	#255,d1			; Delta compression ?
		bne.s	not_delta		; no 
		

		move.l	#32000,d1
		move.w	#1,d2
not_delta:	movea.w	d2,a4			
		move.w	d2,d6
		subq.w	#1,d6
		move.w	d1,d5
		subq.w	#1,d5
		move.w	d5,(a3)			
		neg.w	d1
		muls	d2,d1
		addq.l	#1,d1
		movea.l	d1,a5
		muls	d5,d2
		movea.l	d2,a6

		moveq	#1,d1
		moveq	#3,d2
		moveq	#2,d4
		moveq	#0,d0
L176244:	move.b	(a0)+,d0
		cmp.b	d0,d7
		beq.s	L176290

L176250:	cmpa.l	a2,a1		; start but  
		bmi.s	end_prg

		cmpa.l	2(a3),a1	; End  but 
		bpl.s	end_prg

		move.b	d0,(a1)		; write image bytes
		adda.l	a4,a1		; '''''''''''''''''
		dbf	d5,L176244

		move.w	(a3),d5
		adda.l	a5,a1
		dbf	d6,L176244

		move.w	a4,d6
		subq.w	#1,d6
		adda.l	a6,a1
		bra.s	L176244

L176420:	move.b	(a0)+,d0
		beq.s	L176244
		bra.s	L176420

end_prg:	moveq.l	#0,d0	
		movem.l	(sp)+,d1-d7/a0-a6	
		rts
error: 		moveq.l	#-2,d0
		bra.s	end_prg

L176290:	move.b	(a0)+,d0
		cmp.b	d0,d7
		beq.s	L176250

		moveq	#0,d3
		cmp.w	d2,d0
		bpl.s	L176374

		cmp.b	d4,d0
		bne.s	L176360
		
		move.b	(a0)+,d0
		beq.s	end_prg
		
		cmp.w	d2,d0
		bpl.s	L176332
		
		cmp.b	d4,d0
		beq.s	L176420
		
L176318:	cmp.b	d1,d0
		bne.s	L176330
		
		addi.w	#256,d3
		move.b	(a0)+,d0
		bra.s	L176318

		
L176330:	move.b	(a0)+,d0
L176332:	add.w	d0,d3
L176334:	adda.l	a4,a1
		dbf	d5,L176354
		
		move.w	(a3),d5
		adda.l	a5,a1
		dbf	d6,L176354
		
		move.w	a4,d6
		subq.w	#1,d6
		adda.l	a6,a1
L176354:	dbf	d3,L176334
		bra.s	L176244
		
L176360:	cmp.b	d1,d0
		bne.s	L176372

		addi.w	#256,d3
		move.b	(a0)+,d0
		bra.s	L176360
		
L176372:	move.b	(a0)+,d0
L176374:	add.w	d0,d3
		move.b	(a0)+,d0

L176378:	cmpa.l	a2,a1		; start but ? 
		bmi.s	end_prg		; < 

		cmpa.l	2(a3),a1	; end but ? 
		bpl.s	end_prg		; > = 0
		
		move.b	d0,(a1)
		adda.l	a4,a1
		dbf	d5,L176412
		
		move.w	(a3),d5
		adda.l	a5,a1
		dbf	d6,L176412
		
		move.w	a4,d6
		subq.w	#1,d6
		adda.l	a6,a1
L176412:	dbf	d3,L176378
		bra	L176244
		

;.....................................
*start_adr:	dc.l	0
*end_adr:	dc.l	0

		end
;*************************************************************************

