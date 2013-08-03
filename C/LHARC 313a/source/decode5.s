
__SHELL__	equ			0

			export		bitbuf
			export		bitcount
			export		subbitbuf
			export		origsize
			export		compsize
			export		bad_tab
			export		fill_buf

			export		fillbuf
			export		getbits
			export		decode_lh5
			export		send_block
			export		make_table
			export		putbits

			import		outrec
			import		heap
			import		heapsize
			import		freq
			import		file1
			import		file3
			import		right
			import		left
			import		dad
			import		blocksize
			import		bufsize
			import		pt_table
			import		pt_len
			import		c_len
			import		crc
			import		text_buf
			import		flg_q
			import		has_crc
			import		ProcInd
			import		errorlevel
			import		c_code
			import		c_freq
			import		pt_code
			import		p_freq
			import		t_freq
			import		M_BADTAB

			import		block_crc
			import		read_c_len
			import		read_pt_len
			import		make_tree
			import		count_t_freq
			import		write_pt_len
			import		write_c_len
			import		_filbuf
			import		make_buf
			import		fwrite
			import		error
			import		shipout
			import		print
			import		decrypt
if __SHELL__
			import		copy_to_view
endif

NC			equ			510
NT			equ			19
NP			equ			14

WTERR		equ 		14


fillbuf:	move.w		d4,-(sp)
			pea			(a2)

			move.w		d0,d1
			lea.l		bitbuf(pc),a2

			move.w		(a2)+,d2
			move.w		(a2)+,d0
			move.w		(a2)+,d4

			lsl.w		d1,d2

			sub.b		d1,d4
			bpl.s		fbuf_exitf

			move.l		file1(pc),a0
			movea.l 	4(a0),a1

fbuf_whilef:neg.b		d4
			lsl.w		d4,d0
			or.w		d0,d2
			neg.b		d4

			moveq.l 	#0,d0

			subq.l		#1,(a0)
			bmi.s		fbuf_fgetcf

			move.b		(a1)+,d0

fbuf_wendf: addq.b		#8,d4
			bmi.s		fbuf_whilef

			move.l		a1,4(a0)

fbuf_exitf: move.w		d0,d1
			lsr.w		d4,d0
			or.w		d2,d0

			movem.w 	d0/d1/d4,-(a2)
			move.l 		(sp)+,a2
			move.w		(sp)+,d4
			rts


fill_buf:	movem.l		d1/d2/a0/a1,-(sp)
			bsr			_filbuf
			moveq.l		#1,d0
			jsr			decrypt
			movem.l		(sp)+,d1/d2/a0/a1
			rts


fbuf_fgetcf:move.l		a1,4(a0)
			bsr 		fill_buf
			move.l		4(a0),a1
			bra.s		fbuf_wendf

fbuf_fgetcg:move.l		a1,4(a0)
			bsr 		fill_buf
			move.l		4(a0),a1
			bra.s		fbuf_wendg


getbits:	move.w		d4,-(sp)
			pea			(a2)

			lea.l		bitbuf(pc),a2
			move.w		d0,d1

			move.w		(a2),d2
			moveq.l 	#16,d0
			sub.w		d1,d0
			lsr.w		d0,d2

			swap		d2
			move.w		(a2)+,d2
			move.w		(a2)+,d0
			move.w		(a2)+,d4

			lsl.w		d1,d2

			sub.b		d1,d4
			bpl.s		fbuf_exitg

			movea.l 	file1(pc),a0
			movea.l 	4(a0),a1

fbuf_whileg:neg.b		d4
			lsl.w		d4,d0
			or.w		d0,d2
			neg.b		d4

			moveq.l 	#0,d0

			subq.l		#1,(a0)
			bmi.s		fbuf_fgetcg

			move.b		(a1)+,d0

fbuf_wendg: addq.b		#8,d4
			bmi.s		fbuf_whileg

			move.l		a1,4(a0)

fbuf_exitg: move.w		d0,d1
			lsr.w		d4,d0
			or.w		d2,d0

			movem.w 	d0/d1/d4,-(a2)
			move.l		(sp)+,a2
			move.w		(sp)+,d4

			swap		d2
			move.w		d2,d0

			rts


make_table: movem.l 	D3-D7/A2-A6,-(SP)
			lea 		-$78(SP),SP

			move.w		D0,$76(SP)	; nchar
			move.w		D1,D6		; tablebits
			move.l		A0,$72(SP)	; bitlen
			move.l		A1,A6		; table
			lea.l		left(PC),A3
			lea.l		$2+2(SP),A4 ; &start[1]
			lea 		$4C(SP),A5	; count

			lea.l		2(A5),A1	; &count[1]
			moveq.l 	#0,D1
			rept		8
			move.l		D1,(A1)+
			endm

			subq.w		#1,D0
			bmi.s		no_init

init_count: moveq.l 	#0,D1
			move.b		(A0)+,D1
			add.w		D1,D1
			addq.w		#1,0(A5,D1.W)
			dbra		d0,init_count

no_init:	move.l		A4,A0		; &start[1]
			lea.l		2(A5),A1	; &count[1]
			moveq.l 	#0,d5		; k=0
			move.w		D5,(A0)+	; start[1]=0
			moveq.l 	#15,D2

init_start:	REPT		4
			move.w		(a1)+,D1
			lsl.w		D2,D1
			add.w		D1,D5
			move.w		D5,(A0)+
			subq.w		#1,d2
			ENDM
			bpl.s		init_start

			tst.w		D5			; k==0
			beq.s		table_ok

			ori.w		#1,errorlevel
			addq.w		#1,bad_tab
			tst.b		flg_q
			bne.s		_bad_table

			lea 		M_BADTAB(pc),A0
			moveq.l		#1,d0
			jsr 		print

_bad_table: moveq.l 	#0,d0
			bra 		make_exit

table_ok:	moveq.l 	#16,D2
			sub.w		D6,D2
			move.w		D2,(SP) ; jutbits

			moveq.l 	#1,D3
			lea.l		$26+2(SP),A0; &weight[1]

			move.w		D6,D7
			subq.w		#1,D7
			bmi.s		no_start_weight

			move.l		A4,A1	; &start[1]
			add.w		D6,D3

start_weight:
			move.w		(A1),D0 	; start[i] >>= jutbits
			lsr.w		D2,D0
			move.w		D0,(A1)+

			moveq.l 	#1,D1
			lsl.w		D7,D1
			move.w		D1,(A0)+

			dbra		D7,start_weight

no_start_weight:
			moveq.l 	#16,D1
			sub.w		D3,D1
			bmi.s		no_while_weight

			moveq.l 	#0,D0
			bset		D1,D0
while_weight:
			move.w		D0,(A0)+
			lsr.l		D0
			dbra		D1,while_weight

no_while_weight:
			move.w		D6,D0
			add.w		D0,D0
			move.w		0(A4,D0.w),D3
			lsr.w		D2,D3
			beq.s		i_equal

			moveq.l 	#1,D5
			lsl.w		D6,D5

			cmp.w		D3,D5
			beq.s		i_equal

			moveq.l 	#0,D0
			movea.l 	A6,A1	; table
			add.w		D3,A1
			add.w		D3,A1

			sub.w		D5,D3
			not.w		D3

while_i:	move.w		D0,(A1)+
			dbra		D3,while_i

i_equal:	moveq.l 	#1,D1
			moveq.l 	#15,D2
			sub.w		D6,D2
			lsl.w		D2,D1
			move.w		D1,$4A(SP)		; mask

			move.w		$76(SP),D1		; avail=nchar
			lea 		$26(SP),A0		; weight
			movea.l 	$72(SP),A1		; bitlen
			lea 		right(PC),A5

			moveq.l 	#0,d0			; ch
			bra 		ch_wend

while_ch:	moveq.l 	#0,D4
			move.b		(A1)+,D4	; len=bitlen[ch]
			beq.b		next_ch

			move.w		D4,D7
			add.w		D7,D7
			move.w		-2(A4,D7.w),D2
			move.w		D2,D5			; k=start[len]
			add.w		0(A0,D7.w),D2
			move.w		D2,$48(SP)		; nextcode
			movea.l 	A6,A2			; table

			cmp.w		D6,D4			; len<=tablebits
			bgt.s		len_gt_tablebits

			cmp.w		D2,D5
			bge.s		endif

			adda.w		D5,A2
			adda.w		D5,A2

			sub.w		D5,D2
			subq.w		#1,D2

for_i:		move.w		D0,(A2)+
			dbra		D2,for_i
			bra.s		endif

len_gt_tablebits:
			move.w		(SP),D2 ; jutbits
			move.w		D5,D7
			lsr.w		D2,D7
			add.w		D7,D7
			adda.w		D7,A2

			move.w		D4,D3
			sub.w		D6,D3
			subq.w		#1,d3
			bmi.s		i_endif

while_i_else:
			move.w		(A2),D7
			add.w		D7,D7
			bne.s		table_ne

			moveq.l 	#0,D2
			move.w		D1,D7
			add.w		D7,D7
			move.w		D2,(A3,D7.W)
			move.w		D2,(A5,D7.W)
			move.w		D1,(A2)
			addq.w		#1,D1

table_ne:	move.w		D5,D2
			and.w		$4A(SP),D2
			beq.s		no_mask

			lea 		0(A5,D7.w),A2
			bra.s		mask

no_mask:	lea 		0(A3,D7.w),A2
mask:		add.w		D5,D5

			dbra		d3,while_i_else
i_endif:	move.w		D0,(A2)

endif:		add.w		D4,D4
			move.w		$48(SP),-2(A4,D4.w) ; start[len]=nextcode

next_ch:	addq.w		#1,D0
ch_wend:	cmp.w		$76(SP),D0	; ch<nchar
			blt 		while_ch

make_ok:	moveq.l 	#-1,D0

make_exit:	lea 		$78(SP),SP
			movem.l 	(SP)+,D3-D7/A2-A6
			rts


decode_lh5: movem.l 	D3-D7/A2-A6,-(SP) ; Decoder bis ...

			move.w		#$FF,d4 	; m
			lea.l		dec_j(pc),a2

			moveq.l 	#0,d6
			moveq.l 	#8,d7
			move.w		d6,crc
			move.w		d6,bsize-dec_j(a2)

			move.l		d6,(a2)+
			move.l		d6,(a2)+
			move.l		D1,(a2)+	; pacsize
			move.l		D0,(a2) 	; origsize

			moveq.l 	#16,D0
			bsr 		fillbuf

			move.l		file3(pc),d5
			lea 		text_buf,A4

			moveq.l 	#0,d3
			bra 		wend_orig

while_orig: move.w		#$2000,d3	; n
			cmp.l		d3,d0
			bhs.s		dic_size

			move.w		d0,d3

dic_size:	move.l		file1(pc),a0
			move.l		#12*1024,d0
			jsr			make_buf

			move.l		file1(pc),a0
			move.l		4(a0),-(sp)	; file->_ptr

			bsr			decode5

			move.l		file1(pc),a0
			move.l		4(a0),d1	; file->_ptr
			sub.l		(sp)+,d1
			sub.l		d1,bufsize

			tst.w		d0
			beq.s		bad_table

			tst.l		d5
			beq.s		viewer

			move.l		d3,d1
			movea.l 	d5,a1
			movea.l 	a4,a0
			moveq.l 	#1,d0
			bsr 		fwrite

			cmp.l		d3,d0
			bcc.s		no_error

			sub.l		a0,a0
			moveq.l 	#WTERR,d0
			moveq.l		#-1,D1
			jmp 		error

if __SHELL__
viewer:		move.l		d3,d0
			movea.l		a4,a0
			jsr			copy_to_view
else
viewer:
endif

no_error:	sub.l		d3,(a2)
			add.l		d3,d6

			tst.b		has_crc
			beq.s		no_crc

			move.l		a4,a0
			move.l		d3,d0
			jsr			block_crc

no_crc: 	tst.l		(a2)
			beq.s		ind

proc_ind:	cmp.l		blocksize(pc),d6
			blt.s		wend_orig

ind:		sub.l		blocksize(pc),d6

			jsr 		ProcInd
			bra.s		proc_ind

wend_orig:	move.l		(a2),d0
			bne 		while_orig

			moveq.l 	#1,d0

bad_table:	movem.l 	(SP)+,D3-D7/A2-A6 ; ... hier
			rts

; **************

_read_bsize:move.w		d2,d6
			subq.w		#1,d6
			moveq.l		#0,d2

			sub.b		#16,d5
			bpl.s		fbuf_exit1

fbuf_while1:
			neg.b		d5
			lsl.w		d5,d7
			or.w		d7,d2
			neg.b		d5

			moveq.l 	#0,d7
			move.b		(a6)+,d7

			addq.b		#8,d5
			bmi.s		fbuf_while1

fbuf_exit1:
			lea.l		bitbuf+6(pc),a0
			move.w		d5,-(a0)
			move.w		d7,-(a0)

			lsr.w		d5,d7
			or.w		d2,d7
			move.w		d7,-(a0)

			move.l		file1(pc),a0
			move.l		a6,d0
			sub.l		4(a0),d0
			sub.l		d0,(a0)
			move.l		a6,4(a0)

			moveq.l 	#19,d0
			moveq.l 	#5,d1
			moveq.l 	#3,d2
			jsr 		read_pt_len
			tst.w		d0
			beq 		dc_err

			jsr 		read_c_len
			tst.w		d0
			beq 		dc_err

			moveq.l 	#14,d0
			moveq.l 	#4,d1
			moveq.l 	#-1,d2
			jsr 		read_pt_len
			tst.w		d0
			beq 		dc_err

			move.l		file1(pc),a0
			move.l		4(a0),a6		; file->_ptr

			lea.l		bitbuf(pc),a0
			move.w		(a0)+,d2
			move.w		(a0)+,d7
			move.w		(a0),d5

			lea.l		c_len(pc),a1
			bra			dont_read_bsize

; ---

_loop1:		moveq.l 	#3,d1
			move.w		#510,d0

do1:		add.w		d3,d3
			btst		d1,d2
			beq.s		do_else1

			lea.l		right(pc),a0
			move.w		0(a0,d3.w),d3

			cmp.w		d0,d3
			dblt		d1,do1
			bra			no_do1

do_else1:	lea.l		left(pc),a0
			move.w		0(a0,d3.w),d3

			cmp.w		d0,d3
			dblt		d1,do1
			bra			no_do1

_loop2:		moveq.l 	#7,d1

do2:		add.w		d4,d4
			btst		d1,d2
			beq.s		do_else2

			lea.l		right(pc),a0
			move.w		0(a0,d4.w),d4

			cmp.w		d0,d4
			dblt		d1,do2
			bra			no_do2

do_else2:	lea 		left(PC),a0
			move.w		0(a0,d4.w),d4

			cmp.w		d0,d4
			dblt		d1,do2
			bra			no_do2

; ---

decode5:	movem.l 	d3-d7/a2/a4,-(sp)

			subq.w		#1,d3				; count
			move.w		bsize(pc),d6

			move.l 		file1(pc),a0
			move.l		4(a0),a6			; file->_ptr

		 	lea.l		c_len(pc),a1
			lea.l		pt_table,a2
			move.l		dad(pc),a3
			movea.l		a4,a5				; text_buf

			lea.l 		bitbuf(pc),a0
			move.w		(a0)+,d2
			move.w		(a0)+,d7
			move.w		(a0),d5

			move.w		dec_j(pc),d1
			subq.w		#1,d1
			bmi.s		for

			move.w		#$1fff,d0			; DICSIZ - 1
			move.w		i(pc),d4

while_loop1:
			and.w		d0,d4
			move.b		(a4,d4.w),(a5)+
			addq.w		#1,d4
			subq.w		#1,d3
			dbmi		d1,while_loop1
			bpl.s		for

			move.w		d1,dec_j
			bra			dc_return

read_bsize:	bra			_read_bsize
loop1:		bra			_loop1
loop2:		bra			_loop2

for:		dbra		d6,dont_read_bsize
			bra.s		read_bsize

dont_read_bsize:
			move.w		d2,d1
			lsr.w		#4,d1
			add.w		d1,d1
			swap		d3
			move.w		0(a3,d1.w),d3

			cmp.w		#510,d3
			bcc.s		loop1

no_do1:		move.b		0(a1,d3.w),d0
			lsl.w		d0,d2

			sub.b		d0,d5
			bpl.s		fbuf_exit2

fbuf_while2:
			neg.b		d5
			lsl.w		d5,d7
			or.w		d7,d2
			neg.b		d5

			moveq.l 	#0,d7
			move.b		(a6)+,d7

			addq.b		#8,d5
			bmi.s		fbuf_while2

fbuf_exit2:
			move.w		d7,d0
			lsr.w		d5,d0
			or.w		d0,d2

			cmpi.w		#255,d3
			bhi.s		c_gt_ucmax

			move.b		d3,(a5)+
			swap		d3
			dbra		d3,for

			clr.w		dec_j
			bra			dc_return

c_gt_ucmax:
			swap		d3

			move.w		d2,d1		; count
			lsr.w		#8,d1
			add.w		d1,d1
			move.w		0(a2,d1.w),d4

			moveq.l 	#14,d0
			cmp.w		d0,d4
			bcc.s		loop2

no_do2:		lea 		pt_len(pc),a0
			move.b		0(a0,d4.w),d0
			lsl.w		d0,d2

			sub.b		d0,d5
			bpl.s		fbuf_exit3

fbuf_while3:
			neg.b		d5
			lsl.w		d5,d7
			or.w		d7,d2
			neg.b		d5

			moveq.l 	#0,d7
			move.b		(a6)+,d7

			addq.b		#8,d5
			bmi.s		fbuf_while3

fbuf_exit3:
			move.w		d7,d0
			lsr.w		d5,d0
			or.w		d0,d2

			dbra		d4,i_plus
			bra.s		while_loop2

i_plus:		movea.w		d2,a0
			lsl.w		d4,d2

			sub.b		d4,d5
			bpl.s		fbuf_exit4

fbuf_while4:
			neg.b		d5
			lsl.w		d5,d7
			or.w		d7,d2
			neg.b		d5

			moveq.l 	#0,d7
			move.b		(a6)+,d7

			addq.b		#8,d5
			bmi.s		fbuf_while4

fbuf_exit4:
			move.w		d7,d0
			lsr.w		d5,d0
			or.w		d0,d2

			moveq.l		#-1,d0
			bclr		d4,d0

			moveq.l 	#16,d1
			sub.w		d4,d1

			move.w		a0,d4
			lsr.w		d1,d4
			sub.w		d0,d4
			neg.w		d4

while_loop2:
			move.l		a5,d0
			sub.l		a4,d0
			add.w		d0,d4

			swap		d3
			move.w		d3,d1
			swap		d3

			move.w		#$1fff,d0	; DICSIZ - 1

			subi.w		#254,d1
			sub.w		d1,d3
			bls.s		d1_gt_d3

			and.w		d0,d4
			movea.w		d4,a0
			adda.w		d1,a0

			subq.w		#2,d1

			cmp.w		a0,d0
			blt.s		w_loop2c

			lea.l		0(a4,d4.w),a0
			move.b		(a0)+,(a5)+
			move.b		(a0)+,(a5)+

w_loop2a:	move.b		(a0)+,(a5)+
			dbra		d1,w_loop2a
			dbra		d3,for

w_loop2c:	move.b		0(a4,d4.w),(a5)+
			addq.w		#1,d4
			and.w		d0,d4
			move.b		0(a4,d4.w),(a5)+
			addq.w		#1,d4
			and.w		d0,d4
w_loop2d:	move.b		0(a4,d4.w),(a5)+
			addq.w		#1,d4
			and.w		d0,d4
			dbra		d1,w_loop2d
			dbra		d3,for

d1_gt_d3:	add.w		d1,d3
			sub.w		d3,d1

w_loop2b:	and.w		d0,d4
			move.b		0(a4,d4.w),(a5)+
			addq.w		#1,d4
			dbra		d3,w_loop2b
			move.w		d1,dec_j

dc_return:	moveq.l 	#1,d0

			lea.l		bitbuf+6(pc),a0
			move.w		d5,-(a0)
			move.w		d7,-(a0)
			move.w		d2,-(a0)
			move.w		d4,i-bitbuf(a0)
			move.w		d6,bsize-bitbuf(a0)

			move.l		file1(pc),a0
			move.l		a6,d1
			sub.l		4(a0),d1
			sub.l		d1,(a0)
			move.l		a6,4(a0)

			movem.l 	(sp)+,d3-d7/a2/a4
			rts

dc_err:		moveq.l		#0,d0
			movem.l 	(sp)+,d3-d7/a2/a4
			rts


putbits:	lea.l		bitcount(pc),a1
			sub.w		(a1),d0
			bge.b		_n_ge_bitcount

			neg.w		d0
			lsl.w		d0,d1
			move.w		d0,(a1)
			or.w		d1,-(a1)
			rts

_n_ge_bitcount:
			move.w		d1,d2
			lsr.w		d0,d2
			or.w		-(a1),d2

			lea 		outrec(pc),a0
			move.l		(a0),a1
			move.b		d2,(a1)+

			subq.w		#8,d0
			bge.b		_n_ge_charbit

			move.l		a1,(a0)+

			neg.w		d0
			lsl.w		d0,d1

			lea.l		bitcount(pc),a1
			move.w		d0,(a1)
			move.w		d1,-(a1)

			subq.l		#1,(a0)
			bpl.b		_no_ship
			bra 		shipout

_n_ge_charbit:
			move.w		d1,d2
			lsr.w		d0,d2

			move.b		d2,(a1)+
			move.l		a1,(a0)+

			neg.w		d0
			addq.w		#8,d0
			lsl.w		d0,d1

			lea.l		bitcount(pc),a1
			move.w		d0,(a1)
			move.w		d1,-(a1)

			subq.l		#2,(a0)
			bpl.b		_no_ship
			bra 		shipout

_no_ship:	rts


			MACRO		putbits
			LOCAL		_n_ge_bitcount
			LOCAL		_n_ge_charbit
			LOCAL		_exit

			lea.l		bitcount(pc),a1
			sub.w		(a1),d0
			bge.b		_n_ge_bitcount

			neg.w		d0
			lsl.w		d0,d1
			move.w		d0,(a1)
			or.w		d1,-(a1)
			bra.b		_exit

_n_ge_bitcount:
			move.w		d1,d2
			lsr.w		d0,d2
			or.w		-(a1),d2

			lea 		outrec(pc),a0
			move.l		(a0),a2
			move.b		d2,(a2)+

			subq.w		#8,d0
			bge.b		_n_ge_charbit

			move.l		a2,(a0)+

			neg.w		d0
			lsl.w		d0,d1

			move.w		d1,(a1)+
			move.w		d0,(a1)

			subq.l		#1,(a0)
			bpl.b		_exit
			bsr 		shipout
			bra.b		_exit

_n_ge_charbit:
			move.w		d1,d2
			lsr.w		d0,d2

			move.b		d2,(a2)+
			move.l		a2,(a0)+

			neg.w		d0
			addq.w		#8,d0
			lsl.w		d0,d1

			move.w		d1,(a1)+
			move.w		d0,(a1)

			subq.l		#2,(a0)
			bpl.b		_exit
			bsr 		shipout
_exit:
			ENDM


send_block:	movem.l		D3-D7/A2-A6,-(SP)

			lea			c_freq(pc),A2
			lea			text_buf,A3
			lea			c_code(pc),A4
			lea			c_len(pc),A5
			lea	   		pt_code,A6

			pea			(A4)
			movea.l		A5,A1
			movea.l 	A2,A0
			move.w  	#NC,D0
			bsr	   		make_tree	; make_tree(NC,freq,c_len,c_code)
			addq.w		#4,SP

			move.w		D0,D3			; k

			add.w   	D0,D0
			move.w  	0(A2,D0.w),D4	; size=c_freq[k]

			move.w  	D4,D1
			moveq.l 	#16,D0
			bsr			putbits			; putbits(16,size)

			cmp.w   	#NC,D3			; k>=NC ?
			bcs.s   	k_lt_NC

			jsr	   		count_t_freq

			pea		   	(A6)
			lea	   		pt_len(pc),A1
			lea	   		t_freq,A0
			moveq.l 	#NT,D0
			bsr	    	make_tree		; make_tree(NT,t_freq,pt_len,pt_code)
			addq.w		#4,SP

			move.w		D0,D3			; k

			cmp.w		#NT,D3			; k>=NT ?
			bcs.s		k_lt_NT

			moveq.l		#3,D2
			moveq.l		#5,D1
			moveq.l		#NT,D0
			jsr			write_pt_len	; write_pt_len(NT,TBIT,3)
			jsr	   		write_c_len
			bra.s		_k_ge_NC

k_lt_NT: 	moveq.l		#0,D1
			moveq.l 	#5,D0
			bsr 		putbits

			move.w		D3,D1
			moveq.l 	#5,D0
			bsr 		putbits

			jsr	   		write_c_len
			bra.s		_k_ge_NC

k_lt_NC:	moveq.l		#0,D1
			moveq.l		#8,D0
			bsr 		putbits

			moveq.l		#0,D1
			moveq.l		#11,D0
			bsr			putbits

			move.w		D3,D1
			moveq.l 	#9,D0
			bsr			putbits

_k_ge_NC:	pea			(A6)
			lea			pt_len(pc),A1
			lea 		p_freq(pc),A0
			moveq.l 	#NP,D0
			bsr 		make_tree		; make_tree(NP,p_freq,pt_len,pt_code)
			addq.w		#4,SP

			move.w		D0,D3			; k

			cmp.w		#NP,D3			; k>=NP ?
			bcs.s		k_lt_NP

			moveq.l		#-1,D2
			moveq.l		#4,D1
			moveq.l		#NP,D0
			jsr 		write_pt_len	; write_pt_len(NP,PBIT,-1)
			bra.s		_k_ge_NP

k_lt_NP: 	moveq.l		#0,D1
			moveq.l		#4,D0
			bsr			putbits

			move.w		D3,D1
			moveq.l		#4,D0
			bsr			putbits

_k_ge_NP:	dbra		D4,i_loop
			bra			_send_exit

i_loop:		moveq.l		#0,d5		; i

i_while:	add.w		D6,D6		; flags<<=1

			moveq.l		#7,D0
			and.w		D5,D0
			bne.s		i_char_bit

			moveq.l		#0,D6
			move.b		(A3)+,D6	; flags=*text_buf++

i_char_bit:	btst		#7,D6		; flags&(1U<<(CHAR_BIT-1)) ?
			beq			_not_flags

			move.w		#256,D1
			move.b		(A3)+,D1		; k=(*text_buf++)+(1U<<CHAR_BIT)

			moveq.l		#0,d0
			move.b		0(A5,D1.w),D0	; c_len[k]
			add.w		D1,D1
			move.w		0(A4,D1.w),D1	; c_code[k]
			bsr			putbits

			move.b		(A3)+,D3		; k=(*text_buf++)<<CHAR_BIT
			lsl.w		#8,D3
			move.b		(A3)+,D3 		; k|=*text_buf++

			moveq.l		#15,d7			; c
while_q:	btst		d7,d3			; while (c>>=1)
			dbne		d7,while_q		; c--

			addq.w		#1,d7

			move.w		D7,D0
			add.w		D0,D0
			move.w		0(A6,D0.w),D1	; pt_code[c+1]

			moveq.l		#0,D0
			lea			pt_len(PC),A0
			move.b		0(A0,D7.w),D0	; pt_len[c+1]
			putbits

			subq.w		#1,d7			; c>1 ?
			bls			i_wend

			moveq.l		#-1,d1
			moveq.l		#16,d0
			sub.w		d7,d0
			lsr.w		D0,D1
			and.w		D3,D1			; k&(0xFFFFU>>(17-c))
			move.w		d7,d0			; c-1
			putbits

			addq.w		#1,D5			; i++
			dbra		D4,i_while		; i<size ?
			bra.s		_send_exit

_not_flags:	moveq.l		#0,D1
			move.b		(A3)+,D1		; k=*text_buf++

			moveq.l		#0,D0
			move.b		0(A5,D1.w),D0	; c_len[k]
			add.w		D1,D1
			move.w		0(A4,D1.w),D1	; c_code[k]
			putbits

i_wend:		addq.w		#1,D5			; i++
			dbra		D4,i_while		; i<size ?

_send_exit:	move.w		#(NC>>2)-1,D5
			moveq.l		#0,D3

			lea			c_freq(pc),A2
c_freq_clr:	REPT		2
			move.l		D3,(A2)+
			ENDM
			dbra		D5,c_freq_clr
			move.l		D3,(A2)+

			lea 		p_freq(pc),A2
			REPT		7
			move.l		D3,(A2)+
			ENDM

			movem.l		(SP)+,D3-D7/A2-A6
			rts

dec_j:		.DC.W	0
bitbuf: 	.DC.W	0
subbitbuf:	.DC.W	0
bitcount:	.DC.W	0
compsize:	.DC.L	0
origsize:	.DC.L	0
i:			.DC.W	0
bsize:		.DC.W	0
bufptr: 	.DC.L	0
bad_tab:	.DC.W	0

			.END
