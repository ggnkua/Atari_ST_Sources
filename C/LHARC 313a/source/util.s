
			export	FTimeToULong
			export	ilong
			export	itime
			export	ProcInd
			export	Bputc
			export	block_crc
			export	mkcrc
			export	crc_getc
			export	mksum
			export	stpcpy
			export	strcpy
			export	strchr
			export	strcmp
			export  strncmp
			export	strlen
			export  stricmp
			export	blkcnt
			export	RotInd
			export	rot
			export	make_tree
			export	sortptr
			export	count_len
			export	get_fname
			export	backpath
			export	star
			export	upper
			export  memset

			import	crc
			import	crctbl
			import	fill_buf
			import	_filbuf
			import	error
			import	infname
			import  proc_ind
;			import	freq
			import	heap
;			import	heapsize
			import	make_len
			import	len_cnt
			import	left
			import	right
			import	len
			import	flg_n


RDERR		equ		13
WTERR		equ		14


ilong:		move.l	(a0),d0
			ror.w	#8,d0
			swap	d0
			ror.w	#8,d0
			move.l	d0,(a0)
			rts


itime:		move.l	(a0),d0
			ror.w	#8,d0
			swap	d0
			ror.w	#8,d0
			swap	d0
			move.l	d0,(a0)
			rts


FTimeToULong:
			move.l	(a0),d0
			swap	d0
			rts


ProcInd:	move.b	flg_n,d0
			subq.b	#1,d0
			beq.b	_procexit

			subq.w	#1,blkcnt
			bmi.b	_procexit

			tst.b	d0
			bmi.b	_proc_star

			subq.b	#1,d0
			beq.s	_proc_ind

			lea.l	RotInd(pc),a0
			move.w	(a0),d1
			move.b	rot(pc,d1.w),d2

			addq.w	#1,d1
			and.w	#3,d1
			move.w	d1,(a0)

			pea		(a2)
			move.w	d2,-(sp)
			move.w	#2,-(sp)
			trap	#1

			pea		$20008
			trap	#1		; Cconout
			addq.w	#8,sp
			move.l	(sp)+,a2

			rts

_proc_ind:	jmp		proc_ind

_proc_star:	pea		(a2)
			move.w	star(PC),-(sp)
			move.w	#2,-(sp)
			trap	#1
			addq.w	#4,sp
			move.l	(sp)+,a2

_procexit:	rts

RotInd:		dc.w	0
rot:		dc.b	'-/|\'

			EVEN

mkcrc:		MOVEM.L		D3/A2,-(SP)

			LEA.L       crct_lo+256,A0
			LEA.L       crct_hi+256,A1
			LEA.L		crctbl+512,A2
			MOVE.W		#$A001,D2

			MOVE.W		#255,D1 ; for (i = 0x100; i--;) {
mkfor_i:	MOVE.W		D1,D0	; crc = i;

			MOVEQ.L		#7,D3
for_j:		LSR.W		#1,D0
			BCC.S		next_j
			EOR.W		D2,D0 ; ; crc = (crc >> 1) ^ CRC_16
next_j:		DBRA		D3,for_j ;  for (j=8;--j>=0;)

			MOVE.W		D0,-(A2) ; crctbl[i] = crc
			MOVE.B		D0,-(A0) ; crct_lo[i] = (unsigned char) crc
			LSR.W		#8,D0
			MOVE.B		D0,-(A1) ; crct_hi[i] = crc >> 8
			DBRA		D1,mkfor_i

			MOVEM.L		(SP)+,D3/A2
			RTS


block_crc:	MOVEM.L		D0-D4/A0-A2,-(sp)

			MOVEQ.L		#0,D1
			MOVEQ.L		#0,D2
			MOVEQ.L		#0,D3

			MOVE.B		crc+1,D2 ; crclo = (unsigned char) crc
			MOVE.B		crc,D3 ; crchi = crc >> 8;

			LEA.L		crct_lo,A1
			LEA.L		crct_hi,A2

			MOVEQ.L		#16,d4
			CMP.L		d4,d0
			BLT			end_crc

			MOVE.L		D0,D4

			LSR.L		#4,d0
			SUBQ.L		#1,d0

for_count:	REPT		16
			MOVE.B		(A0)+,D1		; crclo = crct_lo[ndx = *p++ ^ crclo];
			EOR.B		D2,D1
			MOVE.B		(A1,D1.W),D2
			EOR.B		D3,D2			; crclo ^= crchi;
			MOVE.B		(A2,D1.W),D3	; crchi = crct_hi[ndx];
			ENDM

next_count:	DBRA		D0,for_count	; for (++count; --count;)

			MOVEQ.L		#15,D0
			AND.W		D4,D0

end_crc:	SUBQ.W		#1,D0
			BMI.S		crc_set

fwhile_crc:	MOVE.B		(A0)+,D1		; crclo = crct_lo[ndx = *p++ ^ crclo];
			EOR.B		D2,D1
			MOVE.B		(A1,D1.W),D2
			EOR.B		D3,D2			; crclo ^= crchi;
			MOVE.B		(A2,D1.W),D3	; crchi = crct_hi[ndx];
			DBRA		D0,fwhile_crc

crc_set:	MOVE.B		D3,crc ; crc = ((crchi << 8) | crclo);
			MOVE.B		D2,crc+1

			MOVEM.L		(A7)+,D0-D4/A0-A2
			RTS

crc_getc:	subq.l	#1,(a0)+	; _cnt
			bmi.b	_get_empty

			move.l	(a0),a1	; _ptr
			moveq.l	#0,d0
			move.b	(a1)+,d0
			move.l	a1,(a0)

_crc:		lea.l	crc,a0
			move.w	(a0)+,d2
			move.w	d2,d1
			lsr.w	#8,d1
			eor.w	d0,d2
			and.w	#$FF,d2
			add.w	d2,d2
			move.w	(a0,d2.w),d2	; crctbl
			eor.w	d1,d2
			move.w	d2,-(a0)		; crc
			rts

_get_empty:	subq.w	#4,a0
			pea		(a0)
			bsr		_filbuf

			tst.w	d0
			bmi.b	_eof

			addq.w	#4,sp
			bra.b	_crc

_eof:		move.l	(sp)+,a0
			move.w	12(a0),d1	; _flag
			and.w	#$4000,d1
			bne.b	_get_error
			rts

_get_error:	move.l	infname,a0
			moveq.l	#RDERR,d0
			moveq.l	#-1,D1
			jmp		error


mksum:		subq.w	#1,d0
			moveq.l	#0,d1
			addq.w	#2,a0

_sum:		add.b	(a0)+,d1
			dbra	d0,_sum
			move.w	d1,d0
			rts


stpcpy:		move.l	a1,d0
			beq.b	_no_source

_stpcpy:	REPT	23
			move.b	(a1)+,(a0)+
			beq.b	_stp_back
			ENDM

			move.b	(a1)+,(a0)+
			bne.b	_stpcpy

_stp_back:	subq.w	#1,a0
			rts

_no_source:	clr.b	(a0)
			rts


strcpy:		move.l	a1,d0
			beq.b	_no_source

			move.l	a0,d0

_strcpy:	REPT	23
			move.b	(a1)+,(a0)+
			beq.b	_str_exit
			ENDM

			move.b	(a1)+,(a0)+
			bne.b	_strcpy

_str_exit:	move.l	d0,a0
			rts


strncmp:	subq.w	#1,d0
			bmi.s	_str_eq

_strn_lp:	move.b	(a0)+,d1
			beq.b	_strcend
			cmp.b	(a1)+,d1
			dbne	d0,_strn_lp

			tst.w	d0
			bmi.b	_str_eq

			cmp.b	-(a1),d1
			bcs.b	_str_lt
			moveq.l	#1,D0
			rts

_str_eq:	moveq.l	#0,d0
			rts


_strcend:	tst.b	(a1)
			bne.b	_str_lt

			moveq.l	#0,D0
			rts

_str_lt:	moveq.l	#-1,D0
			rts


strcmp:		REPT 13
			move.b	(a0)+,d0
			beq.b	_strcend
			cmp.b	(a1)+,d0
			bne.b	_str_ne
			ENDM

			move.b	(a0)+,d0
			beq.b	_strcend
			cmp.b	(a1)+,d0
			beq.b	strcmp

_str_ne:	bcs.b	_str_lt
			moveq.l	#1,D0
			rts


stricmp:	move.l	a2,d2
			lea.l	upper,a2
			moveq.l	#0,d0
			moveq.l	#0,d1

_stri_lp:	move.b	(a0)+,d0
			beq.b	_stri_cend

			move.b	0(a2,d0.w),d0
			move.b	(a1)+,d1
			cmp.b	0(a2,d1.w),d0
			beq.b	_stri_lp
			bcs.b	_stri_lt

			move.l	d2,a2
			moveq.l	#1,D0
			rts

_stri_cend:	tst.b	(a1)
			bne.b	_stri_lt

			move.l	d2,a2
			moveq.l	#0,D0
			rts

_stri_lt:	move.l	d2,a2
			moveq.l	#-1,D0
			rts


strlen:		move.l	a0,a1

_strlen:	REPT 15
			tst.b	(a0)+
			beq.b	_strlend
			ENDM

			tst.b	(a0)+
			bne.b	_strlen

_strlend:	move.l	a0,d0
			sub.l	a1,d0
			subq.l	#1,d0
			rts


strchr:		move.b	(a0)+,d1
			beq.s	_sch_exit

			cmp.b	d1,d0
			bne.s	strchr

			subq.w	#1,a0
			rts

_sch_exit:	suba.l	a0,a0
			rts


get_fname:	move.l	a0,a1

			move.b	#'\',d1
			move.b	#'/',d2

_gf_loop:	move.b	(a1)+,d0
			beq.s	_gf_exit

			cmp.b	d1,d0
			beq.s	_gf_set

			cmp.b	d2,d0
			beq.s	_gf_set

			cmp.b	#':',d0
			bne.s	_gf_loop

_gf_set:	movea.l	a1,a0
			bra.s	_gf_loop

_gf_exit:	rts


backpath:	bsr.s	get_fname
			clr.b	(a0)
			rts


memset:		move.l	a0,a1

			subq.w	#1,d1
			bmi.s	_mem_exit

_mem_lp:	move.b	d0,(a1)+
			dbra	d1,_mem_lp

_mem_exit:	rts


make_tree:	movem.l D3-D7/A2-A6,-(SP)
			lea		-36(SP),SP

			lea		heap+2,A3	; &heap[1]
			clr.w   (A3)		; heap[1] = 0
			lea		heapsize,A4
			movea.l 80(SP),A5	; codeparm

			move.w  D0,D3		; nparm
			move.w  D3,D4		; avail
			move.w  D4,n		; n
			move.l  A0,freq		; freqparm
			move.l  A1,len		; lenparm

			moveq.l	#0,D1		; heapsize = 0

			subq.w	#1,D0
			bmi.s	_m_no_for_i

			moveq.l	#0,D2
			moveq.l	#0,D5		; i = 0
			move.l	A3,A6		; &heap[1]

_m_for_i:	move.b	D2,(A1)+	; len[i] = 0
			tst.w	(A0)+		; freq[i] ?
			beq.s   _m_next_i

			addq.w  #1,D1
			move.w  D5,(A6)+

_m_next_i: 	addq.w	#1,D5
			dbra	D0,_m_for_i

_m_no_for_i:move.w	D1,(A4)

			subq.w	#2,D1	; heapsize<2 ?
		 	bge.s   hs_ge_2

			move.w  (A3),D0
			move.w	D0,D1
			add.w   D1,D1
			clr.w   0(A5,D1.w)

			lea		36(SP),SP
			movem.l (SP)+,D3-D7/A2-A6
			rts

hs_ge_2:	move.w	(A4),D5
			moveq.l	#1,D6
			asr.w	D6,D5	; i = heapsize>>1
			bra.s	down_h_next

down_h:		move.w	D5,D0
			movem.l	D3-D5,-(SP)

			lea		heap,A0
			movea.l freq,A1

			move.w  heapsize,D1
			add.w	D1,D1

			add.w	D0,D0	; i
			lea.l	0(A0,D0.W),A2

			move.w  (A2),D2	; k = heap[i]
			move.w  D2,D3
			add.w   D3,D3
			move.w  0(A1,D3.w),D3	; fk = freq[k]
			move.w	D0,D4	; j

_d_while1:	add.w	D4,D4

			cmp.w   D1,D4			; j<=heapsize
			bgt.s   _d_exit1
			beq.s   _d_else1

			lea.l	0(A0,D4.W),A6
			move.w	(A6)+,D5		; heap[j]
			add.w   D5,D5
			move.w  0(A1,D5.w),D5	; freq[heap[j]]
			move.w  (A6),D0			; heap[j+1]
			add.w   D0,D0
			cmp.w   0(A1,D0.w),D5	; freq[heap[j+1]]
			bls.s   _d_else1

			addq.w  #2,D4

_d_else1:	lea.l	0(A0,D4.W),A6
			move.w	(A6),D5
			move.w	D5,(A2)			; heap[i] = heap[j]
			add.w   D5,D5
			cmp.w   0(A1,D5.w),D3	; fk<=freq[heap[j]]
			bls.s   _d_exit1

			move.l	A6,A2
			bra.s	_d_while1

_d_exit1: 	move.w  D2,(A2)			; heap[i] = k

			movem.l (SP)+,D3-D5

			subq.w  #1,D5

down_h_next:cmp.w	D6,D5
			bge.s   down_h

no_down_heap:
			move.l  A5,sortptr

do_heap:	move.w	(A3),D5
			cmp.w   n(pc),D5			; i<n
			bge.s   i_ge_n

			movea.l sortptr(pc),A0
			move.w  D5,(A0)+
			move.l	A0,sortptr			; *sortptr++ = i

i_ge_n:		move.w	(A4),D0
			add.w   D0,D0
			move.w  -2(A3,D0.w),(A3)	; heap[1] = heap[heapsize--]
			subq.w  #1,(A4)

			movem.l	D3-D5,-(SP)

			lea		heap,A0
			movea.l freq,A1

			move.w  heapsize,D1
			add.w	D1,D1

			lea.l	2(A0),A2		; downheap(1)

			move.w  (A2),D2			; k = heap[i]
			move.w  D2,D3
			add.w   D3,D3
			move.w  0(A1,D3.w),D3	; fk = freq[k]
			moveq.l	#4,D4	; j

_d_while2:	cmp.w   D1,D4			; j<=heapsize
			bgt.s   _d_exit2
			beq.s   _d_else2

			lea.l	0(A0,D4.W),A6
			move.w	(A6)+,D5		; heap[j]
			add.w   D5,D5
			move.w  0(A1,D5.w),D5	; freq[heap[j]]
			move.w  (A6),D0			; heap[j+1]
			add.w   D0,D0
			cmp.w   0(A1,D0.w),D5	; freq[heap[j+1]]
			bls.s   _d_else2

			addq.w  #2,D4

_d_else2:	lea.l	0(A0,D4.W),A6
			move.w	(A6),D5
			move.w	D5,(A2)			; heap[i] = heap[j]
			add.w   D5,D5
			cmp.w   0(A1,D5.w),D3	; fk<=freq[heap[j]]
			bls.s   _d_exit2

			move.l	A6,A2
			add.w	D4,D4
			bra.s	_d_while2

_d_exit2: 	move.w  D2,(A2)			; heap[i] = k

			movem.l (SP)+,D3-D5

			move.w  (A3),D6
			cmp.w   n(pc),D6		; j<n ?
			bge.s   j_ge_n

			movea.l sortptr,A0
			move.w  D6,(A0)+
			move.l  A0,sortptr			; *sortptr++ = j

j_ge_n:		move.w	D4,D7	; k = avail
			addq.w  #1,D4	; avail++

			movea.l freq,A0

			move.w  D5,D0
			add.w   D0,D0
			move.w  0(A0,D0.w),D1	; freq[i]
			move.w  D6,D2
			add.w   D2,D2
			add.w   0(A0,D2.w),D1	; freq[j]
			move.w  D7,D0
			add.w   D0,D0
			move.w  D1,0(A0,D0.w)	; freq[k] = freq[i] + freq[j]

			move.w  D7,(A3)			; heap[1] = k

			movem.l	D3-D5,-(SP)

			lea		heap,A0
			movea.l freq,A1

			move.w  heapsize,D1
			add.w	D1,D1

			lea.l	2(A0),A2		; downheap(1)

			move.w  (A2),D2			; k = heap[i]
			move.w  D2,D3
			add.w   D3,D3
			move.w  0(A1,D3.w),D3	; fk = freq[k]
			moveq.l	#4,D4	; j

_d_while3:	cmp.w   D1,D4			; j<=heapsize
			bgt.s   _d_exit3
			beq.s   _d_else3

			lea.l	0(A0,D4.W),A6
			move.w	(A6)+,D5		; heap[j]
			add.w   D5,D5
			move.w  0(A1,D5.w),D5	; freq[heap[j]]
			move.w  (A6),D0			; heap[j+1]
			add.w   D0,D0
			cmp.w   0(A1,D0.w),D5	; freq[heap[j+1]]
			bls.s   _d_else3

			addq.w  #2,D4

_d_else3:	lea.l	0(A0,D4.W),A6
			move.w	(A6),D5
			move.w	D5,(A2)			; heap[i] = heap[j]
			add.w   D5,D5
			cmp.w   0(A1,D5.w),D3	; fk<=freq[heap[j]]
			bls.s   _d_exit3

			move.l	A6,A2
			add.w	D4,D4
			bra.s	_d_while3

_d_exit3: 	move.w  D2,(A2)			; heap[i] = k

			movem.l (SP)+,D3-D5

			move.w	D7,D0
			add.w   D0,D0
			lea		left,A0
			move.w  D5,0(A0,D0.w)	; left[i] = k
			lea		right,A1
			move.w  D6,0(A1,D0.w)	; right[i] = k

			cmpi.w  #1,(A4)			; heapsize>1 ?
			bgt		do_heap

			move.l  A5,sortptr		; sortptr = codeparm

			move.w  D7,D0
			jsr		make_len		; make_len(k)

			lea.l	2(SP),A0		; &start[1]
			lea.l	len_cnt+2,A1

			moveq.l	#0,D1
			moveq.l #3,D0
			move.w	D1,(A0)+			; start[1] = 0

for_start:	REPT	4
			add.w	(A1)+,D1		; start[i] + len_cnt[i]
			add.w	D1,D1
			move.w	D1,(A0)+
			ENDM
			dbra	D0,for_start

			moveq.l	#0,D1
			move.l	len,A2
			bra.s	next_i

for_i:		move.b  (A2)+,D1
			add.w   D1,D1
			lea.l	0(SP,D1.W),A0
			move.w  (A0),(A5)+		; codeparm[i] = start[lenparm[i]]
			addq.w  #1,(A0)
next_i:		dbra	d3,for_i

			move.w  D7,D0
			lea	   	36(SP),SP
			movem.l (SP)+,D3-D7/A2-A6
			rts


count_len:	cmp.w	n(pc),d0
			bge.b	_i_ge_n

			move.w	depth(pc),d0
			cmp.w	#16,d0
			bge.b	_ge_16

			add.w	d0,d0
			lea.l	len_cnt,a0
			addq.w	#1,(a0,d0.w)
			rts

_ge_16:		addq.w	#1,len_cnt+32
			rts

_i_ge_n:	move.w	d3,-(sp)
			lea.l	depth(pc),a1
			addq.w	#1,(a1)

			move.w	d0,d3
			add.w	d3,d3

			lea.l	left,a0
			move.w	(a0,d3.w),d0
			bsr.b	count_len

			lea.l	right,a0
			move.w	(a0,d3.w),d0
			bsr.b	count_len

			subq.w	#1,(a1)
			move.w	(sp)+,d3
			rts


sortptr:	DC.L	0
blkcnt:		DC.W	0
depth:		DC.W	0
n:			DC.W	0
star:		DC.B	0,'*'

			EVEN

			BSS

heapsize:	DS.W	1	; int heapsize
freq:		DS.L	1	; ushort *freq
upper:		DS.B		256
crct_lo:	DS.B		256
crct_hi:	DS.B		256

			END
