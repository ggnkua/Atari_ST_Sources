
__SHELL__	equ 0

			import error
			import fill_buf
			import _filbuf
			import pathname
			import backup2
			import InitTree
			import ProcInd
if __SHELL__
			import copy_to_view
endif
			import buffer_3

			import flg_Y
			import key_word
			import key
			import bsize
			import origsize
			import buffered
			import cmdupdate
			import buffer_last
			import method
			import compsize
			import compress
			import outfile

			export hfreq
			export prnt
			export son

			export match_length
			export match_position
			export file3
			export file1
			export blocksize
			export codesize
			export textsize
			export crc
			export crctbl
			export dad
			export lson
			export rson
			export text_buf
			export outrec
			export outrec_decode
			export ship

			export shipout
			export shipout_decode
			export Decode
			export Encode
			export InsertONode
			export DeleteONode
			export OpenOut
			export code
			export buf_putc

DICBIT		set 13
DICSIZ		set (1<<DICBIT)
BUFSIZ		set	16384

N			set 4096
F			set 60
THRESHOLD	set 2
N_CHAR		set 256-THRESHOLD+F
T			set N_CHAR*2-1
FOLD		set 18
R			set T-1
NIL			set	N

WTERR		set 14


outrec_decode:
		ds.l	1	; 0 Speicherzeiger
		ds.l	1	; 4 L„nge
		ds.l	1	; 8 Basispointer
		ds.l	1	; 12 basisl„nge

outrec:	ds.l	1	; 0 Speicherzeiger
		ds.l	1	; 4 L„nge
		ds.l	1	; 8 Basispointer
		ds.l	1	; 12 basisl„nge

ship:   ds.w	1


ferror_enc:
		lea.l	backup2,A0
		bra.s	ferror
ferror_dec:
		lea.l	pathname,a0
ferror:
		moveq	#WTERR,D0
		moveq.l	#-1,D1
		jmp		error


buf_putc:
		lea		outrec(pc),a0
		addq.l	#1,codesize-outrec(a0)

		move.l	(a0),a1
		move.b	d0,(a1)+
		move.l	a1,(a0)+
		subq.l	#1,(a0)
		bpl.b	_buf_exit

		bsr.b	shipout

_buf_exit:
		rts


code:	tst.b	flg_Y
		beq.s	_no_code

		subq.l	#1,d0
		bmi.s	_no_code

		movem.l	d1-d2/a2,-(sp)

		move.l	key,a1
		lea.l	key_word,a2

_code:	move.l	#32767,d2
		cmp.l	d0,d2
		ble.b	_do_code

		move.l	d0,d2
_do_code:
		sub.l	d2,d0
_code_lp:
		move.b	(a1)+,d1
		beq.b	_re_code
		eor.b	d1,(a0)+
		dbra	d2,_code_lp

		subq.l	#1,d0
		bpl.b	_code

_exit_code:
		move.l	a1,key
		movem.l	(sp)+,d1-d2/a2
_no_code:
		rts

_re_code:
		movea.l	a2,a1
		move.b	(a1)+,d1
		eor.b	d1,(a0)+
		dbra	d2,_code_lp
		subq.l	#1,d0
		bpl.b	_code
		bra.b	_exit_code


shipout:movem.l d0-d2/a0-a2,-(sp)

		lea		outrec(pc),a0
		move.l	(a0),d1
		sub.l	8(a0),d1
		beq		ship1

		move.w	ship(pc),d0
		bne		do_ship

		cmp.b	#5,method
		bne.b	not_lha5

		move.l	d1,d0

		tst.b	buffered
		beq.b	_buffer

		move.l	(a0),d0
		sub.l	buffer_last,d0

_buffer:add.l	d0,compsize

not_lha5:
		move.b	compress,d0
		bne.b	code_ship

		move.l	compsize,d0
		cmp.b	#5,method
		beq.b	lha5

		move.l	codesize(pc),d0

lha5:	cmp.l	origsize(pc),d0
		blt.b	code_ship

		tst.b	buffered
		beq.b	ship1

		move.l	buffer_last,d1
		sub.l	8(a0),d1
		bra.b	do_ship

code_ship:
		pea		(a0)

		tst.b	buffered
		beq.b	_crypt1

		move.l	(a0),d0
		move.l	buffer_last,a0
		sub.l	a0,d0
		bra.b	_crypt

_crypt1:move.l	8(a0),a0
		move.l	d1,d0

_crypt:	bsr		code
		move.l	(sp)+,a0

		tst.b	buffered
		beq.b	do_ship

		tst.l	4(a0)
		bpl.s	ex_ship

do_ship:move.l	d1,-(sp)
		move.l	8(a0),-(sp)
		move.l	d1,-(sp)
		move.w	outfile,-(sp)	; (=handle)
		move.w	#$40,-(sp)		; Fwrite
		trap	#1
		lea		12(sp),sp
		move.l	(sp)+,d1

		tst.l	d0
		bmi		ferror_enc

		cmp.l	d1,d0
		blt		ferror_enc

		clr.b	buffered

ship1:	lea		outrec(pc),a0
		move.l	12(a0),4(a0)
		move.l	8(a0),(a0)

ex_ship:movem.l (sp)+,d0-d2/a0-a2
		rts


shipout_decode:
		movem.l d0-d2/a0-a2,-(sp)

		lea		outrec_decode(pc),a0
		move.l	(a0),d0
		move.l	8(a0),a0
		sub.l	a0,d0
		beq.s	ship1_d

if __SHELL__
		jsr		copy_to_view
endif

		lea		outrec_decode(pc),a0
		move.l	(a0),d1
		sub.l	8(a0),d1

		move.l	file3(pc),d0	; _cnt
		beq.s	ship1_d

		move.l	d1,-(sp)
		move.l	8(a0),-(sp)
		move.l	d1,-(sp)
		move.l	d0,a0
		move.w	14(a0),-(sp)	; file3._file (=handle)
		move.w	#$40,-(sp)		; Fwrite
		trap	#1
		lea		12(sp),sp
		move.l	(sp)+,d1

		tst.l	d0
		bmi		ferror_dec

		cmp.l	d1,d0
		blt		ferror_dec

ship1_d:lea		outrec_decode(pc),a0
		move.l	12(a0),4(a0)
		move.l	8(a0),(a0)

		movem.l (sp)+,d0-d2/a0-a2
		rts


		macro	ferror	file
		move.l	file,a0
		move.w	12(a0),d0
		btst	#14,d0
		endm


		macro	putc reg
		local	putc1

		lea		outrec(pc),a0
		addq.l	#1,codesize-outrec(a0)

		move.l	(a0),a1
		move.b	reg,(a1)+
		move.l	a1,(a0)
		subq.l	#1,4(a0)
		bpl.b	putc1
		bsr		shipout
putc1:
		endm

OpenOut:move.l	bsize,d0
		subq.l	#1,d0

		move.l	a1,(a0)+
		move.l	d0,(a0)+
		move.l	a1,(a0)+
		move.l	d0,(a0)
		rts

		macro	getc
		local	getc1
		local	getc2
		local	getc3
		local	getceof

		move.l	file3(pc),a0
		subq.l	#1,(a0)
		bpl.b	getc1

		movem.l d1-d2/a0-a1,-(sp)
		jsr		_filbuf
		movem.l (sp)+,d1-d2/a0-a1

		cmp.w	#$ffff,d0
		beq.b	getceof
		bra.b	getc2

getceof:tst.b	d0
		bra.b	getc3

getc1:	moveq.l #0,d0
		move.l	4(a0),a1
		move.b	(a1)+,d0
		move.l	a1,4(a0)

getc2:	cmp.b	d0,d0
getc3:
		endm

		macro	rgetc
		local	getc1
		local	getc2

		subq.l	#1,(a0)
		bpl.b	getc1

		bsr		fill_buf
		bra.b	getc2

getc1:	moveq.l #0,d0
		move.l	4(a0),a1
		move.b	(a1)+,d0
		move.l	a1,4(a0)
getc2:
		endm

		macro	getw
		local	Fits
		local	getwEnd

		rgetc
		move.w	d0,d7
		lsl.w	#8,d7
		rgetc
		move.b	d0,d7
getwEnd:endm

		macro	crcgetc
		local	no_crc

		lea		crc,A1

		move.w	(A1)+,D1	; A1 -> crctbl
		move.w	d1,d2
		eor.w	D0,D1

		and.w	#$ff,D1
		add.w	D1,D1

		lsr.w	#8,D2
		move.w	0(A1,D1.w),D1
		eor.w	D2,D1
		move.w	D1,-(A1)	; crc
		endm

		macro	putcode
		local	PutCode1
		local	PutCode2
		movem.w D3/D4,-(SP)
		move.w	D0,D4
		move.w	D1,D3
		move.b	d7,D2
		lsr.w	D2,D1
		or.w	D1,d6

		add.b	D0,d7
		cmpi.b	#8,d7
		bcs.b	PutCode2

		move.w	d6,D0
		lsr.w	#8,D0
		putc	d0

		subq.b	#8,d7
		cmpi.b	#8,d7
		bcs.b	PutCode1

		putc	d6

		subq.b	#8,d7

		move.w	D3,D0
		move.b	D4,D1
		sub.b	d7,D1
		lsl.w	D1,D0
		move.w	D0,d6
		bra.b	PutCode2

PutCode1:
		move.w	d6,D0
		lsl.w	#8,D0
		move.w	D0,d6

PutCode2:
		move.w  (sp)+,D3
		move.w	(sp)+,D4
		endm

reconst:movem.l D0-A6,-(SP)
		lea		hfreq,A0
		lea		prnt-hfreq(a0),A1
		lea		son-hfreq(a0),A2
		bra.b	rcon_a

rcon:	movem.l D0-A6,-(SP)
rcon_a: moveq	#0,D0
		moveq	#0,D1
; Collect leaf nodes in the first half of the table
; and relace the hfreq by (hfreq+1)/2
rcon1:	cmpi.w	#2*T,0(A2,D1.w) ; if son[i] >= T
		blt.b	rcon2
		moveq	#1,D2
		add.w	0(A0,D1.w),D2
		lsr.w	#1,D2
		move.w	D2,0(A0,D0.w)	; hfreq[j] = (hfreq[i]+1)/2
		move.w	0(A2,D1.w),0(A2,D0.w) ; son[j]=son[i]
		addq.w	#2,D0		; j++
rcon2:		addq.w	#2,D1		; i++
		cmp.w	#2*T,D1 	; i < T
		blo.b	rcon1

; begin constructing tree by connecting sons
; for (i=0; j=N_CHAR; j < T; i+=2; j++) {

		move.w	#N_CHAR*2,D3
		moveq	#0,D4
rcon3:		moveq	#2,D0
		add.w	D4,D0		;		k=i+2
		move.w	0(A0,D4.w),D6
		add.w	0(A0,D0.w),D6	; f=hfreq[i]+hfreq[k]
		move.w	D6,0(A0,D3.w)	; hfreq[j]=f
; for (k=j-1; f < hfreq[k]; k--);
		moveq	#-2,D5
		add.w	D3,D5
		bra.b	rcon5
rcon4:		subq.w	#2,D5
rcon5:		cmp.w	0(A0,D5.w),D6
		blo.b	rcon4

		addq.w	#2,D5
		move.w	D3,D7
		sub.w	D5,D7		; l=(j-k) * 2

		lea	0(A0,D5.w),A3
		bsr.b	movemem 	;nach oben schieben
		move.w	D6,0(A0,D5.w)	; hfreq[k]= f

		lea	0(A2,D5.w),A3
		bsr.b	movemem

		move.w	D4,0(A2,D5.w)	; son[k] = i

		addq.w	#4,D4		; i+=2
		addq.w	#2,D3		; j++
		cmp.w	#2*T,D3
		blo.b	rcon3

; connect prnt
; for (i=0; i<T; i++) {
		moveq	#0,D0
rcon6:		move.w	0(A2,D0.w),D1
		move.w	D0,0(A1,D1.w)
		cmp.w	#2*T,D1
		blt.b	rcon7		; if ((k=son[j]) >= T) {
		move.w	D0,0(A1,D1.w)	; prnt[k] = i
		bra.b	rcon8
rcon7:		move.w	D0,0(A1,D1.w)	; prnt[k] = i
		move.w	D0,2(A1,D1.w)	; prnt[k+1] = i;
rcon8:		addq.w	#2,D0
		cmp.w	#2*T,D0
		blo.b	rcon6
		movem.l (SP)+,D0-A6
		rts

movemem:	adda.w	D7,A3
		lea	2(A3),A4
		move.w	D7,D0
		bra.b	movemem2
movemem1:	move.w	-(A3),-(A4)
		subq.w	#2,D0
movemem2:	bne.b	movemem1
		rts
; -----------------------------------------------------------------------
;		update
; -----------------------------------------------------------------------


; void update(int c);
; register int i,j,k,l;
; register D3 = c
; register D1 = k
; register D2 = l
; register A1 = son

; register D5 = cardinal c
; a4 = hfreq[c]

;uses: d0,d1,d2,d5
;	   a0,a1,a2,a3,a4,a6
; expects:	 a2 = hfreq		d2 = 2*T
;		   a4 = son
		macro	update
		local	upd_1
		local	upd_2
		local	upd_2a
		local	upd_2b
		local	upd_3
		local	upd_4
		local	upd_5
		local	upd_6
		local	updx
		local	updx1
		local	updrecon

		tst.w	R*2(A2)  ; if hfreq[R] == MAX_FREQ
		bmi		updrecon

upd_1:	lea	prnt-hfreq(a2),A0	 ; A0 = prnt

		move.w	0(a0,d0.w),d0
; do {
		lea	0(A2,d0.w),A1	; A1 = hfreq[c]
		addq.w	#1,(A1) 	; hfreq[c]++

; Ab hier: l=d5
; if the order is disturbed, exchange nodes
		cmpm.w	(A1)+,(a1)+	; if k>hfreq[l=c+1])
		bcs.b	upd_2b

upd_2a: 	move.w	0(a0,d0.w),d0
		beq.b	updx
; do {
upd_2:		lea	0(A2,d0.w),A1	; A1 = hfreq[c]
		addq.w	#1,(A1) 	; hfreq[c]++

; Ab hier: l=d5
; if the order is disturbed, exchange nodes
		cmpm.w	(A1)+,(a1)+	; if k>hfreq[l=c+1])
		bcc.b	upd_2a

; while k > hfreq[++l]
upd_2b: 	subq.w	#1,-4(a1)
		move.w	-4(a1),d1
upd_3:		cmp.w	(a1)+,D1
		beq.b	upd_3		; while (k>hfreq[++l]);
		subq.l	#4,a1
		addq.w	#1,(a1)

		sub.l	A2,a1

		move.w	0(a4,d0.w),d4	; i=son[c]
		move.w	a1,(a0,d4.w)	;prnt[i]=l

		cmp.w	d2,d4			; if i<T
		bge.b	upd_4
		move.w	a1,2(A0,d4.w)	; prnt[i+1]=l

upd_4:		move.w	0(A4,a1.w),D1		   ; j=son[l]
		move.w	d4,0(A4,a1.w)	    ; son[l]=j

		move.w	d0,(A0,d1.w)	; prnt[j] = c

		cmp.w	d2,D1			; if j<T
		bge.b	upd_5
		move.w	d0,2(A0,d1.w)	; prnt[j+1]=c

upd_5:		move.w	D1,0(a4,d0.w)	; son[c]=j
		move.w	a1,d0
upd_6:		move.w	0(a0,d0.w),d0
		beq.b	updx1
; do {
		lea	0(A2,d0.w),A1	; A1 = hfreq[c]
		addq.w	#1,(A1) 	; hfreq[c]++
;		 move.w	(A1)+,D1	  ; k=hfreq[c]

; Ab hier: l=d5
; if the order is disturbed, exchange nodes
		cmp.w	(A1)+,(a1)+	; if k>hfreq[l=c+1])
		bcc.b	upd_6
		bra.b	upd_2b
; while k > hfreq[++l]
updrecon:	bsr	reconst
		bra	upd_1
updx1:
updx:
		endm

; -----------------------------------------------------------------------
;		 EncodeChar
; -----------------------------------------------------------------------

; void EncodeChar(unsigned c);
; register unsigned i;
; register int j,k;
; D5 = c
; D3 = i
; d4 = j
; d0 = k
		macro	EncodeCh
		local	Enchar1
		local	Enchar2
		local	Enchar3
		local	Enchar4
		local	Enchar5
		local	Enchar6
		move.w	d5,-(SP)
		move.w	#2*R,d2
		move.w	D0,D5		; c
		moveq	#0,D1		;i=0
		move.l	d1,a1		;j=0
		moveq	#0,d4		;shift=0
		lea		prnt,A0
		add.w	#T,D0		; T
		add.w	D0,D0
		move.w	0(A0,D0.w),D0	; k=prnt[c+T]
; while
; if (k & 1) i +=0x8000
Enchar1:	addq.w	#1,d4
		btst	#1,D0
		beq.b	Enchar2
		lsr.w	d4,d1
		add.w	d4,a1
		moveq	#0,d4
		add.w	#$8000,d1
Enchar2:	move.w	0(A0,D0.w),D0	; k=prnt[k]
		cmp.w	d2,D0			; R
		bne.b	Enchar1

; putcode(j,i)
Enchar5:add.w	d4,a1
		move.w	a1,D0
		lsr.w	d4,d1
		lea		hfreq,a2
		putcode
; update(c)
		move.w	D5,D0
		add.w	D0,D0
		lea		hfreq,a2
		lea		son-hfreq(A2),a4
		move.w	#2*T,D2
		add.w	d2,d0
		update
		move.w	(SP)+,D5
		endm

; void EncodePosition(unsigned c)
; register unsigned i;

		macro	EncodePo
		move.w	D0,d4

		lsr.w	#6,D0
		move.w	D0,D2		; i = c >> 6

		lea		p_code(pc),A0
		moveq	#0,D1
		move.b	0(A0,D2.w),D1
		lsl.w	#8,D1		; p_code[i] << 8

;		 lea	 p_len,A1
		moveq	#0,D0
		move.b	p_len-p_code(A0,D2.w),D0	; p_len[i]
		putcode 		; putcode(p_len[i],p_code[i] <<8)

		moveq	#$3F,D1
		and.w	d4,D1
		moveq	#$0A,D0
		lsl.w	D0,D1
		moveq	#6,D0
		putcode
		endm

; void DeleteNode(int p);		D5 = P
; register int q;

; register D5 = p	; D4 = cardinal p
; register D1 = q	; D2 = cardinal q
; register D3 = temp

; register A0 = dad
; register A2 = rson
; register A3 = lson
; register A4 = *rson[p]
; register A5 = *lson[p]


; WARNING: THE FOLLOWING REGISTERS MUST BE DEFINED:
;
; A2 = lson
; A3 = rson
; a4 = dad
; A5 = text_buf

		macro	DeleteNo
		local	DNode_1
		local	DNode_2
		local	DNode_3
		local	DNode_4
		local	DNode_5
		local	DNode_6
		local	DNode_7
		local	DNode_8
		local	DNode_9
		local	DNodex1
		local	DNodex2
		move.w	#2*NIL,D7
		cmp.w	0(a4,d5.w),d7	; if dad[p] == NIL
		beq.b	DNode_9 		;	 return
		cmp.w	0(A3,d5.w),d7	; if rson[p] == NIL
		beq.b	DNodex1
		move.w	0(a2,d5.w),d2
		cmp.w	d2,d7			; if lson[p] == NIL
		beq.b	DNodex2
DNode_2:
		move.w	0(a3,d2.w),d1
		cmp.w	d1,d7
		beq.b	DNode_5
; do { q=rson[q] } while (rson[q] != NIL}
DNode_3:
		move.w d2,d1
		move.w	0(A3,D2.w),D2
		cmp.w	D7,D2
		bne.b	DNode_3
		move.w	d1,d2
DNode_4:
; d2 = q	|  d5 = p	 |  d1/d0 = temp |
; a2 = lson |  a3 = rson |	a4	  = dad	|

		move.w	0(a2,d2.w),d0		; lson[q]
		move.w	0(a4,d2.w),d1		; dad[q]
		move.w	d0,0(a3,d1.w)		; rson[dad[q]]=lson[q]
		move.w	d1,0(a4,d0.w)		; dad[lson[q]]=dad[q]
		move.w	0(a2,d5.w),d1		; lson[p]
		move.w	d1,0(a2,d2.w)		; lson[q]=lson[p]
		move.w	d2,0(a4,d1.w)		; dad[lson[p]]=q

DNode_5:
		move.w	(a3,d5.w),d0
		move.w	d0,0(A3,D2.w)		; rson[q] = rson[p]
		move.w	D2,0(A4,d0.w)		; dad[rson[p]] = q
DNode_6:
		move.w	0(a4,d5.w),d0		; dad[p]
		move.w	d0,0(A4,D2.w) 		; dad[q]=dad[p]

		cmp.w	0(A3,d0.w),D5
		bne.b	DNode_7 			; if rson[dad[p]]=p
; else ..
		move.w	D2,0(A3,d0.w)		; rson[dad[p]]=q
		bra.b	DNode_8
DNodex1:
		move.w	0(a2,d5.w),d2		; q=lson[p]
		bra.b	DNode_6
DNodex2:
		move.w	0(a3,d5.w),d2		; q=rson[p]
		bra.b	DNode_6
DNode_7:move.w	D2,0(A2,d0.w)		; lson[dad[p]]=q
DNode_8:move.w	D7,0(a4,d5.w)
DNode_9:
		endm

; -----------------------------------------------------------------------
;		InsertNode
; -----------------------------------------------------------------------

; void InsertNode(int r);
; rester int i,p,cmp;
; unsigned char *key;
; unigned c;

; register D1 = cmp
; register D2 = p
; register A1 = *key
; register a2 = rson
; register A3 = lson

; WARNING: THE FOLLOWING REGISTERS MUST BE DEFINED:
;
; A2 = lson
; A3 = rson
; A4 = dad


		macro	InsertNo
		local	INode_1
		local	INode_1a
		local	INode_2
		local	INode_3
		local	INode_3a
		local	INode_4
		local	INode_6
		local	INode_6e1
		local	INode_6odd
		local	INode_7
		local	INode_8
		local	INode_9
		local	INode_10
		local	INode_11
		local	INode_12
		local	INode_14
		local	Encode_L1
		movem.l a6/d3,-(sp)

		move.w	d6,d1
		lea	0(A5,D1.w),A1	; key=&text_buf[r]

		move.w	(A1)+,D2	; key[0]
		add.w	#N+1,D2 	; p= N+1+key[0]
		add.w	D2,D2		; cardinal
		move.w	#2*NIL,d3
		move.w	d3,0(A2,D1.w)	; rson[r] = NIL
		move.w	d3,0(A3,D1.w)	; lson[r] = NIL

; for ...
;		move.l	dad(pc),A4
INode_1a:	move.w	d2,a6
		move.w	0(A3,D2.w),d2	; rson[p]
		cmp.w	d3,d2		; if rson[p] != NIL
		bne.b	INode_6 	; p=rson[p] else

INode_2:	move.w	a6,d2
		move.w	D1,0(a3,d2.w)	; rson[p] = r
		move.w	D2,0(A4,D1.w)	; dad[r] = p
		bra	INode_14

INode_4:	move.w	a6,d2
		move.w	D1,0(a2,d2.w)	; lson[p] = r
		move.w	D2,0(A4,D1.w)	; dad[r] = p
		bra	INode_14
INode_3a:	bge.b	INode_1a
INode_3:	move.w	d2,a6
		move.w	0(A2,D2.w),d2	; d2=lson[p]
		cmp.w	d3,d2		; if lson[p] != NIL
		beq.b	INode_4

; for (i=1; i<F; i++)
INode_6:	move.l	a1,A0		; key[1] (Siehe oben (a0)+)
		lea	2(A5,D2.w),A6	; text_buf[p+1]
		cmpm.w	(a0)+,(a6)+	; this saves MUTCH time
		bne.b	INode_3a	; and also (why?) some bytes
		cmpm.l	(a0)+,(a6)+
		bne.b	INode_3a

		rept	20
		cmpm.l	(a0)+,(a6)+
		bne.b	INode_8
		endm
		moveq	#7,D0
INode_7:	cmpm.l	(A0)+,(A6)+
		dbne	D0,INode_7

INode_8:	beq.b	INode_10
		bhi.b	INode_3
		move.w	d2,a6
		move.w	0(A3,D2.w),d2	; rson[p]
		cmp.w	d3,d2		; if rson[p] != NIL
		bne.b	INode_6 	; p=rson[p] else

		move.w	a6,d2
		move.w	D1,0(a3,d2.w)	; rson[p] = r
		move.w	D2,0(A4,D1.w)	; dad[r] = p
		bra	INode_14
Encode_L1:	move.w	D1,0(A3,d0.w)
		move.w	d3,0(a4,d2.w)	; dad[p] = NIL
		bra.b	INode_14
;  break
INode_10:	; d2 = p	 a2 = lson	 a4 = dad
		; d1 = r	 a3 = rson
		move.w	0(a2,d2.w),d0		; d0 = lson[p]
		move.w	d1,0(a4,d0.w)		;	dad[lson[p]]=r
		move.w	d0,0(a2,d1.w)		;	lson[r]=lson[p]
		move.w	0(a3,d2.w),d0		; d0=rson[p]
		move.w	d1,0(a4,d0.w)		;	dad[rson[p]]=r
		move.w	d0,0(a3,d1.w)		;	rson[r]=rson[p]
		move.w	0(a4,d2.w),d0		; dad[r]=dad[p]
		move.w	d0,(a4,d1.w)
		cmp.w	0(A3,d0.w),D2
		beq.b	Encode_L1
		move.w	D1,0(A2,D0.w)		; lson[dad[p]] = r
INode_12:	move.w	d3,0(a4,d2.w)		; dad[p] = NIL
INode_14:
		movem.l (sp)+,a6/d3
		endm

		macro	MatchInsertNo
		local	INode_1
		local	INode_1a
		local	INode_2
		local	INode_3
		local	INode_3a
		local	INode_4
		local	INode_6
		local	INode_7
		local	INode_8
		local	INode_9
		local	INode_9a
		local	INode_10
		local	INode_12
		local	INode_14
		local	Encode_L1
		pea		(a6)
		movem.w D3-D5,-(SP)
		moveq	#1,D1		; cmp=1
		move.w	#2*NIL,d5
;		 add.w	 D6,D6
		lea	0(A5,D6.w),A1	; key=&text_buf[r]

		move.w	(A1)+,D2	; key[0]
		add.w	#N+1,D2 	; p= N+1+key[0]
		add.w	D2,D2		; cardinal

		move.w	D5,0(A2,D6.w)	; rson[r] = NIL
		move.w	D5,0(A3,D6.w)	; lson[r] = NIL

; match_position=d7
; match_length=d0
		moveq	#0,d0		; match_length=0
;		 clr.w	 match_length-lson(a2)	  ; match_length=0
; for ...
;		move.l  dad(pc),A4
INode_1:	tst.b	D1		; if (cmp > 0) {
		blt.b	INode_3
INode_1a:	move.w	d2,a6
		move.w	0(A3,D2.w),d2	; rson[p]
		cmp.w	d5,d2		; if rson[p] != NIL
		bne.b	INode_6 	; p=rson[p] else

INode_2:	move.w	a6,d2
		move.w	D6,0(a3,d2.w)	; rson[p] = r
		move.w	D2,0(A4,D6.w)	; dad[r] = p
		bra	INode_14

INode_4:	move.w	a6,d2
		move.w	D6,0(a2,d2.w)	; lson[p] = r
		move.w	D2,0(A4,D6.w)	; dad[r] = p
		bra	INode_14
INode_3a:	bge.b	INode_1a
INode_3:	move.w	d2,a6
		move.w	0(A2,D2.w),d2	; d7=lson[p]
		cmp.w	d5,d2		; if lson[p] != NIL
		beq.b	INode_4

; for (i=1; i<F; i++)
INode_6:	move.l	a1,A0		; key[1] (Siehe oben (a0)+)
		lea	2(A5,D2.w),A6	; text_buf[p+1]
		cmpm.l	(a0)+,(a6)+	; this saves MUTCH time
		bne.b	INode_3a	; and also (why?) some bytes
		cmpm.w	(a0)+,(a6)+
		bne.b	INode_3a
		moveq	#F-5,D3
INode_7:	cmpm.w	(A0)+,(A6)+
		dbne	D3,INode_7

INode_8:	beq	INode_9a
		shi	d1		; cmp=key[i]-text_buf[p+1]
		not	d3
		add.w	#F,d3

		cmp.w	d0,D3		; if i>match_length
		ble.b	INode_1
INode_9:	move.w	D6,D7
		sub.w	D2,D7		; r-p
		and.w	#2*$0FFF,D7	  ; (r-p) & (N-1)
		subq.w	#2,D7		; ((r-p) & (N-1)) -1 = match_pos

		move.w	D3,d0		; match_length=i
		tst.b	D1		; if (cmp > 0) {
		blt	INode_3
		move.w	d2,a6
		move.w	0(A3,D2.w),d2	; rson[p]
		cmp.w	d5,d2		; if rson[p] != NIL
		bne.b	INode_6 	; p=rson[p] else

		move.w	a6,d2
		move.w	D6,0(a3,d2.w)	; rson[p] = r
		move.w	D2,0(A4,D6.w)	; dad[r] = p
		bra	INode_14
INode_9a:	not	d3
		add.w	#F,d3
		move.w	D6,D7
		sub.w	D2,D7		; r-p
		and.w	#2*$0FFF,D7	  ; (r-p) & (N-1)
		subq.w	#2,D7		; ((r-p) & (N-1)) -1 = match_pos

		move.w	D3,d0		; match_length=i
;  break
INode_10:
		move.w	0(a2,d2.w),d4		; d4 = lson[p]
		move.w	d6,0(a4,d4.w)		;	dad[lson[p]]=r
		move.w	d4,0(a2,d6.w)		;	lson[r]=lson[p]
		move.w	0(a3,d2.w),d4		; d4=rson[p]
		move.w	d6,0(a4,d4.w)		;	dad[rson[p]]=r
		move.w	d4,0(a3,d6.w)		;	rson[r]=rson[p]
		move.w	0(a4,d2.w),d4
		move.w	d4,0(a4,d6.w)		; dad[r]=dad[p]

		cmp.w	0(A3,D4.w),D2
		beq.b	Encode_L1

		move.w	D6,0(A2,D4.w)	; lson[dad[p]] = r

INode_12:
		move.w	d5,0(a4,d2.w)	; dad[p] = NIL
		bra.b	INode_14
Encode_L1:
		move.w	D6,0(A3,D4.w)
		move.w	d5,0(a4,d2.w)	; dad[p] = NIL
INode_14:
		move.w	d0,match_length
		move.w	d7,match_position
		move.w  (sp)+,d3
		move.w	(sp)+,d4
		move.w	(sp)+,d5
		move.l	(sp)+,a6
		endm

; -----------------------------------------------------------------------
;		StartHuff
; -----------------------------------------------------------------------


StartHuf:
		movem.l D3-D4/A2-A3,-(SP)
		lea		hfreq,A0
		movea.l A0,A1		; freqp=hfreq
		lea		son,A2		; sonp=son
		lea		2*T+prnt,A3	; prnpt=&prntp[T]
; for(i=0; i<N_CHAR; i++) {
		move.w	#2*T,D1 	; iT=T
		moveq	#0,D4
		moveq	#0,D0		   ; i=0
		bra.b	SHuff2
SHuff1: move.w	#1,(A1)+	; *hfreq++=1
		move.w	D1,(A2)+	; *sonp++=iT++
		addq.w	#2,D1
		move.w	D4,(A3)+	; *prntp++=i;
		addq.w	#1,D0
		addq.w	#2,D4
SHuff2: cmp.w	#$013A,D0
		blt.b	SHuff1
; }
		moveq	#0,D0		   ; i=0
		move.w	#N_CHAR*2,D4
		move.w	#N_CHAR,D1	; j=N_CHAR
		movea.l A0,A1		;freqp=hfreq
		lea		2*N_CHAR+son,A2 ; sonp=&son[N_CHAR]
		lea		prnt,A3 	; prntp=prnt
; while (j<=R) {
		bra.b	SHuff4
SHuff3: move.w	(A1)+,D2
		add.w	(A1)+,D2
		move.w	D1,D3
		add.w	D3,D3
		move.w	D2,0(A0,D3.w)	; hfreq[j] = *freqp++ + *freqp++
		move.w	D0,(A2)+	; *sonp++=i
		move.w	D4,(A3)+	; *prntp++=j
		move.w	D4,(A3)+	; *prntp++=j
		addq.w	#4,D0		; i+=2
		addq.w	#1,D1		; j+=1
		addq.w	#2,D4
SHuff4: cmp.w	#R,D1
		ble.b	SHuff3
; }
		move.w	#$FFFF,$04E6(A0) ;hfreq[T]=0xffff
		clr.w	2*R+prnt	; prnt[R]=0
		movem.l (SP)+,D3-D4/A2-A3
		rts

; -----------------------------------------------------------------------
;		Encode
; -----------------------------------------------------------------------

; void Encode(void);
; register int i,r,s,c;
; register int len,last_match_length
; long printcount,printsize;

; register D4 = c
; register D5 = s
; register D6 = r
; register A2 = *textsize
; 4(sp) = printcount;
Encode: movem.l D3-D7/A2-A6,-(SP)
		lea		-$0A(SP),SP

		clr.w	match_position
		clr.w	match_length

		move.l	lson(pc),A2
		move.l	rson(pc),A3
		move.l	dad(pc),A4

		move.l	textsize(pc),D0
		beq		enc_23		; if (textsize==0) return

		lea		text_buf,A5
		moveq	#0,D1
		move.b	D1,putlen	; putlen=0
		moveq	#0,D2
		move.b	D1,D2
		move.w	D2,putbuf	; putbuf=0
; printcount=textsize < blocksize ? textsize : blocksize
		move.l	D0,(SP)
		cmp.l	blocksize(pc),D0
		bge.b	enc_1
		bra.b	enc_2
enc_1:	move.l	blocksize(pc),D0
enc_2:	move.l	D0,4(SP)
		clr.l	textsize			   ; textsize=0

		bsr		StartHuf
		jsr		InitTree
		moveq	#0,D5		; s=0
		move.w	#N-F,D6 	; r=N-F

; for(i=s; i<r;i++)
		move.w	D5,D7
		movem.l D0/A5,-(SP)
		add.w	d7,d7
		lea		0(A5,D7.w),A5
		lsr.w	#1,d7
		move.w	D6,D0
		sub.w	D7,D0
		sub.w	#1,D0
enc_4:	move.w	#$20,(A5)+	; textbuf[i]=' '
		dbra	D0,enc_4
		movem.l (SP)+,D0/A5

; for(len=0;len<F && (c=crc_getc(file3)) != EOF; len++)
		moveq	#0,D3
		pea		(a5)
		add.w	d6,d6
		lea		0(A5,D6.w),A5
		lsr.w	#1,d6
		bra.b	enc_6
enc_5:	addq.l	#1,a5
		move.b	D4,(A5)+	; text_buf[r+len]=c
		addq.w	#1,D3		; len++
enc_6:	cmp.w	#F,D3
		bge.b	enc_7
		getc
		bne.b	enc_7		; Ist EOF
		crcgetc 		; c=crc_getc(file3)
		move.w	D0,D4
		bra.b	enc_5
; end for
enc_7:	movea.l (SP)+,A5
		move.w	D3,D0
		ext.l	D0
		move.l	D0,textsize		   ; textsize=len

; for(i=1; i<=F; i++)
		moveq	#F-1,D7
		move.w	D6,-(SP)
		subq.w	#1,D6
enc_8:	add.w	d6,d6
		InsertNo	; InsertNode(r-i)		  ***
		lsr.w	d6
		subq.w	#1,D6
enc_9:	dbra	D7,enc_8
		move.w	(SP)+,D6
		add.w	d6,d6
		MatchInsertNo		  ; InsertNode(r)		   ***
		add.w	d5,d5
enc_10: lea		match_length(pc),A6

		cmp.w	(A6),D3
		bge.b	enc_11		; if (match_length > len)
		move.w	D3,(A6) 	;	match_length=len
enc_11: move.b	putlen(pc),d7
		move.w	d6,d1
		move.w	d6,-(sp)
		move.w	putbuf(pc),d6
		cmpi.w	#2,(A6)
		bgt		enc_12		; if match_length <=THRESHOLD
		move.w	#1,(A6) 	;	match_length=1
		moveq	#0,D0
		move.w	(A5,D1.w),D0
		EncodeCh	; EncodeChar(text_buf[r])
		bra		enc_13
enc_12: move.w	(A6),D0
		add.w	#$FD,D0
		EncodeCh	; EncodeChar(255-THRESHOLD+match_length)
		move.w	match_position(pc),D0
		lsr.w	#1,d0
		EncodePo	; EncodePosition(match_position)
enc_13: move.b	d7,putlen
		move.w	d6,putbuf
		move.w	(sp)+,d6
		move.l	lson(pc),a2
		move.l	dad(pc),a4
; for(i=0;i<last_match_length && (c=crc_getc(file3))!= EOF;i++)
		move.w	(a6),D0

		moveq.l #0,d4
		move.w	D0,D4
		add.l	D4,textsize
		lea		2*N(A5),A6
		dbra	d4,enc_14
enc_14a:subq.w	#1,d3
		bra		enc_15
enc_14b:InsertNo
enc_14: DeleteNo		; DeleteNode(s)
		move.w	#2*$fff,d7
		getc
		bne		enc_14a 	; Ist EOF
		crcgetc 		; c=crc_getc(file3)
		move.w	d0,0(A5,D5.w)	; text_buf[s]=c;
		cmp.w	#2*(F-1),D5
		bge.b	enc_15		; if (s<F-1)
		move.w	d0,0(A6,D5.w)	; text_buf[s+N]=c;
enc_15:
		addq.w	#2,D5
		and.w	d7,D5
		addq.w	#2,D6
		and.w	d7,D6
enc_16: dbra	d4,enc_14b
		MatchInsertNo
; end for
; if ((textsize +=i) >= printcount && i>0)
enc_17: tst.w	d3
		beq.b	enc_22

		move.l	textsize(pc),D1
		cmp.l	4(SP),D1
		blt		enc_10

		jsr		ProcInd
enc_18:	move.l	blocksize(pc),d0
		add.l	d0,4(SP)	; printcount+=blocksize
		move.l	4(SP),D0
		cmp.l	(SP),D0
		ble		enc_10		; if (printcount>printsize)
		move.l	(SP),4(SP)	;	printcount=printsize
		bra		enc_10		; while(len>0)

enc_22: move.b	putlen,d0
		beq.b	enc_23

		move.w	putbuf,d0
		lsr.w	#8,d0
		putc	d0

enc_23:	bsr		shipout
		lea		$0A(SP),SP
		movem.l (SP)+,D3-D7/A2-A6
		rts

;**************************************************************************
;**		Stuff for use with Decode				 **
;**************************************************************************

; -----------------------------------------------------------------------
;		DecodeChar
;  this is mixed with GetBit !
; -----------------------------------------------------------------------

		macro	DecodeCh
		local	GBit
		local	GBit1
		local	GBit2
		local	GBit4
		local	GBit5
		local	DeC3
		local	DeC4
		local	DeC2
		move.w	2*R(A4),D1	; C = son[R]
		move.l	#2*T,d2
		cmp.w	d2,D1		;  while c < T
		bcc.b	DeC3

GBit:	dbra	d6,GBit4	; keine Bits mehr da ?
		movea.l file1(pc),A0
		getw
		moveq	#15,d6

GBit4:	add.w	d7,d7		; getbuf << 1 & if (getbuf>0)
		bge.b	GBit5
		addq.w	#2,d1		; c+=getbit()
GBit5:					; getlen--
		move.w	0(A4,D1.w),D1	; c=son[c]

DeC2:	cmp.w	d2,D1		;  while c < T
		bcs.b	GBit
DeC3:	move.w	d1,d0
		sub.w	d2,D1		; C -= T
		swap	d1

		update
		swap	d1
		move.w	d1,d0
		lsr.w	D0	 	; Ausgleich fr Arrays
		endm


; -----------------------------------------------------------------------
;		DecodePosition
; -----------------------------------------------------------------------

		macro	DecodePo
		local	Dpos1
		local	Dpos2
		local	Dpos3
		local	D1Pos1
		local	D1Pos2
		local	Dnpos
		local	GetBit1
		local	GetBit2
		local	GetBit4
		local	GetBit5
		local	GetByte1
		local	GetByte2
		local	GetByte3
		local	GetByte4
		local	x
		moveq	#8,d4
; while getlen<=8 {
		cmp.b	d4,d6
		bgt.b	GetByte4
GetByte1:
;	i=rgetc(file1)
		movea.l file1(pc),A0
		rgetc
;	getbuf |= i << 8 - getlen
		move.w	d4,D1;		d4=8
		sub.b	d6,D1
		lsl.w	D1,D0
		or.w	D0,d7
;	getlen+=8
		add.b	d4,d6
GetByte4:
; i=getbuf;
		and.l	#$ffff,d7
		lsl.l	#8,d7
		swap	d7
		sub.w	d4,d6
		lea		d_code(pc),A0
		moveq	#0,D4
		move.b	0(A0,D7.w),D4
		add.l	#d_len-d_code,a0
		moveq	#0,D2
		move.b	0(A0,D7.w),d2
		lsl.w	#6,D4
		swap	d7
		subq.w	#2,d2
Dpos1:	move.w	d6,d6		; <8 bits availale?
		bgt.b	GetBit5 	 ; getlen = 0?
		movea.l file1(pc),A0
		getw
		moveq	#16,d6
GetBit5:move.w	d2,d0
		cmp.w	d6,d0
		blt.b	GetBit6
		move.w	d6,d0
GetBit6:lsl.l	d0,d7
		sub.w	d0,d6
		sub.w	d0,d2
Dpos2:	bne.b	Dpos1		 ; n„chstes bit
		swap	d7
		moveq	#$3f,d0
		and.w	d7,d0
		swap	d7
Dpos3:	or.w	D4,D0
		endm

; -----------------------------------------------------------------------
;		Decode
; -----------------------------------------------------------------------

Decode: movem.l D3-D7/A2-A6,-(SP)
		subq.w	#6,SP
		lea.l	outrec_decode(pc),a0
		move.l	buffer_3,a1
		bsr		OpenOut
; if textsize == 0
;	 return
		move.l	textsize,D0
		beq		Dcode19
; getlen = 0
		moveq	#0,D1
		move.b	D1,d6
; getbuf = 0
		moveq	#0,D2
		move.b	D1,D2
		move.w	D2,d7
; printcount=textsize<blocksize ? textsize | blocksize
		cmp.l	blocksize(pc),D0
		ble.b	Dcode1
		move.l	blocksize(pc),D0
Dcode1:	move.l	D0,(SP)
; StartHuff()
		bsr		StartHuf
; for (i=0; i<N-F;i++)
		moveq	#0,D4
		lea	text_buf,A5
		bra.b	Dcode5
Dcode4:
;	 text_buf[i] = ' '
		move.b	#$20,0(A5,D4.w)
		addq.w	#1,D4
Dcode5:
		cmp.w	#$0FC4,D4
		blt.b	Dcode4
; r = N-F;
		move.w	#$0FC4,D5
; for (count = 0; count < textsize;) {
		lea		crc,A6
		move.w	(A6)+,A3	; A6 -> crctbl
		lea		son-crctbl(a6),a4
		lea		hfreq-crctbl(a6),a2
		clr.l	delen-son(a4)
		bra		Dcode16
Dcode6:
;  c=DecodeCh()
		DecodeCh
;  if (c<256) {
		cmp.w	#$0100,D0
		bge.b	Dcode8
;	   text_buf[r++]=c;
		move.b	D0,0(A5,D5.w)
		addq.w	#1,D5
;		 putc(c)
		lea		outrec_decode(pc),a0
		move.l	(a0),a1
		move.b	d0,(a1)+
		move.l	a1,(a0)
		subq.l	#1,4(a0)
		bpl.b	Dcode7
		bsr		shipout_decode
Dcode7:
;	  setcrc(c)
		move.w	A3,D1
		eor.w	D0,D1
		and.w	#$FF,D1
		add.w	D1,D1
		move.w	A3,D2
		lsr.w	#8,D2
		move.w	0(A6,D1.w),D0
		eor.w	D2,D0
		move.w	D0,A3

;	   r & = (N-1)
		and.w	#$fff,D5
;	    count ++;
		addq.l	#1,delen-son(A4)
; } else {
		bra	Dcode12
Dcode8:
;	  i= (r-DecodePosition()-1) & (N-1)
		move.w	d0,d3
		DecodePo
		move.w	D5,D4
		sub.w	D0,D4
		subq.w	#1,D4
		move.w	#$fff,d2
		and.w	d2,D4

		exg.l	d3,d4
;	  j = c - 255+THRESHOLD
		add.w	#$FF03-1,D4
;	  for (k=0; k<j; k++) {

		exg.l	a3,d6
		addq.l	#1,delen-son(A4)
		ext.l	d4
		add.l	d4,delen-son(a4)
		lea		outrec_decode(pc),a0
		move.l	(a0)+,a1	; len

Dcode9:
;	 c=text_buf[(i+k) & (N-1)]
		and.w	d2,D3
		move.b	0(A5,D3.w),D0
;	 text_buf[r++] = c;
		move.b	D0,0(A5,D5.w)
		addq.w	#1,D5
;	 r &=(N-1)
		and.w	d2,D5
;		   putc(c)
		move.b	d0,(a1)+
		subq.l	#1,(a0)
		bpl.b	Dcode10
; Hier shipout_decode
		move.l	a1,outrec_decode
		bsr		shipout_decode
		lea		outrec_decode(pc),a0
		move.l	(a0)+,a1	; Memory
Dcode10:
;	 setcrc(c)

		move.w	d6,D1
		eor.b	D0,D6
		and.w	#$FF,D6
		add.w	D6,D6
		lsr.w	#8,D1
		move.w	0(A6,D6.w),D6
		eor.w	D1,D6
;	 count++;
;	}
		addq.w	#1,D3

Dcode11:
		dbra	d4,Dcode9
		move.l	a1,outrec_decode
		exg.l	a3,d6
Dcode12:
;	if (count >= printcount) {
		move.l	delen-son(a4),d0
		cmp.l	(SP),d0
		bcs.b	Dcode16a

		jsr		ProcInd
Dcode13:
;	 printcount +=blocksize;
		move.l	blocksize(pc),D0
		add.l	D0,(SP)
;	 if (printcount > textsize)
		move.l	(SP),D1
		cmp.l	textsize(pc),D1
		ble.b	Dcode14
;	printcount = textsize);
		move.l	textsize(pc),(SP)
Dcode14:
;	if (file3 != NULL && ferror(file3))
		move.l	file3(pc),D0
		beq.b	Dcode16
		ferror	D0

Dcode15:bne.b	Dcode17
Dcode16:move.l	delen-son(a4),d0
Dcode16a:
		cmp.l	textsize(pc),D0
		bcs	Dcode6
Dcode17:
		jsr		ProcInd
Dcode18:
;	 if (file3 != NULL && ferror(file3) {
		move.l	file3(pc),D0
		beq.b	Dcode19
		ferror	D0
		beq.b	Dcode19
;		error(WTERR,file3)
		lea.l	pathname,A0
		moveq.l	#WTERR,D0
		moveq.l	#-1,D1
		jmp		error

Dcode19:move.w	a3,-(a6)	; crc
		addq.w	#6,SP
		bsr		shipout_decode
		movem.l (SP)+,D3-D7/A2-A6
		rts

DeleteONode:	movem.l D0-A6,-(SP)
				move.l 	lson(pc),A2
				move.l 	rson(pc),A3
				move.w	D0,D5
				move.w	#2*NIL,D7
				move.l	dad(pc),A0
				add.w	D5,D5
; if dad[p] == NIL
				cmp.w	0(A0,D5.w),D7
				beq.b	DNode_9
; if rson[p] == NIL
				cmp.w	0(A3,D5.w),D7
				beq.b	DNodex1

; if lson[p] == NIL
DNode_1:		cmp.w	0(A2,D5.w),D7
				beq.b	DNodex2

DNode_2:		lea 	0(A2,D5.w),A4	; lson[p]
				lea 	0(A3,D5.w),A5	; rson[p]
				move.w	(A4),D1

				move.w	D1,D2
				cmp.w	0(A3,D2.w),D7
				beq.b	DNode_5
; do { q=rson[q] } while (rson[q] != NIL}

DNode_3:		move.w	0(A3,D2.w),D2
				cmp.w	D7,D2
				beq.b	DNode_4
				move.w	D2,D1
				bra.b	DNode_3

DNode_4:		move.w	D1,D2
				move.w	0(A0,D2.w),D3
				lea 	0(A2,D2.w),A1	; rson[q]
				move.w	(A1),0(A3,D3.w) ; lson[dad[q]] = rson[q]
				move.w	(A1),D3
				move.w	0(A0,D2.w),0(A0,D3.w) ; dad[rson[q]]=dad[q[
				move.w	(A4),D3
				move.w	D3,(A1) 		; rson[q]=rson[p]
				move.w	D1,0(A0,D3.w)
DNode_5:		move.w	(A5),D3
				move.w	D3,0(A3,D2.w)	; rson[q] = rson[p]
				move.w	D1,0(A0,D3.w)	; dad[rson[p]] = q
DNode_6:		move.w	0(A0,D5.w),0(A0,D1.w) ; dad[q]=dad[p]

				lea 	0(A0,D5.w),A5	; A5=*dad[p]
				move.w	(A5),D3 		; D3 = cardinal dad[p]
				cmp.w	0(A3,D3.w),D5
				bne.b	DNode_7 		; if rson[dad[p]]=p
; else ..
				move.w	D1,0(A3,D3.w)	; rson[dad[p]]=q
				move.w	D7,(A5)
				movem.l (SP)+,D0-A6
				rts
; if ..
DNode_7:		move.w	D1,0(A2,D3.w)	; lson[dad[p]]=q
; endif ..
DNode_8:		move.w	D7,(A5) 		; dad[p]=NIL
DNode_9:		movem.l (SP)+,D0-A6
				rts
DNodex2:		move.w	0(A3,D5.w),D1
				bra.b	DNode_6
DNodex1:		move.w	0(A2,D5.w),D1
				bra.b	DNode_6

; void InsertNode(int r);
; rester int i,p,cmp;
; unsigned char *key;
; unigned c;

; register D1 = cmp
; register D2 = p
; register A1 = *key
; register A2 = rson
; register A3 = lson

; D0 = cardinal p

; Ben”tigt: A0 = text_buf
;			A2 = lson
;			A3 = rson
;			A4 = dad

InsertONode:	movem.l D0-A6,-(SP)
				move.l	lson(pc),A2
				move.l 	rson(pc),A3
				lea 	text_buf,a5

				move.w	D0,D6
				moveq	#1,D1			; cmp=1

				lea 	0(A5,D6.w),A1	; key=&text_buf[r]
				add.w	D6,D6

				moveq	#0,D2
				move.b	(A1),D2 		; key[0]
				add.w	#4097,D2		; p= N+1+key[0]
				add.w	D2,D2			; cardinal

				move.w	#2*NIL,D7		; NIL
				move.w	D7,0(A2,D6.w)	; rson[r] = NIL
				move.w	D7,0(A3,D6.w)	; lson[r] = NIL

				clr.w	match_length	; match_length=0
; for ...
				move.l	dad(pc),A4
I_Node1:		tst.w	D1				; if (cmp > 0) {
				blt.b	I_Node4
				lea 	0(A3,D2.w),A6	; rson[p]
				cmp.w	(A6),D7 		; if rson[p] != NIL
				bne.b	I_Node5 		; p=rson[p] else

I_Node2:		move.w	D6,(A6) 		; rson[p] = r
				move.w	D2,0(A4,D6.w)	; dad[r] = p
				bra 	I_Node11

I_Node3:		move.w	D6,(A6) 		; lson[p] = r
				move.w	D2,0(A4,D6.w)	; dad[r] = p
				bra 	I_Node11

I_Node4:		lea 	0(A2,D2.w),A6	; d7=lson[p]
				cmp.w	(A6),D7 		; if lson[p] != NIL
				beq.b	I_Node3

; for (i=1; i<F; i++)
I_Node5:		move.w	(A6),D2
				moveq	#0,D1
				moveq	#FOLD-2,D5
				lea 	1(A1),A0		; key[1]
				lsr.w	#1,D2
				lea 	1(A5,D2.w),A6	; text_buf[p+1]
				add.w	D2,D2
I_Node6:		cmpm.b	(A0)+,(A6)+
				dbne	D5,I_Node6

I_Node7:		moveq	#FOLD-1,D3
				sub.w	D5,D3
				moveq	#0,D5
				move.b	-1(A0),D1
				move.b	-1(A6),D5
				sub.w	D5,D1			; d1=key[i]-text_buf[p+i]

				lea 	match_length,A6
				cmp.w	(A6),D3 		; if i>match_length
				ble.b	I_Node1

				move.w	D2,D4
				lsr.w	#1,D4
				move.w	D4,match_position

				move.w	D3,(A6) 		; match_length=i
				cmp.w	#FOLD,D3		; if i>=F
				blt.b	I_Node1 		; break

I_Node8:		move.w	0(A4,D2.w),0(A4,D6.w) ; dad[r] = dad[p]
				move.w	0(A2,D2.w),0(A2,D6.w) ; lson[r] = lson[p]
				move.w	0(A3,D2.w),0(A3,D6.w) ; rson[r] = rson[p[

				move.w	0(A2,D2.w),D4
				move.w	D6,0(A4,D4.w)	; dad[lson[p]]=r

				move.w	0(A3,D2.w),D4
				move.w	D6,0(A4,D4.w)	; dad[rson[p]]=r

				lea 	0(A4,D2.w),A6
				move.w	(A6),D4 		; a6 = *dat[p]
				cmp.w	0(A3,D4.w),D2
				beq.b	I_Node12

I_Node9:		move.w	(A6),D3
				move.w	D6,0(A2,D3.w)	; lson[dad[p]] = r

I_Node10:		move.w	D7,(A6) 		; dad[p] = NIL
I_Node11:		movem.l (SP)+,D0-A6
				rts

I_Node12:		move.w	D6,0(A3,D4.w)
				move.w	D7,(A6) 		; dad[p] = NIL
				movem.l (SP)+,D0-A6
				rts

putbuf: 	ds.w	1
putlen: 	ds.b	1

			even

file3:		ds.l	1
file1:		ds.l	1
blocksize:	ds.l	1
lson:		ds.l	1
rson:		ds.l	1
dad:		ds.l	1
textsize:	ds.l	1
match_position:
			ds.w	1
match_length:
			ds.w	1
codesize:	ds.l	1

p_len:
	dc.b	$03, $04, $04, $04, $05, $05, $05, $05
	dc.b	$05, $05, $05, $05, $06, $06, $06, $06
	dc.b	$06, $06, $06, $06, $06, $06, $06, $06
	dc.b	$07, $07, $07, $07, $07, $07, $07, $07
	dc.b	$07, $07, $07, $07, $07, $07, $07, $07
	dc.b	$07, $07, $07, $07, $07, $07, $07, $07
	dc.b	$08, $08, $08, $08, $08, $08, $08, $08
	dc.b	$08, $08, $08, $08, $08, $08, $08, $08

p_code:
	dc.b	$00, $20, $30, $40, $50, $58, $60, $68
	dc.b	$70, $78, $80, $88, $90, $94, $98, $9C
	dc.b	$A0, $A4, $A8, $AC, $B0, $B4, $B8, $BC
	dc.b	$C0, $C2, $C4, $C6, $C8, $CA, $CC, $CE
	dc.b	$D0, $D2, $D4, $D6, $D8, $DA, $DC, $DE
	dc.b	$E0, $E2, $E4, $E6, $E8, $EA, $EC, $EE
	dc.b	$F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7
	dc.b	$F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF

d_code:
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00
	dc.b	$00, $00, $00, $00, $00, $00, $00, $00
	dc.b	$01, $01, $01, $01, $01, $01, $01, $01
	dc.b	$01, $01, $01, $01, $01, $01, $01, $01
	dc.b	$02, $02, $02, $02, $02, $02, $02, $02
	dc.b	$02, $02, $02, $02, $02, $02, $02, $02
	dc.b	$03, $03, $03, $03, $03, $03, $03, $03
	dc.b	$03, $03, $03, $03, $03, $03, $03, $03
	dc.b	$04, $04, $04, $04, $04, $04, $04, $04
	dc.b	$05, $05, $05, $05, $05, $05, $05, $05
	dc.b	$06, $06, $06, $06, $06, $06, $06, $06
	dc.b	$07, $07, $07, $07, $07, $07, $07, $07
	dc.b	$08, $08, $08, $08, $08, $08, $08, $08
	dc.b	$09, $09, $09, $09, $09, $09, $09, $09
	dc.b	$0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A
	dc.b	$0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
	dc.b	$0C, $0C, $0C, $0C, $0D, $0D, $0D, $0D
	dc.b	$0E, $0E, $0E, $0E, $0F, $0F, $0F, $0F
	dc.b	$10, $10, $10, $10, $11, $11, $11, $11
	dc.b	$12, $12, $12, $12, $13, $13, $13, $13
	dc.b	$14, $14, $14, $14, $15, $15, $15, $15
	dc.b	$16, $16, $16, $16, $17, $17, $17, $17
	dc.b	$18, $18, $19, $19, $1A, $1A, $1B, $1B
	dc.b	$1C, $1C, $1D, $1D, $1E, $1E, $1F, $1F
	dc.b	$20, $20, $21, $21, $22, $22, $23, $23
	dc.b	$24, $24, $25, $25, $26, $26, $27, $27
	dc.b	$28, $28, $29, $29, $2A, $2A, $2B, $2B
	dc.b	$2C, $2C, $2D, $2D, $2E, $2E, $2F, $2F
	dc.b	$30, $31, $32, $33, $34, $35, $36, $37
	dc.b	$38, $39, $3A, $3B, $3C, $3D, $3E, $3F

d_len:
	dc.b	$03, $03, $03, $03, $03, $03, $03, $03
	dc.b	$03, $03, $03, $03, $03, $03, $03, $03
	dc.b	$03, $03, $03, $03, $03, $03, $03, $03
	dc.b	$03, $03, $03, $03, $03, $03, $03, $03
	dc.b	$04, $04, $04, $04, $04, $04, $04, $04
	dc.b	$04, $04, $04, $04, $04, $04, $04, $04
	dc.b	$04, $04, $04, $04, $04, $04, $04, $04
	dc.b	$04, $04, $04, $04, $04, $04, $04, $04
	dc.b	$04, $04, $04, $04, $04, $04, $04, $04
	dc.b	$04, $04, $04, $04, $04, $04, $04, $04
	dc.b	$05, $05, $05, $05, $05, $05, $05, $05
	dc.b	$05, $05, $05, $05, $05, $05, $05, $05
	dc.b	$05, $05, $05, $05, $05, $05, $05, $05
	dc.b	$05, $05, $05, $05, $05, $05, $05, $05
	dc.b	$05, $05, $05, $05, $05, $05, $05, $05
	dc.b	$05, $05, $05, $05, $05, $05, $05, $05
	dc.b	$05, $05, $05, $05, $05, $05, $05, $05
	dc.b	$05, $05, $05, $05, $05, $05, $05, $05
	dc.b	$06, $06, $06, $06, $06, $06, $06, $06
	dc.b	$06, $06, $06, $06, $06, $06, $06, $06
	dc.b	$06, $06, $06, $06, $06, $06, $06, $06
	dc.b	$06, $06, $06, $06, $06, $06, $06, $06
	dc.b	$06, $06, $06, $06, $06, $06, $06, $06
	dc.b	$06, $06, $06, $06, $06, $06, $06, $06
	dc.b	$07, $07, $07, $07, $07, $07, $07, $07
	dc.b	$07, $07, $07, $07, $07, $07, $07, $07
	dc.b	$07, $07, $07, $07, $07, $07, $07, $07
	dc.b	$07, $07, $07, $07, $07, $07, $07, $07
	dc.b	$07, $07, $07, $07, $07, $07, $07, $07
	dc.b	$07, $07, $07, $07, $07, $07, $07, $07
	dc.b	$08, $08, $08, $08, $08, $08, $08, $08
	dc.b	$08, $08, $08, $08, $08, $08, $08, $08

			bss

crc:		ds.w	1	; Reihenfolge !
crctbl: 	ds.w	256
delen:		ds.l	1
hfreq:		ds.w	T+1
prnt:		ds.w	T+N_CHAR
son:		ds.w	T

			align	16

text_buf:	ds.b	BUFSIZ

			even
			end
