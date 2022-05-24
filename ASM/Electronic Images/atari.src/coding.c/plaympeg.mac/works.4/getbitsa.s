; PLAYMPEG
; Martin Griffiths 1995

			IMPORT ld_infile,read,Setexc
			IMPORT mb_addr_inc
			IMPORT biggie,zig_zag_scan,ld_intra_quantizer_matrix,ld_quant_scale,ld_block

			macro	showbits X
			bfextu	(a6){d7:X},d0
			endm
			
			macro   showbitsS X
			move.l	ld_bitpos(pc),d1
			bfextu (ld_rdbfr){d1:X},d0	
			endm
								
			macro	flushbits X
			add.w	X,d7
			trapcs	
			endm
			
			macro	flushbitsS X
			add.w	X,ld_bitpos+2
			trapcs
			endm
			
			macro	flushbitsQS X
			addq.w	#X,ld_bitpos+2
			trapcs
			endm
						
			macro	flushbitsQ X
			add.w	#X,d7
			trapcs	
			endm	
							
			macro	getbitsQS X
			move.l	ld_bitpos(pc),d1
			bfextu	(ld_rdbfr){d1:X},d0
			flushbitsQS X
			endm
		
						
			macro	getbitsQ X
			bfextu	(a6){d7:X},d0
			flushbitsQ X
			endm
		
			macro	getbits	X
			bfextu	(a6){d7:X},d0
			flushbits X
			endm


			macro	getDClum
			showbits 7				; show bits(7);
			move.l	(dct_dc_size_luminance,pc,d0*4),d0
			flushbits d0
			swap	d0
			moveq	#0,d1
			tst.w	d0
			beq.s	.DCldone
			bfextu	(a6){d7:d0},d1	; getbits(size)
			bmi.s	.DCl1
			clr		d2
			bset	d0,d2
			subq	#1,d2
			sub.w	d2,d1
.DCl1:		flushbits d0
.DCldone: 	
			endm

			macro	getDCchrom
			showbits 8				; showbits(8)
			move.l	(dct_dc_size_chrominance,pc,d0*4),d0
			flushbits	d0
			swap	d0
			moveq	#0,d1
			tst.w	d0
			beq.s	.DCcdone
			bfextu	(a6){d7:d0},d1	; getbits(size)
			bmi.s	.DCc1
			clr		d2
			bset	d0,d2
			subq	#1,d2
			sub.w	d2,d1
.DCc1:		flushbits	d0
.DCcdone: 	
			endm
			
			EXPORT getMBA

			.ALIGN 16

getMBA:		showbitsS 11
			movem.l	(mb_addr_inc,pc,d0*8),d0/d1
			flushbitsS d1
			rts

			.ALIGN 16
			
fillbfr_exception:
			movem.l	d0-d7/a0-a6,-(sp)
			move.l	ld_rdbfr+8192,ld_rdbfr
			move.l	ld_infile,d0
			lea		ld_rdbfr+4,a0
			move.l	#8192,d1
			jsr		read
			movem.l	(sp)+,d0-d7/a0-a6
			rte
		
			EXPORT initbits
	
			.ALIGN 16
		
initbits:	movem.l	d0-d7/a0-a6,-(sp)
			move.l	ld_infile,d0
			lea		ld_rdbfr,a0
			move.l	#8192+4,d1
			jsr		read
			moveq	#7,d0
			lea		fillbfr_exception,a0
			jsr		Setexc
			clr.l	ld_bitpos
			movem.l	(sp)+,d0-d7/a0-a6
			rts
		
			EXPORT showbits

			.ALIGN 16
		
showbits:	move.l	ld_bitpos(pc),d1
			bfextu (ld_rdbfr){d1:d0},d0
			rts

			EXPORT getbits

			.ALIGN 16

getbits:	move.l	ld_bitpos(pc),d1
			bfextu (ld_rdbfr){d1:d0},d1
			add.w	d0,ld_bitpos+2
			trapcs
.nah:		move.l	d1,d0
			rts
		
			EXPORT flushbits

			.ALIGN 16
			
flushbits:	add.w	d0,ld_bitpos+2
			trapcs
			rts		

		
			EXPORT startcode

			.ALIGN 16
		
startcode:	moveq	#7,d0
			and.w	ld_bitpos+2(pc),d0
			beq.s	.nah
			sub.w	d0,ld_bitpos+2
			flushbitsQS 8
.nah:		showbitsS	24
			cmp.l	#1,d0
			beq.s	.foundit
			flushbitsQS 8
			bra.s	.nah
.foundit:	rts		

			EXPORT getCBP
			
			.ALIGN 16
			
getCBP:		showbitsS	9
			move.l	(coded_block_pattern,pc,d0*4),d0
			flushbitsS  d0
			swap	d0
			rts
			
			EXPORT getslicehdr
			
			.ALIGN 16

getslicehdr:
			getbitsQS 6
			lsr.l	#1,d0
			bcc.s	.nah
			flushbitsQS	8
			move.l	d0,-(sp)
			jsr		ext_bit_info
			move.l	(sp)+,d0
.nah:		move.l	d0,ld_quant_scale	
			rts
			
			EXPORT ext_bit_info

			.ALIGN 16

ext_bit_info:
.ext_lp:	getbitsQS 1
			tst.l	d0
			beq.s	.done
			flushbitsQS 8
			bra.s 	.ext_lp			
.done:		rts

			EXPORT getintrablocks

			.ALIGN 16

; d0 = cbp
; a0 -> dc_dct_pred			

getintrablocks:
			movem.l	d2/d7/a6,-(sp)
			move.w	d0,d3
			lea 	ld_rdbfr,a6
			move.l	ld_bitpos(pc),d7
get_lum1:	btst.b	#5,d3
			beq.s	get_lum2
			lea		ld_block+(8*8*2*0),a1
			getDClum
			bsr		decode_intra
get_lum2:	btst.b	#4,d3
			beq.s	get_lum3
			lea		ld_block+(8*8*2*1),a1
			getDClum
			bsr		decode_intra
get_lum3:	btst.b	#3,d3
			beq.s	get_lum4
			lea		ld_block+(8*8*2*2),a1
			getDClum
			bsr		decode_intra
get_lum4:	btst.b	#2,d3
			beq.s	get_cr
			lea		ld_block+(8*8*2*3),a1
			getDClum
			bsr		decode_intra
get_cr:		addq.l	#4,a0
			btst.b	#1,d3
			beq.s	get_cb
			lea		ld_block+(8*8*2*4),a1
			getDCchrom
			bsr.s	decode_intra
get_cb:		addq.l	#4,a0
			btst.b	#0,d3
			beq.s	doneintra
			lea		ld_block+(8*8*2*5),a1
			getDCchrom
			bsr.s	decode_intra
doneintra:	move.l	d7,ld_bitpos
			movem.l	(sp)+,d2/d7/a6
			rts

			.ALIGN 16
			
decode_intra:
			move.l	(a0),d0
			add.w	d1,d0
			move.l	d0,(a0)
			asl.w	#3,d0
			moveq	#1,d2
			move.w	d0,(a1)				; block[0]
decode_lp:	showbits 16
			move.l	(biggie,pc.l,d0.l*4),d1	; 
			flushbits d1 				; flushbits(tab->len)
			swap	d1					; tab->run
			cmp.b	#64,d1
			bhs.s	is_run				;
			add.b	d1,d2				; i+= tab->run;
			lsr.w	#8,d1				; val = tab->level;
			move.w	(zig_zag_scan,d2.w*2),d0
			mulu.w	(ld_intra_quantizer_matrix,d0.w*2),d1
			mulu.l	ld_quant_scale,d1
			lsr.l	#3,d1
			bftst	(a6){d7:1}			; sign = getbits(1)
			beq.s	notneg
			neg		d1
notneg:		flushbitsQ 1
			move.w	d1,(a1,d0.w*2)
			addq.w	#1,d2
			bra.s	decode_lp	
is_run:		bne.s	not_end				; if (tab->run==65)
is_end:		rts
not_end:	getbitsQ	6				; i+=getbits(6) 
			add.b	d0,d2
			getbitsQ	8				; val = getbits(8)
			tst.w	d0
			beq.s	val_zero			;
			cmp.w	#128,d0
			bpl.s	val_higher
			bmi.s	val_cont
			getbitsQ 8					; val = getbits(8)
val_higher:	sub.w	#256,d0				; val -=256;
val_cont:	
			move.w	(zig_zag_scan,d2.w*2),d1
			muls.w	(ld_intra_quantizer_matrix,d1.w*2),d0
			muls.l	ld_quant_scale,d0
			asr.l	#3,d0
			move.w	d0,(a1,d1.w*2)
			addq.w	#1,d2
			bra		decode_lp	
			
val_zero:	getbitsQ	8				; val = getbits(8)
			move.w	(zig_zag_scan,d2.w*2),d1
			muls.w	(ld_intra_quantizer_matrix,d1.w*2),d0
			muls.l	ld_quant_scale,d0
			asr.l	#3,d0
			move.w	d0,(a1,d1.w*2)
			addq.w	#1,d2
			bra		decode_lp	

ld_bitpos:	ds.l	1

			.ALIGN 16

dct_dc_size_luminance:
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3 
	dc.w	0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3 
	dc.w	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.w	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.w	4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3 
	dc.w	4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3 
	dc.w	5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4 
	dc.w	6, 5, 6, 5, 6, 5, 6, 5, 7, 6, 7, 6, 8, 7, -1,0

dct_dc_size_chrominance:
	dc.w	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.w	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.w	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.w	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.w	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.w	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.w	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.w	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.w	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.w	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.w	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.w	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.w	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 
	dc.w	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 
	dc.w	5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 
	dc.w	6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, -1,0

; val/flush bits (9bit table lookup)

coded_block_pattern:
	dc.w	-1, 0, -1, 0, 39, 9, 27, 9, 59, 9, 55, 9, 47, 9, 31, 9,
	dc.w	58, 8, 58, 8, 54, 8, 54, 8, 46, 8, 46, 8, 30, 8, 30, 8,
	dc.w	57, 8, 57, 8, 53, 8, 53, 8, 45, 8, 45, 8, 29, 8, 29, 8,
	dc.w	38, 8, 38, 8, 26, 8, 26, 8, 37, 8, 37, 8, 25, 8, 25, 8,
	dc.w	43, 8, 43, 8, 23, 8, 23, 8, 51, 8, 51, 8, 15, 8, 15, 8,
	dc.w	42, 8, 42, 8, 22, 8, 22, 8, 50, 8, 50, 8, 14, 8, 14, 8,
	dc.w	41, 8, 41, 8, 21, 8, 21, 8, 49, 8, 49, 8, 13, 8, 13, 8,
	dc.w	35, 8, 35, 8, 19, 8, 19, 8, 11, 8, 11, 8, 7, 8, 7, 8,
	dc.w	34, 7, 34, 7, 34, 7, 34, 7, 18, 7, 18, 7, 18, 7, 18, 7,
	dc.w	10, 7, 10, 7, 10, 7, 10, 7, 6, 7, 6, 7, 6, 7, 6, 7, 
	dc.w	33, 7, 33, 7, 33, 7, 33, 7, 17, 7, 17, 7, 17, 7, 17, 7, 
	dc.w	 9, 7, 9, 7, 9, 7, 9, 7, 5, 7, 5, 7, 5, 7, 5, 7, 
	dc.w	63, 6, 63, 6, 63, 6, 63, 6, 63, 6, 63, 6, 63, 6, 63, 6, 
	dc.w	 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 
	dc.w	36, 6, 36, 6, 36, 6, 36, 6, 36, 6, 36, 6, 36, 6, 36, 6, 
	dc.w	24, 6, 24, 6, 24, 6, 24, 6, 24, 6, 24, 6, 24, 6, 24, 6, 
	dc.w	62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5,
	dc.w	62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5, 62, 5,
	dc.w	 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 
	dc.w	 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 2, 5, 
	dc.w	61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 
	dc.w	61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 61, 5, 
	dc.w	 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 
	dc.w	 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 1, 5, 
	dc.w	56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 
	dc.w	56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 56, 5, 
	dc.w	52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 
	dc.w	52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 52, 5, 
	dc.w	44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 
	dc.w	44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 44, 5, 
	dc.w	28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 
	dc.w	28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 28, 5, 
	dc.w	40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 
	dc.w	40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 40, 5, 
	dc.w	20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 
	dc.w	20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 20, 5, 
	dc.w	48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 
	dc.w	48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 48, 5, 
	dc.w	12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 
	dc.w	12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 12, 5, 
	dc.w	32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 
	dc.w	32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 
	dc.w	32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 
	dc.w	32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 32, 4, 
	dc.w	16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 
	dc.w	16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 
	dc.w	16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 
	dc.w	16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 16, 4, 
	dc.w	 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 
	dc.w	 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 
	dc.w	 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 
	dc.w	 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4, 8, 4,
	dc.w	 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
	dc.w	 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 
	dc.w	 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 
	dc.w	 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
	dc.w	60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 
	dc.w	60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 
	dc.w	60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 
	dc.w	60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 
	dc.w	60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 
	dc.w	60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 
	dc.w	60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 
	dc.w	60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3, 60, 3

			BSS
			
ld_rdbfr:	ds.b	8192+4
