
; Get Coded Block Pattern Entry

cbp_ent_cbp	equ	0
cbp_ent_num	equ	1

getCBP:		move.w	ld_bfr(pc),d0		;
			lsr.w	#7,d0				;	showbits(9)
			lea.l	(coded_block_pattern,d0*2),a5
			clr	d0
			move.b	cbp_ent_num(a5),d0	; flushbits(coded_block_pattern[index].num_bits);
			bsr	flushbits
			clr	d0
			move.b	cbp_ent_cbp(a5),d0	; return coded_block_pattern[index].cbp;
			rts
