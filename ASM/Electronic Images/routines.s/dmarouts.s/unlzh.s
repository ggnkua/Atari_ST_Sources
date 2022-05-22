;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
;                        Depack .LZH file 					;
; The file is depacked above the depacked file unlike most depackers	;
; but I have now added a routine to relocate it back to the packed file ;
; address at the end....								;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

N		equ	4096
F		equ	60
THRESHOLD	equ	2
NIL		equ	N
N_CHAR	equ	(256-THRESHOLD+F)
T		equ	(N_CHAR*2-1)
R		equ	(T-1)
MAX_FREQ	equ	32768

d_code	equ $75000
d_len		equ d_code+512
freq		equ d_len+512
son		equ freq+((T+1)*2)
prnt		equ son+(T*2)
text_buf	equ prnt+(T+N_CHAR)*2

; read a single bit from the packed data

getbitl	macro
		add.b d7,d7
		bne.s notzero\@
		move.b (a0)+,d7
		addx.b d7,d7
notzero\@	
		endm

; First generate bit tables

lzhdepack	lea file(pc),a0
		lea 11+4(a0),a2
		lea xoutput,a1
		move.b -(a2),d7
		rol.w	#8,d7
		move.b -(a2),d7
		swap d7
		move.b -(a2),d7
		rol.w	#8,d7
		move.b -(a2),d7
		moveq	#0,d0
		move.b (a0)+,d0
		lea 1(a0,d0.w),a0
		move.l a1,a6
		add.l d7,a6

; a0 = pointer to LZH data
; a1 = pointer to output
; a6 = pointer to end of output(unpacked)
; d7 = number of bytes to unpack

		bsr starthuff
		lea.l	d_code,a2
		bsr gendcode
		lea.l d_len,a2
		bsr gendlen
		moveq	#$20,d0
		move.w #N-F-1,d1
		lea.l text_buf,a2
.clrbuf	move.b d0,(a2)+
		dbra	d1,.clrbuf
		move.w #N-F,d6
		lea.l son,a2
		move.l a2,usp
		move.l d7,-(sp)
		move.b #$80,d7				;clear bitbuf
		move #-1,depacking
		lea text_buf,a5

;-----------------------------------------------------------------------;
; Main unpacking loop									;
; d7 = count										;
; d6 = R											;
;-----------------------------------------------------------------------;
;------------------;
; decode character ;
;------------------;

unpackloop	move.l usp,a2				;decode character
		move.w R*2(a2),d0				;son[r]
		move #T,d2
wloop1 	getbitl
		bcc.s noadd1
		add.w d0,d0
		move.w 2(a2,d0.w),d0
		cmp.w d2,d0
		bcs.s wloop1
		bra.s wover
noadd1	add.w d0,d0
		move.w 0(a2,d0.w),d0			;c=son[c]
		cmp.w d2,d0
		bcs.s wloop1
wover		move.w d0,d5

; update d0=character

update	lea.l freq,a2
		cmp.w	#MAX_FREQ,R*2(a2)
		beq reconst
noregen	lea.l prnt,a2
		add.w	d0,d0
		move.w 0(a2,d0.w),d0
.doloop	lea.l freq,a2
		add.w	d0,d0				;c*2
		move.l a2,a3
		adda.w d0,a3
		addq.w #1,(a3)
		move.w (a3)+,d1
		cmp.w	(a3)+,d1
		bls .endif
.wloop	cmp.w	(a3)+,d1
		bhi.s	.wloop
		subq.l #4,a3
		move.w (a3),0(a2,d0.w)		;freq[c]=freq[l]
		move.w d1,(a3)
		sub.l	a2,a3
		move.w a3,d2
		move.l usp,a2
		lea.l	prnt,a3
		move.w 0(a2,d0.w),d3		;i=son[c]
		add.w	d3,d3
		lsr.w	#1,d2
		move.w d2,0(a3,d3.w)		;prnt[i]=l
		cmp.w	#T*2,d3
		bcc.s	.nosi
		move.w d2,2(a3,d3.w)		;prnt[i+1]=l
.nosi		add.w	d2,d2
		move.w 0(a2,d2.w),d4		;j=son[l]
		lsr.w	#1,d3
		move.w d3,0(a2,d2.w)		;son[l]=i
		lsr.w	#1,d0
		add.w	d4,d4
		move.w d0,0(a3,d4.w)		;prnt[j]=c
		cmp.w	#T*2,d4
		bcc.s	.nosj
		move.w d0,2(a3,d4.w)		;prnt[j+1]=c
.nosj		add.w	d0,d0
		lsr.w	#1,d4
		move.w d4,0(a2,d0.w)		;son[c]=j
		move.w d2,d0			;c=l
.endif	lea.l prnt,a2
		move.w 0(a2,d0.w),d0		;c=prnt[c]
		bne .doloop
		
		cmp.w #256+T,d5
		bge.s doposition
		sub.w #T,d5
		move.b d5,(a1)+			;output(c)
		move.b d5,(a5,d6.w)		;textbuf[r] = c;
		addq.w #1,d6
		and.w #N-1,d6
		cmp.l a1,a6
		bgt unpackloop			;repeat for rest
		bra unpackdone

doposition	
; decode position
		moveq #0,d4
		rept 8
		getbitl
		addx.b d4,d4
		endr
		move.w d4,d1
		add d1,d1
		lea.l d_len,a2
		move.w 0(a2,d1.w),d2
wloop		getbitl
		addx.w d4,d4
		dbf d2,wloop
zero		and.w #$3f,d4
		lea.l d_code,a2
		or.w 0(a2,d1.w),d4
		move.w d6,d1
		sub.w d4,d1				;r - decodepos() -1
		subq.w #1,d1
		sub.w #255-THRESHOLD+1+T,d5	;c - 255 + threshold  +1(dbf)
		move #N-1,d4
.floop	and.w	d4,d1
		move.b 0(a5,d1.w),d0		;c = textbuf[]
		move.b d0,(a1)+
		move.b d0,0(a5,d6.w)
		addq.w #1,d6			;r++
		and.w	d4,d6
		addq.w #1,d1
		dbf d5,.floop
		cmp.l a1,a6
		bgt unpackloop

; Depack is done...
unpackdone	move.l (sp)+,d7
		move.w vbl_timer(pc),d0
waitquim	cmp vbl_timer(pc),d0
		beq waitquim
		clr depacking
		lea xoutput,a0
		lea file(pc),a1
		moveq #0,d0
		moveq #16,d1
reloc_lp	move.l (a0),(a1)+
		move.l d0,(a0)+
		move.l (a0),(a1)+
		move.l d0,(a0)+
		move.l (a0),(a1)+
		move.l d0,(a0)+
		move.l (a0),(a1)+
		move.l d0,(a0)+
		sub.l d1,d7
		bgt.s reloc_lp
		rts

;
; reconstruct
;

reconst	movem.l d5/a5,-(sp)
		moveq	#0,d1
		moveq	#0,d2
		move.l usp,a2
		lea.l freq,a3
.floop1	move.w 0(a2,d1.w),d3		;son[i]
		cmp.w	#T,d3
		bcs.s	.if1
		move.w 0(a3,d1.w),d4		;freq[i]
		addq.w #1,d4
		asr.w	#1,d4
		move.w d4,0(a3,d2.w)		;freq[j]=(freq[i]+1)/2
		move.w d3,0(a2,d2.w)		;son[j]=son[i]
		addq.w #2,d2
.if1		addq.w #2,d1
		cmp.w	#T*2,d1
		blt.s	.floop1
		moveq	#0,d1				;i=0
		move.w #N_CHAR*2,d2		;j=n_char
.floop2	move.w 0(a3,d1.w),d3
		add.w	2(a3,d1.w),d3
		move.w d3,0(a3,d2.w)		;freq[j] = freq[i]+freq[i+1]
		move.w d2,d4
.floop3	subq.w #2,d4			;k--
		cmp.w	0(a3,d4.w),d3
		bcs.s	.floop3			;while f<freq[k]
		addq.w #2,d4
		lea 0(a3,d4.w),a4			;from
		lea 2(a4),a5			;to
		move.w d2,d5
		sub.w	d4,d5				;(j-k)*2
		beq.s	.nomov1
		move.w d5,d0
		add.w	d0,a4
		add.w	d0,a5
		subq.w #1,d0
.movmem1	move.b -(a4),-(a5)
		dbra	d0,.movmem1
		lea 0(a2,d4.w),a4
		lea 2(a4),a5
		move.w d5,d0
		add.w	d0,a4				;from
		add.w	d0,a5				;to
		subq.w #1,d0
.movmem2	move.b -(a4),-(a5)
		dbra	d0,.movmem2
.nomov1	move.w d3,0(a3,d4.w)		;freq[k]=f
		move.w d1,d0
		lsr.w	#1,d0
		move.w d0,0(a2,d4.w)		;son[k]=i
		addq.w #4,d1			;i+=2
		addq.w #2,d2			;j++
		cmp.w	#T*2,d2
		blt.s	.floop2
		moveq	#0,d1				;i=0
		moveq	#0,d2
		lea.l prnt,a3
.floop4	move.w 0(a2,d2.w),d3
		add.w	d3,d3
		cmp.w	#T*2,d3
		bcc.s	.if3
		move.w d1,2(a3,d3.w)
.if3		move.w d1,0(a3,d3.w)
		addq.w #2,d2
		addq.w #1,d1
		cmp.w	#T,d1
		blt.s	.floop4
		movem.l (sp)+,d5/a5
		move.w d5,d0
		bra noregen

;
; generate d_code lookup table
; a2 = destination
;

gendcode	lea .gtab(pc),a3
		moveq	#0,d0
		moveq	#32,d1
		move.w (a3)+,d2
.outer	move.w d1,d3
		subq.w #1,d3
.inner	move.w d0,(a2)+
		dbra d3,.inner
		add.w #64,d0
		dbra d2,.outer
		asr.w	#1,d1
		move.w (a3)+,d2
		bpl.s	.outer
		rts

.gtab		dc.w	1-1,3-1,8-1,12-1,24-1,16-1,-1

;
; generate d_len lookup table
; a2 = destination
;

gendlen	lea .gtab(pc),a3
		moveq	#0,d0
		move.w (a3)+,d1
.loop		move.w d0,(a2)+
		dbra d1,.loop
		addq.w #1,d0
		move.w (a3)+,d1
		bpl.s	.loop
		rts
.gtab		dc.w	32-1,48-1,64-1,48-1,48-1,16-1,-1

;
; start huffman code
;
starthuff	moveq	#0,d0
		lea.l freq,a2
		lea.l	son,a3
		lea.l	prnt,a4
.loop		move.w #1,(a2)+			;freq[i]=1
		move.w d0,d1
		add.w	#T,d1
		move.w d1,(a3)+			;son[i]=T+i
		add.w	d1,d1	
		move.w d0,0(a4,d1.w)		;prnt[i+T]=i
		addq.w #1,d0
		cmp.w	#N_CHAR,d0
		blt.s .loop
		moveq	#0,d0				;i=0
		move.w #N_CHAR,d1			;j=n_char
		lea.l freq,a2
		lea.l son,a3
.wloop	move.w d0,d2
		add.w	d2,d2				;(i*2) coz words
		move.w 0(a2,d2.w),d3
		add.w	2(a2,d2.w),d3		;freq[i]+freq[i+1]
		move.w d1,d2
		add.w	d2,d2
		move.w d3,0(a2,d2.w)
		move.w d0,0(a3,d2.w)		;son[j]=i
		move.w d0,d2
		add.w	d2,d2
		move.w d1,0(a4,d2.w)		;prnt[i]=j
		move.w d1,2(a4,d2.w)		;prnt[i+1]=j
		addq.w #2,d0
		addq.w #1,d1			;j++
		cmp.w	#R,d1
		ble .wloop
.wover	lea.l freq,a2
		move.w #-1,T*2(a2)
		lea.l prnt,a2
		clr.w R*2(a2)
		rts


		EVEN
