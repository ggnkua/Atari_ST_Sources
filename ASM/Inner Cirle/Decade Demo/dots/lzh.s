		opt	hsym
;
; uncompression routine for LZH files
;
N		equ	4096
F		equ	60
THRESHOLD	equ	2
NIL		equ	N
N_CHAR		equ	(256-THRESHOLD+F)
T		equ	(N_CHAR*2-1)
R		equ	(T-1)
MAX_FREQ	equ	32768
;
; main program starts here
;
main		move.l	main-256+16(pc),a1	;bss start
		lea	d_code(pc),a0
		move.l	a1,(a0)+	;d_code
		lea	256(a1),a1
		move.l	a1,(a0)+	;d_len
		lea	256(a1),a1
		move.l	a1,(a0)+	;freq
		lea	(T+1)*2(a1),a1
		move.l	a1,(a0)+	;son
		lea	T*2(a1),a1
		move.l	a1,(a0)+	;prnt
		lea	(T+N_CHAR)*2(a1),a1
		move.l	a1,(a0)+	;text_buf
		lea	N+F(a1),a1
		move.l	a1,(a0)+	;xoutput
;
; for flash effects
;
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		lea	6(sp),sp
;
; generate bit tables
;
		lea	lzhfile(pc),a0
		move.l	xoutput(pc),a1
		lea	11+4(a0),a2
		move.b	-(a2),d7
		rol.w	#8,d7
		move.b	-(a2),d7
		swap	d7
		move.b	-(a2),d7
		rol.w	#8,d7
		move.b	-(a2),d7
		moveq	#0,d0
		move.b	(a0)+,d0
		lea	1(a0,d0.w),a0
;
; a0 = pointer to LZH data
; a1 = pointer to output
; d7 = number of bytes to unpack
;
		bsr	starthuff
		move.l	d_code(pc),a2
		bsr	gendcode
		move.l	d_len(pc),a2
		bsr	gendlen
		moveq	#$20,d0
		move.w	#N-F-1,d1
		move.l	text_buf(pc),a2
.clrbuf		move.b	d0,(a2)+
		dbra	d1,.clrbuf
		move.w	#N-F,d6
;
; main unpacking loop
; d7 = count
; d6 = R
;
; ** important the packed data must start at an even boundary **
; ** note: that means the filename must be an even length     **
;
		move.l	d7,-(sp)
		move.l	d7,-(sp)
		move.l	#$80000000,d7		;clear bitbuf
unpackloop	not.w	$FFFF8240.w
		bsr	decodechar
		cmp.w	#256,d0
		bge.s	.doposition
		move.b	d0,(a1)+		;output(c)
		move.l	text_buf(pc),a2
		move.b	d0,(a2,d6.w)		;textbuf[r] = c;
		addq.w	#1,d6
		and.w	#N-1,d6
		subq.l	#1,(sp)
		bgt.s	unpackloop		;repeat for rest
		bra	unpackdone
.doposition	move.w	d0,-(sp)
		bsr	decodeposition
		move.w	d6,d1
		sub.w	d0,d1			;r - decodepos() -1
		subq.w	#1,d1
		and.w	#N-1,d1			;i
		move.w	(sp)+,d2
		sub.w	#255,d2			;c - 255 + threshold
		add.w	#THRESHOLD,d2
		moveq	#0,d3			;k=0
		move.l	text_buf(pc),a2
.floop		move.w	d1,d4
		add.w	d3,d4			;(i+k) & (N-1)
		and.w	#N-1,d4
		move.b	0(a2,d4.w),d0		;c = textbuf[]
		move.b	d0,(a1)+
		move.b	d0,0(a2,d6.w)
		addq.w	#1,d6			;r++
		and.w	#N-1,d6
		subq.l	#1,(sp)
		addq.w	#1,d3
		cmp.w	d2,d3
		bcs.s	.floop
		tst.l	(sp)
		bgt	unpackloop
unpackdone	move.l	(sp)+,d7
		move.l	(sp)+,d7		;length
		clr.l	d0
		move.l	xoutput(pc),a0
.sumloop	add.l	(a0)+,d0
		subq.l	#4,d7
		bgt.s	.sumloop
		illegal
;
; generate d_code lookup table
; a2 = destination
;
gendcode	lea	.gtab(pc),a3
		moveq	#0,d0
		moveq	#32,d1
		move.w	(a3)+,d2
.outer		move.w	d1,d3
		subq.w	#1,d3
.inner		move.b	d0,(a2)+
		dbra	d3,.inner
		addq.w	#1,d0
		dbra	d2,.outer
		asr.w	#1,d1
		move.w	(a3)+,d2
		bpl.s	.outer
		rts
.gtab		dc.w	1-1,3-1,8-1,12-1,24-1,16-1,-1
;
; generate d_len lookup table
; a2 = destination
;
gendlen		lea	.gtab(pc),a3
		moveq	#3,d0
		move.w	(a3)+,d1
.loop		move.b	d0,(a2)+
		dbra	d1,.loop
		addq.w	#1,d0
		move.w	(a3)+,d1
		bpl.s	.loop
		rts
.gtab		dc.w	32-1,48-1,64-1,48-1,48-1,16-1,-1
;
; read a single bit from the packed data
;
getbit		add.l	d7,d7
		bne.s	.notzero
		move.l	(a0)+,d7
		addx.l	d7,d7
.notzero	rts
;
; get eight bits of data
;
getbyte		clr.w	d0
		rept	8
		bsr.s	getbit
		addx.b	d0,d0
		endr
		rts
;
; start huffman code
;
starthuff	moveq	#0,d0
		move.l	freq(pc),a2
		move.l	son(pc),a3
		move.l	prnt(pc),a4
.loop		move.w	#1,(a2)+	;freq[i]=1
		move.w	d0,d1
		add.w	#T,d1
		move.w	d1,(a3)+	;son[i]=T+i
		add.w	d1,d1
		move.w	d0,0(a4,d1.w)	;prnt[i+T]=i
		addq.w	#1,d0
		cmp.w	#N_CHAR,d0
		blt.s	.loop
		moveq	#0,d0		;i=0
		move.w	#N_CHAR,d1	;j=n_char
		move.l	freq(pc),a2
		move.l	son(pc),a3
;		cmp.w	#R,d1
;		bgt.s	.wover
.wloop		move.w	d0,d2
		add.w	d2,d2		;(i*2) coz words
		move.w	0(a2,d2.w),d3
		add.w	2(a2,d2.w),d3	;freq[i]+freq[i+1]
		move.w	d1,d2
		add.w	d2,d2
		move.w	d3,0(a2,d2.w)
		move.w	d0,0(a3,d2.w)	;son[j]=i
		move.w	d0,d2
		add.w	d2,d2
		move.w	d1,0(a4,d2.w)	;prnt[i]=j
		move.w	d1,2(a4,d2.w)	;prnt[i+1]=j
		addq.w	#2,d0
		addq.w	#1,d1		;j++
		cmp.w	#R,d1
		ble	.wloop
.wover		move.l	freq(pc),a2
		move.w	#-1,T*2(a2)
		move.l	prnt(pc),a2
		move.w	#0,R*2(a2)
		rts
;
; decode character
;
decodechar	move.l	son(pc),a2
		move.w	R*2(a2),d0	;son[r]
		cmp.w	#T,d0
		bcc	.wover
.wloop		add.l	d7,d7		;getbit
		bne.s	.notzero
		move.l	(a0)+,d7
		addx.l	d7,d7
.notzero	bcc.s	.noadd
		addq.w	#1,d0
.noadd		add.w	d0,d0
		move.w	0(a2,d0.w),d0	;c=son[c]
		cmp.w	#T,d0
		bcs.s	.wloop
.wover		move.w	d0,d5
;		sub.w	#T,d0
;		move.w	d0,-(sp)
		bsr	update
;		move.w	(sp)+,d0
		move.w	d5,d0
		sub.w	#T,d0
		rts
;
; decode position
;
decodeposition	bsr	getbyte
		clr.w	d1
		clr.w	d2
		move.l	d_code(pc),a2
		move.b	0(a2,d0.w),d1
		asl.w	#6,d1
		move.l	d_len(pc),a2
		move.b	0(a2,d0.w),d2
		subq.w	#2,d2
		beq.s	.zero
.wloop		bsr	getbit
		addx.w	d0,d0
		subq.w	#1,d2
		bne.s	.wloop
.zero		and.w	#$3f,d0
		or.w	d1,d0
		rts
;
; update d0=character
;
update		move.l	freq(pc),a2
		cmp.w	#MAX_FREQ,R*2(a2)
		bne.s	.noregen
		move.w	d5,-(sp)
		bsr	reconst
		move.w	(sp)+,d5
		move.w	d5,d0
.noregen	move.l	prnt(pc),a2
;		add.w	#T,d0
		add.w	d0,d0
		move.w	0(a2,d0.w),d0
.doloop		move.l	freq(pc),a2
		add.w	d0,d0		;c*2
		lea	0(a2,d0.w),a3
		addq.w	#1,(a3)
		move.w	(a3)+,d1
		cmp.w	(a3)+,d1
		bls	.endif
.wloop		cmp.w	(a3)+,d1
		bhi.s	.wloop
		lea	-4(a3),a3
		move.w	(a3),0(a2,d0.w)	;freq[c]=freq[l]
		move.w	d1,(a3)
		sub.l	a2,a3
		move.w	a3,d2
		move.l	son(pc),a2
		move.l	prnt(pc),a3
		move.w	0(a2,d0.w),d3	;i=son[c]
		add.w	d3,d3
		lsr.w	#1,d2
		move.w	d2,0(a3,d3.w)	;prnt[i]=l
		cmp.w	#T*2,d3
		bcc.s	.nosi
		move.w	d2,2(a3,d3.w)	;prnt[i+1]=l
.nosi		add.w	d2,d2
		move.w	0(a2,d2.w),d4	;j=son[l]
		lsr.w	#1,d3
		move.w	d3,0(a2,d2.w)	;son[l]=i
		lsr.w	#1,d0
		add.w	d4,d4
		move.w	d0,0(a3,d4.w)	;prnt[j]=c
		cmp.w	#T*2,d4
		bcc.s	.nosj
		move.w	d0,2(a3,d4.w)	;prnt[j+1]=c
.nosj		add.w	d0,d0
		lsr.w	#1,d4
		move.w	d4,0(a2,d0.w)	;son[c]=j
		move.w	d2,d0		;c=l
.endif		move.l	prnt(pc),a2
		move.w	0(a2,d0.w),d0	;c=prnt[c]
		bne	.doloop
		rts
;
; reconstruct
;
reconst		moveq	#0,d1
		moveq	#0,d2
		move.l	son(pc),a2
		move.l	freq(pc),a3
.floop1		move.w	0(a2,d1.w),d3	;son[i]
		cmp.w	#T,d3
		bcs.s	.if1
		move.w	0(a3,d1.w),d4	;freq[i]
		addq.w	#1,d4
		asr.w	#1,d4
		move.w	d4,0(a3,d2.w)	;freq[j]=(freq[i]+1)/2
		move.w	d3,0(a2,d2.w)	;son[j]=son[i]
		addq.w	#2,d2
.if1		addq.w	#2,d1
		cmp.w	#T*2,d1
		blt.s	.floop1
		moveq	#0,d1		;i=0
		move.w	#N_CHAR*2,d2	;j=n_char
.floop2		move.w	0(a3,d1.w),d3
		add.w	2(a3,d1.w),d3
		move.w	d3,0(a3,d2.w)	;freq[j] = freq[i]+freq[i+1]
		move.w	d2,d4
.floop3		subq.w	#2,d4		;k--
		cmp.w	0(a3,d4.w),d3
		bcs.s	.floop3		;while f<freq[k]
		addq.w	#2,d4
		lea	0(a3,d4.w),a4	;from
		lea	2(a4),a5	;to
		move.w	d2,d5
		sub.w	d4,d5		;(j-k)*2
		beq.s	.nomov1
		move.w	d5,d0
		add.w	d0,a4
		add.w	d0,a5
		subq.w	#1,d0
.movmem1	move.b	-(a4),-(a5)
		dbra	d0,.movmem1
		lea	0(a2,d4.w),a4
		lea	2(a4),a5
		move.w	d5,d0
		add.w	d0,a4		;from
		add.w	d0,a5		;to
		subq.w	#1,d0
.movmem2	move.b	-(a4),-(a5)
		dbra	d0,.movmem2
.nomov1		move.w	d3,0(a3,d4.w)	;freq[k]=f
		move.w	d1,d0
		lsr.w	#1,d0
		move.w	d0,0(a2,d4.w)	;son[k]=i
		addq.w	#4,d1		;i+=2
		addq.w	#2,d2		;j++
		cmp.w	#T*2,d2
		blt.s	.floop2
		moveq	#0,d1		;i=0
		moveq	#0,d2
		move.l	prnt(pc),a3
.floop4		move.w	0(a2,d2.w),d3
		add.w	d3,d3
		cmp.w	#T*2,d3
		bcc.s	.if3
		move.w	d1,2(a3,d3.w)
.if3		move.w	d1,0(a3,d3.w)
		addq.w	#2,d2
		addq.w	#1,d1
		cmp.w	#T,d1
		blt.s	.floop4
		rts
;
; variables
;
count		dc.l	0
d_code		dc.l	0
d_len		dc.l	0
freq		dc.l	0
son		dc.l	0
prnt		dc.l	0
text_buf	dc.l	0
xoutput		dc.l	0

lzhfile		incbin	"gfabasic.lzh"

