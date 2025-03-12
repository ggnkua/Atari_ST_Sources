	opt	o+
	org	$40000
;
; d‚compacteur ARJ
;
;
; make_crctable
;
main:
	moveq	#0,d0
	lea	crctable(pc),a0
.l01	move.l	d0,d1
	moveq	#8-1,d2
.l02	lsr.l	#1,d1
	bcc.s	.l03
	eor.l	#$EDB88320,d1
.l03	dbra	d2,.l02
	move.l	d1,(a0)+
	addq.b	#1,d0
	bne.s	.l01
;
; findheader
;
	lea	source(pc),a0
.l49
	cmp.l	#fin_source,a0
	bhs.s	.l47
	cmp.b	#$60,(a0)+
	bne.s	.l49
	cmp	#$EA,(a0)
	bne.s	.l49
	bra.s	.l54
.l47
	moveq	#9,d0
	illegal
.l54
	subq	#1,a0
	move.l	a0,ptr_read

	bsr.s	read_header
	bsr.s	read_header

	cmp.b	#3,arj_x_nbr
	bls.s	.l75
	moveq	#12,d0
	illegal
.l75
	btst.b	#0,arj_flags
	beq.s	.l76
	moveq	#7,d0
	illegal
.l76
	cmp.b	#1,method
	blt.s	.l78
	cmp.b	#3,method
	ble.s	.l77
.l78
	moveq	#10,d0
	illegal
.l77
	tst.b	file_type
	beq.s	.l79
	moveq	#11,d0
	illegal
.l79
	bsr	decode
	moveq	#0,d0
	illegal

read_header:
	move.l	ptr_read(pc),a0
	movep	1(a0),d0
	move.b	(a0),d0
	addq	#2,a0
	move.l	a0,ptr_read

	cmp	#$EA60,d0
	beq.s	.l58
	moveq	#2,d0
	illegal
.l58
	move.l	ptr_read(pc),a0
	movep	1(a0),d0
	move.b	(a0),d0
	addq	#2,a0
	move.l	a0,ptr_read

	move	d0,headersize
	bne.s	.l61
	moveq	#1,d0
	illegal
.l61
	cmp	#2152,headersize
	bls.s	.l63
	moveq	#2,d0
	illegal
.l63
;
; read crc
;
	move	headersize(pc),d0
	beq.s	.l27
	move.l	ptr_read(pc),a0
	move.l	a0,ptr_header
	add	d0,a0
	move.l	a0,ptr_read
.l27
	moveq	#0,d0
	move	headersize(pc),d0
	move.l	ptr_header(pc),a0
	bsr	crc_buf

	move.l	ptr_read(pc),a0
	movep	3(a0),d0
	move.b	2(a0),d0
	swap	d0
	movep	1(a0),d0
	move.b	(a0),d0
	addq	#4,a0
	move.l	a0,ptr_read

	cmp.l	d1,d0
	beq.s	.l64
	moveq	#8,d0
	illegal
.l64
	move.l	ptr_header(pc),a0

	addq	#1+1,a0
	move.b	(a0)+,arj_x_nbr
	addq	#1,a0
	move.b	(a0)+,arj_flags
	move.b	(a0)+,method
	move.b	(a0)+,file_type
	addq	#1+4,a0

	movep	3(a0),d0
	move.b	2(a0),d0
	swap	d0
	movep	1(a0),d0
	move.b	(a0),d0
	addq	#4,a0
	move.l	d0,compsize
	movep	3(a0),d0
	move.b	2(a0),d0
	swap	d0
	movep	1(a0),d0
	move.b	(a0),d0
	addq	#4,a0
	move.l	d0,origsize
	movep	3(a0),d0
	move.b	2(a0),d0
	swap	d0
	movep	1(a0),d0
	move.b	(a0),d0
	addq	#4,a0
	move.l	d0,file_crc

	addq	#6,a0
.l65
	move.l	ptr_read(pc),a0
	movep	1(a0),d0
	move.b	(a0),d0
	addq	#2,a0
	move.l	a0,ptr_read

	tst	d0
	beq.s	.l66
	addq	#4,d0
	move.l	ptr_read(pc),a0
	add	d0,a0
	move.l	a0,ptr_read
	bra.s	.l65
.l66
	rts

;crc_buf(A0,D0.L)->D1.L
crc_buf:
	moveq	#-1,d1
	tst.l	d0
	beq.s	.l16

	lea	crctable(pc),a1
.l15
	moveq	#0,d2
	move.b	(a0)+,d2
	eor.b	d1,d2
	add	d2,d2
	add	d2,d2
	lsr.l	#8,d1
	move.l	(a1,d2.w),d2
	eor.l	d2,d1
	subq.l	#1,d0
	bne.s	.l15
.l16
	not.l	d1
	rts

;fillbuf(D0.W)
fillbuf:
	move	bitbuf(pc),d1
	asl	d0,d1
	move	d1,bitbuf
.l84
	cmp	bitcount(pc),d0
	ble.s	.l85
	moveq	#0,d1
	move.b	subbitbuf(pc),d1
	move	bitcount(pc),d2
	sub	d2,d0
	asl	d0,d1
	or	d1,bitbuf
	tst.l	compsize
	beq.s	.l86
	subq.l	#1,compsize
	move.l	ptr_read(pc),a0
	move.b	(a0)+,subbitbuf
	move.l	a0,ptr_read
	bra.s	.l87
.l86
	clr.b	subbitbuf
.l87
	move	#8,bitcount
	bra.s	.l84
.l85
	moveq	#0,d1
	move.b	subbitbuf(pc),d1
	sub	d0,bitcount
	move	bitcount(pc),d2
	lsr	d2,d1
	or	d1,bitbuf
.l88
	rts

;getbits(D0.W)
getbits:
	moveq	#16,d1
	sub	d0,d1
	move	bitbuf(pc),d2
	lsr	d1,d2
	move	d2,-(sp)
	bsr.s	fillbuf
	move	(sp)+,d0
	rts

	section	bss
count:	ds.w	17+1
start:	ds.w	18+1
weight:	ds.w	17+1

avail:	ds.w	1
mask:	ds.w	1
nextcode:ds.w	1
	section	text
;
; make_table(int,uchar *,int,ushort *)
;
make_table:
	link	a6,#0
	movem.l	d4/d5/d6/d7/a3,-(sp)

	moveq	#16-1,d0
	lea	count+2(pc),a0
.l96
	clr	(a0)+
	dbra	d0,.l96

	move	8(a6),d1
	beq.s	.l98
	subq	#1,d1

	move.l	10(a6),a0
	lea	count(pc),a1
.l99
	moveq	#0,d0
	move.b	(a0)+,d0
	add	d0,d0
	addq	#1,(a1,d0.w)
	dbra	d1,.l99
.l98

	lea	start+2(pc),a0
	clr	(a0)
	lea	count+2(pc),a1
	moveq	#15,d0
.l103
	move	(a1)+,d1
	asl	d0,d1
	add	(a0)+,d1
	move	d1,(a0)
	dbra	d0,.l103

	tst	start+17*2
	beq.s	.l104
	moveq	#3,d0
	illegal
.l104

	moveq	#16,d3
	sub	14(a6),d3
	moveq	#1,d0

	lea	start+2(pc),a0
	lea	weight+2(pc),a1
	bra.s	.l108
.l107
	move	(a0),d1
	lsr	d3,d1
	move	d1,(a0)+
	move	14(a6),d1
	sub	d0,d1

	moveq	#0,d2
	bset	d1,d2
	move	d2,(a1)+
	addq	#1,d0
.l108
	cmp	14(a6),d0
	ble.s	.l107

.l109
	cmp	#16,d0
	bhi.s	.l110
	moveq	#16,d1
	sub	d0,d1
	moveq	#0,d2
	bset	d1,d2
	move	d2,(a1)+
	addq	#1,d0
	bra.s	.l109
.l110

	move	14(a6),d0
	addq	#1,d0
	add	d0,d0
	lea	start(pc),a0
	move	(a0,d0.w),d4
	lsr	d3,d4
	beq.s	.l111
	move	14(a6),d0
	moveq	#1,d5
	asl	d0,d5
.l112
	cmp	d5,d4
	beq.s	.l111
	move	d4,d0
	add	d0,d0
	move.l	16(a6),a0
	clr	(a0,d0.w)
	addq	#1,d4
	bra.s	.l112
.l111

	move	8(a6),avail
	moveq	#15,d0
	sub	14(a6),d0
	moveq	#1,d1
	asl	d0,d1
	move	d1,mask
	moveq	#0,d7
	bra	.l117
.l116
	move.l	10(a6),a0
	moveq	#0,d6
	move.b	(a0,d7.w),d6
	beq	.l114
	move	d6,d0
	add	d0,d0
	lea	start(pc),a0
	move	(a0,d0.w),d5
	lea	weight(pc),a0
	move	(a0,d0.w),d1
	add	d5,d1
	move	d1,nextcode
	cmp	14(a6),d6
	bgt.s	.l118
	move	d5,d4
	bra.s	.l122
.l121
	move	d4,d0
	add	d0,d0
	move.l	16(a6),a0
	move	d7,(a0,d0.w)
	addq	#1,d4
.l122
	cmp	nextcode(pc),d4
	blo.s	.l121
	bra.s	.l123
.l118
	move	d5,d0
	lsr	d3,d0
	add	d0,d0
	move.l	16(a6),a3
	add	d0,a3
	move	d6,d4
	sub	14(a6),d4
	beq.s	.l125
.l124
	tst	(a3)
	bne.s	.l126
	move	avail(pc),d0
	add	d0,d0
	lea	left(pc),a0
	clr	(a0,d0.w)
	lea	right(pc),a0
	clr	(a0,d0.w)
	move	avail(pc),(a3)
	addq	#1,avail
.l126
	move	d5,d0
	and	mask(pc),d0
	beq.s	.l127
	move	(a3),d0
	add	d0,d0
	lea	right(pc),a3
	add	d0,a3
	bra.s	.l128
.l127
	move	(a3),d0
	add	d0,d0
	lea	left(pc),a3
	add	d0,a3
.l128
	add	d5,d5
	subq	#1,d4
	bne.s	.l124
.l125
	move	d7,(a3)
.l123
	move	d6,d0
	add	d0,d0
	lea	start(pc),a0
	move	nextcode(pc),(a0,d0.w)
.l114
	addq	#1,d7
.l117
	cmp	8(a6),d7
	blt	.l116
	movem.l	(sp)+,d4/d5/d6/d7/a3
	unlk	a6
	rts

;read_pt_len(int,int,int)
read_pt_len:
	link	a6,#0
	movem.l	d4/d5/d6/d7,-(sp)
	move	10(a6),d0
	bsr	getbits
	move	d0,d5
	bne.s	.l132
	move	10(a6),d0
	bsr	getbits
	move	d0,d6

	moveq	#0,d4
	bra.s	.l136
.l135
	lea	pt_len(pc),a0
	clr.b	(a0,d4.w)
	addq	#1,d4
.l136
	cmp	8(a6),d4
	blt.s	.l135

	move	#256-1,d0
	lea	pt_table(pc),a0
.l139
	move	d6,(a0)+
	dbra	d0,.l139
	bra	.l140

.l132
	moveq	#0,d4
.l141
	cmp	d5,d4
	bhs.s	.l142
	move	bitbuf(pc),d6
	moveq	#13,d0
	lsr	d0,d6
	cmp	#7,d6
	bne.s	.l145
	move	#4096,d7
.l144
	move	d7,d0
	and	bitbuf(pc),d0
	beq.s	.l145
	lsr	#1,d7
	addq	#1,d6
	bra.s	.l144
.l145
	cmp	#7,d6
	bhs.s	.l146
	moveq	#3,d0
	bra.s	.l147
.l146
	move	d6,d0
	subq	#3,d0
.l147
	bsr	fillbuf
	lea	pt_len(pc),a0
	move.b	d6,(a0,d4.w)
	addq	#1,d4
	cmp	12(a6),d4
	bne.s	.l141
	moveq	#2,d0
	bsr	getbits
	move	d0,d6
	subq	#1,d6
	blt.s	.l141
.l149
	lea	pt_len(pc),a0
	clr.b	(a0,d4.w)
	addq	#1,d4
	subq	#1,d6
	bhs.s	.l149
	bra.s	.l141
.l142
	cmp	8(a6),d4
	bhs.s	.l152
	lea	pt_len(pc),a0
	clr.b	(a0,d4.w)
	addq	#1,d4
	bra.s	.l142
.l152
	pea	pt_table(pc)
	move	#8,-(sp)
	pea	pt_len(pc)
	move	8(a6),-(sp)
	bsr	make_table
	lea	12(sp),sp
.l140
	movem.l	(sp)+,d4/d5/d6/d7
	unlk	a6
	rts

;read_c_len()
read_c_len:
	movem.l	d4/d5/d6/d7,-(sp)
	moveq	#9,d0
	bsr	getbits
	move	d0,d6
	bne.s	.l156

	moveq	#9,d0
	bsr	getbits
	move	d0,d5

	move	#510-1,d0
	lea	c_len(pc),a0
.l159
	clr.b	(a0)+
	dbra	d0,.l159

	move	#4096-1,d0
	lea	c_table(pc),a0
.l162
	move	d5,(a0)+
	dbra	d0,.l162
	bra	.l163
.l156
	moveq	#0,d4
.l164
	cmp	d6,d4
	bhs	.l165
	move	bitbuf(pc),d0
	lsr	#8,d0
	move	d0,d1
	add	d1,d1
	lea	pt_table(pc),a0
	move	(a0,d1.w),d5
	cmp	#19,d5
	blt.s	.l166
	move	#128,d7
.l169
	add	d5,d5
	lea	left(pc),a0
	move	bitbuf(pc),d0
	and	d7,d0
	beq.s	.l170
	lea	right(pc),a0
.l170
	move	(a0,d5.w),d5
	lsr	#1,d7
	cmp	#19,d5
	bhs.s	.l169
.l166
	lea	pt_len(pc),a0
	moveq	#0,d0
	move.b	(a0,d5.w),d0
	bsr	fillbuf
	cmp	#2,d5
	bgt.s	.l172
	tst	d5
	bne.s	.l173
	moveq	#1,d5
	bra.s	.l174
.l173
	cmp	#1,d5
	bne.s	.l175
	moveq	#4,d0
	bsr	getbits
	move	d0,d5
	addq	#3,d5
	bra.s	.l174
.l175
	moveq	#9,d0
	bsr	getbits
	moveq	#20,d5
	add	d0,d5
.l174
	subq	#1,d5
	blt.s	.l164
	lea	c_len(pc),a0
	clr.b	(a0,d4.w)
	addq	#1,d4
	bra.s	.l174
.l172
	move	d5,d0
	subq	#2,d0
	move	d4,d1
	addq	#1,d4
	lea	c_len(pc),a0
	move.b	d0,(a0,d1.w)
	bra	.l164
.l165
	cmp	#510,d4
	bhs.s	.l181
	lea	c_len(pc),a0
	clr.b	(a0,d4.w)
	addq	#1,d4
	bra.s	.l165
.l181
	pea	c_table(pc)
	move	#12,-(sp)
	pea	c_len(pc)
	move	#510,-(sp)
	bsr	make_table
	lea	12(sp),sp
.l163
	movem.l	(sp)+,d4/d5/d6/d7
	rts

;decode_c()
decode_c:
	movem.l	d4/d5,-(sp)
	tst	blocksize
	bne.s	.l185
	moveq	#16,d0
	bsr	getbits
	move	d0,blocksize
	move	#3,-(sp)
	move	#5,-(sp)
	move	#19,-(sp)
	bsr	read_pt_len
	addq	#6,sp
	bsr	read_c_len
	move	#-1,-(sp)
	move	#5,-(sp)
	move	#17,-(sp)
	bsr	read_pt_len
	addq	#6,sp
.l185
	subq	#1,blocksize
	move	bitbuf(pc),d0
	lsr	#4,d0
	move	d0,d1
	add	d1,d1
	lea	c_table(pc),a0
	move	(a0,d1.w),d4
	cmp	#510,d4
	blo.s	.l186
	moveq	#8,d5
.l189
	add	d4,d4
	lea	left(pc),a0
	move	bitbuf(pc),d0
	and	d5,d0
	beq.s	.l190
	lea	right(pc),a0
.l190
	move	(a0,d4.w),d4
	lsr	#1,d5
	cmp	#510,d4
	bhs.s	.l189
.l186
	lea	c_len(pc),a0
	moveq	#0,d0
	move.b	(a0,d4.w),d0
	bsr	fillbuf
	move	d4,d0
	movem.l	(sp)+,d4/d5
	rts

;decode_p()
decode_p:
	movem.l	d4/d5,-(sp)
	move	bitbuf(pc),d0
	lsr	#8,d0
	move	d0,d1
	add	d1,d1
	lea	pt_table(pc),a0
	move	(a0,d1.w),d4
	cmp	#17,d4
	blo.s	.l195
	move	#128,d5
.l198
	add	d4,d4		;stocker table*2
	lea	left(pc),a0
	move	bitbuf(pc),d0
	and	d5,d0
	beq.s	.l199
	lea	right(pc),a0
.l199
	move	(a0,d4.w),d4
	lsr	#1,d5
	cmp	#17,d4
	bhs.s	.l198
.l195
	lea	pt_len(pc),a0
	moveq	#0,d0
	move.b	(a0,d4.w),d0
	bsr	fillbuf
	tst	d4
	beq.s	.l201
	subq	#1,d4
	move	d4,d0
	bsr	getbits
	moveq	#1,d1
	asl	d4,d1
	move	d0,d4
	add	d1,d4
.l201
	move	d4,d0
	movem.l	(sp)+,d4/d5
	rts


decode:
	movem.l	a3/a4/d7,-(sp)

	lea	dest,a3
	move.l	a3,a4
	add.l	origsize(pc),a4
;
; decode_start
;
	clr	blocksize
	clr	bitbuf
	clr.b	subbitbuf
	clr	bitcount
	moveq	#16,d0
	bsr	fillbuf
.l212
	cmp.l	a4,a3
	bhs.s	.l213
	bsr	decode_c
	cmp	#256,d0
	bhs.s	.l214
	move.b	d0,(a3)+
	bra.s	.l212
.l214
	move	d0,d7
	bsr	decode_p
	neg	d0
	lea	-1(a3,d0.w),a0
	sub	#253+1,d7
	blo.s	.l212
.l219
	move.b	(a0)+,(a3)+
	dbra	d7,.l219
	bra.s	.l212
.l213
	move.l	a3,d0
	sub.l	#dest,d0
	lea	dest,a0
	bsr	crc_buf
	cmp.l	file_crc(pc),d1
	beq.s	.l80
	moveq	#6,d0
	illegal
.l80
	movem.l	(sp)+,a3/a4/d7
	rts

	section	bss
crc:	ds.l	1
bitbuf:	ds.w	1
bitcount:ds.w	1
compsize:ds.l	1
origsize:ds.l	1
subbitbuf:ds.b	1
	even
ptr_header:ds.l	1
headersize:ds.w	1

arj_x_nbr:ds.b	1
arj_flags:ds.b	1
method:	ds.b	1
file_type:ds.b	1
	even
file_crc:ds.l	1
ptr_read:ds.l	1

crctable:ds.l	256
;
; buffers d‚codage
;
blocksize:ds.w	1
left:	ds.w	2038/2
right:	ds.w	2038/2
c_len:	ds.b	510/1
pt_len:	ds.b	19
	even
c_table:ds.w	8192/2
pt_table:ds.w	512/2

source:		ds.b	100000
fin_source:
dest:		ds.b	100000



	end

count:	ds.b	34
weight:	ds.b	34
start:	ds.b	36
p:	ds.l	1
i:	ds.w	1
k:	ds.w	1
len:	ds.w	1
ch:	ds.w	1
jutbits:ds.w	1
avail:	ds.w	1
nextcode:ds.w	1
mask:	ds.w	1

make_table:
	link	a6,#0
	move	#1,i
.96
	move	i,d0
	add	d0,d0
	lea	count,a0
	clr	(a0,d0.w)
	addq	#1,i
	cmp	#16,i
	bls.s	.96

	clr	i
	bra.s	.100
.99
	move	i,d0
	move.l	10(a6),a0
	moveq	#0,d1
	move.b	(a0,d0.w),d1
	add	d1,d1
	lea	count,a0
	addq	#1,(a0,d1.w)
	addq	#1,i
.100
	move	i,d0
	cmp	8(a6),d0
	blt.s	.99

	clr	start+2
	move	#1,i
.103
	move	i,d0
	add	d0,d0
	lea	start,a0
	lea	count,a1
	moveq	#16,d2
	sub	i,d2
	move	(a1,d0.w),d3
	asl	d2,d3
	lea	start,a1
	add	(a1,d0.w),d3
	move	d3,2(a0,d1.w)
	addq	#1,i
	cmp	#16,i
	bls.s	.103

	tst	start+34
	beq.s	.104
	moveq	#3,d0
	illegal
.104
	moveq	#16,d0
	sub	14(a6),d0
	move	d0,jutbits
	move	#1,i
	bra.s	.108
.107
	move	i,d0
	add	d0,d0
	lea	start,a0
	move	(a0.w),d2
	move	jutbits,d1
	lsr	d1,d2
	move	d2,(a0.w)
	lea	weight,a0
	move	14(a6),d1
	sub	i,d1
	moveq	#1,d2
	asl	d1,d2
	move	d2,(a0,d0.w)
	addq	#1,i
.108
	move	i,d0
	cmp	14(a6),d0
	ble.s	.107
.109
	cmp	#16,i
	bhi.s	.110
	move	i,d0
	add	d0,d0
	lea	weight,a0
	moveq	#16,d1
	sub	i,d1
	moveq	#1,d2
	asl	d1,d2
	move	d2,(a0,d0.w)
	addq	#1,i
	bra.s	.109
.110
	move	14(a6),d0
	addq	#1,d0
	add	d0,d0
	lea	start,a0
	move	(a0,d0.w),d1
	move	jutbits,d0
	lsr	d0,d1
	move	d1,i
	beq.s	.111
	moveq	#1,d0
	move	14(a6),d1
	asl	d1,d0
	move	d0,k
.112
	move	i,d0
	cmp	k,d0
	beq.s	.111
	add	d0,d0
	move.l	16(a6),a0
	clr	(a0,d0.w)
	addq	#1,i
	bra.s	.112
.111
	move	8(a6),avail
	moveq	#15,d0
	sub	14(a6),d0
	moveq	#1,d1
	asl	d0,d1
	move	d1,mask
	clr	ch
	bra.s	.117
.116
	move	ch,d0
	move.l	10(a6),a0
	moveq	#0,d1
	move.b	(a0,d0.w),d1
	move	d1,len
	beq.s	.114
	move	len,d0
	add	d0,d0
	lea	start,a0
	move	(a0,d0.w),k
	move	len,d0
	add	d0,d0
	lea	weight,a0
	move	(a0,d0.w),d1
	add	k,d1
	move	d1,nextcode
	move	len,d0
	cmp	14(a6),d0
	bgt.s	.118
	move	len,d0
	add	d0,d0
	lea	start,a0
	move	(a0,d0.w),i
	bra.s	.122
.121
	move	i,d0
	add	d0,d0
	move.l	16(a6),a0
	move	ch,(a0,d0.w)
	addq	#1,i
.122
	move	i,d0
	cmp	nextcode,d0
	blo.s	.121
	bra	.123
.118
	moveq	#0,d0
	move	k,d0
	move	jutbits,d1
	lsr	d1,d0
	add.l	16(a6),d0
	move.l	d0,p
	move	len,d0
	sub	14(a6),d0
	move	d0,i
.124
	tst	i
	beq.s	.125
	move.l	p,a0
	tst	(a0)
	bne.s	.126
	move	avail,d0
	add	d0,d0
	lea	left,a0
	clr	(a0,d0.w)
	lea	right,a0
	clr	(a0,d0.w)
	move.l	p,a0
	move	avail,(a0)
	addq	#1,avail
.126
	move	k,d0
	and	mask,d0
	beq.s	.127
	move.l	p,a0
	move	(a0),d0
	add	d0,d0
	lea	right,a0
	bra.s	.128
.127
	move.l	p,a0
	move	(a0),d0
	add	d0,d0
	lea	left,a0
.128
	add	d0,a0
	move.l	d0,p
	asl	k
	subq	#1,i
	bne.s	.124
.125
	move.l	p,a0
	move	ch,(a0)
.123
	move	len,d0
	add	d0,d0
	lea	start,a0
	move	nextcode,(a0,d0.w)
.114
	addq	#1,ch
.117
	move	ch,d0
	cmp	8(a6),d0
	blt.s	.116
	unlk	a6
	rts
