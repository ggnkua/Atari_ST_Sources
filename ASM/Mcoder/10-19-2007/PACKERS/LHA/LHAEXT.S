	opt	c-,o+,ow-,x+
archive=0			;$20=bit d'archive mis
;
; LHARC X
;
; version d‚compacteur externe
;
PRINT	MACRO
	PEA	\1
	MOVE	#9,-(SP)
	TRAP	#1
	ADDQ	#6,SP
	ENDM

exehdr	=	0

;bp	equr	a4

CRC16	=	$A001
BufSiz	=	$4000

NC	=	$200-2
NP	=	14
NT	=	19
NPT	=	$80

CBIT	=	9
PBIT	=	4
TBIT	=	5

DSIZ	=	$2000
DSIZ2	=	DSIZ*2

	rsreset
HeadSiz	rs.b	1
HeadChk	rs.b	1
HeadId	rs.b	3
Method	rs.b	1
	rs.b	1
Pacsiz	rs.b	4
Orgsiz	rs.b	4
FTime	rs.b	2
FDate	rs.b	2
FAttr	rs.b	2
FnLen	rs.b	1
Fname	rs.b	$80
Lzhead	rs.b	0


	section	text
main:
	PRINT	cright

	clr	-(sp)
	pea	myself
	move	#$3d,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0
	bmi	brokenerr
	move	d0,infile
;
; SEEK
;
	clr	-(sp)
	move	infile,-(sp)
	pea	exehdr
	move	#$42,-(sp)	;move a file pointer
	trap	#1
	lea	10(sp),sp

	tst.l	d0
	bmi	brokenerr
;
; make CRC table
;
makecrc:
	lea	crctbl,a0
	moveq	#0,d2
1$
	move	d2,d0
	moveq	#8-1,d1
2$
	lsr	#1,d0
	bcc.s	3$
	eor	#CRC16,d0
3$
	dbra	d1,2$
	move	d0,(a0)+
	addq.b	#1,d2
	bne.s	1$
;
; get Header
;
mainloop:
	lea	cpyhdr+HeadSiz,a5
	clr.b	(a5)

	pea	(a5)		;adresse lecture
	pea	1		;nb octets … lire
	move	infile,-(sp)	;handle
	move	#$3f,-(sp)
	trap	#1		;read header size
	lea	12(sp),sp

	moveq	#0,d2
	MOVE.b	(a5)+,d2
	beq	exit

	addq	#1,d2

	pea	(a5)		;adresse lecture
	move.l	d2,-(sp)	;nb octets … lire
	move	infile,-(sp)	;handle
	move	#$3f,-(sp)
	trap	#1		;read header
	lea	12(sp),sp

; test header sum

	subq	#1,d2
	BEQ	BUG

	move.b	(a5)+,d0
	move.l	a5,a0		;cpyhdr+HeadID
.loop
	sub.b	(a0)+,d0
	subq	#1,d2
	bne.s	.loop

	tst.b	d0
	bne	errhdr
;
; test header id
;
	cmp.b	#'-',(a5)+
	bne	errhdr
	cmp.b	#'l',(a5)+
	bne	errhdr
	cmp.b	#'h',(a5)+
	bne	errhdr

	move.b	(a5)+,d0
	sub.b	#'0',d0
	move.b	d0,d6

	beq.s	.loc15
	subq.b	#4,d0
	beq.s	.loc15
	subq.b	#1,d0
	bne	errhdr
.loc15
	cmp.b	#'-',(a5)+
	bne	errhdr
	movep	3(a5),d0
	move.b	2(a5),d0
	swap	d0
	movep	1(a5),d0
	move.b	(a5),d0
	move.l	d0,packsize

	movep	7(a5),d0
	move.b	6(a5),d0
	swap	d0
	movep	5(a5),d0
	move.b	4(a5),d0
	move.l	d0,origsize
;
; get original CRC
;
	lea	cpyhdr+Fname,a1
	move.l	a1,fnptr

	moveq	#0,d0
	move.b	-1(a1),d0

	move.l	a1,a0
	add	d0,a0

	movep	1(a0),d0
	move.b	(a0),d0
	move	d0,orgcrc

	move.b	#' ',(a0)+
	clr.b	(a0)
;
; display file name
;
	bsr	disp		;output file name
	clr.b	-(a0)
;
; check existence of file
;

	bra	MN1		;pour d‚buggage

	clr	-(sp)
	clr	-(sp)
	move.l	fnptr,-(sp)
	move	#$43,-(sp)	;get file attribute
	trap	#1
	lea	10(sp),sp
	tst.l	d0
	bmi.s	mn1
;
; overwrite ?
;
	PRINT	overwrt		;prompt
	bsr	getyn
	beq	mn1
;
; skip to next file
;
	move	#1,-(sp)
	move	infile,-(sp)
	move.l	packsize,-(sp)	;skip file
	move	#$42,-(sp)	;move a file pointer
	trap	#1
	lea	10(sp),sp
	bra	mainloop
;
; create a new file
;
mn1:
	move	#archive,-(sp)	;$20=bit d'archive
	move.l	fnptr,-(sp)
	move	#$3c,-(sp)
	trap	#1		;create a file
	addq	#8,sp
	tst.l	d0
	bmi	errwrite
	move	d0,outfile
;
; decode
;
	clr	curcrc
	move.l	#-1,inpptr

	tst	d6
	beq.s	.copy
	bsr	decode
	bra.s	.loc20
.copy
	bsr	copyall
.loc20

; set time-stamp

	lea	cpyhdr,a0
	movep	Fdate+1(a0),d0
	move.b	fdate(a0),d0
	move	d0,filetime+2

	movep	Ftime+1(a0),d0
	move.b	Ftime(a0),d0
	move	d0,filetime

	clr	-(sp)
	move	outfile,-(sp)
	pea	filetime
	move	#$57,-(sp)	;set date
	trap	#1
	lea	10(sp),sp

	move	outfile,-(sp)
	move	#$3e,-(sp)	;close file
	trap	#1
	addq	#4,sp
;
; check CRC
;
	move	curcrc,d0
	cmp	orgcrc,d0
	bne	errcrc

	bra	mainloop
exit:
	move	infile,-(sp)
	move	#$3e,-(sp)	;close file
	trap	#1
	addq	#4,sp
exit1:
	moveq	#0,d0
exit2:
	ILLEGAL

	move	d0,-(sp)
	move	#$4c,-(sp)
	trap	#1

errhdr:
	lea	header,a1
	bra	errout
brokenerr:
	lea	broken,a1
	bra	errout
errcrc:
	bsr	unlink
	lea	crcmess,a1
	bra	errout1
errwrite:
	move	outfile,-(sp)
	move	#$3e,-(sp)	;close file
	trap	#1
	addq	#4,sp

	bsr	unlink
	lea	write,a1
errout:
	bsr	disp
	lea	error,a1
errout1:
	bsr	disp
	moveq	#1,d0
	bra	exit2
;
; get Y or N
;
getyn:
	PRINT	yesno		;prompt
.loc21
	move	#8,-(sp)
	trap	#1
	addq	#2,sp
	and	#$df,d0
	cmp	#'Y',d0
	beq.s	.loc22
	cmp	#'N',d0
	bne.s	.loc21
.loc22
	move.b	d0,mes_yn
	PRINT	mes_yn
	cmp.b	#'Y',mes_yn
	rts

copyall:
	moveq	#0,d7
.while
	sub.l	d7,origsize
	beq.s	cpyend

	move.l	#DSIZ2,d7
	move.l	origsize,d0
	cmp.l	d7,d0
	bhs.s	.loc41
	move.l	d0,d7
.loc41
	pea	text
	move.l	d7,-(sp)
	move	infile,-(sp)	;handle
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp

	lea	text,a0
	move.l	d7,d0
	bsr	putbuf2
	bra	.while
cpyend:
	rts
;
; delete file
;
unlink:
	RTS

	move.l	fnptr,-(sp)
	move	#$41,-(sp)		;unlink
	trap	#1
	addq	#6,sp
	rts
;
; display ASCIZ char
;
disp:
	movem.l	d0-d7/a0-a6,-(sp)
.loc43
	moveq	#0,d0
	move.b	(a1)+,d0
	beq.s	.fini
	move	d0,-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp
	bra.s	.loc43
.fini
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
; extract routines
;
decode:

	moveq	#0,d0
	move	d0,blocksize
	move	d0,bitbuf
	move	d0,subbitbuf
	move	d0,bitcount

	moveq	#16,d0
	bsr	fillbuf

	lea	text,a6			;di
	bra	.entry
.loop
	bsr	decode_c_st1
	cmp	#$100,d0
	bhs.s	.loc50

	move.b	d0,(a6)+
	cmp.l	#text+DSIZ2,a6
	blo.s	.entry
	bsr	putbuf
.entry

	TST.L	INPPTR
	BEQ	BUG

	subq.l	#1,origsize
	bhs.s	.loop
	bra.s	.loc53
.loc50
	move	d0,d2		;cx
	sub	#$100-3,d2
	bsr	decode_p_st1

	move	d2,-(sp)	;cx

	move.l	a6,a5		;si
	subq.l	#1,a5		;si
	sub	d0,a5

.circ0:	cmp.l	#text,a5
	bhs.s	.circ1
	lea	DSIZ2(a5),a5
	bra.s	.circ0
.circ1

.do1
	move.b	(a5)+,(a6)+

	cmp.l	#text+DSIZ2,a5
	blo.s	.circ2
	lea	-DSIZ2(a5),a5
.circ2
	cmp.l	#text+DSIZ2,a6
	blo.s	.loc52

	move	d2,-(sp)
	pea	(a5)		;si
	bsr	putbuf
	move.l	(sp)+,a5
	move	(sp)+,d2
.loc52
	TST	D2
	BEQ	BUG

	subq	#1,d2
	bne.s	.do1

	TST.L	INPPTR
	BEQ	BUG


	moveq	#0,d2
	move	(sp)+,d2
	sub.l	d2,origsize
	bhs	.loop
.loc53
	bra	putbuf
;
;
;
read_pt_len
	move	d4,-(sp)	;si
	move	d3,d0		;al=dl
	bsr	getbits
	cmp	d4,d0		;comp ax et si
	bhi	brokenerr

	lea	pt_len,a6	;di

	tst	d0
	bne.s	.loc1

	move	(sp)+,d2
	BEQ	BUG
.loc2
	move.b	d0,(a6)+
	subq	#1,d2
	bne.s	.loc2

	cmp.l	#fin_pt_len,a6
	bhi	BUG

	move	d3,d0
	bsr	getbits
	move	#256,d2
	lea	pt_table,a6
.loc3
	move	d0,(a6)+
	subq	#1,d2
	bne.s	.loc3
	rts
.loc1
	move.l	a6,a3
	add	d2,a3		;+di

	move.l	a6,a5		;si
	add	d0,a5		;ax=n
.do1
	moveq	#3,d0
	bsr	getbits
	cmp	#7,d0
	bne.s	.not1

	move	bitbuf,d1
.while1
	add	d1,d1
	bcc.s	.endw
	addq	#1,d0
	bra.s	.while1
.endw
	move	d0,-(sp)
	subq	#6,d0
	bsr	fillbuf
	move	(sp)+,d0
.not1
	move.b	d0,(a6)+	;stosb
	cmp.l	a3,a6
	bne.s	.not2

	moveq	#2,d0
	bsr	getbits
	move	d0,d2
	moveq	#0,d0
	tst	d2
;	beq.s	.not2
	BEQ	BUG
.loc11
	move.b	d0,(a6)+
	subq	#1,d2
	bne.s	.loc11

.not2
	cmp.l	a5,a6
	blo.s	.do1


	cmp.l	#fin_pt_len,a6
	bhi	BUG


	move	(sp)+,d4	;si

	lea	pt_len,a4

	move.l	a4,d2		;cx=bp
	sub.l	a6,d2		;-di
	add	d4,d2		;+si
	beq.s	.none1
	moveq	#0,d0
.loc12
	move.b	d0,(a6)+
	subq	#1,d2
	bne.s	.loc12
.none1:

	move	d4,d0		;ax=si
	moveq	#8,d2		;cx
	lea	pt_table,a6	;di
	bra	make_table
;
;
read_c_len
	moveq	#CBIT,d0
	bsr	getbits

	cmp	#NC,d0
	bhi	brokenerr

	lea	c_len,a6	;di

	tst	d0
	bne.s	.not1

	move	#NC,d2
.lop1
	move.b	d0,(a6)+
	subq	#1,d2
	bne.s	.lop1

	CMP.L	#FIN_C_LEN,A6
	BHI	BUG

	moveq	#CBIT,d0
	bsr	getbits
	move	#4096,d2
	lea	c_table,a6
.lop2
	move	d0,(a6)+
	subq	#1,d2
	bne.s	.lop2
	rts
.not1
	move.l	a6,a3		;dx
	add.l	d0,a3		;ax=n
	pea	(a6)		;di

do100
	move	bitbuf,d0
	move	d0,d1
	lsr	#8,d1
	add	d1,d1
	lea	pt_table,a0
	move	(a0,d1.w),d1

	lea	read_c_len_1,a5		;si
	moveq	#NT,d2
	bra	tree1

read_c_len_1:
	move	d1,-(sp)	;bx
	lea	pt_len,a0
	CLR	D0
	move.b	(a0,d1.w),d0
	bsr	fillbuf
	move	(sp)+,d0

	sub	#2,d0
	bhi.s	.loc68

	bne.s	.loc65

	moveq	#CBIT,d0
	bsr	getbits
	add	#20,d0
	move	d0,d2

	bra.s	.loc67
.loc65
	addq	#1,d0
	bne.s	.loc66

	moveq	#4,d0
	bsr	getbits
	add	#3,d0
	move	d0,d2

	bra.s	.loc67
.loc66
	moveq	#1,d2
.loc67
	moveq	#0,d0
.lopxx1
	TST	D2
	BEQ	BUG
	move.b	d0,(a6)+
	subq	#1,d2
	bne.s	.lopxx1
	bra.s	.loc69
.loc68
	move.b	d0,(a6)+
.loc69
	cmp.l	a3,a6
	blo.s	do100


	CMP.L	#FIN_C_LEN,A6
	BHI	BUG

	moveq	#0,d0
	move.l	#c_len+NC,d2
	sub.l	a6,d2
	BEQ.S	.NONE2
.fil0
	move.b	d0,(a6)+
	subq	#1,d2
	bne.s	.fil0
.NONE2
	move	#NC,d0
	move.l	(sp)+,a4

	moveq	#12,d2		;cx
	lea	c_table,a6
	bra	make_table

decode_c:

decode_c_st1_2:
	pea	(a6)
	moveq	#16,d0
	bsr	getbits
	subq	#1,d0
	move	d0,blocksize

	move	#NT,d4		;si
	moveq	#TBIT,d3	;dx
	moveq	#3,d2		;cx
	bsr	read_pt_len

	bsr	read_c_len

	move	#NP,d4		;si
	moveq	#PBIT,d3	;dx
	moveq	#-1,d2		;cx

	bsr	read_pt_len

	move.l	(sp)+,a6
	bra	decode_c_st1_3

decode_c_st1
	subq	#1,blocksize
	blo	decode_c_st1_2
decode_c_st1_3:
	move	bitbuf,d1		;bx

	lsr	#4,d1
	moveq	#4,d2			;cx
	add	d1,d1
	lea	c_table,a0
	move	(a0,d1.w),d1

	cmp	#NC,d1
	bhs.s	loc1
decode_c_st1_1
	move	d1,-(sp)
	lea	c_len,a0
	clr	d0
	move.b	(a0,d1.w),d0
	bsr	fillbuf
	move	(sp)+,d0
	rts
loc1:
	move	bitbuf,d0
	asl.b	d2,d0
	lea	decode_c_st1_1,a5	;si
	move	#NC,d2			;cx
tree0:
	lea	left,a0
	add.b	d0,d0
	bcc.s	.loc1
	lea	right,a0
.loc1
	move	(a0,d1.w),d1
tree1:
	cmp	d2,d1
	bhs.s	tree0
	jmp	(a5)		;si
;
;
;
decode_p_st1
	move	d2,-(sp)
	moveq	#0,d1
	move.b	bitbuf,d1	;poids fort dans bl
	add	d1,d1
	lea	pt_table,a0
	move	(a0,d1.w),d1

	cmp	#NP,d1
	bhs	loc2
decode_p_st1_1
	move	d1,-(sp)
	lea	pt_len,a0
	clr	d0
	move.b	(a0,d1.w),d0
	bsr	fillbuf
	move	(sp)+,d0
	cmp	#1,d0
	bls.s	loc3
	subq	#1,d0
	move	d0,d2
	bsr	getbits
	moveq	#1,d1
	asl	d2,d1

	or	d1,d0
loc3:
	move	(sp)+,d2
	rts
loc2:
	move.b	bitbuf+1,d0		;poids faible
	lea	decode_p_st1_1,a5	;si
	moveq	#NP,d2
	bra	tree0
;
;
;
make_table
	move	d0,nchar
	add	d0,d0
	move	d0,avail_mt
	move	d2,tablebits
	move.l	a6,table

	moveq	#16,d0
	sub	d2,d0
	move.b	d0,restbits

	moveq	#1,d0
	asl	d2,d0
	move	d0,d2
	BEQ	BUG
	moveq	#0,d0
.stos
	move	d0,(a6)+
	subq	#1,d2
	bne.s	.stos

	moveq	#0,d4		;si
	move	#$8000,d1	;bx
	moveq	#1,d3		;dx
do200
	move.l	a4,a6		;di=bp
	move	nchar,d2
	BEQ	BUG
.do2
	move	d3,d0		;al=dl
.scasb
	cmp.b	(a6)+,d0
	beq.s	.fnd
	subq	#1,d2
	bne.s	.scasb
	bra	mt1
.fnd
	bne	mt1
	move.l	a6,d0
	sub.l	a4,d0
	subq	#1,d0
	move	d2,-(sp)	;cx

	pea	(a6)		;di
;
; bx=weight
; si=code
; dx=len
;
	moveq	#0,d2
	move.b	restbits,d2
	move	d4,d7
	lsr	d2,d7
	add	d7,d7
	move.l	table,a6
	add	d7,a6

	move	d1,-(sp)		;bx

	cmp	tablebits,d3		;dx
	bhi.s	.loc1
	lsr	d2,d1
	move	d1,d2
	BEQ	BUG
.stosw1
	move	d0,(a6)+
	subq	#1,d2
	bne.s	.stosw1
	bra.s	.loc2
.loc1
;
; di=taddr
; si=
; cx=
; ax=char
;
	move	d4,-(sp)
	move	tablebits,d2
	asl	d2,d4

	neg	d2
	add	d3,d2
	BEQ	BUG
.do3
	tst	(a6)
	bne.s	.loo
	move	avail_mt,d1	;bx
	lea	right,a0
	clr	(a0,d1.w)
	lea	left,a0
	clr	(a0,d1.w)

	move	d1,(a6)
	addq	#2,avail_mt
.loo
;	move.l	d1,a0
;	moveq	#0,d1
;	move	(a0),d1
	MOVE	(A6),A6

;	add	d1,d1
	ADD	D4,D4
	bcc.s	.noc1
	add.l	#right,A6
	bra.s	.noc2
.noc1
	add.l	#left,A6
.noc2
	subq	#1,d2
	bne.s	.do3
	move	d0,(a6)

	move	(sp)+,d4
.loc2
	move	(sp)+,d1
	move.l	(sp)+,a6
	move	(sp)+,d2
	add	d1,d4
	bcs	mt2

	TST	D2
	BEQ	BUG

	SUBQ	#1,d2		;DEBUGGAGE
	bne	.do2
mt1:
	addq	#1,d3
	lsr	#1,d1
	bcc	do200
mt2:
	rts
;
; retourne d0 bits
;
bug:	illegal

getbits:
	cmp	#16,d0
	bhi	bug

	move	d2,-(sp)
	moveq	#16,d2
	sub	d0,d2

	move	bitbuf,-(sp)
	bsr	fillbuf
	move	(sp)+,d0
	lsr	d2,d0
	move	(sp)+,d2
	rts
;
; shift bitbuf n bits left, read n bits
;
; rafraichit bitbuf_ avec d0 bits
;
fillbuf:
	cmp	#16,d0
	bhi	bug


	movem.l	d1/d2/d3,-(sp)

	move	d0,d2
	move	bitcount,d1
	move	bitbuf,d3

	move	subbitbuf,d0

	cmp	d1,d2
	bls.s	loc100

	sub	d1,d2
	asl	d1,d3
	rol.b	d1,d0
	add.b	d0,d3

	moveq	#8,d1
fb1:
	bsr	getc
	cmp	d1,d2
	bls	loc100
	sub	d1,d2
	asl	#8,d3
	move.b	d0,d3
	bra	fb1

loc100:
	sub	d2,d1
	move	d1,bitcount

	asl	d2,d3
	asl	d2,d0

	move	d0,d7
	lsr	#8,d7
	add.b	d7,d3

	move	d3,bitbuf
	and	#$ff,d0
	move	d0,subbitbuf

	movem.l	(sp)+,d1/d2/d3
	rts
;
; getc :
;
; retourne d0=1 octet lu
;
getc:
	move.l	inpptr,a0
	cmp.l	#inpbuf+bufsiz,a0
	blo.s	.ok
;
; getbuf
;
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	#bufsiz,d0
	sub.l	d0,packsize
	bhs.s	.ok2
	add.l	packsize,d0
.ok2:
	pea	inpbuf		;adresse chargement
	move.l	d0,-(sp)	;nb octets … lire
	move	infile,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	movem.l	(sp)+,d0-d7/a0-a6
	lea	inpbuf,a0
.ok
	move.b	(a0)+,d0
	move.l	a0,inpptr
	rts

putbuf:
	lea	text,a0
	move.l	a6,d0		;ptr courant en ‚criture
	sub.l	a0,d0
;
; a0=adresse d‚but sauvegarde
; d0=nb octets … sauver
;
putbuf2:
	tst.l	d0
	beq.s	return
	pea	(a0)
	move.l	d0,-(sp)

	pea	(a0)		;adr d‚but
	move.l	d0,-(sp)	;nb octets
	move	outfile,-(sp)	;handle
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp

	cmp.l	(sp)+,d0	;on a tout sauv‚ ???
	bne	errwrite
	move.l	(sp)+,a0

calccrc:
	move	curcrc,d1	;bx
	lea	crctbl,a1
.do
	clr	d2
	move.b	(a0)+,d2
	eor.b	d1,d2

	lsr	#8,d1
	add	d2,d2
	move	(a1,d2.w),d2

	eor	d2,d1

	subq.l	#1,d0
	bne.s	.do

	move	d1,curcrc

	move	#'.',-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp

	lea	text,a6
return:
	rts
;
; liste des variables utilis‚es
;
	section	data
;
; bytes...
cright:	dc.b	"LHA's SFX 2.11",13,10,0
myself:
;	dc.b	"SEKA.LZH",0
	DC.B	"PAK.LZH",0
overwrt:dc.b	'Overwrite ',0
mes_yn:	dc.b	'  ',0
yesno:	dc.b	"[Y/N] ",0
broken:	dc.b	'Broken file',0
write:	dc.b	'Write',0
header:	dc.b	'Header',0
crcmess:dc.b	'CRC'
error:	dc.b	' Error',0
	even

	section	bss

left	ds.w	2*NC-1
right	ds.w	2*NC-1
c_table:ds.w	4096
pt_table:ds.w	256
c_len:	ds.b	NC
FIN_C_LEN:
pt_len:ds.b	NPT
fin_pt_len:

avail_mt:ds.w	1
nchar:	ds.w	1
tablebits:ds.w	1
table:	ds.l	1
restbits:ds.b	1
	even

; words,longs...
packsize:ds.l	1
origsize:ds.l	1
fnptr:	ds.l	1
inpptr	ds.l	1
filetime:ds.l	1

orgcrc	ds.w	1
infile	ds.w	1
outfile	ds.w	1
curcrc	ds.w	1

bitbuf:ds.w	1
subbitbuf:ds.w	1
bitcount:ds.w	1

blocksize:ds.w	1

crctbl	ds.w	$100
cpyhdr	ds.b	LzHead
	even
text	ds.b	DSIZ2
inpbuf	ds.b	BufSiz
