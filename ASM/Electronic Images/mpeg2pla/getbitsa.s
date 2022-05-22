; PLAYMPEG
; Martin Griffiths 1995

SEQ_END_CODE	equ 	$1B7
SLICE_MIN_START equ		$101
SLICE_MAX_START equ	  	$1AF

			IMPORT ld_infile,read,Setexc
			IMPORT mb_addr_inc
			IMPORT huff_first,huff_next,zig_zag_scan
			IMPORT ld_intra_quantizer_matrix,ld_non_intra_quantizer_matrix
			IMPORT ld_quant_scale,ld_block
			IMPORT pict_type,PMBtab,BMBtab

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
			
			macro	MgetMBA
			showbits 11
			movem.w	(mb_addr_inc,pc,d0*4),d0/d1
			flushbits d1
			endm
		
			macro	Mstartcode
			moveq	#7,d0
			and.w	d7,d0
			beq.s	.nahs
			sub.w	d0,d7
			flushbitsQ 8
.nahs:		showbits	24
			cmp.l	#1,d0
			beq.s	.foundit
			flushbitsQ 8
			bra.s	.nahs
.foundit:	
			endm	
				
			macro Mgetslicehdr
			getbitsQ 6
			lsr.l	#1,d0
			bcc.s	.nahsl
			flushbitsQ	8
			move.l	d0,-(sp)
.ext_lpsl:		getbitsQ 1
			tst.l	d0
			beq.s	.donesl
			flushbitsQ 8
			bra.s 	.ext_lpsl			
.donesl:	move.l	(sp)+,d0
.nahsl:		move.l	d0,ld_quant_scale	
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
			movem.w	(mb_addr_inc,pc,d0*4),d0/d1
			flushbitsS d1
			rts

			.ALIGN 16

fillbfr_exception:
			movem.l	d0-d2/a0-a2,-(sp)
			move.l	ld_rdbfr+8192,ld_rdbfr
			move.l	ld_infile,d0
			lea		ld_rdbfr+4,a0
			move.l	#(8192),d1
			jsr		read
.not:		cmp.l	#8192,d0
			beq.s	.ok
			lea	ld_rdbfr+4,a0
.notonlw:	moveq	#3,d1
			and.l	d0,d1
			beq.s	.ok1
			clr.b	(a0,d0.l)
			addq.l	#1,d0
			bra.s	.notonlw
.ok1:		cmp.l	#8192,d0
			bge.s	.ok
			move.l	#SEQ_END_CODE,(a0,d0.l)
			addq.l	#4,d0
			bra.s	.ok1
			
.ok:		movem.l	(sp)+,d0-d2/a0-a2
			rte
		
			EXPORT initbits
	
			.ALIGN 16
		
initbits:	movem.l	d0-d7/a0-a6,-(sp)
			move.l	ld_infile,d0
			lea		ld_rdbfr,a0
			move.l	#(8192)+4,d1
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

			EXPORT getMV
			IMPORT motion_vectors
					
			.ALIGN 16

getMV:		showbitsS 11
			movem.w	(motion_vectors,pc,d0*4),d0/d1
			flushbitsS d1
			rts			
			
			EXPORT getMBtype
			
			.ALIGN 16

getMBtype:	move.w	pict_type,a0
			cmp.w	#1,a0
			bne.s	.not_I
.is_I:		getbitsQS 1
			tst.w	d0
			bne.s	.return
			getbitsQS 1
			beq.s	.returnerr		; if (!getbits) "invalid macroblock codetype"
			moveq	#17,d0
.return:	rts
.returnerr:	RTS
.not_I:		cmp.w	#2,a0
			bne.s	.not_P

.is_P:		showbitsS 6				; code = showbits(6)
			move.l (PMBtab,d0*4),d0
			flushbitsS d0			; flushbits(PMBtab[code].len);
			swap 	d0				; return PMBtab0[code].val;
			rts
									; 
.not_P:		cmp.w	#3,a0
			bne.s	.returnerr		
.is_B:		showbitsS 6				; code = showbits(6)
			move.l (BMBtab,d0*4),d0
			flushbitsS d0			; flushbits(BMBtab[code].len);
			swap 	d0				; return BMBtab[code].val;
			rts						; 

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

;--------------------------------------------------------
; Get INTRA-frame block
; d0 = cbp
; a0 -> dc_dct_pred			

			EXPORT getintrablocks

			.ALIGN 16


getintrablocks:
			movem.l	d2/d3/d4/d7/a2/a6,-(sp)
			move.l	a0,a2
			move.w	d0,d3
			lea 	ld_rdbfr,a6
			move.l	ld_bitpos(pc),d7
get_lum1:	btst.b	#5,d3
			beq.s	get_lum2
			lea		ld_block+(8*8*2*0),a0
			getDClum
			bsr		decode_intra
get_lum2:	btst.b	#4,d3
			beq.s	get_lum3
			lea		ld_block+(8*8*2*1),a0
			getDClum
			bsr		decode_intra
get_lum3:	btst.b	#3,d3
			beq.s	get_lum4
			lea		ld_block+(8*8*2*2),a0
			getDClum
			bsr		decode_intra
get_lum4:	btst.b	#2,d3
			beq.s	get_cr
			lea		ld_block+(8*8*2*3),a0
			getDClum
			bsr		decode_intra
get_cr:		addq.l	#2,a2
			btst.b	#1,d3
			beq.s	get_cb
			lea		ld_block+(8*8*2*4),a0
			getDCchrom
			bsr.s	decode_intra
get_cb:		addq.l	#2,a2
			btst.b	#0,d3
			beq.s	doneintra
			lea		ld_block+(8*8*2*5),a0
			getDCchrom
			bsr.s	decode_intra
doneintra:	move.l	d7,ld_bitpos
			movem.l	(sp)+,d2/d3/d4/d7/a2/a6
			rts

			.ALIGN 16
			
decode_intra:
			move.w	(a2),d0
			add.w	d1,d0
			move.w	d0,(a2)		
		
			asl.w	#3,d0
			moveq	#1,d2
			move.l	ld_quant_scale,d4
			move.w	d0,(a0)				; block[0]
.decode_lp:	showbits 16
			move.l	(huff_next,d0.l*4),d1	; 
			flushbits d1 				; flushbits(tab->len)
			swap	d1
			cmp.b	#64,d1
			bhs.s	.is_run				;
			add.b	d1,d2				; i+= tab->run;
			lsr.w	#8,d1				; val = tab->level;
			move.w	(zig_zag_scan,d2*2),d0
			mulu.w	d4,d1				; val * quant_scale
			mulu.w	(ld_intra_quantizer_matrix,d0.w*2),d1
			lsr.l	#3,d1
			bftst	(a6){d7:1}			; sign = getbits(1)
			beq.s	.notneg
			neg		d1
.notneg:	flushbitsQ 1
			move.w	d1,(a0,d0.w*2)
			addq.w	#1,d2
			bra.s	.decode_lp	
.is_run:	bne.s	.not_end			; if (tab->run==65)
.is_end:	rts
.not_end:	getbitsQ	6				; i+=getbits(6) 
			add.b	d0,d2
			getbitsQ	8				; val = getbits(8)
			tst.w	d0
			beq.s	.val_zero			;
			cmp.w	#128,d0
			bpl.s	.val_higher
			bmi.s	.val_cont
			getbitsQ 8					; val = getbits(8)
.val_higher:sub.w	#256,d0				; val -=256;
.val_cont:	
; val = (val-1) | 1;
			move.w	(zig_zag_scan,d2.w*2),d1
			muls.w	d4,d0
			muls.w	(ld_intra_quantizer_matrix,d1.w*2),d0
			asr.l	#3,d0
			move.w	d0,(a0,d1.w*2)
			addq.w	#1,d2
			bra		.decode_lp	
			
.val_zero:	getbitsQ	8				; val = getbits(8)
			bra.s	.val_cont

;--------------------------------------------------------
; Get INTER-frame block 
; D0 = cbp

			EXPORT getinterblocks

			.ALIGN 16

getinterblocks:
			movem.l	d2/d3/d4/d7/a6,-(sp)
			move.w	d0,d3
			
			lea 	ld_rdbfr,a6
			move.l	ld_bitpos(pc),d7
			move.l	ld_quant_scale,d4
inter_lum1:	btst.b	#5,d3
			beq.s	inter_lum2
			lea		ld_block+(8*8*2*0),a1
			bsr.s	decode_inter
inter_lum2:	btst.b	#4,d3
			beq.s	inter_lum3
			lea		ld_block+(8*8*2*1),a1
			bsr.s	decode_inter
inter_lum3:	btst.b	#3,d3
			beq.s	inter_lum4
			lea		ld_block+(8*8*2*2),a1
			bsr.s	decode_inter
inter_lum4:	btst.b	#2,d3
			beq.s	inter_cr
			lea		ld_block+(8*8*2*3),a1
			bsr.s	decode_inter
inter_cr:	btst.b	#1,d3
			beq.s	inter_cb
			lea		ld_block+(8*8*2*4),a1
			bsr.s	decode_inter
inter_cb:	btst.b	#0,d3
			beq.s	inter_done
			lea		ld_block+(8*8*2*5),a1
			bsr.s	decode_inter
inter_done:	move.l	d7,ld_bitpos
			movem.l	(sp)+,d2/d3/d4/d7/a6
			rts

			.ALIGN 16
			
decode_inter:
			moveq	#0,d2
			lea		huff_first,a0
.decode_lp:	showbits 16
			move.l	(a0,d0.l*4),d0	; 
			flushbits d0 				; flushbits(tab->len)
			swap	d0					; tab->run
			cmp.b	#64,d0
			bhs.s	.is_run				;
			add.b	d0,d2				; i+= tab->run;
			lsr.w	#8,d0				; val = tab->level;
			move.w	(zig_zag_scan,d2.w*2),d1
			mulu.w	d4,d0
			mulu.w	(ld_intra_quantizer_matrix,d1.w*2),d0
			lsr.l	#3,d0
			bftst	(a6){d7:1}			; sign = getbits(1)
			beq.s	.notneg
			neg		d0
.notneg:	flushbitsQ 1
			move.w	d0,(a1,d1.w*2)
			lea		huff_next,a0
			addq.w	#1,d2
			bra.s	.decode_lp	
.is_run:	bne.s	.not_end			; if (tab->run==65)
.is_end:	rts
.not_end:	getbitsQ	6				; i+=getbits(6) 
			add.b	d0,d2
			getbitsQ	8				; val = getbits(8)
			tst.w	d0
			beq.s	.val_zero			;
			cmp.w	#128,d0
			bpl.s	.val_higher
			bmi.s	.val_cont
			getbitsQ 8					; val = getbits(8)
.val_higher:sub.w	#256,d0				; val -=256;
.val_cont:	
; val = (((val<<1)+1)*ld_quant_scale*ld_non_intra_quantizer_matrix[j]) >> 4;
; val = (val-1) | 1;
			move.w	(zig_zag_scan,d2.w*2),d1
			muls.w	d4,d0
			muls.w	(ld_intra_quantizer_matrix,d1.w*2),d0
			asr.l	#3,d0
			move.w	d0,(a1,d1.w*2)
			lea		huff_next,a0
			addq.w	#1,d2
			bra		.decode_lp	
			
.val_zero:	getbitsQ	8				; val = getbits(8)
			bra.s	.val_cont


;
; Decode an I frame.
;

			EXPORT get_I_frame

			IMPORT mb_width,mb_height,idct
			IMPORT clp,newframe,coded_picture_width,chrom_width
			
			.ALIGN 16

get_I_frame:
			movem.l	d1-d7/a1-a6,-(sp)
			move.l	mb_width,d0
			muls.l	mb_height,d0
			move.l	d0,MBAmax
			moveq	#0,d5		; MBAinc = 0
			moveq	#0,d6		; MBA = 0
			lea 	ld_rdbfr,a6
			move.l	ld_bitpos(pc),d7
			
get_I_lp:	tst.l	d5			; if (MBAinc == 0)	
			beq.s	isMBA_zero
notMBAinc_zero:
			moveq	#1,d0
			cmp.l	d0,d5
			beq		isMBA_one
			clr.l	dc_dct_pred
			clr.w	dc_dct_pred+4
			addq.l	#1,d6		; MBA++
			subq.l	#1,d5		; MBAinc--
			bra.s	get_I_lp			
isMBA_zero:
			showbits 23		; {
			beq.s	get_I_resync
			MgetMBA 
			tst.w	d0
			bmi.s	get_I_resync
			
			move.l	d0,d5			; MBAinc =getMBA
			bra.s notMBAinc_zero			
			
get_I_resync:
			cmp.l	MBAmax(pc),d6	; if (MBA > MBAmax) return;
			bge		got_I
			Mstartcode
			showbits 32
			cmp.l	#SLICE_MIN_START,d0
			blo		got_I
			cmp.l	#SLICE_MAX_START,d0
			bhi		got_I
			bfextu	d0{24:8},d6		; code & 255
			flushbitsQ 32
			Mgetslicehdr
			MgetMBA
			tst.w	d0
			bmi		get_I_resync
			move.l	d0,d5			; MBAinc = getMBA()
			subq.l	#1,d6
			mulu.l	mb_width(pc),d6
			add.l	d5,d6
			moveq	#1,d5			; MBAinc = 1
			subq.l	#1,d6
			clr.l	dc_dct_pred
			clr.w	dc_dct_pred+4
			
isMBA_one:	getbitsQ 1
			tst.w	d0
			bne.s	.no
			getbitsQ 1
			tst.w	d0
			beq		get_I_resync
			getbitsQ 5
			move.l	d0,ld_quant_scale
.no:					
			lea		ld_block,a0
			moveq	#0,d1
			moveq	#0,d2
			moveq	#0,d3
			moveq	#0,d4
			moveq	#6,d0
.lp:		movem.l	d1-d4,(a0)
			movem.l	d1-d4,16(a0)
			movem.l	d1-d4,32(a0)
			movem.l	d1-d4,48(a0)
			movem.l	d1-d4,64(a0)
			movem.l	d1-d4,80(a0)
			movem.l	d1-d4,96(a0)
			movem.l	d1-d4,112(a0)	
			lea		128(a0),a0
			subq	#1,d0
			bne.s	.lp
			lea		dc_dct_pred,a2
Iget_lum1:	
			lea		ld_block+(8*8*2*0),a0
			getDClum
			bsr		decode_intra
			bsr		idct
Iget_lum2:	lea		ld_block+(8*8*2*1),a0
			getDClum
			bsr		decode_intra
			bsr		idct
Iget_lum3:	lea		ld_block+(8*8*2*2),a0
			getDClum
			bsr		decode_intra
			bsr		idct
			
Iget_lum4:	lea		ld_block+(8*8*2*3),a0
			getDClum
			bsr		decode_intra
			bsr		idct
Iget_cr:	addq.l	#2,a2
			lea		ld_block+(8*8*2*4),a0
			getDCchrom
			bsr		decode_intra
			bsr		idct
Iget_cb:	addq.l	#2,a2
			lea		ld_block+(8*8*2*5),a0
			getDCchrom
			bsr		decode_intra
			bsr		idct
			
Idone:		move.l	d6,d3
			divul.l	mb_width,d4:d3
			move.l clp,a4
			lea		128(a4),a4
			lsl.l	#4,d3		; by*16
			lsl.l	#4,d4		; bx*16

			move.l	coded_picture_width,d2
			move.l	newframe,a0
			add.l	d4,a0
			move.l	d3,d0
			mulu.l	d2,d0
			lea		ld_block+(8*8*2*0),a2
			lea		(a0,d0.l),a3
			jsr		copy_block
			
			move.l	d3,d0
			mulu.l	d2,d0
			lea		ld_block+(8*8*2*1),a2
			lea		8(a0,d0.l),a3
			jsr		copy_block
			
			move.l	d3,d0
			addq.l	#8,d0
			mulu.l	d2,d0
			lea		ld_block+(8*8*2*2),a2
			lea		(a0,d0.l),a3
			jsr		copy_block

			move.l	d3,d0
			addq.l	#8,d0
			mulu.l	d2,d0
			lea		ld_block+(8*8*2*3),a2
			lea		8(a0,d0.l),a3
			jsr		copy_block
			
			move.l	chrom_width,d2
			asr.l	#1,d3			
			asr.l	#1,d4
			move.l	newframe+4,a0
			move.l	d3,d0
			mulu.l	d2,d0
			add.l	d4,d0
			lea		ld_block+(8*8*2*4),a2
			lea		(a0,d0.l),a3
			jsr		copy_block
	
			move.l	newframe+8,a0
			lea		ld_block+(8*8*2*5),a2
			move.l	d3,d0
			mulu.l	d2,d0
			add.l	d4,d0
			lea		(a0,d0.l),a3
			jsr		copy_block
			
			addq.l	#1,d6		; MBA++
			subq.l	#1,d5		; MBAinc--			
			bra		get_I_lp

got_I:			
			move.l	d7,ld_bitpos
			movem.l	(sp)+,d1-d7/a1-a6
			rts
			
			.ALIGN 16
; a2 -> src
; a3 -> dst 

copy_block:	moveq	#8,d0
.lp:		move.w	(a2)+,d1
			move.b	(a4,d1),(a3)
			move.w	(a2)+,d1
			move.b	(a4,d1),1(a3)
			move.w	(a2)+,d1
			move.b	(a4,d1),2(A3)
			move.w	(a2)+,d1
			move.b	(a4,d1),3(a3)
			move.w	(a2)+,d1
			move.b	(a4,d1),4(a3)
			move.w	(a2)+,d1
			move.b	(a4,d1),5(a3)
			move.w	(a2)+,d1
			move.b	(a4,d1),6(a3)
			move.w	(a2)+,d1
			move.b	(a4,d1),7(a3)
			add.l	d2,a3
			subq	#1,d0
			bne.s	.lp
			rts
			
			.ALIGN 16
			
MBAmax:		ds.l	1			
ld_bitpos:	ds.l	1
dc_dct_pred:ds.w 	3

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

			EXPORT getCBP
			
			.ALIGN 16
			
getCBP:		showbitsS	9
			move.l	(coded_block_pattern,pc,d0*4),d0
			flushbitsS  d0
			swap	d0
			rts
			
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
